using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.IO.Ports;

namespace CoCoDisk.Comm
{
	public class CoCoComm
	{
		private SerialPort _comm;

		/// <summary>
		/// 
		/// </summary>
		public CoCoComm (string portName, int baudRate)
		{
			_comm = new SerialPort (portName, baudRate, Parity.None, 8, StopBits.One);
		}

		/// <summary>
		/// Writes the byte array to COM port.
		/// </summary>
		/// <param name="buff"></param>
		/// <returns></returns>
		public bool SendData (byte [] buff)
		{
			try
			{
				_comm.Open ();
				_comm.Write (buff, 0, buff.Length);
				_comm.Close ();

				return true;
			}
			catch (Exception)
			{
				return false;
			}
		}

		public byte [] GetData ()
		{
			return null;
		}
	}
}
