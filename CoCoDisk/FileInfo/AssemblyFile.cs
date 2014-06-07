using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace CoCoDisk
{
	/*
MACHINE LANGUAGE FILE INPUT/OUTPUT 
 
The DOS uses a special format for transferring binary files to and from the 
disk. The format is fairly simple and straightforward and allows the loading of 
non—contiguous blocks of memory from the same file. The only problem is that Radio 
Shack has not provided a SAVEM function, which will allow the saving of non—
contiguous blocks of memory into one disk file. This minor problem can be gotten 
around with the help of a neat utility called JOIN which is included in the Spec-
tral Associates Color Computer Editor Assembler, ULTRA 80CC. This utility will 
allow the concatenation of as many machine language files as the user requires into 
one large file. LOADM will then load all of the segments into memory and the 
segments may overlay one another. 
 
Binary data is stored on the disk as one large block proceeded by a five-byte 
preamble. The data block is followed by five more bytes which are another preamble 
if there is another block of data following or the five bytes are a post-amble if 
there are no further data blocks. The format for the preamble and the post-amble 
are given below: 
 
  BYTE		PREAMBLE				POSTAMBLE 
  0			00 Preamble flag		$FF Post-amble flag 
  1,2		Length of data block	Two zero bytes 
  3,4		Load address			EXEC address 
	*/

	/// <summary>
	/// Summary description for AssemblyFile.
	/// </summary>
	public class AssemblyFile : SimpleFile
	{
		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		public override string ToString ()
		{
			// generate a temp file to store the binary data in from the file
			string asmPath = Path.GetDirectoryName (Assembly.GetExecutingAssembly ().Location);
			string fileName = Path.Combine (asmPath, this.Name);
			string outFile = Path.Combine (asmPath, Path.GetFileNameWithoutExtension (this.Name) + ".lst");

			// clean up the temp file
			if (File.Exists (fileName))
				File.Delete (fileName);

			// write the data to the file
			using (FileStream f_out = File.Create (fileName, this.Data.Length))
			{
				f_out.Write (this.Data, 0, this.Data.Length);
				f_out.Flush ();
			}

			return Dissamble (asmPath, fileName, outFile);
		}

		/// <summary>
		/// Generates a disassembly listing for the file
		/// </summary>
		private string Dissamble (string path, string srcFile, string dstPath)
		{
			// build the command arguments
			string exePath = Path.Combine (path, "6809dasm.exe");
			string cmdArgs = String.Format ("{0} -i{1} > ", exePath, srcFile, dstPath);
			string data = null;

			// 6809DASM.EXE
			ProcessStartInfo psi = new ProcessStartInfo ("6809dasm.exe", cmdArgs);
			psi.UseShellExecute = true;
			psi.CreateNoWindow = true;
			psi.WindowStyle = ProcessWindowStyle.Hidden;

			using (Process proc = Process.Start (exePath, cmdArgs))
			{
                proc.WaitForExit ();
			}

			return data;
		}

		/// <summary>
		/// Returns the address that the assembly file should load into
		/// </summary>
		public int LoadAddress
		{
			get
			{
				int msb = base.Data [3];
				int lsb = base.Data [4];

				return msb * 256 + lsb;
			}
		}

		/// <summary>
		/// Returns the length of the assembly file
		/// </summary>
		public int BlockLength
		{
			get
			{
				int msb = base.Data [1];
				int lsb = base.Data [2];

				return msb * 256 + lsb;
			}
		}

		/// <summary>
		/// Returns the entry point to the assembly file
		/// </summary>
		public int ExecAddress
		{
			get
			{
				int msb = base.Data [base.Data.Length - 2];
				int lsb = base.Data [base.Data.Length - 1];

				return msb * 256 + lsb;
			}
		}

		public override byte [] SerialData
		{
			get
			{
				return this.Data;
			}
		}

		/// <summary>
		/// Returns the literal bytes for the assembly file, minus the preamble and postamble
		/// </summary>
		private byte [] _asmData;
		public override byte [] Data
		{
			get
			{
				if (null == _asmData)
				{
					// get a reference to the raw data
					byte [] tmp = base.Data;

					// create a buffer that excludes the pre and post ambles
					_asmData = new byte [BlockLength];

					// copy the assembly binary data
					Array.Copy (tmp, 5, _asmData, 0, BlockLength);
				}
				return _asmData;
			}
		}
	}
}
