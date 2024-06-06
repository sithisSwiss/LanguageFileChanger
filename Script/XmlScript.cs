using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using cfnLanguageFileChanger.Script;
using cfnLanguageFileChanger.Script.LanguageFile;
using Godot;
using Array = System.Array;

[GlobalClass]
public sealed partial class XmlScript : GodotObject
{
	private static LanguageFileConfiguration Configuration => LangaugeFileHelper.GetCurrentConfiguration();
	private static Func<XDocument, XElement> GetRootFromXDocument => doc => doc.Root!;

	private static Func<XElement, IEnumerable<XElement>> GetItemsInRoot =>
		root => root.Elements().Where(x => x.Name.LocalName == Configuration.ItemTagName);

	private static string KeyName => Configuration.Attributes[Configuration.KeyAttributeIndex].Name;
	private static string ItemTagName => Configuration.ItemTagName;

	public static string[] GetKeys(string path)
	{
		try
		{
			var root = GetRootFromXDocument!(XDocument.Load(path));
			IEnumerable<XElement> elements = GetItemsInRoot!(root);
			return elements.Select(item => item.Attribute(KeyName)!.Value).ToArray();
		}
		catch (Exception)
		{
			return Array.Empty<string>();
		}
	}

	public static string GetAttribute(string key, string attributeName, string path)
	{
		try
		{
			return GetSpecificElement(key, XDocument.Load(path))?.Attribute(attributeName)?.Value ?? string.Empty;
		}
		catch (Exception)
		{
			return string.Empty;
		}
	}

	public static string GetValue(string key, string path)
	{
		try
		{
			var t = GetSpecificElement(key, XDocument.Load(path))!.Value;
			return t;
		}
		catch (Exception)
		{
			return string.Empty;
		}
	}

	public static void SaveValue(LanguageFileItem item, LanguageFileValue value)
	{
		try
		{
			using var handler = new XDocumentHandler(value.FilePath);
			var element = GetSpecificElement(item.Key, handler.Doc);
			if (element is null)
			{
				return;
			}

			element.Value = value.Value;
		}
		catch (Exception)
		{
			// ignored
		}
	}
	
	public static void SaveAttribute(LanguageFileItem item, LanguageFileAttribute attr)
	{
		try
		{
			foreach(var path in LangaugeFileHelper.GetLanguageFilePaths())
			{
				using var handler = new XDocumentHandler(path);
				var element = GetSpecificElement(item.Key, handler.Doc);
				element?.SetAttributeValue(attr.Name, attr.Value);
			}
		}
		catch (Exception)
		{
			// ignored
		}
	}

	public static void ChangeKey(string oldKey, string newKey)
	{
		try
		{
			foreach(var path in LangaugeFileHelper.GetLanguageFilePaths())
			{
				using var handler = new XDocumentHandler(path);
				var element = GetSpecificElement(oldKey, handler.Doc);
				element?.SetAttributeValue(KeyName, newKey);
			}
		}
		catch (Exception)
		{
			// ignored
		}
	}

	public static void RemoveItem(string key)
	{
		try
		{
			foreach(var path in LangaugeFileHelper.GetLanguageFilePaths())
			{
				using var handler = new XDocumentHandler(path);
				GetSpecificElement(key, handler.Doc)?.Remove();
			}
		}
		catch (Exception)
		{
			// ignored
		}
	}

	private static XElement? GetSpecificElement(string key, XDocument doc)
	{
		var root = GetRootFromXDocument!(doc);
		IEnumerable<XElement> elements = GetItemsInRoot!(root);
		return elements.FirstOrDefault(x => x.Attribute(KeyName)!.Value == key);
	}

	private static void SetAttributes(ref XElement element, Godot.Collections.Dictionary<string, string> attributes)
	{
		foreach (KeyValuePair<string, string> attribute in attributes)
		{
			element.SetAttributeValue(attribute.Key, attribute.Value);
		}
	}

	private static void RemoveEmptyNamespace(string filePath)
	{
		try
		{
			var fileContent = File.ReadAllText(filePath);
			var newFileContent = fileContent.Replace(" xmlns=\"\"", "");
			File.WriteAllText(filePath, newFileContent);
		}
		catch (Exception)
		{
			// ignored
		}
	}

	private sealed class XDocumentHandler : IDisposable
	{
		private readonly string _path;

		public XDocumentHandler(string path)
		{
			Doc = XDocument.Load(path);
			_path = path;
		}

		public XDocument Doc { get; }

		public void Dispose()
		{
			Doc.Save(_path);
			RemoveEmptyNamespace(_path);
		}
	}
}
