using System;
using System.Collections.Generic;
using System.Text;

namespace CoCoDisk
{
	/// <summary>
	/// FATEntry
	/// 
	/// Represents the FAT table disk bytes, which includes the granule map.
	/// </summary>
	public class FATEntry
	{
		private byte [] _gatBytes;

		/// <summary>
		/// 
		/// </summary>
		/// <param name="buff"></param>
		public FATEntry (byte [] buff)
		{
			if (null == buff || buff.Length < 256)
				return;

			// copy the GAT bytes with validation
			_gatBytes = new byte [68];
			for (int i = 0; i < 68; i++)
			{
				byte gat = buff [i];
				if ((gat > 0x43 && gat < 0xC0) || (gat > 0xC9 && gat != 0xFF))
					throw new Exception ("Granule Table is not valid!");

				_gatBytes [i] = gat;
			}
		}

		/// <summary>
		/// Returns the granule allocation table (GAT)
		/// </summary>
		public byte [] GranuleAllocationTable
		{
			get
			{ return _gatBytes; }
		}
	}
}
