using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CoCoDisk
{
	public class TextFile : SimpleFile
	{
		private string _toString;

		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		public override string ToString ()
		{
			if (null == _toString)
			{
				_toString = Encoding.ASCII.GetString (Data);
				_toString = _toString.Replace ("\r", "\r\n").Replace (" \t", "\t\t");
			}

			return _toString;
		}
	}
}
