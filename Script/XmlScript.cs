using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using cfnLanguageFileChanger.Script;
using Godot;
using Array = System.Array;

[GlobalClass]
public sealed partial class XmlScript : GodotObject
{
	private static LanguageFileConfiguration Configuration => LanguageFileConfiguration.GetCurrentConfiguration();

	// private static Func<XDocument, XElement> GetRootFromXDocument => doc => doc.Element(Configuration.RootTagName);
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

	// public void AddItem(LanguageFileItem item, string path)
	// {
	// 	try
	// 	{
	// 		using var handler = new XDocumentHandler(path);
	// 		var element = new XElement(_itemTagName);
	// 		SetAttributes(ref element, item.Attributes);
	// 		handler.Doc.Root!.Add(element);
	// 	}
	// 	catch (Exception)
	// 	{
	// 		// ignored
	// 	}
	// }

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

	// public static string GetValue(string key, string path) => Get(key, FieldTypes.Value, path);
	// public static string GetInfo(string key, string path) => Get(key, FieldTypes.Info, path);
	// public static string GetField(string key, string path) => Get(key, FieldTypes.Field, path);
	// public static string GetLayout(string key, string path) => Get(key, FieldTypes.Layout, path);

	public static void SaveValue(string key, string value, string path)
	{
		try
		{
			using var handler = new XDocumentHandler(path);
			var element = GetSpecificElement(key, handler.Doc);
			if (element is null)
			{
				element = new XElement(ItemTagName);
				GetRootFromXDocument!(handler.Doc).Add(element);
			}

			element.Value = value;
		}
		catch (Exception)
		{
			// ignored
		}
	}

	public static void SaveAttribute(LanguageFileItem item, string path)
	{
		try
		{
			using var handler = new XDocumentHandler(path);
			var element = GetSpecificElement(item.Key, handler.Doc);
			if (element is null)
			{
				element = new XElement(ItemTagName);
				GetRootFromXDocument!(handler.Doc).Add(element);
			}

			SetAttributes(ref element, item.Attributes);
		}
		catch (Exception)
		{
			// ignored
		}
	}

	public static void ChangeKey(string oldKey, string newKey, string path)
	{
		try
		{
			using var handler = new XDocumentHandler(path);
			var element = GetSpecificElement(oldKey, handler.Doc);
			element?.SetAttributeValue(KeyName, newKey);
		}
		catch (Exception)
		{
			// ignored
		}
	}

	// public void SaveAttribute(Dictionary attributeValue, string key, string path)
	// {
	// 	try
	// 	{
	// 		using var handler = new XDocumentHandler(path);
	// 		var element = GetSpecificElement(key, handler.Doc);
	// 		SetAttributes(ref element, attributeValue);
	// 	}
	// 	catch (Exception)
	// 	{
	// 		// ignored
	// 	}
	// }

	public static void RemoveItem(string key, string path)
	{
		try
		{
			using var handler = new XDocumentHandler(path);
			GetSpecificElement(key, handler.Doc)?.Remove();
		}
		catch (Exception)
		{
			// ignored
		}
	}

	// private static string Get(string key, string field, string path)
	// {
	// 	try
	// 	{
	// 		return field switch
	// 		{
	// 			FieldTypes.Value => GetSpecificElement(key, XDocument.Load(path)).Value,
	// 			FieldTypes.Info or FieldTypes.Field or FieldTypes.Layout => GetSpecificElement(key, XDocument.Load(path)).Attribute(field)!.Value,
	// 			_ => string.Empty
	// 		};
	// 	}
	// 	catch (Exception)
	// 	{
	// 		return string.Empty;
	// 	}
	// }

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
