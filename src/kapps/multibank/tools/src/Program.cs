using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace MbGen
{
	internal static class Program
	{
		[DllImport("kernel32.dll")]
		private static extern bool FreeConsole();

		[STAThread]
		private static void Main(string[] args)
		{
			if (args != null && args.Length > 0)
			{
				Environment.Exit(RunCli(args));
				return;
			}
			try { FreeConsole(); } catch { /* ignore */ }
			Application.EnableVisualStyles();
			Application.SetCompatibleTextRenderingDefault(false);
			Application.Run(new MainForm());
		}

		/* mbgen.exe --scan path\to\codebank_01.c
		 * mbgen.exe --apply <codebank> <jt.asm> <jt.h> <call.c> [req.h] [bankIdx]
		 */
		private static int RunCli(string[] args)
		{
			try
			{
				if (args[0] == "--scan" && args.Length >= 2)
				{
					ScanResult r = Engine.ScanCodebank(args[1]);
					foreach (string line in r.Log)
						Console.WriteLine(line);
					return r.Found.Count > 0 ? 0 : 2;
				}
				if (args[0] == "--apply" && args.Length >= 5)
				{
					string req = args.Length >= 6 ? args[5] : "";
					int idx = 0;
					if (args.Length >= 7)
						int.TryParse(args[6], out idx);
					else
						idx = Engine.InferBankIndex(args[1]);
					PatchResult r = Engine.Apply(args[1], args[2], args[3], args[4], req, idx);
					foreach (string line in r.Log)
						Console.WriteLine(line);
					return 0;
				}
				Console.Error.WriteLine("Usage:");
				Console.Error.WriteLine("  mbgen.exe                  GUI");
				Console.Error.WriteLine("  mbgen.exe --scan codebank_XX.c");
				Console.Error.WriteLine("  mbgen.exe --apply codebank.c bank_jt.asm bank_jt.h bank_call.c [mb_req.h] [bankIdx]");
				return 1;
			}
			catch (Exception ex)
			{
				Console.Error.WriteLine(ex.Message);
				return 1;
			}
		}
	}
}
