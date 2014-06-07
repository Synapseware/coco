using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;
using CoCoDisk.Configuration;
using System.IO.Ports;

namespace CoCoDisk
{
	/// <summary>
	/// Summary description for frmMain.
	/// </summary>
	public class frmMain : System.Windows.Forms.Form
	{
		private System.Windows.Forms.OpenFileDialog dlgOpenFile;
		private System.Windows.Forms.Label lblInfo;
		private Container components = null;
		private System.Windows.Forms.TabPage tabPage1;
		private System.Windows.Forms.TabPage tabPage2;
		private System.Windows.Forms.TabPage tabPage3;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Button cmdGetGranule;
		private System.Windows.Forms.Button cmdGetSector;
		private System.Windows.Forms.TextBox txtGranule;
		private System.Windows.Forms.TextBox txtSector;
		private System.Windows.Forms.TextBox txtTrack;
		private System.Windows.Forms.TextBox txtData;
		private System.Windows.Forms.TreeView lstFiles;

		private SimpleDisk	m_dskInfo;
		private System.Windows.Forms.TabControl tabMain;
		private TextBox txtFileData;
		private MenuStrip menuStrip1;
		private ToolStripMenuItem fileToolStripMenuItem;
		private ToolStripMenuItem openDiskToolStripMenuItem;
		private ToolStripMenuItem exitToolStripMenuItem;
		private ToolStripMenuItem optionsToolStripMenuItem;
		private ToolStripMenuItem settingsToolStripMenuItem;
		private Button cmdSend;
		private Button cmdView;
		private ProgressBar pbProgress;
		private Button cmdSave;
		private SaveFileDialog dlgSaveFile;
		private Settings	m_settings;

		/// <summary>
		/// Constructor
		/// </summary>
		public frmMain ()
		{
			InitializeComponent();

			tabMain.Enabled = false;

			m_settings = Settings.Load (GetPath ());

			LoadState ();
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose (bool disposing)
		{
			SaveState ();

			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.dlgOpenFile = new System.Windows.Forms.OpenFileDialog ();
			this.lblInfo = new System.Windows.Forms.Label ();
			this.tabMain = new System.Windows.Forms.TabControl ();
			this.tabPage1 = new System.Windows.Forms.TabPage ();
			this.tabPage2 = new System.Windows.Forms.TabPage ();
			this.txtFileData = new System.Windows.Forms.TextBox ();
			this.lstFiles = new System.Windows.Forms.TreeView ();
			this.tabPage3 = new System.Windows.Forms.TabPage ();
			this.label3 = new System.Windows.Forms.Label ();
			this.label2 = new System.Windows.Forms.Label ();
			this.label1 = new System.Windows.Forms.Label ();
			this.cmdGetGranule = new System.Windows.Forms.Button ();
			this.cmdGetSector = new System.Windows.Forms.Button ();
			this.txtGranule = new System.Windows.Forms.TextBox ();
			this.txtSector = new System.Windows.Forms.TextBox ();
			this.txtTrack = new System.Windows.Forms.TextBox ();
			this.txtData = new System.Windows.Forms.TextBox ();
			this.menuStrip1 = new System.Windows.Forms.MenuStrip ();
			this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem ();
			this.openDiskToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem ();
			this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem ();
			this.optionsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem ();
			this.settingsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem ();
			this.cmdSend = new System.Windows.Forms.Button ();
			this.cmdView = new System.Windows.Forms.Button ();
			this.pbProgress = new System.Windows.Forms.ProgressBar ();
			this.cmdSave = new System.Windows.Forms.Button ();
			this.dlgSaveFile = new System.Windows.Forms.SaveFileDialog ();
			this.tabMain.SuspendLayout ();
			this.tabPage1.SuspendLayout ();
			this.tabPage2.SuspendLayout ();
			this.tabPage3.SuspendLayout ();
			this.menuStrip1.SuspendLayout ();
			this.SuspendLayout ();
			// 
			// dlgOpenFile
			// 
			this.dlgOpenFile.Filter = "CoCo Virtual Disk (*.dsk)|*.dsk|All files (*.*)|*.*";
			this.dlgOpenFile.FileOk += new System.ComponentModel.CancelEventHandler (this.dlgOpenFile_FileOk);
			// 
			// lblInfo
			// 
			this.lblInfo.Font = new System.Drawing.Font ("Courier New", 8F);
			this.lblInfo.Location = new System.Drawing.Point (8, 8);
			this.lblInfo.Name = "lblInfo";
			this.lblInfo.Size = new System.Drawing.Size (480, 400);
			this.lblInfo.TabIndex = 4;
			// 
			// tabMain
			// 
			this.tabMain.Controls.Add (this.tabPage1);
			this.tabMain.Controls.Add (this.tabPage2);
			this.tabMain.Controls.Add (this.tabPage3);
			this.tabMain.Enabled = false;
			this.tabMain.Location = new System.Drawing.Point (8, 27);
			this.tabMain.Name = "tabMain";
			this.tabMain.SelectedIndex = 0;
			this.tabMain.Size = new System.Drawing.Size (640, 461);
			this.tabMain.TabIndex = 14;
			// 
			// tabPage1
			// 
			this.tabPage1.Controls.Add (this.lblInfo);
			this.tabPage1.Location = new System.Drawing.Point (4, 22);
			this.tabPage1.Name = "tabPage1";
			this.tabPage1.Size = new System.Drawing.Size (632, 435);
			this.tabPage1.TabIndex = 0;
			this.tabPage1.Text = "General";
			// 
			// tabPage2
			// 
			this.tabPage2.Controls.Add (this.cmdSave);
			this.tabPage2.Controls.Add (this.pbProgress);
			this.tabPage2.Controls.Add (this.cmdView);
			this.tabPage2.Controls.Add (this.cmdSend);
			this.tabPage2.Controls.Add (this.txtFileData);
			this.tabPage2.Controls.Add (this.lstFiles);
			this.tabPage2.Location = new System.Drawing.Point (4, 22);
			this.tabPage2.Name = "tabPage2";
			this.tabPage2.Size = new System.Drawing.Size (632, 435);
			this.tabPage2.TabIndex = 1;
			this.tabPage2.Text = "Directory";
			// 
			// txtFileData
			// 
			this.txtFileData.Font = new System.Drawing.Font ("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte) (0)));
			this.txtFileData.Location = new System.Drawing.Point (208, 8);
			this.txtFileData.Multiline = true;
			this.txtFileData.Name = "txtFileData";
			this.txtFileData.ReadOnly = true;
			this.txtFileData.ScrollBars = System.Windows.Forms.ScrollBars.Both;
			this.txtFileData.Size = new System.Drawing.Size (421, 355);
			this.txtFileData.TabIndex = 3;
			// 
			// lstFiles
			// 
			this.lstFiles.Location = new System.Drawing.Point (8, 8);
			this.lstFiles.Name = "lstFiles";
			this.lstFiles.Size = new System.Drawing.Size (192, 413);
			this.lstFiles.TabIndex = 2;
			this.lstFiles.DoubleClick += new System.EventHandler (this.lstFiles_DoubleClick);
			// 
			// tabPage3
			// 
			this.tabPage3.Controls.Add (this.label3);
			this.tabPage3.Controls.Add (this.label2);
			this.tabPage3.Controls.Add (this.label1);
			this.tabPage3.Controls.Add (this.cmdGetGranule);
			this.tabPage3.Controls.Add (this.cmdGetSector);
			this.tabPage3.Controls.Add (this.txtGranule);
			this.tabPage3.Controls.Add (this.txtSector);
			this.tabPage3.Controls.Add (this.txtTrack);
			this.tabPage3.Controls.Add (this.txtData);
			this.tabPage3.Location = new System.Drawing.Point (4, 22);
			this.tabPage3.Name = "tabPage3";
			this.tabPage3.Size = new System.Drawing.Size (632, 435);
			this.tabPage3.TabIndex = 2;
			this.tabPage3.Text = "Raw View";
			// 
			// label3
			// 
			this.label3.Location = new System.Drawing.Point (280, 11);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size (48, 23);
			this.label3.TabIndex = 31;
			this.label3.Text = "Granule:";
			this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// label2
			// 
			this.label2.Location = new System.Drawing.Point (88, 11);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size (40, 23);
			this.label2.TabIndex = 30;
			this.label2.Text = "Sector:";
			this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// label1
			// 
			this.label1.Location = new System.Drawing.Point (8, 11);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size (40, 23);
			this.label1.TabIndex = 29;
			this.label1.Text = "Track:";
			this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// cmdGetGranule
			// 
			this.cmdGetGranule.Location = new System.Drawing.Point (368, 11);
			this.cmdGetGranule.Name = "cmdGetGranule";
			this.cmdGetGranule.Size = new System.Drawing.Size (75, 23);
			this.cmdGetGranule.TabIndex = 28;
			this.cmdGetGranule.Text = "Get &Granule";
			this.cmdGetGranule.Click += new System.EventHandler (this.cmdGetGranule_Click);
			// 
			// cmdGetSector
			// 
			this.cmdGetSector.Location = new System.Drawing.Point (176, 11);
			this.cmdGetSector.Name = "cmdGetSector";
			this.cmdGetSector.Size = new System.Drawing.Size (104, 23);
			this.cmdGetSector.TabIndex = 27;
			this.cmdGetSector.Text = "Get &Track/Sector";
			this.cmdGetSector.Click += new System.EventHandler (this.cmdGetSector_Click);
			// 
			// txtGranule
			// 
			this.txtGranule.Location = new System.Drawing.Point (328, 11);
			this.txtGranule.MaxLength = 3;
			this.txtGranule.Name = "txtGranule";
			this.txtGranule.Size = new System.Drawing.Size (32, 20);
			this.txtGranule.TabIndex = 26;
			// 
			// txtSector
			// 
			this.txtSector.Location = new System.Drawing.Point (136, 11);
			this.txtSector.MaxLength = 3;
			this.txtSector.Name = "txtSector";
			this.txtSector.Size = new System.Drawing.Size (32, 20);
			this.txtSector.TabIndex = 25;
			// 
			// txtTrack
			// 
			this.txtTrack.Location = new System.Drawing.Point (56, 11);
			this.txtTrack.MaxLength = 3;
			this.txtTrack.Name = "txtTrack";
			this.txtTrack.Size = new System.Drawing.Size (32, 20);
			this.txtTrack.TabIndex = 24;
			// 
			// txtData
			// 
			this.txtData.BackColor = System.Drawing.Color.White;
			this.txtData.Font = new System.Drawing.Font ("Courier New", 8F);
			this.txtData.Location = new System.Drawing.Point (8, 40);
			this.txtData.Multiline = true;
			this.txtData.Name = "txtData";
			this.txtData.ReadOnly = true;
			this.txtData.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
			this.txtData.Size = new System.Drawing.Size (480, 376);
			this.txtData.TabIndex = 23;
			// 
			// menuStrip1
			// 
			this.menuStrip1.Items.AddRange (new System.Windows.Forms.ToolStripItem [] {
            this.fileToolStripMenuItem,
            this.optionsToolStripMenuItem});
			this.menuStrip1.Location = new System.Drawing.Point (0, 0);
			this.menuStrip1.Name = "menuStrip1";
			this.menuStrip1.Size = new System.Drawing.Size (654, 24);
			this.menuStrip1.TabIndex = 15;
			this.menuStrip1.Text = "menuStrip1";
			// 
			// fileToolStripMenuItem
			// 
			this.fileToolStripMenuItem.DropDownItems.AddRange (new System.Windows.Forms.ToolStripItem [] {
            this.openDiskToolStripMenuItem,
            this.exitToolStripMenuItem});
			this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
			this.fileToolStripMenuItem.Size = new System.Drawing.Size (35, 20);
			this.fileToolStripMenuItem.Text = "&File";
			// 
			// openDiskToolStripMenuItem
			// 
			this.openDiskToolStripMenuItem.Name = "openDiskToolStripMenuItem";
			this.openDiskToolStripMenuItem.Size = new System.Drawing.Size (122, 22);
			this.openDiskToolStripMenuItem.Text = "&Open Disk";
			this.openDiskToolStripMenuItem.Click += new System.EventHandler (this.openDiskToolStripMenuItem_Click);
			// 
			// exitToolStripMenuItem
			// 
			this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
			this.exitToolStripMenuItem.Size = new System.Drawing.Size (122, 22);
			this.exitToolStripMenuItem.Text = "E&xit";
			this.exitToolStripMenuItem.Click += new System.EventHandler (this.exitToolStripMenuItem_Click);
			// 
			// optionsToolStripMenuItem
			// 
			this.optionsToolStripMenuItem.DropDownItems.AddRange (new System.Windows.Forms.ToolStripItem [] {
            this.settingsToolStripMenuItem});
			this.optionsToolStripMenuItem.Name = "optionsToolStripMenuItem";
			this.optionsToolStripMenuItem.Size = new System.Drawing.Size (56, 20);
			this.optionsToolStripMenuItem.Text = "O&ptions";
			// 
			// settingsToolStripMenuItem
			// 
			this.settingsToolStripMenuItem.Name = "settingsToolStripMenuItem";
			this.settingsToolStripMenuItem.Size = new System.Drawing.Size (113, 22);
			this.settingsToolStripMenuItem.Text = "&Settings";
			this.settingsToolStripMenuItem.Click += new System.EventHandler (this.settingsToolStripMenuItem_Click);
			// 
			// cmdSend
			// 
			this.cmdSend.Location = new System.Drawing.Point (554, 369);
			this.cmdSend.Name = "cmdSend";
			this.cmdSend.Size = new System.Drawing.Size (75, 23);
			this.cmdSend.TabIndex = 4;
			this.cmdSend.Text = "Sen&d";
			this.cmdSend.UseVisualStyleBackColor = true;
			this.cmdSend.Click += new System.EventHandler (this.cmdSend_Click);
			// 
			// cmdView
			// 
			this.cmdView.Location = new System.Drawing.Point (473, 369);
			this.cmdView.Name = "cmdView";
			this.cmdView.Size = new System.Drawing.Size (75, 23);
			this.cmdView.TabIndex = 5;
			this.cmdView.Text = "&View";
			this.cmdView.UseVisualStyleBackColor = true;
			this.cmdView.Click += new System.EventHandler (this.cmdView_Click);
			// 
			// pbProgress
			// 
			this.pbProgress.Location = new System.Drawing.Point (208, 398);
			this.pbProgress.Name = "pbProgress";
			this.pbProgress.Size = new System.Drawing.Size (422, 23);
			this.pbProgress.Step = 100;
			this.pbProgress.TabIndex = 6;
			// 
			// cmdSave
			// 
			this.cmdSave.Location = new System.Drawing.Point (392, 369);
			this.cmdSave.Name = "cmdSave";
			this.cmdSave.Size = new System.Drawing.Size (75, 23);
			this.cmdSave.TabIndex = 7;
			this.cmdSave.Text = "&Save";
			this.cmdSave.UseVisualStyleBackColor = true;
			this.cmdSave.Click += new System.EventHandler (this.cmdSave_Click);
			// 
			// dlgSaveFile
			// 
			this.dlgSaveFile.Filter = "Basic (*.bas)|*.bas|Assembly (*.bin)|*.bin|All files (*.*)|*.*";
			this.dlgSaveFile.FileOk += new System.ComponentModel.CancelEventHandler (this.dlgSaveFile_FileOk);
			// 
			// frmMain
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size (5, 13);
			this.ClientSize = new System.Drawing.Size (654, 517);
			this.Controls.Add (this.tabMain);
			this.Controls.Add (this.menuStrip1);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
			this.MainMenuStrip = this.menuStrip1;
			this.MaximizeBox = false;
			this.Name = "frmMain";
			this.Text = "CoCo3 Virtual Disk Viewer";
			this.tabMain.ResumeLayout (false);
			this.tabPage1.ResumeLayout (false);
			this.tabPage2.ResumeLayout (false);
			this.tabPage2.PerformLayout ();
			this.tabPage3.ResumeLayout (false);
			this.tabPage3.PerformLayout ();
			this.menuStrip1.ResumeLayout (false);
			this.menuStrip1.PerformLayout ();
			this.ResumeLayout (false);
			this.PerformLayout ();

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run (new frmMain());
		}

		/// <summary>
		/// Returns the selected file.
		/// </summary>
		public SimpleFile SelectedFile { get; private set; }

		/// <summary>
		/// Handles file selection option from open file dialog window
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void dlgOpenFile_FileOk (object sender, CancelEventArgs e)
		{
			if (null == (m_dskInfo = SimpleDisk.CreateInstance (dlgOpenFile.FileName)))
			{
				lblInfo.Text = "Image is not a valid CoCo disk!";
				return;
			}

			tabMain.Enabled = true;

			lblInfo.Text = String.Format (@"       Tracks: {0}
 Track Length: {1} bytes
     Granules: {2}
Free Granules: {3}
   Free Space: {4} bytes
   Used Space: {5} bytes
        Files: {6}",
				m_dskInfo.Tracks,
				m_dskInfo.TrackLength,
				m_dskInfo.Granules.Length,
				m_dskInfo.FreeGranules,
				m_dskInfo.FreeGranules * 2304,
				(68 - m_dskInfo.FreeGranules) * 2304,
				m_dskInfo.Files.Count);

			lstFiles.Nodes.Clear ();
			foreach (DirectoryEntry de in m_dskInfo.Directory)
			{
				TreeNode file = new TreeNode (de.Name);
				file.Nodes.Add (String.Format ("Type: {0}", de.FileType));

				SimpleFile sf = de.GetFile ();
				switch (de.FileType)
				{
					case FileTypes.Assembly:
						AssemblyFile af = (AssemblyFile) sf;
						file.Nodes.Add (String.Format ("Length: {0}", af.BlockLength));
						file.Nodes.Add (String.Format ("Load Addr: {0}", af.LoadAddress));
						file.Nodes.Add (String.Format ("Exec Addr: {0}", af.ExecAddress));
						break;
					default:
						break;
				}

				//file.Nodes.Add (String.Format ("Length: {0}", de.Length));
				//file.Nodes.Add (String.Format ("Granule: {0}", de.Granule));
				lstFiles.Nodes.Add (file);
			}
		}

		/// <summary>
		/// Handles the save dialog event
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void dlgSaveFile_FileOk (object sender, CancelEventArgs e)
		{
			SelectedFile.Save (dlgSaveFile.FileName);
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void cmdBrowse_Click(object sender, EventArgs args)
		{
			dlgOpenFile.ShowDialog ();
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="args"></param>
		private void cmdGetSector_Click(object sender, EventArgs args)
		{
			int		track		= -1;
			int		sector		= -1;
			byte []	data		= null;

			if (null == m_dskInfo)
				return;

			txtData.Text = "";

			try
			{
				track		= Convert.ToInt32 (txtTrack.Text);
				sector		= Convert.ToInt32 (txtSector.Text);

				if (null == (data = m_dskInfo.Read (track, sector)))
					return;

				txtData.Text = Utility.FormatBuffer (data);
			}
			catch (Exception e)
			{
				txtData.Text = e.ToString ();
				return;
			}
		}

		/// <summary>
		/// Event handler for double click event on file name in tree view control.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void lstFiles_DoubleClick (object sender, System.EventArgs e)
		{
			string			name		= null;

			name = lstFiles.SelectedNode.Text;

			if (null == (SelectedFile = m_dskInfo.GetFile (name)))
				return;

			txtFileData.Text = SelectedFile.ToString ();
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="args"></param>
		private void cmdGetGranule_Click(object sender, EventArgs args)
		{
			int		granule		= -1;
			byte []	data		= null;

			if (null == m_dskInfo)
				return;

			txtData.Text = "";

			try
			{
				granule		= Convert.ToInt32 (txtGranule.Text);

				if (null == (data = m_dskInfo.Read (granule)))
					return;

				txtData.Text = Utility.FormatBuffer (data);
			}
			catch (Exception e)
			{
				txtData.Text = e.ToString ();
				return;
			}
		}

		#region state management

		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		private string GetPath ()
		{
			return Path.Combine (
				Path.GetDirectoryName (Application.ExecutablePath),
				"settings.xml");
		}


		/// <summary>
		/// Loads the last saved state
		/// </summary>
		private void LoadState ()
		{
			if (null == m_settings)
				return;

			//dlgOpenFile.FileName = m_settings ["filename"];
			txtTrack.Text		 = m_settings ["track"];
			txtSector.Text		 = m_settings ["sector"];
			txtGranule.Text		 = m_settings ["granule"];
		}


		/// <summary>
		/// Saves the last saved state
		/// </summary>
		private void SaveState ()
		{
			if (null == m_settings)
				return;

			m_settings ["filename"] = dlgOpenFile.FileName;
			m_settings ["track"]	= txtTrack.Text;
			m_settings ["sector"]	= txtSector.Text;
			m_settings ["granule"]	= txtGranule.Text;

			Settings.Save (GetPath (), m_settings);
		}

		#endregion

		/// <summary>
		/// Opens the file dialog window to allow the user to browse for a disk image.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void openDiskToolStripMenuItem_Click (object sender, EventArgs e)
		{
			dlgOpenFile.ShowDialog ();
		}

		/// <summary>
		/// Exits the application
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void exitToolStripMenuItem_Click (object sender, EventArgs e)
		{
			Application.Exit ();
		}

		/// <summary>
		/// Opens the settings window.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void settingsToolStripMenuItem_Click (object sender, EventArgs e)
		{
			frmSettings s = new frmSettings ();
			s.Settings = m_settings;

			s.Show (this);
		}

		/// <summary>
		/// Sends the selected file over the COMM port.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void cmdSend_Click (object sender, EventArgs e)
		{
			if (null == SelectedFile)
				return;

			pbProgress.Step = 100;
			pbProgress.Value = 0;

			int stepSize = (int) (SelectedFile.Data.Length / 100.0);
			string portName = m_settings ["commport"];
			int baudRate = int.Parse (m_settings ["baudrate"]);

			using (SerialPort sp = new SerialPort (portName, baudRate, Parity.None, 8, StopBits.One))
			{
				//sp.Parity = (Parity) Enum.Parse (typeof (Parity), m_settings ["parity"]);
				//sp.DataBits = int.Parse (m_settings ["databits"]);
				//sp.StopBits = (StopBits) Enum.Parse (typeof (StopBits), m_settings ["stopbits"]);

				try
				{
					sp.Open ();
					for (int i = 0; i < SelectedFile.SerialData.Length; i++)
					{
						sp.Write (SelectedFile.SerialData, i, 1);

						if (i > 0 && i % stepSize == 0)
							pbProgress.PerformStep ();
					}
				}
				catch
				{
					MessageBox.Show ("Error sending data.", "Send Error");
				}
			}

			pbProgress.Value = 0;
		}

		/// <summary>
		/// Views the selected files details.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void cmdView_Click (object sender, EventArgs e)
		{

		}

		/// <summary>
		/// Saves the file to the specified location
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void cmdSave_Click (object sender, EventArgs e)
		{
			if (null == SelectedFile)
				return;

			dlgSaveFile.FileName = SelectedFile.Name;
			dlgSaveFile.DefaultExt = Path.GetExtension (SelectedFile.Name);

			dlgSaveFile.ShowDialog ();
		}
	}
}
