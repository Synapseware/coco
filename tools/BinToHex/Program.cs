using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace BinToHex
{
	class Program
	{
		static void Main (string [] args)
		{
			string srcFile = null;
			string dstFile = null;

			if (args.Length == 0)
			{
				srcFile = GetFileName ("Input file: ");
				dstFile = GetFileName ("Output file: ");
			}
			else if (args.Length > 1)
			{
				srcFile = args [0];
				dstFile = args [1];
			}
			else
			{
				Console.WriteLine("Invalid number of parameters");
				return;
			}

			// throw error if no input file is found
			if (!File.Exists (srcFile))
			{
				Console.WriteLine("Input file not found.");
				return;
			}

			// delete output file if user confirms
			if (File.Exists (dstFile))
			{
				Console.Write ("Output file exists.  Overwrite [y/n]?");
				if (Console.ReadKey ().Key == ConsoleKey.Y)
					File.Delete (dstFile);
			}

			// convert file
			FileInfo fi = new FileInfo (srcFile);
			using (FileStream f_in = fi.Open (FileMode.Open))
			{
				using (StreamWriter s_out = File.CreateText (dstFile))
				{
					// check the position so we don't run past the end of the file
					while (f_in.Position < fi.Length)
					{
						byte val = Convert.ToByte (f_in.ReadByte ());
						s_out.Write (val.ToString("X2"));
					}
				}
			}
		}

		private static string GetFileName (string msg)
		{
			Console.Write (msg);
			return Console.ReadLine ();
		}
	}
}
