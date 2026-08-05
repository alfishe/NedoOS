using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace MbGen
{
	internal sealed class MainForm : Form
	{
		private readonly TextBox _project;
		private readonly TextBox _codebank;
		private readonly TextBox _jtAsm;
		private readonly TextBox _jtH;
		private readonly TextBox _callC;
		private readonly TextBox _reqH;
		private readonly NumericUpDown _bankIdx;
		private readonly TextBox _log;
		private readonly CheckBox _autoIdx;
		private readonly ListBox _regList;

		public MainForm()
		{
			Text = "mbgen - Plan JT scanner";
			Width = 820;
			Height = 680;
			MinimumSize = new Size(680, 520);
			StartPosition = FormStartPosition.CenterScreen;
			Font = new Font("Segoe UI", 9F);

			var root = new TableLayoutPanel
			{
				Dock = DockStyle.Fill,
				ColumnCount = 1,
				RowCount = 4,
				Padding = new Padding(8)
			};
			root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
			root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
			root.RowStyles.Add(new RowStyle(SizeType.Percent, 35F));
			root.RowStyles.Add(new RowStyle(SizeType.Percent, 65F));
			Controls.Add(root);

			/* --- project row --- */
			var projPanel = new FlowLayoutPanel
			{
				Dock = DockStyle.Top,
				AutoSize = true,
				WrapContents = false
			};
			projPanel.Controls.Add(new Label
			{
				Text = "Project folder:",
				AutoSize = true,
				Margin = new Padding(0, 6, 6, 0)
			});
			_project = MakePathBox(420);
			projPanel.Controls.Add(_project);
			projPanel.Controls.Add(MakeButton("Browse?", delegate
			{
				using (var d = new FolderBrowserDialog())
				{
					d.Description = "Select kapps/<app> folder (e.g. multibank)";
					if (Directory.Exists(_project.Text))
						d.SelectedPath = _project.Text;
					if (d.ShowDialog(this) == DialogResult.OK)
					{
						_project.Text = d.SelectedPath;
						Autofill();
					}
				}
			}));
			projPanel.Controls.Add(MakeButton("Autofill", delegate { Autofill(); }));
			root.Controls.Add(projPanel);

			/* --- file rows --- */
			var files = new TableLayoutPanel
			{
				Dock = DockStyle.Top,
				AutoSize = true,
				ColumnCount = 4,
				Padding = new Padding(0, 8, 0, 0)
			};
			files.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 110));
			files.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
			files.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 70));
			files.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 70));

			_codebank = AddFileRow(files, "codebank_XX.c", "C files|*.c|All|*.*");
			_jtAsm = AddFileRow(files, "bank_jt.asm", "ASM|*.asm|All|*.*");
			_jtH = AddFileRow(files, "bank_jt.h", "Headers|*.h|All|*.*");
			_callC = AddFileRow(files, "bank_call.c", "C files|*.c|All|*.*");
			_reqH = AddFileRow(files, "mb_req.h", "Headers|*.h|All|*.*");

			var idxPanel = new FlowLayoutPanel
			{
				Dock = DockStyle.Fill,
				AutoSize = true,
				WrapContents = false
			};
			_autoIdx = new CheckBox
			{
				Text = "Bank index from codebank_NN",
				Checked = true,
				AutoSize = true,
				Margin = new Padding(0, 4, 12, 0)
			};
			_autoIdx.CheckedChanged += delegate
			{
				_bankIdx.Enabled = !_autoIdx.Checked;
				if (_autoIdx.Checked)
					_bankIdx.Value = Engine.InferBankIndex(_codebank.Text);
			};
			idxPanel.Controls.Add(_autoIdx);
			idxPanel.Controls.Add(new Label
			{
				Text = "g_bankPg[",
				AutoSize = true,
				Margin = new Padding(0, 6, 0, 0)
			});
			_bankIdx = new NumericUpDown
			{
				Minimum = 0,
				Maximum = 15,
				Width = 50,
				Enabled = false
			};
			idxPanel.Controls.Add(_bankIdx);
			idxPanel.Controls.Add(new Label
			{
				Text = "]",
				AutoSize = true,
				Margin = new Padding(0, 6, 0, 0)
			});
			files.Controls.Add(new Label
			{
				Text = "Bank page:",
				AutoSize = true,
				Anchor = AnchorStyles.Left,
				Margin = new Padding(0, 6, 0, 0)
			});
			files.SetColumnSpan(idxPanel, 3);
			files.Controls.Add(idxPanel);

			var actionPanel = new FlowLayoutPanel
			{
				Dock = DockStyle.Fill,
				AutoSize = true
			};
			var scanBtn = MakeButton("Scan and add", DoScanAndAdd);
			scanBtn.Width = 140;
			scanBtn.Height = 28;
			scanBtn.Font = new Font(Font, FontStyle.Bold);
			actionPanel.Controls.Add(scanBtn);
			actionPanel.Controls.Add(MakeButton("Scan only", DoScanOnly));
			actionPanel.Controls.Add(MakeButton("List registered", DoListRegistered));
			actionPanel.Controls.Add(MakeButton("Remove selected", DoRemoveSelected));
			actionPanel.Controls.Add(MakeButton("+1 bank", DoAddBank));
			actionPanel.Controls.Add(MakeButton("Remove bank?", DoRemoveBank));
			files.Controls.Add(new Label());
			files.SetColumnSpan(actionPanel, 3);
			files.Controls.Add(actionPanel);

			root.Controls.Add(files);

			_regList = new ListBox
			{
				Dock = DockStyle.Fill,
				Font = new Font("Consolas", 9F),
				IntegralHeight = false
			};
			_regList.DoubleClick += delegate { DoRemoveSelected(null, EventArgs.Empty); };
			root.Controls.Add(_regList);

			_log = new TextBox
			{
				Dock = DockStyle.Fill,
				Multiline = true,
				ScrollBars = ScrollBars.Both,
				Font = new Font("Consolas", 9F),
				ReadOnly = true,
				WordWrap = false
			};
			root.Controls.Add(_log);

			_codebank.TextChanged += delegate
			{
				if (_autoIdx.Checked)
					_bankIdx.Value = Engine.InferBankIndex(_codebank.Text);
				/* Point JT asm at this bank's table (bank_jt.asm / bank_jt2.asm / ?). */
				try
				{
					string jt = Engine.ResolveJtAsmFromCodebank(_codebank.Text.Trim());
					if (!string.IsNullOrEmpty(jt))
						_jtAsm.Text = jt;
				}
				catch
				{
					/* ignore path errors while typing */
				}
			};

			TryDefaultProject();
		}

		private void TryDefaultProject()
		{
			try
			{
				string here = Path.GetDirectoryName(Application.ExecutablePath);
				/* tools/ -> multibank/ */
				string parent = Directory.GetParent(here) != null
					? Directory.GetParent(here).FullName : here;
				if (File.Exists(Path.Combine(parent, "codebank_01.c")))
				{
					_project.Text = parent;
					Autofill();
				}
			}
			catch
			{
				/* ignore */
			}
		}

		private void Autofill()
		{
			string dir = _project.Text.Trim();
			if (dir.Length == 0 || !Directory.Exists(dir))
			{
				AppendLog("Set a valid project folder first.");
				return;
			}
			string cb, asm, h, call, req;
			Engine.AutofillFromProject(dir, out cb, out asm, out h, out call, out req);
			_codebank.Text = cb;
			_jtAsm.Text = asm;
			_jtH.Text = h;
			_callC.Text = call;
			_reqH.Text = req;
			if (_autoIdx.Checked)
				_bankIdx.Value = Engine.InferBankIndex(cb);
			AppendLog("Autofilled from " + dir);
		}

		private void DoScanOnly(object sender, EventArgs e)
		{
			_log.Clear();
			string cb = _codebank.Text.Trim();
			try
			{
				AppendLog("Scan only -> " + (cb.Length == 0 ? "(empty)" : Path.GetFullPath(cb)));
			}
			catch
			{
				AppendLog("Scan only -> " + cb);
			}
			ScanResult r = Engine.ScanCodebank(cb);
			foreach (string line in r.Log)
				AppendLog(line);
		}

		private void DoScanAndAdd(object sender, EventArgs e)
		{
			_log.Clear();
			int idx = (int)_bankIdx.Value;
			if (_autoIdx.Checked)
				idx = Engine.InferBankIndex(_codebank.Text.Trim());

			/* Always patch the JT that belongs to the selected codebank. */
			string jt = Engine.ResolveJtAsmFromCodebank(_codebank.Text.Trim());
			if (!string.IsNullOrEmpty(jt))
				_jtAsm.Text = jt;

			string req = _reqH.Text.Trim();
			PatchResult r = Engine.Apply(
				_codebank.Text.Trim(),
				_jtAsm.Text.Trim(),
				_jtH.Text.Trim(),
				_callC.Text.Trim(),
				req,
				idx);
			foreach (string line in r.Log)
				AppendLog(line);
			RefreshRegList();
		}

		private void DoListRegistered(object sender, EventArgs e)
		{
			_log.Clear();
			RefreshRegList();
			ListResult r = Engine.ListRegistered(
				_jtAsm.Text.Trim(),
				_jtH.Text.Trim(),
				_callC.Text.Trim(),
				_reqH.Text.Trim(),
				_codebank.Text.Trim());
			foreach (string line in r.Log)
				AppendLog(line);
		}

		private void DoRemoveSelected(object sender, EventArgs e)
		{
			if (_regList.SelectedItem == null)
			{
				AppendLog("Select a registered procedure first (List registered).");
				return;
			}

			string name = ExtractProcName(_regList.SelectedItem.ToString());
			if (string.IsNullOrEmpty(name))
			{
				AppendLog("Cannot parse procedure name from selection.");
				return;
			}

			DialogResult ask = MessageBox.Show(this,
				"Remove JT wiring for:\n  " + name + "\n\n"
				+ "Deletes EXTERN/JP, #define, wrapper, prototype.\n"
				+ "Does NOT delete the function body in codebank_XX.c.",
				Text, MessageBoxButtons.YesNo, MessageBoxIcon.Question);
			if (ask != DialogResult.Yes)
				return;

			_log.Clear();
			RemoveResult r = Engine.Remove(
				name,
				_jtAsm.Text.Trim(),
				_jtH.Text.Trim(),
				_callC.Text.Trim(),
				_reqH.Text.Trim());
			foreach (string line in r.Log)
				AppendLog(line);
			RefreshRegList();
		}

		private void DoAddBank(object sender, EventArgs e)
		{
			string dir = _project.Text.Trim();
			if (dir.Length == 0 || !Directory.Exists(dir))
			{
				AppendLog("Set a valid project folder first.");
				return;
			}
			_log.Clear();
			PatchResult r = Engine.AddBank(dir);
			foreach (string line in r.Log)
				AppendLog(line);
			Autofill();
		}

		private void DoRemoveBank(object sender, EventArgs e)
		{
			string dir = _project.Text.Trim();
			if (dir.Length == 0 || !Directory.Exists(dir))
			{
				AppendLog("Set a valid project folder first.");
				return;
			}

			string input = ShowInput("Remove bank number (1..15):", "1");
			if (input == null)
				return;
			int n;
			if (!int.TryParse(input.Trim(), out n))
			{
				AppendLog("Invalid bank number.");
				return;
			}

			DialogResult ask = MessageBox.Show(this,
				"Remove bank " + n.ToString("00") + " from project?\n\n"
				+ "Updates Makefile BANKS, mb_banks.h, bank_call/mb_plug,\n"
				+ "deletes codebank_XX.c and renumbers higher banks down.\n"
				+ "JT proc wrappers for that bank page need manual cleanup.",
				Text, MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
			if (ask != DialogResult.Yes)
				return;

			_log.Clear();
			RemoveResult r = Engine.RemoveBank(dir, n);
			foreach (string line in r.Log)
				AppendLog(line);
			Autofill();
		}

		private string ShowInput(string prompt, string defaultValue)
		{
			using (var f = new Form())
			{
				f.Text = Text;
				f.FormBorderStyle = FormBorderStyle.FixedDialog;
				f.StartPosition = FormStartPosition.CenterParent;
				f.MinimizeBox = false;
				f.MaximizeBox = false;
				f.ClientSize = new Size(360, 110);
				var lbl = new Label
				{
					Text = prompt,
					Left = 12,
					Top = 12,
					Width = 330,
					AutoSize = true
				};
				var box = new TextBox
				{
					Left = 12,
					Top = 40,
					Width = 330,
					Text = defaultValue
				};
				var ok = new Button
				{
					Text = "OK",
					DialogResult = DialogResult.OK,
					Left = 186,
					Top = 72,
					Width = 75
				};
				var cancel = new Button
				{
					Text = "Cancel",
					DialogResult = DialogResult.Cancel,
					Left = 267,
					Top = 72,
					Width = 75
				};
				f.Controls.Add(lbl);
				f.Controls.Add(box);
				f.Controls.Add(ok);
				f.Controls.Add(cancel);
				f.AcceptButton = ok;
				f.CancelButton = cancel;
				return f.ShowDialog(this) == DialogResult.OK ? box.Text : null;
			}
		}

		private void RefreshRegList()
		{
			_regList.Items.Clear();
			ListResult r = Engine.ListRegistered(
				_jtAsm.Text.Trim(),
				_jtH.Text.Trim(),
				_callC.Text.Trim(),
				_reqH.Text.Trim());
			foreach (RegisteredProc p in r.Items)
			{
				_regList.Items.Add(string.Format(
					System.Globalization.CultureInfo.InvariantCulture,
					"[{0}] {1}  -> {2} / {3}",
					p.Slot, p.Name, p.DefineName, p.WrapperName));
			}
		}

		private static string ExtractProcName(string listLine)
		{
			/* "[0] r_foo  -> MB_JT_FOO / mb_foo" */
			if (string.IsNullOrEmpty(listLine))
				return "";
			int a = listLine.IndexOf(']');
			if (a < 0 || a + 1 >= listLine.Length)
				return "";
			string rest = listLine.Substring(a + 1).Trim();
			int sp = rest.IndexOf(' ');
			if (sp > 0)
				rest = rest.Substring(0, sp);
			int arrow = rest.IndexOf('-');
			if (arrow > 0)
				rest = rest.Substring(0, arrow).Trim();
			return rest.Trim();
		}

		private void AppendLog(string s)
		{
			_log.AppendText(s + Environment.NewLine);
		}

		private TextBox AddFileRow(TableLayoutPanel host, string label, string filter)
		{
			host.Controls.Add(new Label
			{
				Text = label,
				AutoSize = true,
				Anchor = AnchorStyles.Left,
				Margin = new Padding(0, 6, 0, 0)
			});
			TextBox box = MakePathBox(1);
			box.Dock = DockStyle.Fill;
			host.Controls.Add(box);

			TextBox captured = box;
			string capFilter = filter;
			host.Controls.Add(MakeButton("Browse?", delegate
			{
				using (var d = new OpenFileDialog())
				{
					d.Filter = capFilter;
					if (File.Exists(captured.Text))
					{
						d.InitialDirectory = Path.GetDirectoryName(captured.Text);
						d.FileName = Path.GetFileName(captured.Text);
					}
					else if (Directory.Exists(_project.Text))
						d.InitialDirectory = _project.Text;
					if (d.ShowDialog(this) == DialogResult.OK)
						captured.Text = d.FileName;
				}
			}));
			host.Controls.Add(MakeButton("Open", delegate
			{
				OpenInDefaultApp(captured.Text.Trim());
			}));
			return box;
		}

		private void OpenInDefaultApp(string path)
		{
			if (string.IsNullOrEmpty(path) || !File.Exists(path))
			{
				MessageBox.Show(this, "File not found:\n" + path, Text,
					MessageBoxButtons.OK, MessageBoxIcon.Warning);
				return;
			}
			try
			{
				Process.Start(new ProcessStartInfo
				{
					FileName = path,
					UseShellExecute = true
				});
			}
			catch (Exception ex)
			{
				MessageBox.Show(this, ex.Message, Text,
					MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private static TextBox MakePathBox(int width)
		{
			var t = new TextBox { Width = width > 10 ? width : 200 };
			return t;
		}

		private static Button MakeButton(string text, EventHandler onClick)
		{
			var b = new Button
			{
				Text = text,
				AutoSize = true,
				Margin = new Padding(4, 2, 0, 2)
			};
			b.Click += onClick;
			return b;
		}
	}
}
