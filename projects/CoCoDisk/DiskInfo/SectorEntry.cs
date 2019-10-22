using System;
using System.Collections.Generic;
using System.Text;

namespace CoCoDisk
{
	public class SectorList : List<SectorEntry>
	{
		/// <summary>
		/// Gets or sets the pointer to the IDAM table
		/// </summary>
		public int IDAMTablePointer { get; set; }
	}


	public class SectorEntry
	{
		public SectorEntry (int sectorStart, int logicalNumber, int physicalNumber)
		{
			SectorStart = sectorStart;
			LogicalNumber = logicalNumber;
			PhysicalNumber = physicalNumber;
		}

		/// <summary>
		/// Returns the index into the raw disk data where this sector starts
		/// </summary>
		public int SectorStart { get; protected set; }

		/// <summary>
		/// Returns the logical sector number
		/// </summary>
		public int LogicalNumber { get; protected set; }

		/// <summary>
		/// Returns the physical sector number (can be used as an offset from the IDAM table)
		/// </summary>
		public int PhysicalNumber { get; protected set; }
	}
}
