using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.IO;
using System.Windows.Forms;
using System.Data;

namespace Dasm6809
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
		private System.Windows.Forms.OpenFileDialog openFileDialog1;
		private System.Windows.Forms.TextBox txtFilename;
		private System.Windows.Forms.Button cmdBrowse;
		private System.Windows.Forms.Button cmdAnalyze;
		private System.Windows.Forms.TextBox txtData;
		private System.Windows.Forms.Button cmdSave;
		private System.Windows.Forms.SaveFileDialog saveFileDialog1;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
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
			this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
			this.txtFilename = new System.Windows.Forms.TextBox();
			this.cmdBrowse = new System.Windows.Forms.Button();
			this.cmdAnalyze = new System.Windows.Forms.Button();
			this.txtData = new System.Windows.Forms.TextBox();
			this.cmdSave = new System.Windows.Forms.Button();
			this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
			this.SuspendLayout();
			// 
			// openFileDialog1
			// 
			this.openFileDialog1.FileOk += new System.ComponentModel.CancelEventHandler(this.openFileDialog1_FileOk);
			// 
			// txtFilename
			// 
			this.txtFilename.Location = new System.Drawing.Point(8, 8);
			this.txtFilename.Name = "txtFilename";
			this.txtFilename.Size = new System.Drawing.Size(240, 20);
			this.txtFilename.TabIndex = 0;
			this.txtFilename.Text = "C:\\coco3\\program.hex";
			// 
			// cmdBrowse
			// 
			this.cmdBrowse.Location = new System.Drawing.Point(256, 8);
			this.cmdBrowse.Name = "cmdBrowse";
			this.cmdBrowse.TabIndex = 1;
			this.cmdBrowse.Text = "&Browse";
			this.cmdBrowse.Click += new System.EventHandler(this.cmdBrowse_Click);
			// 
			// cmdAnalyze
			// 
			this.cmdAnalyze.Location = new System.Drawing.Point(336, 8);
			this.cmdAnalyze.Name = "cmdAnalyze";
			this.cmdAnalyze.TabIndex = 2;
			this.cmdAnalyze.Text = "&Analyze";
			this.cmdAnalyze.Click += new System.EventHandler(this.cmdAnalyze_Click);
			// 
			// txtData
			// 
			this.txtData.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((System.Byte)(0)));
			this.txtData.Location = new System.Drawing.Point(16, 48);
			this.txtData.Multiline = true;
			this.txtData.Name = "txtData";
			this.txtData.ReadOnly = true;
			this.txtData.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
			this.txtData.Size = new System.Drawing.Size(512, 448);
			this.txtData.TabIndex = 3;
			this.txtData.Text = "";
			// 
			// cmdSave
			// 
			this.cmdSave.Location = new System.Drawing.Point(416, 8);
			this.cmdSave.Name = "cmdSave";
			this.cmdSave.TabIndex = 4;
			this.cmdSave.Text = "&Save";
			this.cmdSave.Click += new System.EventHandler(this.cmdSave_Click);
			// 
			// saveFileDialog1
			// 
			this.saveFileDialog1.FileOk += new System.ComponentModel.CancelEventHandler(this.saveFileDialog1_FileOk);
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(544, 510);
			this.Controls.Add(this.cmdSave);
			this.Controls.Add(this.txtData);
			this.Controls.Add(this.cmdAnalyze);
			this.Controls.Add(this.cmdBrowse);
			this.Controls.Add(this.txtFilename);
			this.MaximizeBox = false;
			this.Name = "Form1";
			this.Text = "6809 Dissassembler";
			this.ResumeLayout(false);

		}
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new Form1());
		}

		private void cmdBrowse_Click(object sender, System.EventArgs e)
		{
			openFileDialog1.ShowDialog ();
		}

		private void openFileDialog1_FileOk(object sender, System.ComponentModel.CancelEventArgs e)
		{
			txtFilename.Text = openFileDialog1.FileName;
		}

		private void cmdAnalyze_Click(object sender, System.EventArgs e)
		{
			ISimpleFile handler = SimpleFile.CreateInstance (txtFilename.Text);
			if (null == handler)
			{
				txtData.Text = "Unknown file type.";
				return;
			}

			handler.Initialize (txtFilename.Text);

			txtData.Text = handler.ToString ();
		}

		private void cmdSave_Click(object sender, System.EventArgs e)
		{
			saveFileDialog1.ShowDialog ();
		}

		private void saveFileDialog1_FileOk(object sender, System.ComponentModel.CancelEventArgs args)
		{
			StreamWriter	f_out		= null;

			try
			{
				f_out	= File.CreateText (saveFileDialog1.FileName);

				f_out.Write (txtData.Text);

			}
			catch (Exception e)
			{

			}
			finally
			{
				if (null != f_out)
				{
					f_out.Flush ();
					f_out.Close ();
				}
			}
		}
	}
}
