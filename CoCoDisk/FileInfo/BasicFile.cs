using System;
using System.Collections;
using System.Collections.Specialized;
using System.Text;
using System.IO;

namespace CoCoDisk
{
	/// <summary>
	/// BasicFile
	/// 
	/// The BASIC storage format:
	/// A single line record is formatted like:
	///		word	Pointer to next line
	///		word	Line number
	///		byte[]	Tokenised data
	///		byte	$00		End of line delimiter
	/// </summary>
	public class BasicFile : SimpleFile
	{
		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		public override string ToString ()
		{
			return ConvertProgram ();
		}

		public override void Save (string filename)
		{
			if (File.Exists (filename))
				File.Delete (filename);

			using (StreamWriter s_out = File.CreateText (filename))
			{
				s_out.Write (ConvertProgram ());
				s_out.Flush ();
			}
		}

		public override byte [] SerialData
		{
			get
			{
				byte [] buff = Encoding.ASCII.GetBytes (ConvertProgram ());
				return buff;
			}
		}

		/// <summary>
		/// Converts the data buffer to a BASIC program.
		/// </summary>
		/// <returns></returns>
		protected string ConvertProgram ()
		{
			StringBuilder	sb				= null;
			int				ptrline			= 0;
			int				linenum			= 0;
			int				spos			= 0;
			int				epos			= 0;
			int				length			= 0;

            if (null == Data || 0 == Data.Length)
				return null;

			// not a BASIC file!
			if (0xFF != Data [0])
				return null;

			// get length of file
			length	= Data [1] * 256 + Data [2];
			spos	= 3;
			sb		= new StringBuilder ();

			while (spos < Data.Length - 4)
			{
				// get the pointer to the next line (not used for now)
				ptrline		= (int) Data [spos + 0] * 256 + (int) Data [spos + 1];

				// get the line number
				linenum		= (int) Data [spos + 2] * 256 + (int) Data [spos + 3];
				spos		+= 4;

				// find end of current line
				for (int i = spos; i < Data.Length; i++)
				{
					if (0x00 != Data [i])
						continue;

					epos = i;
					break;
				}

				// quit if line length not valid!
				if (epos - spos < 1)
					break;

				// append the formatted line
				sb.AppendFormat ("{0} {1}\r\n", linenum, ConvertLine (Data, spos, epos - spos));

				// update the start position
				spos = epos + 1;
			}

			return sb.ToString ();
		}

		/// <summary>
		/// 
		/// </summary>
		/// <param name="line"></param>
		/// <returns></returns>
		protected string ConvertLine (byte [] buff, int index, int length)
		{
			StringBuilder	sb		= new StringBuilder ();

			for (int i = 0; i < length; i++)
			{
				byte value = buff [index + i];

				if (value > 0x7F && value < 0xFF)
				{
					sb.Append (ConvertOperatorToken (value));
				}
				else if (value == 0xFF && i < length - 2)
				{
					i++;
					sb.Append (ConvertFunctionToken (buff [index + i]));
				}
				else
				{
					sb.Append (Encoding.ASCII.GetString (buff, index + i, 1));
				}
			}

			return sb.ToString ();
		}

		/// <summary>
		/// Converts an operator token to its string form.
		/// </summary>
		/// <param name="token"></param>
		/// <returns></returns>
		protected string ConvertOperatorToken (byte token)
		{
			switch (token)
			{
				case 0x80:
					return "FOR";
				case 0x81:
					return "GO";
				case 0x82:
					return "REM";
				case 0x83:
					return "'";
				case 0x84:
					return "ELSE";
				case 0x85:
					return "IF";
				case 0x86:
					return "DATA";
				case 0x87:
					return "PRINT";
				case 0x88:
					return "ON";
				case 0x89:
					return "INPUT";
				case 0x8a:
					return "END";
				case 0x8b:
					return "NEXT";
				case 0x8c:
					return "DIM";
				case 0x8d:
					return "READ";
				case 0x8e:
					return "RUN";
				case 0x8f:
					return "RESTORE";
				case 0x90:
					return "RETURN";
				case 0x91:
					return "STOP";
				case 0x92:
					return "POKE";
				case 0x93:
					return "CONT";
				case 0x94:
					return "LIST";
				case 0x95:
					return "CLEAR";
				case 0x96:
					return "NEW";
				case 0x97:
					return "CLOAD";
				case 0x98:
					return "CSAVE";
				case 0x99:
					return "OPEN";
				case 0x9a:
					return "CLOSE";
				case 0x9b:
					return "LLIST";
				case 0x9c:
					return "SET";
				case 0x9d:
					return "RESET";
				case 0x9e:
					return "CLS";
				case 0x9f:
					return "MOTOR";
				case 0xa0:
					return "SOUND";
				case 0xa1:
					return "AUDIO";
				case 0xa2:
					return "EXEC";
				case 0xa3:
					return "SKIPF";
				case 0xa4:
					return "TAB";
				case 0xa5:
					return "TO";
				case 0xa6:
					return "SUB";
				case 0xa7:
					return "THEN";
				case 0xa8:
					return "NOT";
				case 0xa9:
					return "STEP";
				case 0xaa:
					return "OFF";
				case 0xab:
					return "+";
				case 0xac:
					return "-";
				case 0xad:
					return "*";
				case 0xae:
					return "/";
				case 0xaf:
					return "^";
				case 0xb0:
					return "AND";
				case 0xb1:
					return "OR";
				case 0xb2:
					return ">";
				case 0xb3:
					return "=";
				case 0xb4:
					return "<";
				case 0xb5:
					return "DEL";
				case 0xb6:
					return "EDIT";
				case 0xb7:
					return "TRON";
				case 0xb8:
					return "TROFF";
				case 0xb9:
					return "DEF";
				case 0xba:
					return "LET";
				case 0xbb:
					return "LINE";
				case 0xbc:
					return "PCLS";
				case 0xbd:
					return "PSET";
				case 0xbe:
					return "PRESET";
				case 0xbf:
					return "SCREEN";
				case 0xc0:
					return "PCLEAR";
				case 0xc1:
					return "COLOR";
				case 0xc2:
					return "CIRCLE";
				case 0xc3:
					return "PAINT";
				case 0xc4:
					return "GET";
				case 0xc5:
					return "PUT";
				case 0xc6:
					return "DRAW";
				case 0xc7:
					return "PCOPY";
				case 0xc8:
					return "PMODE";
				case 0xc9:
					return "PLAY";
				case 0xca:
					return "DLOAD";
				case 0xcb:
					return "RENUM";
				case 0xcc:
					return "FN";
				case 0xcd:
					return "USING";
				case 0xce:
					return "DIR";
				case 0xcf:
					return "DRIVE";
				case 0xd0:
					return "FIELD";
				case 0xd1:
					return "FILES";
				case 0xd2:
					return "KILL";
				case 0xd3:
					return "LOAD";
				case 0xd4:
					return "LSET";
				case 0xd5:
					return "MERGE";
				case 0xd6:
					return "RENAME";
				case 0xd7:
					return "RSET";
				case 0xd8:
					return "SAVE";
				case 0xd9:
					return "WRITE";
				case 0xda:
					return "VERIFY";
				case 0xdb:
					return "UNLOAD";
				case 0xdc:
					return "DSKINI";
				case 0xdd:
					return "BACKUP";
				case 0xde:
					return "COPY";
				case 0xdf:
					return "DSKI$";
				case 0xe0:
					return "DSKO$";
				case 0xe2:
					return "WIDTH";
				case 0xe3:
					return "PALETTE";
				case 0xe4:
					return "HSCREEN";
				case 0xe7:
					return "HCOLOR";
				case 0xf0:
					return "BRK";
				case 0xf5:
					return "HDRAW";
			}
			return null;
		}

		/// <summary>
		/// Converts a function token to its string value
		/// </summary>
		/// <param name="token"></param>
		/// <returns></returns>
		protected string ConvertFunctionToken (byte token)
		{
			switch (token)
			{
				case 0x80:
					return "SGN";
				case 0x81:
					return "INT";
				case 0x82:
					return "ABS";
				case 0x83:
					return "USR";
				case 0x84:
					return "RND";
				case 0x85:
					return "SIN";
				case 0x86:
					return "PEEK";
				case 0x87:
					return "LEN";
				case 0x88:
					return "STR$";
				case 0x89:
					return "VAL";
				case 0x8a:
					return "ASC";
				case 0x8b:
					return "CHR$";
				case 0x8c:
					return "EOF";
				case 0x8d:
					return "JOYSTK";
				case 0x8e:
					return "LEFT$";
				case 0x8f:
					return "RIGHT$";
				case 0x90:
					return "MID$";
				case 0x91:
					return "POINT";
				case 0x92:
					return "INKEY$";
				case 0x93:
					return "MEM";
				case 0x94:
					return "ATN";
				case 0x95:
					return "COS";
				case 0x96:
					return "TAN";
				case 0x97:
					return "EXP";
				case 0x98:
					return "FIX";
				case 0x99:
					return "LOG";
				case 0x9a:
					return "POS";
				case 0x9b:
					return "SQR";
				case 0x9c:
					return "HEX$";
				case 0x9d:
					return "VARPTR";
				case 0x9e:
					return "INSTR";
				case 0x9f:
					return "TIMER";
				case 0xa0:
					return "PPOINT";
				case 0xa1:
					return "STRING$";
				case 0xa2:
					return "CVN";
				case 0xa3:
					return "FREE";
				case 0xa4:
					return "LOC";
				case 0xa5:
					return "LOF";
				case 0xa6:
					return "MKN$";
			}

			return null;
		}
	}
}
