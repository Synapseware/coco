using System;
using System.Collections.Generic;
using System.Text;

namespace CoCoDisk
{
	/// <summary>
	/// Represents a single directory entry for a file.
	/// </summary>
	public class DirectoryEntry
	{
		/// <summary>
		/// Private constructor
		/// </summary>
		/// <param name="disk"></param>
		private DirectoryEntry (SimpleDisk disk)
		{
			Disk = disk;
		}

		/// <summary>
		/// Creates an instance of DirectoryEntry object using binary data from the sector
		/// </summary>
		/// <param name="disk"></param>
		/// <param name="entry"></param>
		/// <returns></returns>
		public static DirectoryEntry CreateInstance (SimpleDisk disk, byte [] entry)
		{
			/*
			entry contains specific information (bytes listed):
				0 - 7	= file name
				8 - 10	= file extension
				11		= file type
				12		= ascii/binary flag (0 = bin, 255 = asc)
				13		= first granule number
				14 - 15	= number of bytes in last granule
				16 - 31 = reserved
			*/

			// quit for bad data
			if (null == entry || 32 != entry.Length)
				return null;

			// check for unused entry name - if bit 7 is set, then
			// entry is not in use.
			if ((0x80 & entry [0]) == 0x80)
				return null;

			DirectoryEntry	di	= new DirectoryEntry (disk);

			string	name	= Encoding.ASCII.GetString (entry, 0, 8);
			string	ext		= Encoding.ASCII.GetString (entry, 8, 3);

			// create file handler for specified type
			di.Name = String.Format ("{0}.{1}", name.Trim (), ext.Trim ());
			di.FileType = (FileTypes) entry [11];
			di.StartGranule = entry [13];
			di.LastSectorLength = ((int) entry [14]) * 256 + (int) entry [15];

			return di;
		}

		/// <summary>
		/// Returns the file object for this directory entry.
		/// </summary>
		/// <returns></returns>
		public SimpleFile GetFile ()
		{
			return SimpleFile.CreateInstance (this);
		}

		public virtual SimpleDisk Disk { get; protected set; }

		public virtual FileTypes FileType { get; protected set; }

		public virtual string Name { get; protected set; }

		public virtual byte StartGranule { get; protected set; }

		public virtual int LastSectorLength { get; protected set; }
	}
}
