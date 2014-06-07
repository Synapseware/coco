using System;
using System.Collections;
using System.Text;

namespace CoCoDisk
{
	/// <summary>
	/// Summary description for Utility.
	/// </summary>
	public class Utility
	{
		/// <summary>
		/// 
		/// </summary>
		/// <param name="data"></param>
		/// <returns></returns>
		public static string FormatBuffer (byte [] data)
		{
			StringBuilder sb = null;

			if (null == data || 0 == data.Length)
				return null;

			sb = new StringBuilder (data.Length * 4);

			for (int i = 0; i < data.Length; i++)
			{
				if (0 != i && i % 16 == 0)
					sb.Append ("\r\n");

				if (0 != i && i % 256 == 0)
					sb.Append ("\r\n");

				sb.AppendFormat ("{0} ", data [i].ToString ("X2"));

				if (((i + 1) % 8 == 0) && ((i + 1) % 16) == 8)
					sb.Append ("   ");
			}

			return sb.ToString ();
		}
	}
}
