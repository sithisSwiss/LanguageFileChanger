using System;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using Godot;

public partial class XmlScript : GodotObject
{
    public static string[] GetKeys(string path)
    {
        try
        {
            return XDocument.Load(path).Root!.Elements().Select(item => item.Attribute("key")!.Value).ToArray();
        }
        catch (Exception)
        {
            return Array.Empty<string>();
        }
    }

    public static void AddKeySoftware(string key, string path, string info)
    {
        try
        {
            var root = XDocument.Load(path).Root!;
            var newItem = new XElement(
                "Item",
                null,
                new XAttribute("key", key),
                new XAttribute("info", info));
            root.Add(newItem);
            root.Save(path);
            RemoveEmptyNamespace(path);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public static void AddKeyFirmware(string key, string path, string info, string layout, string field)
    {
        try
        {
            var root = XDocument.Load(path).Root!;
            var newItem = new XElement(
                "Item",
                null,
                new XAttribute("key", key),
                new XAttribute("info", info),
                new XAttribute("layout", layout),
                new XAttribute("field", field));
            root.Add(newItem);
            root.Save(path);
            RemoveEmptyNamespace(path);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public static string GetInfo(string key, string path)
    {
        try
        {
            return XDocument.Load(path).Root!.Elements().First(item => item.Attribute("key")!.Value == key).Attribute("info")!.Value;
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }

    public static string GetLayout(string key, string path)
    {
        try
        {
            return XDocument.Load(path).Root!.Elements().First(item => item.Attribute("key")!.Value == key).Attribute("layout")!.Value;
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }

    public static string GetField(string key, string path)
    {
        try
        {
            return XDocument.Load(path).Root!.Elements().First(item => item.Attribute("key")!.Value == key).Attribute("field")!.Value;
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
            return XDocument.Load(path).Root!.Elements().First(item => item.Attribute("key")!.Value == key).Value;
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }

    public static void SaveValue(string key, string path, string value)
    {
        try
        {
            var root = XDocument.Load(path).Root!;
            var element = root.Elements().First(x => x.Attribute("key")!.Value == key);
            element.Value = value;
            root.Save(path);
            RemoveEmptyNamespace(path);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public static void SaveAttributeSoftware(string key, string path, string info)
    {
        try
        {
            var root = XDocument.Load(path).Root!;
            var element = root.Elements().First(x => x.Attribute("key")!.Value == key);
            element.SetAttributeValue("info", info);
            root.Save(path);
            RemoveEmptyNamespace(path);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public static void SaveAttributeFirmware(string key, string path, string info, string field, string layout)
    {
        try
        {
            var root = XDocument.Load(path).Root!;
            var element = root.Elements().First(x => x.Attribute("key")!.Value == key);
            element.SetAttributeValue("info", info);
            element.SetAttributeValue("field", field);
            element.SetAttributeValue("layout", layout);
            root.Save(path);
            RemoveEmptyNamespace(path);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public static void RemoveItem(string key, string path)
    {
        try
        {
            var root = XDocument.Load(path).Root!;
            root.Elements().First(x => x.Attribute("key")!.Value == key).Remove();
            root.Save(path);
            RemoveEmptyNamespace(path);
        }
        catch (Exception)
        {
            // ignored
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
}