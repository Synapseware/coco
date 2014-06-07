using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;

namespace CoCoDisk
{
	/// <summary>
	/// Basic disk class, provides generic functions.
	/// </summary>
	public abstract class SimpleDisk
	{
		/*
		Each track is composed of 18 sectors and each sector contains 256 bytes. The DOS treats 
		this raw data as 68 granules with each granule containing 9 sectors, 2 granules per 
		track. The one remaining track is used for the directory and the file allocation 
		table (FAT)
		*/
		/// <summary>
		/// Internal constructor.
		/// </summary>
		protected SimpleDisk ()
		{
			Granules			= null;		// 
			Tracks				= -1;
			TrackLength			= 0;		// 
			ReadOnly			= true;		// 
			IsDMKFormat			= false;	// 
			IsNativeFormat		= true;		// 
			SingleSidedOnly		= false;	// 
			SingleDensity		= true;		// 
			IgnoreDensity		= false;	// 
		}

		/// <summary>
		/// Initializes the simple disk with the given binary file
		/// </summary>
		/// <param name="path"></param>
		/// <returns></returns>
		virtual public bool Initialize (string path)
		{
			FileStream		f_in		= null;

			// quit for bad file
			if (!File.Exists (path))
				return false;

			try
			{
				f_in = File.OpenRead (path);

				RawData = new byte [f_in.Length];

				f_in.Read (RawData, 0, RawData.Length);

				Diskname = path;
			}
			finally
			{
				if (null != f_in)
					f_in.Close ();
			}

			return true;
		}

		/// <summary>
		/// Loads the disk image at the specified location and returns either a DMKDisk or RealDisk
		/// object.
		/// </summary>
		/// <param name="path"></param>
		/// <returns></returns>
		static public SimpleDisk CreateInstance (string path)
		{
			FileInfo		info		= null;
			SimpleDisk		dsk			= null;

			// quit if the file doesn't exist
			if (!File.Exists (path))
				return null;

			// get the file info
			info = new FileInfo (path);

			// figure out what type of image this is
			switch (info.Length)
			{
				case 224016:
					dsk = new DMKVirtualDisk ();
					break;
				case 161280:
				case 156672:
					dsk = new RawDisk ();
					break;
				default:
					break;
			}

			// unknown type, based on size alone
			if (null == dsk)
				return null;

			// initialize the disk object
			dsk.Initialize (path);
			return dsk;
		}

		/// <summary>
		/// Reads all the data in the specified granule.
		/// </summary>
		/// <param name="granule"></param>
		/// <returns></returns>
		public virtual byte [] Read (int granule)
		{
			int			track		= 0;
			int			sector		= 0;
			byte []		data		= null;
			byte []		sect		= null;

			// quit if we couldn't get track/sector for granule
			if (!MapGranuleToTrackSector (granule, out track, out sector))
				return null;

			data = new byte [2304];
			for (int i = 0; i < 9; i++)
			{
				if (null == (sect = Read (track, sector + i)))
					return null;

				for (int j = 0; j < sect.Length; j++)
					data [i * 256 + j] = sect [j];
			}

			return data;
		}

		/// <summary>
		/// Does actual sector read from the disk.  Translation of skip factor,
		/// disk image format and other parameters is accounted for.
		/// </summary>
		/// <param name="track"></param>
		/// <param name="sector"></param>
		/// <returns></returns>
		public abstract byte [] Read (int track, int sector);

		/// <summary>
		/// Computes track/sector for a given granule.  Returns start sector only.
		/// </summary>
		/// <param name="granule"></param>
		/// <returns></returns>
		virtual public bool MapGranuleToTrackSector (int granule, out int track, out int sector)
		{
			track	= -1;
			sector	= -1;

			// don't allow out-of-bounds granule numbers, or access to the FAT/directory entry
			// track (protect special track)
			if (granule < 0 || granule > 67 || granule == 17)
				return false;

			// compute granule track
			track = (int) granule / 2;

			if (track > 16)
				track++;

			// compute granule start sector
			// even granules = sectors 1-9
			// odd granules = sectors 10-18
			sector = 1;
			if (granule % 2 != 0)
				sector = 10;

			return true;
		}

		/// <summary>
		/// Gets the track for the specified granule
		/// </summary>
		/// <param name="granule"></param>
		/// <returns></returns>
		virtual protected int GetTrack (int granule)
		{
			int		track		= 0;

			// compute granule track
			track = (int) granule / 2;

			if (track > 16)
				track++;

			return track;
		}

		/// <summary>
		/// Converts a track and sector to an index position in the raw data.  This index
		/// points to the start of the sector and includes the 45 byte sector header.
		/// </summary>
		/// <param name="track">0 to x</param>
		/// <param name="logicalSector">1 to 18</param>
		/// <returns></returns>
		protected virtual int MapTrackSectorToIndex (int track, int logicalSector)
		{
			SectorList sectors = GetSectorList (track);
			SectorEntry sector = sectors.Find (s => s.LogicalNumber == logicalSector);

			return sector.SectorStart;
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="name"></param>
		/// <returns></returns>
		virtual public SimpleFile GetFile (string name)
		{
			if (null == Files || 0 == Files.Count)
				return null;

			foreach (SimpleFile file in Files)
			{
				if (0 == String.Compare (file.Name, name, true))
					return file;
			}

			return null;
		}

		#region properties

		/// <summary>
		/// 
		/// </summary>
		virtual public int FreeGranules
		{
			get
			{
				if (null == Granules)
					return -1;

				int		free		= 0;

				for (int i = 0; i < Granules.Length; i++)
				{
					if (0xFF == Granules [i])
						free++;
				}

				return free;
			}
		}

		/// <summary>
		/// Returns the bytes for the disk file.
		/// </summary>
		virtual public byte [] RawData { get; protected set; }

		/// <summary>
		/// Gets a value indicating the number of tracks.
		/// </summary>
		virtual public int Tracks { get; protected set; }

		/// <summary>
		/// Gets the list of DirectoryEntry objects
		/// </summary>
		private List<DirectoryEntry> _dirEntries;
		public virtual List<DirectoryEntry> Directory
		{
			get
			{
				if (null == _dirEntries)
				{
					List<DirectoryEntry> items = new List<DirectoryEntry> ();
					DirectoryEntry	item		= null;
					byte []			data		= null;
					byte []			entry		= new byte [32];

					// the directory entires exist on track 17 between sectors 3 and 11, inclusive.
					for (int s = 3; s <= 11; s++)
					{
						// get the bytes for the sector
						if (null == (data = Read (17, s)))
							continue;

						// read each raw directory entry for this sector
						for (int i = 0; i < 8; i++)
						{
							// copy directory entry bytes
							for (int j = 0; j < 32; j++)
								entry [j] = data [i * 32 + j];

							// create the directory entry object
							if (null == (item = DirectoryEntry.CreateInstance (this, entry)))
								continue;

							items.Add (item);
						}
					}

					// copy the array
					_dirEntries = new List<DirectoryEntry> (items);
				}

				return _dirEntries;
			}
			protected set
			{
				_dirEntries = value;
			}
		}
		/// <summary>
		/// Gets the file list
		/// </summary>
		private List<SimpleFile> _files;
		public virtual List<SimpleFile> Files
		{
			get
			{
				if (null == _files)
				{
					List<SimpleFile> files = new List<SimpleFile> ();

					foreach (DirectoryEntry de in this.Directory)
					{
						files.Add (de.GetFile ());
					}

					// copy the array
					_files = files;
				}

				return _files;
			}
			protected set
			{
				_files = value;
			}
		}

		/// <summary>
		/// Gets the granule allocation table (GAT)
		/// </summary>
		private byte [] _granules;
		public virtual byte [] Granules
		{
			get
			{
				if (null == _granules)
				{
					byte []	buff = Read (17, 2);
					FATEntry fat = new FATEntry (buff);

					_granules = fat.GranuleAllocationTable;
				}

				return _granules;
			}
			protected set
			{
				_granules = value;
			}
		}

		/// <summary>
		/// Returns the size of the disk.
		/// </summary>
		virtual public int Size { get; protected set; }

		/// <summary>
		/// 
		/// </summary>
		abstract public SectorList GetSectorList (int track);

		/// <summary>
		/// Gets the length of each track.
		/// </summary>
		virtual public int TrackLength { get; protected set; }

		/// <summary>
		/// Gets a value indicating if the disk can be modified.
		/// </summary>
		virtual public bool ReadOnly { get; protected set; }

		/// <summary>
		/// Gets a value indicating if the disk is DMK format.
		/// </summary>
		virtual public bool IsDMKFormat { get; protected set; }

		/// <summary>
		/// Gets a value indicating if the disk is in native format.
		/// </summary>
		virtual public bool IsNativeFormat { get; protected set; }

		/// <summary>
		/// 
		/// </summary>
		virtual public bool SingleSidedOnly { get; protected set; }

		/// <summary>
		/// 
		/// </summary>
		virtual public bool SingleDensity { get; protected set; }

		/// <summary>
		/// 
		/// </summary>
		virtual public bool IgnoreDensity { get; protected set; }
		
		/// <summary>
		/// Gets the filename of the disk
		/// </summary>
		virtual public string Diskname { get; protected set; }

#endregion
	}
}