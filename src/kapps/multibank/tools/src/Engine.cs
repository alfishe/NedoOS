using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace MbGen
{
	internal sealed class ProcInfo
	{
		public string Name;           /* bank symbol, e.g. r_get_dns */
		public string ReturnType;     /* e.g. unsigned char */
		public string ParamsRaw;      /* inside parentheses */
		public string WrapperName;    /* mb_get_dns */
		public string DefineName;     /* MB_JT_GET_DNS */
		public int SourceLine;
	}

	internal sealed class ScanResult
	{
		public readonly List<ProcInfo> Found = new List<ProcInfo>();
		public readonly List<string> Log = new List<string>();
	}

	internal sealed class PatchResult
	{
		public int Added;
		public int Skipped;
		public readonly List<string> Log = new List<string>();
	}

	internal sealed class RegisteredProc
	{
		public string Name;          /* bank symbol from JP table */
		public int Slot;
		public string DefineName;
		public string WrapperName;
		public bool HasAsm;
		public bool HasDefine;
		public bool HasWrapper;
		public bool HasPrototype;
	}

	internal sealed class ListResult
	{
		public readonly List<RegisteredProc> Items = new List<RegisteredProc>();
		public readonly List<string> Log = new List<string>();
	}

	internal sealed class RemoveResult
	{
		public int Removed;
		public readonly List<string> Log = new List<string>();
	}

	internal static class Engine
	{
		private static readonly HashSet<string> Keywords = new HashSet<string>(StringComparer.Ordinal)
		{
			"if", "while", "for", "switch", "return", "sizeof", "do", "else",
			"case", "default", "goto", "typedef", "struct", "enum", "union"
		};

		public static ScanResult ScanCodebank(string path)
		{
			var result = new ScanResult();
			if (string.IsNullOrEmpty(path) || !File.Exists(path))
			{
				result.Log.Add("codebank: file not found");
				return result;
			}

			string text = File.ReadAllText(path, Encoding.Default);
			string stripped = StripComments(text);
			var re = new Regex(
				@"(?m)^(?!\s*static\b)((?:(?:unsigned|signed|const|volatile)\s+)*\w+(?:\s+\w+)*(?:\s*\*+)?)\s+(\w+)\s*\(([^;{]*)\)\s*\{",
				RegexOptions.CultureInvariant);

			foreach (Match m in re.Matches(stripped))
			{
				string ret = NormalizeSpaces(m.Groups[1].Value);
				string name = m.Groups[2].Value;
				string parms = NormalizeSpaces(m.Groups[3].Value);

				if (Keywords.Contains(name))
					continue;
				if (name == "main" || name == "WinMain")
					continue;
				if (!LooksLikeType(ret))
					continue;
				/* Skip if 'static' appears in the return-type blob somehow */
				if (Regex.IsMatch(ret, @"\bstatic\b"))
					continue;

				var p = new ProcInfo
				{
					Name = name,
					ReturnType = ret,
					ParamsRaw = parms,
					WrapperName = ToWrapperName(name),
					DefineName = ToDefineName(name),
					SourceLine = LineOfIndex(stripped, m.Index)
				};
				result.Found.Add(p);
				result.Log.Add(string.Format(CultureInfo.InvariantCulture,
					"found L{0}: {1} {2}({3}) -> {4} / {5}",
					p.SourceLine, p.ReturnType, p.Name, p.ParamsRaw,
					p.WrapperName, p.DefineName));
			}

			if (result.Found.Count == 0)
				result.Log.Add("no non-static procedures found");
			return result;
		}

		public static int InferBankIndex(string codebankPath)
		{
			if (string.IsNullOrEmpty(codebankPath))
				return 0;
			var m = Regex.Match(Path.GetFileName(codebankPath),
				@"codebank_(\d+)", RegexOptions.IgnoreCase);
			if (!m.Success)
				return 0;
			int n;
			if (!int.TryParse(m.Groups[1].Value, NumberStyles.Integer,
					CultureInfo.InvariantCulture, out n) || n < 1)
				return 0;
			return n - 1;
		}

		/* bank 1 -> bank_jt.asm; bank 2 -> bank_jt2.asm; ? */
		public static string ResolveJtAsm(string projectDir, int bankNum1)
		{
			if (string.IsNullOrEmpty(projectDir))
				projectDir = ".";
			if (bankNum1 <= 1)
			{
				string p = Path.Combine(projectDir, "bank_jt.asm");
				if (File.Exists(p))
					return p;
				return Path.Combine(projectDir, "bank_jt01.asm");
			}
			string named = Path.Combine(projectDir,
				string.Format(CultureInfo.InvariantCulture, "bank_jt{0}.asm", bankNum1));
			if (File.Exists(named))
				return named;
			/* fall back to shared bank_jt.asm only if per-bank file missing */
			return Path.Combine(projectDir, "bank_jt.asm");
		}

		public static string ResolveJtAsmFromCodebank(string codebankPath)
		{
			string dir = string.IsNullOrEmpty(codebankPath)
				? "." : (Path.GetDirectoryName(codebankPath) ?? ".");
			int idx0 = InferBankIndex(codebankPath);
			return ResolveJtAsm(dir, idx0 + 1);
		}

		public static void AutofillFromProject(string projectDir,
			out string codebank, out string jtAsm, out string jtH,
			out string callC, out string reqH)
		{
			codebank = FirstExisting(projectDir, "codebank_01.c");
			jtAsm = ResolveJtAsmFromCodebank(codebank);
			jtH = FirstExisting(projectDir, "bank_jt.h");
			callC = FirstExisting(projectDir, "bank_call.c", "net_call.c");
			reqH = Path.Combine(projectDir, "mb_req.h");
			if (!File.Exists(reqH))
			{
				string net = Path.Combine(projectDir, "net_req.h");
				if (File.Exists(net))
					reqH = net;
			}
		}

		public static PatchResult Apply(string codebankPath, string jtAsmPath,
			string jtHPath, string callCPath, string reqHPath, int bankIndex)
		{
			var result = new PatchResult();
			ScanResult scan = ScanCodebank(codebankPath);
			result.Log.AddRange(scan.Log);

			if (scan.Found.Count == 0)
				return result;

			if (string.IsNullOrEmpty(jtAsmPath) || !File.Exists(jtAsmPath))
			{
				result.Log.Add("ERROR: bank_jt.asm missing");
				return result;
			}
			if (string.IsNullOrEmpty(jtHPath) || !File.Exists(jtHPath))
			{
				result.Log.Add("ERROR: bank_jt.h missing");
				return result;
			}
			if (string.IsNullOrEmpty(callCPath) || !File.Exists(callCPath))
			{
				result.Log.Add("ERROR: bank_call.c / net_call.c missing");
				return result;
			}

			string asm = File.ReadAllText(jtAsmPath, Encoding.Default);
			string hdr = File.ReadAllText(jtHPath, Encoding.Default);
			string call = File.ReadAllText(callCPath, Encoding.Default);
			string req = null;
			bool haveReq = !string.IsNullOrEmpty(reqHPath);
			if (haveReq)
			{
				if (File.Exists(reqHPath))
					req = File.ReadAllText(reqHPath, Encoding.Default);
				else
					req = CreateReqStub(Path.GetFileName(reqHPath));
			}

			EnsureCallMacros(ref call, result.Log);
			int nextSlot = NextSlot(hdr, asm);

			foreach (ProcInfo p in scan.Found)
			{
				bool existsAsm = HasAsmEntry(asm, p.Name);
				bool existsDef = HasDefine(hdr, p.DefineName);
				bool existsWrap = HasWrapper(call, p.WrapperName);
				bool existsReq = haveReq && HasPrototype(req, p.WrapperName);

				if (existsAsm && existsDef && existsWrap && (!haveReq || existsReq))
				{
					result.Skipped++;
					result.Log.Add("skip (already present): " + p.Name);
					continue;
				}

				/* Already in jump table: do not invent a new slot number. */
				int slotForDef = -1;
				if (existsAsm)
					slotForDef = SlotIndexOf(asm, p.Name);

				if (!existsAsm)
				{
					asm = PatchAsm(asm, p.Name);
					slotForDef = SlotIndexOf(asm, p.Name);
					result.Log.Add("  + asm EXTERN/JP " + p.Name);
				}
				else
					result.Log.Add("  = asm already has " + p.Name);

				if (!existsDef)
				{
					if (slotForDef < 0)
					{
						slotForDef = nextSlot;
						nextSlot++;
					}
					else if (slotForDef >= nextSlot)
						nextSlot = slotForDef + 1;

					hdr = PatchDefine(hdr, p.DefineName, slotForDef);
					result.Log.Add(string.Format(CultureInfo.InvariantCulture,
						"  + {0} {1}u", p.DefineName, slotForDef));
				}
				else
					result.Log.Add("  = define already has " + p.DefineName);

				if (!existsWrap)
				{
					call = PatchWrapper(call, p, bankIndex);
					result.Log.Add("  + wrapper " + p.WrapperName + "()");
				}
				else
					result.Log.Add("  = wrapper already has " + p.WrapperName);

				if (haveReq && !existsReq)
				{
					req = PatchPrototype(req, p);
					result.Log.Add("  + prototype " + p.WrapperName);
				}

				result.Added++;
			}

			File.WriteAllText(jtAsmPath, asm, Encoding.Default);
			File.WriteAllText(jtHPath, hdr, Encoding.Default);
			File.WriteAllText(callCPath, call, Encoding.Default);
			if (haveReq)
			{
				string dir = Path.GetDirectoryName(reqHPath);
				if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
					Directory.CreateDirectory(dir);
				File.WriteAllText(reqHPath, req, Encoding.Default);
			}

			result.Log.Add(string.Format(CultureInfo.InvariantCulture,
				"done: added {0}, skipped {1}", result.Added, result.Skipped));
			return result;
		}

		/* ---- list / remove registered JT wiring ---- */

		public static ListResult ListRegistered(string jtAsmPath, string jtHPath,
			string callCPath, string reqHPath)
		{
			return ListRegistered(jtAsmPath, jtHPath, callCPath, reqHPath, null);
		}

		/* codebankPath optional: if set, also report how many exports are in that .c
		 * (NOT the same as JT registered ? TUI may live in bank without JT slots). */
		public static ListResult ListRegistered(string jtAsmPath, string jtHPath,
			string callCPath, string reqHPath, string codebankPath)
		{
			var result = new ListResult();
			result.Log.Add("List registered = JT slots (JP in bank_jt.asm), NOT codebank body.");
			result.Log.Add("  jt.asm : " + AbsOrMissing(jtAsmPath));
			result.Log.Add("  jt.h   : " + AbsOrMissing(jtHPath));
			result.Log.Add("  call.c : " + AbsOrMissing(callCPath));
			result.Log.Add("  req.h  : " + AbsOrMissing(reqHPath));
			if (!string.IsNullOrEmpty(codebankPath))
			{
				result.Log.Add("  codebank (for Scan, not List): " + AbsOrMissing(codebankPath));
				if (File.Exists(codebankPath))
				{
					ScanResult scan = ScanCodebank(codebankPath);
					result.Log.Add(string.Format(CultureInfo.InvariantCulture,
						"  codebank non-static exports: {0}  (use Scan only to see them)",
						scan.Found.Count));
				}
			}

			string asm = ReadOrEmpty(jtAsmPath);
			string hdr = ReadOrEmpty(jtHPath);
			string call = ReadOrEmpty(callCPath);
			string req = ReadOrEmpty(reqHPath);

			if (string.IsNullOrEmpty(asm))
			{
				result.Log.Add("ERROR: bank_jt.asm missing or empty");
				return result;
			}

			List<string> names = JpNames(asm);
			for (int i = 0; i < names.Count; i++)
			{
				string name = names[i];
				string def = ToDefineName(name);
				string wrap = ToWrapperName(name);
				var item = new RegisteredProc
				{
					Name = name,
					Slot = i,
					DefineName = def,
					WrapperName = wrap,
					HasAsm = true,
					HasDefine = HasDefine(hdr, def),
					HasWrapper = HasWrapper(call, wrap),
					HasPrototype = !string.IsNullOrEmpty(req) && HasPrototype(req, wrap)
				};
				result.Items.Add(item);
				result.Log.Add(string.Format(CultureInfo.InvariantCulture,
					"[{0}] {1}  def={2}{3}  wrap={4}{5}  proto={6}",
					i, name, def, item.HasDefine ? "" : "!",
					wrap, item.HasWrapper ? "" : "!",
					item.HasPrototype ? "yes" : "no"));
			}

			/* Orphans: defines / wrappers not in JP table */
			foreach (Match m in Regex.Matches(hdr,
				@"#\s*define\s+(MB_JT_(?!SLOT_SIZE\b|ADDR\b|ENTRY\b)[A-Z0-9_]+)\s+(\d+)\s*u?"))
			{
				string def = m.Groups[1].Value;
				bool known = result.Items.Any(p =>
					string.Equals(p.DefineName, def, StringComparison.Ordinal));
				if (!known)
					result.Log.Add("orphan define: " + def + " = " + m.Groups[2].Value);
			}
			foreach (Match m in Regex.Matches(call, @"/\*\s*mbgen:\s*(\w+)\s*\*/"))
			{
				string name = m.Groups[1].Value;
				if (!names.Contains(name))
					result.Log.Add("orphan wrapper comment: mbgen: " + name);
			}

			result.Log.Add(string.Format(CultureInfo.InvariantCulture,
				"total registered: {0}", result.Items.Count));
			return result;
		}

		public static RemoveResult Remove(string procName, string jtAsmPath,
			string jtHPath, string callCPath, string reqHPath)
		{
			var result = new RemoveResult();
			if (string.IsNullOrEmpty(procName))
			{
				result.Log.Add("ERROR: empty procedure name");
				return result;
			}

			if (string.IsNullOrEmpty(jtAsmPath) || !File.Exists(jtAsmPath))
			{
				result.Log.Add("ERROR: bank_jt.asm missing");
				return result;
			}
			if (string.IsNullOrEmpty(jtHPath) || !File.Exists(jtHPath))
			{
				result.Log.Add("ERROR: bank_jt.h missing");
				return result;
			}
			if (string.IsNullOrEmpty(callCPath) || !File.Exists(callCPath))
			{
				result.Log.Add("ERROR: bank_call.c missing");
				return result;
			}

			string asm = File.ReadAllText(jtAsmPath, Encoding.Default);
			string hdr = File.ReadAllText(jtHPath, Encoding.Default);
			string call = File.ReadAllText(callCPath, Encoding.Default);
			string req = null;
			bool haveReq = !string.IsNullOrEmpty(reqHPath) && File.Exists(reqHPath);
			if (haveReq)
				req = File.ReadAllText(reqHPath, Encoding.Default);

			string defineName = ToDefineName(procName);
			string wrapperName = ToWrapperName(procName);
			bool touched = false;

			if (HasAsmEntry(asm, procName))
			{
				asm = RemoveAsmEntry(asm, procName);
				result.Log.Add("  - asm EXTERN/JP " + procName);
				touched = true;
			}
			else
				result.Log.Add("  = asm has no " + procName);

			if (HasDefine(hdr, defineName))
			{
				hdr = RemoveDefine(hdr, defineName);
				result.Log.Add("  - define " + defineName);
				touched = true;
			}
			else
				result.Log.Add("  = define has no " + defineName);

			if (HasWrapper(call, wrapperName) ||
				Regex.IsMatch(call, @"/\*\s*mbgen:\s*" + Regex.Escape(procName) + @"\s*\*/"))
			{
				call = RemoveWrapper(call, procName, wrapperName);
				result.Log.Add("  - wrapper " + wrapperName + "()");
				touched = true;
			}
			else
				result.Log.Add("  = wrapper has no " + wrapperName);

			if (haveReq && HasPrototype(req, wrapperName))
			{
				req = RemovePrototype(req, wrapperName);
				result.Log.Add("  - prototype " + wrapperName);
				touched = true;
			}

			/* Keep JT defines in sync with remaining JP order. */
			hdr = RenumberDefines(hdr, JpNames(asm), result.Log);

			if (!touched)
			{
				result.Log.Add("nothing to remove for " + procName);
				return result;
			}

			File.WriteAllText(jtAsmPath, asm, Encoding.Default);
			File.WriteAllText(jtHPath, hdr, Encoding.Default);
			File.WriteAllText(callCPath, call, Encoding.Default);
			if (haveReq)
				File.WriteAllText(reqHPath, req, Encoding.Default);

			result.Removed = 1;
			result.Log.Add("removed wiring for " + procName
				+ " (codebank .c body left untouched)");
			return result;
		}

		private static string ReadOrEmpty(string path)
		{
			if (string.IsNullOrEmpty(path) || !File.Exists(path))
				return "";
			return File.ReadAllText(path, Encoding.Default);
		}

		private static string AbsOrMissing(string path)
		{
			if (string.IsNullOrEmpty(path))
				return "(empty)";
			try
			{
				string full = Path.GetFullPath(path);
				return File.Exists(full) ? full : full + "  [MISSING]";
			}
			catch
			{
				return path + "  [bad path]";
			}
		}

		private static List<string> JpNames(string asm)
		{
			var list = new List<string>();
			foreach (Match x in Regex.Matches(asm, @"(?m)^\s*JP\s+(\w+)"))
				list.Add(x.Groups[1].Value);
			return list;
		}

		private static string RemoveAsmEntry(string asm, string procName)
		{
			string nl = asm.Contains("\r\n") ? "\r\n" : "\n";
			asm = Regex.Replace(asm,
				@"(?m)^[ \t]*EXTERN[ \t]+" + Regex.Escape(procName) + @"[ \t]*\r?\n",
				"");
			asm = Regex.Replace(asm,
				@"(?m)^[ \t]*JP[ \t]+" + Regex.Escape(procName) + @"[^\r\n]*\r?\n",
				"");
			/* tidy double blank lines */
			asm = Regex.Replace(asm, @"(\r?\n){3,}", nl + nl);
			return asm;
		}

		private static string RemoveDefine(string hdr, string defineName)
		{
			return Regex.Replace(hdr,
				@"(?m)^#\s*define\s+" + Regex.Escape(defineName) + @"\s+\d+\s*u?[ \t]*\r?\n",
				"");
		}

		private static string RemoveWrapper(string call, string procName, string wrapperName)
		{
			/* Preferred: block headed by mbgen marker comment. */
			var headed = new Regex(
				@"/\*\s*mbgen:\s*" + Regex.Escape(procName) + @"\s*\*/\s*\r?\n"
				+ @".*?\r?\n\}\s*\r?\n",
				RegexOptions.Singleline);
			if (headed.IsMatch(call))
				return headed.Replace(call, "");

			/* Fallback: function named wrapperName { ... } */
			var fn = new Regex(
				@"(?m)^[^\r\n]*\b" + Regex.Escape(wrapperName) + @"\s*\([^;]*\)\s*\r?\n\{\r?\n"
				+ @".*?\r?\n\}\s*\r?\n",
				RegexOptions.Singleline);
			return fn.Replace(call, "");
		}

		private static string RemovePrototype(string req, string wrapperName)
		{
			return Regex.Replace(req,
				@"(?m)^[^\r\n]*\b" + Regex.Escape(wrapperName) + @"\s*\([^;]*\);\s*\r?\n",
				"");
		}

		private static string RenumberDefines(string hdr, List<string> jpNames,
			List<string> log)
		{
			for (int i = 0; i < jpNames.Count; i++)
			{
				string def = ToDefineName(jpNames[i]);
				if (HasDefine(hdr, def))
				{
					hdr = Regex.Replace(hdr,
						@"(#\s*define\s+" + Regex.Escape(def) + @"\s+)\d+(\s*u?)",
						"${1}" + i.ToString(CultureInfo.InvariantCulture) + "${2}");
				}
				else
				{
					/* Recreate missing define for remaining JP entries. */
					hdr = PatchDefine(hdr, def, i);
					log.Add(string.Format(CultureInfo.InvariantCulture,
						"  * restored {0} {1}u", def, i));
				}
			}
			/* MB_JT_ENTRY stays the first slot. */
			if (Regex.IsMatch(hdr, @"#\s*define\s+MB_JT_ENTRY\b"))
			{
				hdr = Regex.Replace(hdr,
					@"(#\s*define\s+MB_JT_ENTRY\s+)\d+(\s*u?)",
					"${1}0${2}");
			}
			return hdr;
		}

		/* ---- add / remove whole code banks ---- */

		public static PatchResult AddBank(string projectDir)
		{
			var result = new PatchResult();
			if (string.IsNullOrEmpty(projectDir) || !Directory.Exists(projectDir))
			{
				result.Log.Add("ERROR: project folder missing");
				return result;
			}

			string makefile = Path.Combine(projectDir, "Makefile");
			if (!File.Exists(makefile))
			{
				result.Log.Add("ERROR: Makefile not found");
				return result;
			}

			List<int> banks = ReadBanksList(makefile);
			int next = banks.Count == 0 ? 1 : banks.Max() + 1;
			if (banks.Contains(next))
			{
				result.Log.Add("ERROR: bank " + FmtBank(next) + " already in BANKS");
				return result;
			}

			banks.Add(next);
			banks.Sort();
			WriteBanksList(makefile, banks);
			result.Log.Add("  + Makefile BANKS := " + FormatBanks(banks));

			WriteBanksHeader(projectDir, banks.Count, result.Log);

			string cbPath = Path.Combine(projectDir, "codebank_" + FmtBank(next) + ".c");
			if (File.Exists(cbPath))
				result.Log.Add("  = codebank exists: " + Path.GetFileName(cbPath));
			else
			{
				string app = Path.GetFileName(projectDir.TrimEnd('\\', '/'));
				File.WriteAllText(cbPath, BuildCodebankStub(next, app), Encoding.Default);
				result.Log.Add("  + " + Path.GetFileName(cbPath));
			}

			string callPath = FirstExisting(projectDir, "bank_call.c", "net_call.c");
			string plugPath = Path.Combine(projectDir, "mb_plug.h");
			SyncBankThunks(callPath, plugPath, banks.Count, result.Log);
			EnsureBankLoader(projectDir, result.Log);

			WarnSharedJt(projectDir, result.Log);

			result.Added = 1;
			result.Log.Add(string.Format(CultureInfo.InvariantCulture,
				"done: added bank {0} (g_bankPg[{1}])", FmtBank(next), next - 1));
			return result;
		}

		public static RemoveResult RemoveBank(string projectDir, int bankNum1)
		{
			var result = new RemoveResult();
			if (string.IsNullOrEmpty(projectDir) || !Directory.Exists(projectDir))
			{
				result.Log.Add("ERROR: project folder missing");
				return result;
			}
			if (bankNum1 < 1 || bankNum1 > 15)
			{
				result.Log.Add("ERROR: bank number must be 1..15");
				return result;
			}

			string makefile = Path.Combine(projectDir, "Makefile");
			if (!File.Exists(makefile))
			{
				result.Log.Add("ERROR: Makefile not found");
				return result;
			}

			List<int> banks = ReadBanksList(makefile);
			if (!banks.Contains(bankNum1))
			{
				result.Log.Add("ERROR: bank " + FmtBank(bankNum1) + " not in BANKS ("
					+ FormatBanks(banks) + ")");
				return result;
			}
			if (banks.Count <= 1)
			{
				result.Log.Add("ERROR: cannot remove the last remaining bank");
				return result;
			}

			int removedIdx = bankNum1 - 1; /* g_bankPg index before compact */
			string victim = Path.Combine(projectDir, "codebank_" + FmtBank(bankNum1) + ".c");
			if (File.Exists(victim))
			{
				File.Delete(victim);
				result.Log.Add("  - deleted " + Path.GetFileName(victim));
			}
			else
				result.Log.Add("  = no file codebank_" + FmtBank(bankNum1) + ".c");

			/* Compact higher banks downward: 03->02, 04->03, ... */
			int max = banks.Max();
			for (int n = bankNum1 + 1; n <= max; n++)
			{
				string src = Path.Combine(projectDir, "codebank_" + FmtBank(n) + ".c");
				string dst = Path.Combine(projectDir, "codebank_" + FmtBank(n - 1) + ".c");
				if (!File.Exists(src))
					continue;
				if (File.Exists(dst))
					File.Delete(dst);
				string text = File.ReadAllText(src, Encoding.Default);
				text = Regex.Replace(text,
					@"mb_report_bank\s*\(\s*" + n.ToString(CultureInfo.InvariantCulture) + @"\s*u?\s*\)",
					"mb_report_bank(" + (n - 1).ToString(CultureInfo.InvariantCulture) + "u)");
				text = Regex.Replace(text,
					@"bank" + FmtBank(n),
					"bank" + FmtBank(n - 1));
				File.WriteAllText(dst, text, Encoding.Default);
				File.Delete(src);
				result.Log.Add("  * renamed codebank_" + FmtBank(n)
					+ ".c -> codebank_" + FmtBank(n - 1) + ".c");
			}

			banks = Enumerable.Range(1, max - 1).ToList();
			WriteBanksList(makefile, banks);
			result.Log.Add("  * Makefile BANKS := " + FormatBanks(banks));
			WriteBanksHeader(projectDir, banks.Count, result.Log);

			string callPath = FirstExisting(projectDir, "bank_call.c", "net_call.c");
			string plugPath = Path.Combine(projectDir, "mb_plug.h");
			if (File.Exists(callPath))
			{
				string call = File.ReadAllText(callPath, Encoding.Default);
				call = FixBankEnterIndices(call, removedIdx, result.Log);
				File.WriteAllText(callPath, call, Encoding.Default);
			}
			SyncBankThunks(callPath, plugPath, banks.Count, result.Log);
			EnsureBankLoader(projectDir, result.Log);

			result.Removed = 1;
			result.Log.Add(string.Format(CultureInfo.InvariantCulture,
				"done: removed bank {0}, now {1} bank(s)",
				FmtBank(bankNum1), banks.Count));
			return result;
		}

		private static List<int> ReadBanksList(string makefilePath)
		{
			string text = File.ReadAllText(makefilePath, Encoding.Default);
			Match m = Regex.Match(text, @"(?m)^BANKS\s*:?=\s*(.+)$");
			var list = new List<int>();
			if (!m.Success)
				return list;
			foreach (Match x in Regex.Matches(m.Groups[1].Value, @"\d+"))
			{
				int n;
				if (int.TryParse(x.Value, NumberStyles.Integer,
						CultureInfo.InvariantCulture, out n) && n >= 1)
					list.Add(n);
			}
			return list.Distinct().OrderBy(v => v).ToList();
		}

		private static void WriteBanksList(string makefilePath, List<int> banks)
		{
			string text = File.ReadAllText(makefilePath, Encoding.Default);
			string line = "BANKS := " + FormatBanks(banks);
			if (Regex.IsMatch(text, @"(?m)^BANKS\s*:?="))
				text = Regex.Replace(text, @"(?m)^BANKS\s*:?=.*$", line);
			else
				text = line + "\r\n" + text;
			File.WriteAllText(makefilePath, text, Encoding.Default);
		}

		private static string FormatBanks(List<int> banks)
		{
			return string.Join(" ", banks.Select(FmtBank).ToArray());
		}

		private static string FmtBank(int n)
		{
			return n.ToString("00", CultureInfo.InvariantCulture);
		}

		private static void WriteBanksHeader(string projectDir, int count, List<string> log)
		{
			string path = Path.Combine(projectDir, "mb_banks.h");
			string body =
				"/* Auto-generated by mbgen / mbovl from Makefile BANKS - do not edit. */\r\n"
				+ "#define MB_BANK_COUNT "
				+ count.ToString(CultureInfo.InvariantCulture) + "u\r\n";
			File.WriteAllText(path, body, Encoding.Default);
			log.Add("  * mb_banks.h MB_BANK_COUNT " + count + "u");
		}

		private static string BuildCodebankStub(int bankNum1, string appName)
		{
			string nn = FmtBank(bankNum1);
			return
				"#pragma language=extended\r\n"
				+ "#pragma codeseg(CODE_RESIDENT)\r\n"
				+ "\r\n"
				+ "#include \"mb_inc.h\"\r\n"
				+ "\r\n"
				+ "extern void mb_report_bank(unsigned int bank_nr);\r\n"
				+ "\r\n"
				+ "void r_bank_entry(void)\r\n"
				+ "{\r\n"
				+ "\tmb_report_bank(" + bankNum1.ToString(CultureInfo.InvariantCulture) + "u);\r\n"
				+ "\tputs(\"" + (appName ?? "app") + " bank" + nn + " ok\\r\\n\");\r\n"
				+ "}\r\n";
		}

		private static void SyncBankThunks(string callPath, string plugPath,
			int count, List<string> log)
		{
			if (!string.IsNullOrEmpty(callPath) && File.Exists(callPath))
			{
				string call = File.ReadAllText(callPath, Encoding.Default);
				call = StripBankThunks(call);
				string block = BuildBankThunksC(count);
				if (Regex.IsMatch(call, @"/\*\s*mbgen:banks-begin\s*\*/"))
				{
					call = Regex.Replace(call,
						@"/\*\s*mbgen:banks-begin\s*\*/.*?/\*\s*mbgen:banks-end\s*\*/",
						block, RegexOptions.Singleline);
				}
				else
				{
					/* insert after mb_run_bank function if present */
					Match m = Regex.Match(call,
						@"void\s+mb_run_bank\s*\([^)]*\)\s*\{.*?\n\}",
						RegexOptions.Singleline);
					if (m.Success)
					{
						int at = m.Index + m.Length;
						call = call.Insert(at, "\r\n\r\n" + block + "\r\n");
					}
					else
						call = call + "\r\n" + block + "\r\n";
				}
				File.WriteAllText(callPath, call, Encoding.Default);
				log.Add("  * bank_call.c bank1..bank" + count);
			}

			if (!string.IsNullOrEmpty(plugPath) && File.Exists(plugPath))
			{
				string plug = File.ReadAllText(plugPath, Encoding.Default);
				string decls = BuildBankThunksH(count);
				if (Regex.IsMatch(plug, @"/\*\s*mbgen:banks-begin\s*\*/"))
				{
					plug = Regex.Replace(plug,
						@"/\*\s*mbgen:banks-begin\s*\*/.*?/\*\s*mbgen:banks-end\s*\*/",
						decls, RegexOptions.Singleline);
				}
				else
				{
					/* remove old void bankN(void); lines then insert before Legacy/endif */
					plug = Regex.Replace(plug, @"(?m)^void\s+bank\d+\s*\(\s*void\s*\)\s*;\s*\r?\n", "");
					Match m = Regex.Match(plug, @"(?m)^/\*\s*Legacy");
					if (!m.Success)
						m = Regex.Match(plug, @"(?m)^#\s*endif\b");
					if (m.Success)
						plug = plug.Insert(m.Index, decls + "\r\n");
					else
						plug = plug + decls;
				}
				File.WriteAllText(plugPath, plug, Encoding.Default);
				log.Add("  * mb_plug.h bank1..bank" + count + " decls");
			}
		}

		private static string StripBankThunks(string call)
		{
			call = Regex.Replace(call,
				@"/\*\s*mbgen:banks-begin\s*\*/.*?/\*\s*mbgen:banks-end\s*\*/\s*",
				"", RegexOptions.Singleline);
			call = Regex.Replace(call,
				@"(?m)^void\s+bank\d+\s*\(\s*void\s*\)\s*\r?\n\{\r?\n\s*mb_run_bank\s*\([^;]*\);\r?\n\}\s*\r?\n",
				"");
			return call;
		}

		private static string BuildBankThunksC(int count)
		{
			var sb = new StringBuilder();
			sb.Append("/* mbgen:banks-begin */\r\n");
			for (int i = 1; i <= count; i++)
			{
				sb.Append("void bank");
				sb.Append(i.ToString(CultureInfo.InvariantCulture));
				sb.Append("(void)\r\n{\r\n\tmb_run_bank(");
				sb.Append((i - 1).ToString(CultureInfo.InvariantCulture));
				sb.Append("u);\r\n}\r\n\r\n");
			}
			sb.Append("/* mbgen:banks-end */");
			return sb.ToString();
		}

		private static string BuildBankThunksH(int count)
		{
			var sb = new StringBuilder();
			sb.Append("/* mbgen:banks-begin */\r\n");
			for (int i = 1; i <= count; i++)
			{
				sb.Append("void bank");
				sb.Append(i.ToString(CultureInfo.InvariantCulture));
				sb.Append("(void);\r\n");
			}
			sb.Append("/* mbgen:banks-end */");
			return sb.ToString();
		}

		private static string FixBankEnterIndices(string call, int removedIdx,
			List<string> log)
		{
			/* Decrement MB_BANK_ENTER(n) for n > removedIdx; warn on == removedIdx. */
			return Regex.Replace(call,
				@"MB_BANK_ENTER\s*\(\s*(\d+)\s*u?\s*\)",
				delegate(Match m)
				{
					int n;
					if (!int.TryParse(m.Groups[1].Value, NumberStyles.Integer,
							CultureInfo.InvariantCulture, out n))
						return m.Value;
					if (n == removedIdx)
					{
						log.Add("  ! wrapper still uses MB_BANK_ENTER("
							+ n + ") ? remove its JT proc or re-apply");
						return m.Value;
					}
					if (n > removedIdx)
					{
						log.Add(string.Format(CultureInfo.InvariantCulture,
							"  * MB_BANK_ENTER({0}) -> ({1})", n, n - 1));
						return "MB_BANK_ENTER("
							+ (n - 1).ToString(CultureInfo.InvariantCulture) + ")";
					}
					return m.Value;
				});
		}

		private static void EnsureBankLoader(string projectDir, List<string> log)
		{
			string mainPath = Path.Combine(projectDir, "main.c");
			if (!File.Exists(mainPath))
			{
				log.Add("  = main.c missing ? skip loader patch");
				return;
			}
			string app = Path.GetFileName(projectDir.TrimEnd('\\', '/'));
			if (string.IsNullOrEmpty(app))
				app = "app";
			string main = File.ReadAllText(mainPath, Encoding.Default);
			string block = BuildLoaderBlock(app);

			if (Regex.IsMatch(main, @"/\*\s*mbgen:bank-load-begin\s*\*/"))
			{
				main = Regex.Replace(main,
					@"/\*\s*mbgen:bank-load-begin\s*\*/.*?/\*\s*mbgen:bank-load-end\s*\*/",
					block, RegexOptions.Singleline);
				log.Add("  * main.c bank loader refreshed");
			}
			else if (Regex.IsMatch(main, @"mb_load_first_bank|mb_load_all_banks|mb_try_load"))
			{
				/* Replace old mb_load_first_bank function if present */
				if (Regex.IsMatch(main,
					@"static\s+unsigned\s+char\s+mb_load_first_bank\s*\(\s*void\s*\)\s*\{.*?\n\}",
					RegexOptions.Singleline))
				{
					main = Regex.Replace(main,
						@"static\s+unsigned\s+char\s+mb_load_first_bank\s*\(\s*void\s*\)\s*\{.*?\n\}",
						block, RegexOptions.Singleline);
					main = main.Replace("mb_load_first_bank()", "mb_load_all_banks()");
					log.Add("  * main.c mb_load_first_bank -> mb_load_all_banks");
				}
				else
					log.Add("  = main.c already has custom loader");
			}
			else
			{
				/* Insert before first #define BR_ or after mb_shutdown */
				Match m = Regex.Match(main, @"(?m)^#define\s+BR_");
				if (m.Success)
					main = main.Insert(m.Index, block + "\r\n\r\n");
				else
					main = main + "\r\n" + block + "\r\n";
				log.Add("  + main.c inserted mb_load_all_banks()");
			}

			File.WriteAllText(mainPath, main, Encoding.Default);
		}

		private static string BuildLoaderBlock(string app)
		{
			return
				"/* mbgen:bank-load-begin */\r\n"
				+ "static void mb_fmt_bank_name(unsigned char idx0, char *name)\r\n"
				+ "{\r\n"
				+ "\tsprintf(name, \"codeB_%02u.bin\", (unsigned int)(idx0 + 1u));\r\n"
				+ "}\r\n"
				+ "\r\n"
				+ "static unsigned char mb_try_load(unsigned char idx, unsigned char *page_out)\r\n"
				+ "{\r\n"
				+ "\tchar path[40];\r\n"
				+ "\tchar name[16];\r\n"
				+ "\r\n"
				+ "\tmb_fmt_bank_name(idx, name);\r\n"
				+ "\tstrcpy(path, \"" + app + "/\");\r\n"
				+ "\tstrcat(path, name);\r\n"
				+ "\tif (mb_load_bank_bin(path, page_out))\r\n"
				+ "\t\treturn 1u;\r\n"
				+ "\tstrcpy(path, \"bin/" + app + "/\");\r\n"
				+ "\tstrcat(path, name);\r\n"
				+ "\treturn mb_load_bank_bin(path, page_out);\r\n"
				+ "}\r\n"
				+ "\r\n"
				+ "static unsigned char mb_load_all_banks(void)\r\n"
				+ "{\r\n"
				+ "\tunsigned char i;\r\n"
				+ "\tunsigned char ok;\r\n"
				+ "\r\n"
				+ "\tok = 1u;\r\n"
				+ "\tfor (i = 0u; i < MB_BANK_COUNT; i++)\r\n"
				+ "\t{\r\n"
				+ "\t\tif (!mb_try_load(i, &g_bankPg[i]))\r\n"
				+ "\t\t\tok = 0u;\r\n"
				+ "\t}\r\n"
				+ "\treturn ok;\r\n"
				+ "}\r\n"
				+ "/* mbgen:bank-load-end */";
		}

		private static void WarnSharedJt(string projectDir, List<string> log)
		{
			string asmPath = Path.Combine(projectDir, "bank_jt.asm");
			if (!File.Exists(asmPath))
				return;
			List<string> names = JpNames(File.ReadAllText(asmPath, Encoding.Default));
			if (names.Count > 1)
			{
				log.Add("NOTE: shared bank_jt.asm has " + names.Count
					+ " JP slots; every codebank must provide those symbols");
				log.Add("      (multibank demo uses only r_bank_entry per bank)");
			}
		}

		/* ---- naming ---- */

		public static string ToWrapperName(string procName)
		{
			string stem = StripRPrefix(procName);
			if (stem.StartsWith("mb_", StringComparison.Ordinal))
				return stem;
			return "mb_" + stem;
		}

		public static string ToDefineName(string procName)
		{
			string stem = StripRPrefix(procName);
			if (stem.StartsWith("mb_", StringComparison.OrdinalIgnoreCase))
				stem = stem.Substring(3);
			string snake = CamelToSnake(stem).ToUpperInvariant();
			if (string.IsNullOrEmpty(snake))
				snake = "ENTRY";
			return "MB_JT_" + snake;
		}

		private static string StripRPrefix(string name)
		{
			if (name.Length >= 2 && (name[0] == 'r' || name[0] == 'R') && name[1] == '_')
				return name.Substring(2);
			return name;
		}

		private static string CamelToSnake(string s)
		{
			if (string.IsNullOrEmpty(s))
				return s;
			var sb = new StringBuilder();
			for (int i = 0; i < s.Length; i++)
			{
				char c = s[i];
				if (c == '-' || c == ' ')
				{
					sb.Append('_');
					continue;
				}
				if (char.IsUpper(c) && i > 0 && (char.IsLower(s[i - 1]) || char.IsDigit(s[i - 1])))
					sb.Append('_');
				sb.Append(c);
			}
			return sb.ToString().Replace("__", "_");
		}

		/* ---- detect existing ---- */

		private static bool HasAsmEntry(string asm, string procName)
		{
			return Regex.IsMatch(asm,
				@"\bJP\s+" + Regex.Escape(procName) + @"\b",
				RegexOptions.IgnoreCase)
				|| Regex.IsMatch(asm,
				@"\bEXTERN\s+" + Regex.Escape(procName) + @"\b",
				RegexOptions.IgnoreCase);
		}

		private static bool HasDefine(string hdr, string defineName)
		{
			return Regex.IsMatch(hdr,
				@"#\s*define\s+" + Regex.Escape(defineName) + @"\b");
		}

		private static bool HasWrapper(string call, string wrapperName)
		{
			return Regex.IsMatch(call,
				@"\b" + Regex.Escape(wrapperName) + @"\s*\(");
		}

		private static bool HasPrototype(string req, string wrapperName)
		{
			return Regex.IsMatch(req,
				@"\b" + Regex.Escape(wrapperName) + @"\s*\(");
		}

		private static int NextSlot(string hdr, string asm)
		{
			/* Per-bank JT: next slot = JP count in THIS asm only.
			 * Ignore shared bank_jt.h MB_JT_* maxima (slots are per-bank). */
			if (string.IsNullOrEmpty(asm))
				return 0;
			return Regex.Matches(asm, @"(?m)^\s*JP\s+\w+").Count;
		}

		private static int SlotIndexOf(string asm, string procName)
		{
			int i = 0;
			foreach (Match x in Regex.Matches(asm, @"(?m)^\s*JP\s+(\w+)"))
			{
				if (string.Equals(x.Groups[1].Value, procName, StringComparison.Ordinal))
					return i;
				i++;
			}
			return -1;
		}

		/* ---- patchers ---- */

		private static string PatchAsm(string asm, string procName)
		{
			string nl = asm.Contains("\r\n") ? "\r\n" : "\n";

			if (!Regex.IsMatch(asm, @"\bEXTERN\s+" + Regex.Escape(procName) + @"\b"))
			{
				Match last = null;
				foreach (Match x in Regex.Matches(asm, @"(?m)^[ \t]*EXTERN[ \t]+\w+[^\r\n]*"))
					last = x;
				if (last != null)
				{
					int at = last.Index + last.Length;
					/* skip trailing newline of that line */
					if (at < asm.Length && asm[at] == '\r') at++;
					if (at < asm.Length && asm[at] == '\n') at++;
					asm = asm.Insert(at, "\tEXTERN " + procName + nl);
				}
				else
				{
					Match rseg = Regex.Match(asm, @"(?m)^[ \t]*RSEG[ \t]+CODE_RESIDENT");
					if (rseg.Success)
						asm = asm.Insert(rseg.Index, "\tEXTERN " + procName + nl);
					else
						asm = "\tEXTERN " + procName + nl + asm;
				}
			}

			if (!Regex.IsMatch(asm, @"\bJP[ \t]+" + Regex.Escape(procName) + @"\b"))
			{
				Match lastJp = null;
				foreach (Match x in Regex.Matches(asm, @"(?m)^[ \t]*JP[ \t]+\w+[^\r\n]*"))
					lastJp = x;
				if (lastJp != null)
				{
					int at = lastJp.Index + lastJp.Length;
					if (at < asm.Length && asm[at] == '\r') at++;
					if (at < asm.Length && asm[at] == '\n') at++;
					asm = asm.Insert(at, "\tJP\t" + procName + nl);
				}
				else
				{
					Match end = Regex.Match(asm, @"(?m)^[ \t]*END\b");
					if (end.Success)
						asm = asm.Insert(end.Index, "\tJP\t" + procName + nl);
					else
						asm = asm + nl + "\tJP\t" + procName + nl;
				}
			}
			return asm;
		}

		private static string PatchDefine(string hdr, string defineName, int slot)
		{
			string line = "#define " + defineName + "  "
				+ slot.ToString(CultureInfo.InvariantCulture) + "u\r\n";

			/* Prefer insert before MB_JT_ADDR macro */
			var m = Regex.Match(hdr, @"(?m)^#\s*define\s+MB_JT_ADDR\b");
			if (m.Success)
				return hdr.Insert(m.Index, line);

			/* else after last MB_JT_ define */
			Match last = null;
			foreach (Match x in Regex.Matches(hdr, @"(?m)^#\s*define\s+MB_JT_[A-Z0-9_]+\s+.*\r?\n"))
				last = x;
			if (last != null)
				return hdr.Insert(last.Index + last.Length, line);

			/* before #endif */
			m = Regex.Match(hdr, @"(?m)^#\s*endif\b");
			if (m.Success)
				return hdr.Insert(m.Index, line);

			return hdr + line;
		}

		private static void EnsureCallMacros(ref string call, List<string> log)
		{
			if (Regex.IsMatch(call, @"#\s*define\s+MB_BANK_SAVE\b") ||
				Regex.IsMatch(call, @"#\s*define\s+MB_BANK_ENTER\b"))
				return;

			string macros =
				"\r\n" +
				"/* mbgen: paging around JT CALL ? override trio together if needed.\r\n" +
				" * Empty no-op SAVE:  #define MB_BANK_SAVE()\r\n" +
				" * (no ';' after MB_BANK_SAVE() in wrappers ? C89 decls.) */\r\n" +
				"#ifndef MB_BANK_SAVE\r\n" +
				"#define MB_BANK_SAVE() \\\r\n" +
				"\tunsigned char _mb_saved8000 = mb_code_current();\r\n" +
				"#define MB_BANK_ENTER(idx) OS_SETPG8000(g_bankPg[(idx)])\r\n" +
				"#define MB_BANK_LEAVE()    OS_SETPG8000(_mb_saved8000)\r\n" +
				"#endif\r\n";

			/* after last #include */
			Match last = null;
			foreach (Match x in Regex.Matches(call, @"(?m)^#\s*include\s+.*\r?\n"))
				last = x;
			if (last != null)
			{
				call = call.Insert(last.Index + last.Length, macros);
				log.Add("  + injected MB_BANK_SAVE/ENTER/LEAVE macros");
				return;
			}
			call = macros + call;
			log.Add("  + injected MB_BANK_SAVE/ENTER/LEAVE macros (top)");
		}

		private static string PatchWrapper(string call, ProcInfo p, int bankIndex)
		{
			string block = BuildWrapper(p, bankIndex);
			/* before EOF, after last function ? append */
			if (!call.EndsWith("\n", StringComparison.Ordinal))
				call += "\r\n";
			return call + "\r\n" + block;
		}

		private static string BuildWrapper(ProcInfo p, int bankIndex)
		{
			string parms = string.IsNullOrEmpty(p.ParamsRaw) ? "void" : p.ParamsRaw;
			bool isVoidRet = Regex.IsMatch(p.ReturnType, @"^void$", RegexOptions.IgnoreCase);
			List<string> argNames = ExtractArgNames(p.ParamsRaw);
			string argList = string.Join(", ", argNames.ToArray());
			string fnTypeArgs = ParamTypesOnly(p.ParamsRaw);
			if (string.IsNullOrEmpty(fnTypeArgs) || fnTypeArgs == "void")
				fnTypeArgs = "void";

			var sb = new StringBuilder();
			sb.Append("/* mbgen: ");
			sb.Append(p.Name);
			sb.Append(" */\r\n");
			sb.Append(p.ReturnType);
			sb.Append(' ');
			sb.Append(p.WrapperName);
			sb.Append('(');
			sb.Append(parms);
			sb.Append(")\r\n{\r\n");

			if (isVoidRet)
			{
				sb.Append('\t');
				sb.Append(p.ReturnType);
				sb.Append(" (*fn)(");
				sb.Append(fnTypeArgs);
				sb.Append(");\r\n");
				sb.Append("\tMB_BANK_SAVE()\r\n");
				sb.Append("\tMB_BANK_ENTER(");
				sb.Append(bankIndex.ToString(CultureInfo.InvariantCulture));
				sb.Append(");\r\n");
				sb.Append("\tfn = (");
				sb.Append(p.ReturnType);
				sb.Append(" (*)(");
				sb.Append(fnTypeArgs);
				sb.Append("))MB_JT_ADDR(");
				sb.Append(p.DefineName);
				sb.Append(");\r\n");
				sb.Append("\tfn(");
				sb.Append(argList);
				sb.Append(");\r\n");
				sb.Append("\tMB_BANK_LEAVE();\r\n");
			}
			else
			{
				sb.Append('\t');
				sb.Append(p.ReturnType);
				sb.Append(" (*fn)(");
				sb.Append(fnTypeArgs);
				sb.Append(");\r\n");
				sb.Append('\t');
				sb.Append(p.ReturnType);
				sb.Append(" r;\r\n");
				sb.Append("\tMB_BANK_SAVE()\r\n");
				sb.Append("\tMB_BANK_ENTER(");
				sb.Append(bankIndex.ToString(CultureInfo.InvariantCulture));
				sb.Append(");\r\n");
				sb.Append("\tfn = (");
				sb.Append(p.ReturnType);
				sb.Append(" (*)(");
				sb.Append(fnTypeArgs);
				sb.Append("))MB_JT_ADDR(");
				sb.Append(p.DefineName);
				sb.Append(");\r\n");
				sb.Append("\tr = fn(");
				sb.Append(argList);
				sb.Append(");\r\n");
				sb.Append("\tMB_BANK_LEAVE();\r\n");
				sb.Append("\treturn r;\r\n");
			}
			sb.Append("}\r\n");
			return sb.ToString();
		}

		private static string PatchPrototype(string req, ProcInfo p)
		{
			string parms = string.IsNullOrEmpty(p.ParamsRaw) ? "void" : p.ParamsRaw;
			string line = p.ReturnType + " " + p.WrapperName + "(" + parms + ");\r\n";

			Match m = Regex.Match(req, @"(?m)^#\s*endif\b");
			if (m.Success)
				return req.Insert(m.Index, line);
			return req + line;
		}

		private static string CreateReqStub(string fileName)
		{
			string guard = Regex.Replace(fileName.ToUpperInvariant(), @"[^A-Z0-9]", "_");
			return "#ifndef " + guard + "\r\n#define " + guard + "\r\n\r\n"
				+ "/* mbgen-generated root wrappers */\r\n\r\n"
				+ "#endif\r\n";
		}

		/* ---- helpers ---- */

		private static List<string> ExtractArgNames(string paramsRaw)
		{
			var names = new List<string>();
			if (string.IsNullOrEmpty(paramsRaw) || paramsRaw.Trim() == "void")
				return names;

			foreach (string part in SplitParams(paramsRaw))
			{
				string t = part.Trim();
				if (t.Length == 0 || t == "void")
					continue;
				t = Regex.Replace(t, @"\[\s*\]", "");
				Match m = Regex.Match(t, @"^(.*?)([A-Za-z_]\w*)\s*$");
				if (!m.Success)
					continue;
				string before = m.Groups[1].Value.Trim();
				/* need a type/stars before the name */
				if (before.Length == 0)
					continue;
				names.Add(m.Groups[2].Value);
			}
			return names;
		}

		private static string ParamTypesOnly(string paramsRaw)
		{
			if (string.IsNullOrEmpty(paramsRaw) || paramsRaw.Trim() == "void")
				return "void";
			var types = new List<string>();
			foreach (string part in SplitParams(paramsRaw))
			{
				string t = part.Trim();
				if (t.Length == 0)
					continue;
				if (t == "void")
				{
					types.Add("void");
					continue;
				}
				Match m = Regex.Match(t, @"^(.*?)([A-Za-z_]\w*)(\s*\[\s*\])*\s*$");
				if (m.Success && m.Groups[1].Value.Trim().Length > 0)
					types.Add(NormalizeSpaces(m.Groups[1].Value + m.Groups[3].Value));
				else
					types.Add(NormalizeSpaces(t));
			}
			return string.Join(", ", types.ToArray());
		}

		private static IEnumerable<string> SplitParams(string paramsRaw)
		{
			var list = new List<string>();
			int depth = 0;
			int start = 0;
			for (int i = 0; i < paramsRaw.Length; i++)
			{
				char c = paramsRaw[i];
				if (c == '(') depth++;
				else if (c == ')') depth--;
				else if (c == ',' && depth == 0)
				{
					list.Add(paramsRaw.Substring(start, i - start));
					start = i + 1;
				}
			}
			list.Add(paramsRaw.Substring(start));
			return list;
		}

		private static bool LooksLikeType(string s)
		{
			if (string.IsNullOrEmpty(s))
				return false;
			string first = s.Trim().Split(new[] { ' ', '\t' },
				StringSplitOptions.RemoveEmptyEntries)[0];
			switch (first)
			{
				case "void":
				case "char":
				case "int":
				case "long":
				case "short":
				case "float":
				case "double":
				case "unsigned":
				case "signed":
				case "const":
				case "volatile":
				case "struct":
				case "enum":
				case "union":
				case "FILE":
				case "size_t":
				case "BYTE":
				case "WORD":
				case "DWORD":
					return true;
				default:
					/* typedef names used in project */
					return first.Length > 0 && char.IsLetter(first[0]);
			}
		}

		private static string StripComments(string text)
		{
			var sb = new StringBuilder(text.Length);
			int i = 0;
			while (i < text.Length)
			{
				if (i + 1 < text.Length && text[i] == '/' && text[i + 1] == '/')
				{
					sb.Append("  ");
					i += 2;
					while (i < text.Length && text[i] != '\n')
					{
						sb.Append(text[i] == '\t' ? '\t' : ' ');
						i++;
					}
					continue;
				}
				if (i + 1 < text.Length && text[i] == '/' && text[i + 1] == '*')
				{
					sb.Append("  ");
					i += 2;
					while (i + 1 < text.Length && !(text[i] == '*' && text[i + 1] == '/'))
					{
						sb.Append(text[i] == '\n' ? '\n' : ' ');
						i++;
					}
					if (i + 1 < text.Length)
					{
						sb.Append("  ");
						i += 2;
					}
					continue;
				}
				if (text[i] == '"' || text[i] == '\'')
				{
					char q = text[i++];
					sb.Append(q);
					while (i < text.Length && text[i] != q)
					{
						if (text[i] == '\\' && i + 1 < text.Length)
						{
							sb.Append(' ');
							sb.Append(' ');
							i += 2;
							continue;
						}
						sb.Append(text[i] == '\n' ? '\n' : ' ');
						i++;
					}
					if (i < text.Length)
						sb.Append(text[i++]);
					continue;
				}
				sb.Append(text[i++]);
			}
			return sb.ToString();
		}

		private static string NormalizeSpaces(string s)
		{
			return Regex.Replace(s.Trim(), @"\s+", " ");
		}

		private static int LineOfIndex(string text, int index)
		{
			int line = 1;
			for (int i = 0; i < index && i < text.Length; i++)
				if (text[i] == '\n') line++;
			return line;
		}

		private static string FirstExisting(string dir, params string[] names)
		{
			if (string.IsNullOrEmpty(dir))
				return names.Length > 0 ? names[0] : "";
			foreach (string n in names)
			{
				string p = Path.Combine(dir, n);
				if (File.Exists(p))
					return p;
			}
			return Path.Combine(dir, names[0]);
		}
	}
}
