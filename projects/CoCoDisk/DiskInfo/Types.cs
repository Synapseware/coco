using System;
using System.Collections;
using System.Text;

namespace CoCoDisk
{
	public enum FileType
	{
		Basic		= 0,

		BasicData	= 1,

		Assembly	= 2,

		Text		= 3
	}


	/// <summary>
	/// Contains information about a directory entry.
	/// </summary>
	public class DosFile
	{
		protected string		m_name;
		protected byte []		m_data;
		protected int			m_granule;
		protected int			m_length;
		protected bool			m_isbinary;
		protected FileType		m_type;


		/// <summary>
		/// Hidden Constructor - force clients to call CreateEntry with
		/// required parameters.
		/// </summary>
		public DosFile ()
		{  }


		/// <summary>
		/// 
		/// </summary>
		/// <param name="entry"></param>
		/// <param name="gat"></param>
		/// <param name="index"></param>
		public static DosFile CreateEntry (byte [] entry)
		{
			if (null == entry || 32 != entry.Length)
				return null;

			/*
			entry contains specific information (bytes listed):
				0 - 7	= file name
				8 - 10	= file extension
				11		= file type
				12		= ascii/binary flag (0 = bin, 255 = asc)
				13		= first granule number
				14 - 15	= number of bytes in last granule
			*/

			// check for unused entry name - if bit 7 is set, then
			// entry is not in use.
			if ((0x80 & entry [0]) == 0x80)
				return null;

			string	name	= Encoding.ASCII.GetString (entry, 0, 8);
			string	ext		= Encoding.ASCII.GetString (entry, 8, 3);

			DosFile	de	= new DosFile ();

			de.m_name		= String.Format ("{0}.{1}", name.Trim (), ext.Trim ());
			de.m_type		= (FileType) entry [11];
			de.m_isbinary	= (0x00 == entry [12]) ? true : false;
			de.m_granule	= (int) entry [13];
			de.m_length		= ((int) entry [14]) * 256 + (int) entry [15];

			return de;
		}


		#region properties

		public string Name
		{
			get
			{ return m_name; }
		}

		public byte [] Data
		{
			get
			{ return m_data; }
		}

		public int Granule
		{
			get
			{ return m_granule; }
		}

		public int Length
		{
			get
			{ return m_length; }
		}

		public FileType FileType
		{
			get
			{ return m_type; }
		}

		/// <summary>
		/// Gets or sets the GAT table index for this directory entry.
		/// </summary>
		public int Index;

		#endregion
	}
}
