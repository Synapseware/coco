using System;
using System.Collections;
using System.Collections.Specialized;
using System.Text;
using System.Text.RegularExpressions;

namespace Dasm6809
{
	/// <summary>
	/// Summary description for AssemblyFile.
	/// </summary>
	public class AssemblyFile : SimpleFile
	{
		protected int		m_loadat;
		protected int		m_exec;


		/// <summary>
		/// Static Constructor
		/// </summary>
		static AssemblyFile ()
		{
		}

		/// <summary>
		/// 
		/// </summary>
		/// <returns></returns>
		public override string ToString ()
		{
			return Compiler.Disassemble (m_data);
		}

		/// <summary>
		/// 
		/// </summary>
		public int LoadAddress
		{
			get
			{
				if (null != m_data && 0 == m_loadat)
					m_loadat = m_data [3] * 256 + m_data [4];

				return m_loadat;
			}
		}

		/// <summary>
		/// 
		/// </summary>
		public int ExecAddress
		{
			get
			{
				if (null != m_data && m_data.Length > 3 && 0 == m_exec)
					m_exec = m_data [m_data.Length - 2] * 256 + m_data [m_data.Length - 1];

				return m_exec;
			}
		}
	}
}
