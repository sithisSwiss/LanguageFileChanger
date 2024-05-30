using System;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using Godot;
using Godot.Collections;
using Array = System.Array;

public partial class XmlScript : GodotObject
{
    public enum RequestField
    {
        Info,
        Field,
        Layout,
        Value
    }

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

    public static void AddItem(GodotObject item, string path, bool isSoftware)
    {
        try
        {
            using var handler = new XDocumentHandler(path);
            var element = new XElement("Item");
            SetAttributes(ref element, item, isSoftware);
            handler.Doc.Root!.Add(element);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public static string GetValue(string key, string path) => Get(key, RequestField.Value, path);
    public static string GetInfo(string key, string path) => Get(key, RequestField.Info, path);
    public static string GetField(string key, string path) => Get(key, RequestField.Field, path);
    public static string GetLayout(string key, string path) => Get(key, RequestField.Layout, path);

    public static void SaveValue(string key, string path, string value)
    {
        try
        {
            using var handler = new XDocumentHandler(path);
            var element = GetSpecificElement(key, handler.Doc);
            element.Value = value;
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
            element.SetAttributeValue("key", newKey);
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public static void SaveAttribute(GodotObject item, string path, bool isSoftware)
    {
        try
        {
            using var handler = new XDocumentHandler(path);
            var element = GetSpecificElement(item.Get("key").ToString(), handler.Doc);
            SetAttributes(ref element, item, isSoftware);
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
            using var handler = new XDocumentHandler(path);
            GetSpecificElement(key, handler.Doc).Remove();
        }
        catch (Exception)
        {
            // ignored
        }
    }

    private static string Get(string key, RequestField field, string path)
    {
        try
        {
            return field switch
            {
                RequestField.Info => GetSpecificElement(key, XDocument.Load(path)).Attribute("info")!.Value,
                RequestField.Field => GetSpecificElement(key, XDocument.Load(path)).Attribute("field")!.Value,
                RequestField.Layout => GetSpecificElement(key, XDocument.Load(path)).Attribute("layout")!.Value,
                RequestField.Value => GetSpecificElement(key, XDocument.Load(path)).Value,
                var _ => string.Empty
            };
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }

    private static XElement GetSpecificElement(string key, XDocument doc)
    {
        return doc.Root!.Elements().First(x => x.Attribute("key")!.Value == key);
    }

    private static void SetAttributes(ref XElement element, GodotObject item, bool isSoftware)
    {
        element.SetAttributeValue("key", item.Get("key").ToString());
        element.SetAttributeValue("info", item.Get("info").ToString());
        if (isSoftware)
        {
            return;
        }

        element.SetAttributeValue("field", (string)item.Get("field"));
        var layoutIndex = (int)item.Get("layout");
        var layoutDictionary = (Dictionary)item.Get("LAYOUT_TYPES");
        var layout = layoutDictionary.First(x => (int)x.Value == layoutIndex).Key;
        element.SetAttributeValue("layout", (string)layout);
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