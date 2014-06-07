namespace CoCoDisk
{
	partial class frmSettings
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose (bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose ();
			}
			base.Dispose (disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent ()
		{
			this.label1 = new System.Windows.Forms.Label ();
			this.label2 = new System.Windows.Forms.Label ();
			this.label3 = new System.Windows.Forms.Label ();
			this.label4 = new System.Windows.Forms.Label ();
			this.label5 = new System.Windows.Forms.Label ();
			this.cmbxPort = new System.Windows.Forms.ComboBox ();
			this.cmbxBaud = new System.Windows.Forms.ComboBox ();
			this.cmbxDataBits = new System.Windows.Forms.ComboBox ();
			this.cmbxStopBits = new System.Windows.Forms.ComboBox ();
			this.cmbxParity = new System.Windows.Forms.ComboBox ();
			this.cmdOK = new System.Windows.Forms.Button ();
			this.cmdCancel = new System.Windows.Forms.Button ();
			this.pnlCommSettings = new System.Windows.Forms.Panel ();
			this.pnlCommSettings.SuspendLayout ();
			this.SuspendLayout ();
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point (17, 11);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size (56, 13);
			this.label1.TabIndex = 0;
			this.label1.Text = "COM Port:";
			this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Location = new System.Drawing.Point (11, 41);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size (66, 13);
			this.label2.TabIndex = 1;
			this.label2.Text = "BAUD Rate:";
			this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// label3
			// 
			this.label3.AutoSize = true;
			this.label3.Location = new System.Drawing.Point (25, 102);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size (52, 13);
			this.label3.TabIndex = 2;
			this.label3.Text = "Stop Bits:";
			this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// label4
			// 
			this.label4.AutoSize = true;
			this.label4.Location = new System.Drawing.Point (37, 129);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size (36, 13);
			this.label4.TabIndex = 3;
			this.label4.Text = "Parity:";
			this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// label5
			// 
			this.label5.AutoSize = true;
			this.label5.Location = new System.Drawing.Point (24, 76);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size (53, 13);
			this.label5.TabIndex = 4;
			this.label5.Text = "Data Bits:";
			this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
			// 
			// cmbxPort
			// 
			this.cmbxPort.FormattingEnabled = true;
			this.cmbxPort.Location = new System.Drawing.Point (83, 8);
			this.cmbxPort.MaxLength = 10;
			this.cmbxPort.Name = "cmbxPort";
			this.cmbxPort.Size = new System.Drawing.Size (121, 21);
			this.cmbxPort.TabIndex = 5;
			// 
			// cmbxBaud
			// 
			this.cmbxBaud.FormattingEnabled = true;
			this.cmbxBaud.Items.AddRange (new object [] {
            "19200",
            "9600",
            "4800",
            "1200"});
			this.cmbxBaud.Location = new System.Drawing.Point (83, 38);
			this.cmbxBaud.Name = "cmbxBaud";
			this.cmbxBaud.Size = new System.Drawing.Size (121, 21);
			this.cmbxBaud.TabIndex = 6;
			this.cmbxBaud.Text = "9600";
			// 
			// cmbxDataBits
			// 
			this.cmbxDataBits.FormattingEnabled = true;
			this.cmbxDataBits.Items.AddRange (new object [] {
            "8",
            "7",
            "6",
            "5"});
			this.cmbxDataBits.Location = new System.Drawing.Point (83, 68);
			this.cmbxDataBits.MaxLength = 1;
			this.cmbxDataBits.Name = "cmbxDataBits";
			this.cmbxDataBits.Size = new System.Drawing.Size (121, 21);
			this.cmbxDataBits.TabIndex = 7;
			this.cmbxDataBits.Text = "8";
			// 
			// cmbxStopBits
			// 
			this.cmbxStopBits.FormattingEnabled = true;
			this.cmbxStopBits.Items.AddRange (new object [] {
            "None",
            "1",
            "1.5",
            "2"});
			this.cmbxStopBits.Location = new System.Drawing.Point (83, 99);
			this.cmbxStopBits.MaxLength = 3;
			this.cmbxStopBits.Name = "cmbxStopBits";
			this.cmbxStopBits.Size = new System.Drawing.Size (121, 21);
			this.cmbxStopBits.TabIndex = 8;
			this.cmbxStopBits.Text = "1";
			// 
			// cmbxParity
			// 
			this.cmbxParity.FormattingEnabled = true;
			this.cmbxParity.Items.AddRange (new object [] {
            "None",
            "Even",
            "Odd"});
			this.cmbxParity.Location = new System.Drawing.Point (83, 126);
			this.cmbxParity.Name = "cmbxParity";
			this.cmbxParity.Size = new System.Drawing.Size (121, 21);
			this.cmbxParity.TabIndex = 9;
			this.cmbxParity.Text = "None";
			// 
			// cmdOK
			// 
			this.cmdOK.Location = new System.Drawing.Point (98, 264);
			this.cmdOK.Name = "cmdOK";
			this.cmdOK.Size = new System.Drawing.Size (75, 23);
			this.cmdOK.TabIndex = 10;
			this.cmdOK.Text = "&OK";
			this.cmdOK.UseVisualStyleBackColor = true;
			this.cmdOK.Click += new System.EventHandler (this.cmdOK_Click);
			// 
			// cmdCancel
			// 
			this.cmdCancel.Location = new System.Drawing.Point (179, 264);
			this.cmdCancel.Name = "cmdCancel";
			this.cmdCancel.Size = new System.Drawing.Size (75, 23);
			this.cmdCancel.TabIndex = 11;
			this.cmdCancel.Text = "&Cancel";
			this.cmdCancel.UseVisualStyleBackColor = true;
			this.cmdCancel.Click += new System.EventHandler (this.cmdCancel_Click);
			// 
			// pnlCommSettings
			// 
			this.pnlCommSettings.Controls.Add (this.label1);
			this.pnlCommSettings.Controls.Add (this.cmbxParity);
			this.pnlCommSettings.Controls.Add (this.label2);
			this.pnlCommSettings.Controls.Add (this.cmbxStopBits);
			this.pnlCommSettings.Controls.Add (this.label3);
			this.pnlCommSettings.Controls.Add (this.cmbxDataBits);
			this.pnlCommSettings.Controls.Add (this.label4);
			this.pnlCommSettings.Controls.Add (this.cmbxBaud);
			this.pnlCommSettings.Controls.Add (this.label5);
			this.pnlCommSettings.Controls.Add (this.cmbxPort);
			this.pnlCommSettings.Location = new System.Drawing.Point (12, 12);
			this.pnlCommSettings.Name = "pnlCommSettings";
			this.pnlCommSettings.Size = new System.Drawing.Size (242, 246);
			this.pnlCommSettings.TabIndex = 12;
			// 
			// frmSettings
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF (6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size (266, 305);
			this.Controls.Add (this.cmdCancel);
			this.Controls.Add (this.cmdOK);
			this.Controls.Add (this.pnlCommSettings);
			this.MaximizeBox = false;
			this.MinimizeBox = false;
			this.Name = "frmSettings";
			this.Text = "Settings";
			this.Shown += new System.EventHandler (this.frmSettings_Shown);
			this.pnlCommSettings.ResumeLayout (false);
			this.pnlCommSettings.PerformLayout ();
			this.ResumeLayout (false);

		}

		#endregion

		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.Label label5;
		private System.Windows.Forms.ComboBox cmbxPort;
		private System.Windows.Forms.ComboBox cmbxBaud;
		private System.Windows.Forms.ComboBox cmbxDataBits;
		private System.Windows.Forms.ComboBox cmbxStopBits;
		private System.Windows.Forms.ComboBox cmbxParity;
		private System.Windows.Forms.Button cmdOK;
		private System.Windows.Forms.Button cmdCancel;
		private System.Windows.Forms.Panel pnlCommSettings;
	}
}