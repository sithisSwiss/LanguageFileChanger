#nullable enable
using System;

namespace languageFileChanger.Script.LanguageFile;

public class BaseParseScript
{
    private static BaseParseScript? _instance;
    public static BaseParseScript GetScript(LanguageFileConfiguration configuration)
    {
        var newInstance = configuration.FileType.ToLower() switch
        {
            "xml" => new XmlParseScript("TextPool", configuration.ItemTagName, configuration.Attributes[configuration.KeyAttributeIndex].Name),
            var _ => new BaseParseScript()
        };
        if (_instance == null || newInstance.GetType() != _instance.GetType())
        {
            _instance = newInstance;
        }

        return _instance;
    }

    public virtual string[] GetKeys(string path) => Array.Empty<string>();
    public virtual void CreateEntry(LanguageString item) {}
    public virtual void ChangeKey(string oldKey, string newKey) { }
    public virtual string GetAttribute(string key, string attributeName, string path) => string.Empty;
    public virtual void SaveAttribute(LanguageString item, LanguageStringAttribute attr) { }
    public virtual string GetValue(string key, string path) => string.Empty;
    public virtual void SaveValue(LanguageString item, LanguageStringValue value, string filePath) { }
    public virtual void RemoveItem(string key) { }
}