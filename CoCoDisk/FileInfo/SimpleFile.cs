using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace CoCoDisk
{
	/// <summary>
	/// 
	/// </summary>
	public enum FileTypes
	{
		Basic		= 0,
		Data		= 1,
		Assembly	= 2,
		Text		= 3
	}

	/// <summary>
	/// Summary description for SimpleFile.
	/// </summary>
	public abstract class SimpleFile
	{
		/// <summary>
		/// 
		/// </summary>
		/// <param name="entry"></param>
		/// <returns></returns>
		public static SimpleFile CreateInstance (DirectoryEntry entry)
		{
			SimpleFile file = null;

			switch (entry.FileType)
			{
				case FileTypes.Basic:
					file = new BasicFile ();
					break;
				case FileTypes.Data:
					throw new Exception("Unsupported file type: Data");
					break;
				case FileTypes.Text:
					file = new TextFile ();
					break;
				case FileTypes.Assembly:
					file = new AssemblyFile ();
					break;
			}

			if (null == file)
				return null;

			file.Disk = entry.Disk;
			file.Name = entry.Name;
			file.Granule = entry.StartGranule;
			file.LastSectorLength = entry.LastSectorLength;

			return file;
		}

		public virtual void Save (string filename)
		{
			Save (Data, filename);
		}

		/// <summary>
		/// Internal method to actually save the file.
		/// </summary>
		/// <param name="buff"></param>
		/// <param name="filename"></param>
		protected virtual void Save (byte [] buff, string filename)
		{
			if (File.Exists (filename))
				File.Delete (filename);

			using (FileStream f_out = File.Create (filename, buff.Length, FileOptions.None))
			{
				f_out.Write (buff, 0, buff.Length);
				f_out.Flush ();
			}
		}

		/// <summary>
		/// Loads the buff for the file.
		/// </summary>
		/// <returns></returns>
		protected virtual byte [] GetRawData ()
		{
			List<byte[]> chunks		= null;
			byte []		buff		= null;
			byte []		tmp			= null;
			int			granule		= 0;
			int			track		= 0;
			int			sector		= 0;
			int			length		= 0;
			int			index		= 0;

			if (Granule > 0x43)
				return null;

			// create list to hold pieces of file buff
			chunks = new List<byte []> ();

			// get the granule table
			if (null == Disk.Granules)
				return null;

			/* Granule entries:
			 * 0xFF			= Free
			 * 0x00 - 0x43	= Next granule pointer
			 * 0xC0 - 0xC9	= Last granule in file chain, tells how many sectors are used
			 * 
			 * 2B		->		2C
			 * 2C		->		C3
			*/

			// read file buff
			for (int i = 0; i < GranuleMap.Length; i++)
			{
				// get the start granule for this file
				granule = GranuleMap [i];

				// get the track number for this granule
				Disk.MapGranuleToTrackSector (granule, out track, out sector);

				// set the sector limit to 9
				int sectorLimit = (granule != LastGranule ? 9 : LastGranuleSectors);

				// read the data from each sector for this granule
				for (int s = 0; s < sectorLimit; s++)
				{
					// read the entire sector data
					buff = Disk.Read (track, sector + s);

					// test for last sector
					if (granule == LastGranule && s == sectorLimit - 1)
					{
						// last sector of last granule - only copy LastSectorSize bytes.
						tmp = new byte [LastSectorLength];
						Array.Copy (buff, tmp, LastSectorLength);

						chunks.Add (tmp);
						length += tmp.Length;
					}
					else
					{
						// add the sector data to the list
						chunks.Add (buff);
						length += buff.Length;
					}
				}
			}

			// create a buffer to hold all the data for the return call
			buff = new byte [length];
			index = 0;
			foreach (byte [] chunk in chunks)
			{
				chunk.CopyTo (buff, index);
				index += chunk.Length;
			}

			return buff;
		}

		#region properties

		/// <summary>
		/// Returns a reference to the disk object that this file is in.
		/// </summary>
		public virtual SimpleDisk Disk { get; protected set; }

		/// <summary>
		/// Returns the filename including extension.
		/// </summary>
		public virtual string Name { get; protected set; }

		/// <summary>
		/// Returns the length of the file.
		/// </summary>
		public virtual int Size
		{
			get
			{
				if (null == Data)
					return -1;

				return Data.Length;
			}
		}

		/// <summary>
		/// Returns the binary buff for the file.
		/// </summary>
		private byte [] _data;
		public virtual byte [] Data
		{
			get
			{
				if (null == _data)
				{
					_data = GetRawData ();
				}

				return _data;
			}
		}

		public virtual byte [] SerialData
		{
			get
			{
				return Data;
			}
		}

		/// <summary>
		/// Gets or sets the GAT table index for this directory entry.
		/// </summary>
		public virtual int Index { get; protected set; }

		#endregion

		/// <summary>
		/// Gets or sets the number of sectors in use by the last granule
		/// </summary>
		protected virtual int LastGranuleSectors { get; set; }

		/// <summary>
		/// Gets or sets the number of bytes used by the last sector
		/// </summary>
		protected virtual int LastSectorLength { get; set; }

		/// <summary>
		/// Gets or sets the number of the last granule.
		/// </summary>
		protected virtual int LastGranule
		{
			get
			{ return GranuleMap [GranuleMap.Length - 1]; }
		}

		/// <summary>
		/// Returns the start granule for the file.
		/// </summary>
		protected virtual byte Granule { get; set; }

		/// <summary>
		/// Returns the files Granule Allocation Map, or GAT
		/// </summary>
		private byte [] _granuleMap;
		protected virtual byte [] GranuleMap
		{
			get
			{
				if (null == _granuleMap)
				{
					List<byte> granules = null;
					byte granule = Granule;

					if (null == Disk || 0 == Disk.Size)
						return null;

					if (null == Disk.Granules || 0 == Disk.Granules.Length)
						return null;

					granules = new List<byte> ();

					while (granule <= 0x43)
					{
						granules.Add (granule);

						granule = Disk.Granules [granule];

						if (granule >= 0xC0 && granule <= 0xC9)
						{
							this.LastGranuleSectors = granule & 0x1f;
							break;
						}
					}

					_granuleMap = granules.ToArray ();
				}

				return _granuleMap;
			}
		}
	}
}
