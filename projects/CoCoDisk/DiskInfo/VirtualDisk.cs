using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace CoCoDisk
{
	/// <summary>
	/// Reads information about a real disk image, one that does not use the DMK disk
	/// image format
	/// 
	/// DMK disks closely model physical format of real CoCo disks.
	/// 16 byte header
	///		0 = readonly flag (0xFF = readonly, 0x00 = read/write)
	///		1 = number of tracks (0x23 = 35 tracks)
	///		2 = track length LSB (DMK is little endian)
	///		3 = track length MSB
	///		4 = option flags byte
	///			0 = 
	///			1 = 
	///			2 = 
	///			3 = 
	///			4: 1 = single sided
	///			5 = 
	///			6: 1 = single density
	///			7: 1 = ignore density
	///		5 = reserved
	///		6 = reserved
	///		7 = reserved
	///		8 = reserved
	///		9 = reserved
	///		A = reserved
	///		B = reserved
	///		C = Bytes C-F, must be zero if disk is in emulators native format
	///		D = Bytes C-F, must be 12345678h if virtual disk is a REAL disk spec, used to access REAL coco floppies in compatible PC drives
	///		E = 
	///		F = 
	///		
	///
	/// Each track has a 128 byte header which contains an offest to each IDAM in the track.
	/// IDAM Rules:
	///		- each pointer is a 2 byte offset to the FEh byte of the IDAM.  In double byte single density, the pointer is to the first FEh.
	///		- The offset includes the 128 byte header
	///		- IDAM offsets must be in ascending order
	///		- header is terminated with 0000h any entry is unused
	///		- pointer bytes are little endian
	///	
	/// Each IDAM pointer has two flags.  Bit 15 is set if the sector is double density.  Bit 14 is undefined.
	/// Example: An offset to an IDAM at byte 90h would be 0090h for single density, and 8090h for double density.
	/// 
	/// Track data follows the header.  If bits 6 or 7 are not set in disk header byte 4, then each single density data byte is written twice.
	/// This includes IDAMs and CRCs (CRCs are calculated as if only 1 byte were written though).
	/// 
	/// 
	/// </summary>
	public class DMKVirtualDisk : SimpleDisk
	{
		private const int DISK_HEADER_LEN = 16;

		/// <summary>
		/// Initialize disk
		/// </summary>
		/// <param name="path"></param>
		/// <returns></returns>
		public override bool Initialize (string path)
		{
			if (!base.Initialize (path))
				return false;

			// analyze header information and set flags

			// set readonly flag
			ReadOnly = (0xff == RawData [0]);

			// get the tracks
			Tracks = (int) RawData [1];

			// get the track length
			TrackLength = (int) RawData [3] * 256 + (int) RawData [2];

			// get native flag
			if (0x12 == RawData [0x0c] &&
				0x34 == RawData [0x0d] &&
				0x56 == RawData [0x0e] &&
				0x78 == RawData [0x0f])
				IsNativeFormat = false;

			// get single sided only flag
			if ((0x10 & RawData [4]) == 0x10)
				SingleSidedOnly = true;

			// get the single density flag
			if ((0x40 & RawData [4]) == 0x40)
				SingleDensity = true;

			// get the ignore density flag
			if ((0x80 & RawData [4]) == 0x80)
				IgnoreDensity = true;

			// set the size of the raw data
			Size = (SingleDensity ? 1 : 2) * (SingleSidedOnly ? 1 : 2) * 35 * TrackLength;

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

			// sector data starts 45 bytes from sector start
			pos += 45;

			// copy bytes from disk into buffer
			buffer = new byte [256];
			Array.Copy (RawData, pos, buffer, 0, buffer.Length);

			return buffer;
		}

		/// <summary>
		/// Returns the sector skip bytes
		/// </summary>
		public override SectorList GetSectorList (int track)
		{
			SectorList list = new SectorList ();
			int		sp			= 0;

			// set the sector lists IDAM table pointer
			list.IDAMTablePointer = track * TrackLength + DISK_HEADER_LEN;

			// walk each pointer pair in the IDAM table, find the sector, pull
			// the sectors number and record it in the list.
			for (int s = 0; s < 18; s++)
			{
				// read IDAM pointer values (little endian format)
				int idx = list.IDAMTablePointer + s * 2;
				int lsb = RawData [idx];
				int msb = RawData [idx + 1];

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

		/// <summary>
		/// Returns a value indicating that this is a DMK formatted disk image.
		/// </summary>
		public override bool IsDMKFormat
		{
			get
			{ return true; }
		}
	}
}
