using System;
using System.Collections;
using System.IO;
using System.Text;
using System.Collections.Generic;

namespace CoCoDisk
{
	/// <summary>
	/// Reads DMK virtual disk image format
	/// </summary>
	public class RawDisk : SimpleDisk
	{
		/// <summary>
		/// Initializes this raw disk image.
		/// </summary>
		/// <param name="path"></param>
		/// <returns></returns>
		public override bool Initialize (string path)
		{
			if (!base.Initialize (path))
				return false;

			// analyze header information and set flags

			// set the track length
			TrackLength = 4608;

			// set the track count
			Tracks = 35;

			// set native flag
			IsNativeFormat = true;

			// set single sided only flag
			SingleSidedOnly = true;

			// set the single density flag
			SingleDensity = true;

			// set the ignore density flag
			IgnoreDensity = true;

			// set the size of the raw data
			Size = TrackLength * Tracks;

			return true;
		}

		/// <summary>
		/// Does actual sector read from the disk.  Translation of skip factor,
		/// disk image format and other parameters is accounted for.
		/// </summary>
		/// <param name="track"></param>
		/// <param name="sector"></param>
		/// <returns></returns>
		public override byte [] Read (int track, int sector)
		{
			byte []			buffer			= null;
			int				pos				= -1;

			// convert track/sector to index
			pos = MapTrackSectorToIndex (track, sector);

			// copy bytes from disk into buffer
			buffer = new byte [256];
			Array.Copy (RawData, pos, buffer, 0, buffer.Length);

			return buffer;
		}

		public override SectorList GetSectorList (int track)
		{
			SectorList list = new SectorList ();
			for (int i = 0; i < 18; i++)
				list.Add (new SectorEntry ((track * TrackLength) + (i * 256), i + 1, i + 1));
			return list;
			int		sp			= 0;

			// set the sector lists IDAM table pointer
			list.IDAMTablePointer = track * TrackLength;

			// walk each pointer pair in the IDAM table, find the sector, pull
			// the sectors number and record it in the list.
			for (int s = 0; s < 18; s++)
			{
				// read IDAM pointer values (little endian format)
				int idx = list.IDAMTablePointer + s * 2;
				int msb = RawData [idx];
				int lsb = RawData [idx + 1];

				// clear control bits
				msb &= 0x1f;

				// point at the sector header
				sp = (msb * 256) + lsb + list.IDAMTablePointer;

				// copy sector skip data
				// sp is the sector pointer
				// RawData [sp +3] gets the sectors logical number
				// s + 1 is the physical sector number
				list.Add (new SectorEntry (sp, RawData [sp + 3], s + 1));
			}

			return list;
		}
	}
}