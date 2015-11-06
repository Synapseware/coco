using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;

namespace CoCoDisk
{
	public partial class frmSettings : Form
	{
		/// <summary>
		/// Construstor
		/// </summary>
		public frmSettings ()
		{
			InitializeComponent ();

			// set the default button
			this.AcceptButton = cmdOK;

			// fill the COM port drop down
			string [] ports = SerialPort.GetPortNames ();
			if (ports.Length > 0)
			{
				foreach (string port in ports)
					cmbxPort.Items.Add (port);

				if (String.IsNullOrEmpty (COMPort))
					COMPort = ports [0];
			}
		}

		#region properties

		/// <summary>
		/// Gets or sets the configuration object.
		/// </summary>
		public Configuration.Settings Settings { get; set; }

		/// <summary>
		/// Gets or sets the COM port
		/// </summary>
		public string COMPort
		{
			get
			{ return cmbxPort.Text; }
			set
			{ cmbxPort.Text = value; }
		}

		/// <summary>
		/// Gets or sets the baud rate
		/// </summary>
		public string BAUDRate
		{
			get
			{ return cmbxBaud.Text; }
			set
			{ cmbxBaud.Text = value; }
		}

		/// <summary>
		/// Gets or sets the data bits
		/// </summary>
		public string DataBits
		{
			get
			{ return cmbxDataBits.Text; }
			set
			{ cmbxDataBits.Text = value; }
		}

		/// <summary>
		/// Gets or sets the stop bits.
		/// </summary>
		public string StopBits
		{
			get
			{ return cmbxStopBits.Text; }
			set
			{ cmbxStopBits.Text = value; }
		}

		/// <summary>
		/// Gets or sets the Partiy
		/// </summary>
		public string Parity
		{
			get
			{ return cmbxParity.Text; }
			set
			{ cmbxParity.Text = value; }
		}

		#endregion

		/// <summary>
		/// Saves the settings and closes the form.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void cmdOK_Click (object sender, EventArgs e)
		{
			if (null != Settings)
			{
				Settings ["commport"] = this.COMPort;
				Settings ["baudrate"] = this.BAUDRate;
				Settings ["databits"] = this.DataBits;
				Settings ["stopbits"] = this.StopBits;
				Settings ["parity"] = this.Parity;
			}

			Close ();
		}

		/// <summary>
		/// Close the form without saving.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void cmdCancel_Click (object sender, EventArgs e)
		{
			Close ();
		}

		/// <summary>
		/// Event handler for when the settings form is shown.
		/// </summary>
		/// <param name="sender"></param>
		/// <param name="e"></param>
		private void frmSettings_Shown (object sender, EventArgs e)
		{
			if (null == Settings)
				return;

			this.COMPort = Settings ["commport"];
			this.BAUDRate = Settings ["baudrate"];
			this.DataBits = Settings ["databits"];
			this.StopBits = Settings ["stopbits"];
			this.Parity = Settings ["parity"];
		}
	}
}
