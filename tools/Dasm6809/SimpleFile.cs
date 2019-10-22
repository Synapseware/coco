using System;
using System.IO;

namespace Dasm6809
{
	public interface ISimpleFile
	{
		/// <summary>
		/// 
		/// </summary>
		/// <param name="path"></param>
		void Initialize (string path);

		/// <summary>
		/// 
		/// </summary>
		/// <param name="hex"></param>
		/// <returns></returns>
		byte ConvertHexWord (byte [] hex);

		/// <summary>
		/// 
		/// </summary>
		/// <param name="data"></param>
		/// <returns></returns>
		byte ConvertByte (byte data);

		/// <summary>
		/// 
		/// </summary>
		string Filename { get; }
	}

	/// <summary>
	/// Summary description for SimpleFile.
	/// </summary>
	public class SimpleFile : ISimpleFile
	{
		protected byte []	m_data;
		protected string	m_filename;

		/// <summary>
		/// 
		/// </summary>
		public SimpleFile ()
		{
		}

		/// <summary>
		/// Creates an appropriate ISimpleFile object to handle the specified file type.
		/// </summary>
		/// <param name="path"></param>
		/// <returns></returns>
		public static ISimpleFile CreateInstance (string path)
		{
			switch (Path.GetExtension (path).ToLower ())
			{
				case ".hex":
					return new SimpleFile ();
				case ".asm":
					return new AssemblyFile ();
				case ".bin":
					return new BinaryFile ();
			}

			return null;
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="path"></param>
		virtual public void Initialize (string path)
		{
			FileStream	f_in		= null;

			try
			{
				// get the filename
				m_filename = Path.GetFileName (path);

				// open the file object
				f_in = File.OpenRead (path);

				// read hex file or binary file
				if (0 == String.Compare (Path.GetExtension (path), ".hex", true) && f_in.Length % 2 == 0)
				{
					byte []		hexword = new byte [2];
					int			len		= (int) f_in.Length / 2;
					m_data				= new byte [len];

					for (int i = 0; i < len; i++)
					{
						if (2 != f_in.Read (hexword, 0, 2))
							throw new Exception ("Error reading hex file!");

						m_data [i] = ConvertHexWord (hexword);
					}
				}
				else
				{
					m_data = new byte [f_in.Length];
					f_in.Read (m_data, 0, m_data.Length);
				}
			}
			finally
			{
				if (null != f_in)
					f_in.Close ();
			}
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="hex"></param>
		/// <returns></returns>
		public byte ConvertHexWord (byte [] hex)
		{
			byte a	= 0x00;
			byte b	= 0x00;

			a = ConvertByte (hex [0]);
			b = ConvertByte (hex [1]);

			return (byte) (a * 16 + b);
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="data"></param>
		/// <returns></returns>
		public byte ConvertByte (byte data)
		{
			switch ((int)data)
			{
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					data = (byte) (data - 0x30);
					break;
				case 'A':	// 10
				case 'B':	// 11
				case 'C':	// 12
				case 'D':	// 13
				case 'E':	// 14
				case 'F':	// 15
					data = (byte) (data - 0x37);
					break;
				case 'a':
				case 'b':
				case 'c':
				case 'd':
				case 'e':
				case 'f':
					data = (byte) (data - 0x57);
					break;
			}

			return data;
		}

		/// <summary>
		/// 
		/// </summary>
		public string Filename
		{
			get
			{ return m_filename; }
		}
	}
}
