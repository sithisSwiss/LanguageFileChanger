#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml.Linq;

namespace languageFileChanger.Script.LanguageFile;

public sealed class XmlParseScript: BaseParseScript
{
    private readonly string _itemTagName;
    private readonly string _keyName;
    private static Func<XDocument, XElement> GetRootFromXDocument => doc => doc.Root!;

    private Func<XElement, IEnumerable<XElement>> GetItemsInRoot =>
        root => root.Elements().Where(x => x.Name.LocalName == _itemTagName);

    internal XmlParseScript(string rootTagName, string itemTagName, string keyName)
    {
        _itemTagName = itemTagName;
        _keyName = keyName;
    }
    
    public override string[] GetKeys(string path)
    {
        try
        {
            var root = GetRootFromXDocument!(XDocument.Load(path));
            IEnumerable<XElement> elements = GetItemsInRoot!(root);
            return elements.Select(item => item.Attribute(_keyName)!.Value).ToArray();
        }
        catch (Exception)
        {
            return Array.Empty<string>();
        }
    }

    public override void CreateEntry(LanguageString item)
    {
        try
        {
            foreach (var path in LanguageFileHelper.GetLanguageFilePaths())
            {
                using var handler = new XDocumentHandler(path);
                var element = new XElement(_itemTagName, item.GetValueFromFile(path));
                foreach (var attribute in item.Attributes)
                {
                    element.SetAttributeValue(attribute.Name, attribute.Value);
                }
                GetRootFromXDocument(handler.Doc).Add(element);
            }
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public override string GetAttribute(string key, string attributeName, string path)
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

    public override string GetValue(string key, string path)
    {
        try
        {
            return GetSpecificElement(key, XDocument.Load(path))!.Value;
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }

    public override void SaveValue(LanguageString item, LanguageStringValue value, string filePath)
    {
        try
        {
            using var handler = new XDocumentHandler(filePath);
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

    public override void SaveAttribute(LanguageString item, LanguageStringAttribute attr)
    {
        try
        {
            foreach (var path in LanguageFileHelper.GetLanguageFilePaths())
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

    public override void ChangeKey(string oldKey, string newKey)
    {
        try
        {
            foreach (var path in LanguageFileHelper.GetLanguageFilePaths())
            {
                using var handler = new XDocumentHandler(path);
                var element = GetSpecificElement(oldKey, handler.Doc);
                element?.SetAttributeValue(_keyName, newKey);
            }
        }
        catch (Exception)
        {
            // ignored
        }
    }

    public override void RemoveItem(string key)
    {
        try
        {
            foreach (var path in LanguageFileHelper.GetLanguageFilePaths())
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

    private XElement? GetSpecificElement(string key, XDocument doc)
    {
        var root = GetRootFromXDocument(doc);
        IEnumerable<XElement> elements = GetItemsInRoot(root);
        return elements.FirstOrDefault(x => x.Attribute(_keyName)!.Value == key);
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