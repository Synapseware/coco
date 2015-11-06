using System;
using System.Collections;
using System.Collections.Specialized;
using System.IO;
using System.Xml;
using System.Xml.Serialization;

namespace CoCoDisk.Configuration
{
	/// <summary>
	/// Summary description for Settings.
	/// </summary>
	[XmlRoot ("settings")]
	public class Settings
	{
		private StringDictionary	m_items;

		/// <summary>
		/// 
		/// </summary>
		public Settings ()
		{
			m_items = new StringDictionary ();
		}


		/// <summary>
		/// 
		/// </summary>
		public void Clear ()
		{
			m_items.Clear ();
		}


		/// <summary>
		/// 
		/// </summary>
		/// <param name="key"></param>
		/// <param name="value"></param>
		public void Add (string key, string value)
		{
			this [key] = value;
		}


		/// <summary>
		/// 
		/// </summary>
		/// <param name="key"></param>
		public void Remove (string key)
		{
			if (m_items.ContainsKey (key))
				m_items.Remove (key);
		}


		/// <summary>
		/// 
		/// </summary>
		public string this [string key]
		{
			get
			{
				if (!m_items.ContainsKey (key))
					return null;

				return m_items [key];
			}
			set
			{
				if (null == value)
				{
					m_items.Remove (key);
					return;
				}
				
				if (m_items.ContainsKey (key))
					m_items [key] = value;
				else
					m_items.Add (key, value);
			}
		}


		/// <summary>
		/// 
		/// </summary>
		[XmlArray ("items")]
		[XmlArrayItem ("item", typeof (NameValuePair))]
		public NameValuePair [] Items
		{
			get
			{
				NameValuePair [] items	= new NameValuePair [m_items.Count];
				int count			= 0;

				foreach (string key in m_items.Keys)
					items [count++] = new NameValuePair (key, m_items [key]);

				return items;
			}
			set
			{
				if (null == value)
					return;

				for (int i = 0; i < value.Length; i++)
					this [value [i].Key] = value [i].Value;
			}
		}


		/// <summary>
		/// 
		/// </summary>
		/// <param name="path"></param>
		/// <returns></returns>
		public static Settings Load (string path)
		{
			StreamReader	fin		= null;
			XmlSerializer	ser		= null;

			try
			{
				if (!File.Exists (path))
					return new Settings ();

				ser		= new XmlSerializer (typeof (Settings));
				fin		= File.OpenText (path);

				return ser.Deserialize (fin) as Settings;
			}
			catch // (Exception e)
			{
				return null;
			}
			finally
			{
				if (null != fin)
					fin.Close ();
			}
		}


		/// <summary>
		/// 
		/// </summary>
		/// <param name="path"></param>
		/// <param name="settings"></param>
		public static void Save (string path, Settings settings)
		{
			StreamWriter	fout	= null;
			XmlSerializer	ser		= null;

			if (null == settings)
				return;

			try
			{
				ser		= new XmlSerializer (typeof (Settings));
				fout	= File.CreateText (path);
				ser.Serialize (fout, settings);
			}
			finally
			{
				if (null != fout)
				{
					fout.Flush ();
					fout.Close ();
				}
			}
		}
	}


	/// <summary>
	/// 
	/// </summary>
	[XmlRoot ("item")]
	public class NameValuePair
	{
		public NameValuePair ()
		{
		}


		public NameValuePair (string key, string value)
		{
			Key = key;
			Value = value;
		}


		[XmlAttributeAttribute ("key")]
		public string Key;

		[XmlAttributeAttribute ("value")]
		public string Value;
	}
}
