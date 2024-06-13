#nullable enable
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using cfnLanguageFileChanger.Script.LanguageFile.Validator;
using Godot;

namespace cfnLanguageFileChanger.Script.LanguageFile;

[GlobalClass]
public sealed partial class LanguageString : GodotObject
{
    private readonly Dictionary<string, LanguageStringAttribute> _attributes = new();
    private readonly Dictionary<string, LanguageStringValue> _valuePerFile = new();
    public string Key => KeyAttribute.Value;
    public LanguageStringAttribute KeyAttribute => GetAttribute(Configuration.Attributes[Configuration.KeyAttributeIndex].Name);
    public LanguageStringAttribute[] Attributes => _attributes.Values.ToArray();
    public LanguageFileConfiguration Configuration { get; init; }

    public static LanguageString CreateNewItem()
    {
        var configuration = LanguageFileHelper.GetCurrentConfiguration();
        var keyAttributeName = configuration.Attributes[configuration.KeyAttributeIndex].Name;
        var item = new LanguageString { Configuration = configuration };
        foreach (var attributeConfiguration in configuration.Attributes)
        {
            var name = attributeConfiguration.Name;
            var value = string.Empty;
            if (name != keyAttributeName)
            {
                value = attributeConfiguration.Type.ToLower() switch
                {
                    "int" => "0",
                    "float" => "0.0",
                    "string" => string.Empty,
                    "enum" => attributeConfiguration.EnumValues!.First(),
                    var _ => throw new ArgumentOutOfRangeException()
                };
            }

            item._attributes[name] = new LanguageStringAttribute(CreateAttributeType(attributeConfiguration), attributeConfiguration, value);
            item.SubscribeAttributeChangeEvent(item._attributes[name], keyAttributeName == name);
        }

        foreach (var filePath in LanguageFileHelper.GetLanguageFilePaths())
        {
            var value = new LanguageStringValue("");
            item.SubscribeValueChanged(value, filePath);
            item._valuePerFile[filePath] = value;
        }

        return item;
    }

    public static LanguageString CreateExistingItem(string key)
    {
        var configuration = LanguageFileHelper.GetCurrentConfiguration();
        var keyAttributeName = configuration.Attributes[configuration.KeyAttributeIndex].Name;
        var item = new LanguageString { Configuration = configuration };
        foreach (var attributeConfiguration in configuration.Attributes)
        {
            var name = attributeConfiguration.Name;
            var value = LanguageFileHelper.Script.GetAttribute(key, name, LanguageFileHelper.GetLanguageFilePaths().First());
            item._attributes[name] = new LanguageStringAttribute(CreateAttributeType(attributeConfiguration), attributeConfiguration, value);
            item.SubscribeAttributeChangeEvent(item._attributes[name], keyAttributeName == name);
        }

        foreach (var filePath in LanguageFileHelper.GetLanguageFilePaths())
        {
            var value = new LanguageStringValue(LanguageFileHelper.Script.GetValue(key, filePath));
            item.SubscribeValueChanged(value, filePath);
            item._valuePerFile[filePath] = value;
        }

        return item;
    }

    public void SetAttributeValue(string key, string value) => _attributes[key].Value = value;

    public LanguageStringAttribute GetAttribute(string key) => _attributes[key];

    public void SetValueToFile(string filePath, string value) => _valuePerFile[filePath].Value = value;

    public string GetFolderPath() => Configuration.LanguageFileFolderPath;

    public string GetLanguage(string fileName)
    {
        var languageTag = Regex.Match(fileName, Configuration.LanguageTagRegexPattern).Groups[1].Value;

        if (string.IsNullOrEmpty(languageTag))
        {
            return fileName;
        }

        try
        {
            return $"{new CultureInfo(languageTag).EnglishName} ({languageTag})";
        }
        catch (CultureNotFoundException)
        {
            return fileName;
        }
    }

    public void RemoveItemFromFile() => LanguageFileHelper.Script.RemoveItem(Key);

    public string GetValueFromFile(string filePath) => _valuePerFile.TryGetValue(filePath, out var value) ? value.Value : string.Empty;

    public string GetValueFromEnglishFile()
    {
        var englishFilePath = _valuePerFile.Keys.FirstOrDefault(x => x.Contains("en"));
        return string.IsNullOrEmpty(englishFilePath) ? string.Empty : GetValueFromFile(englishFilePath);
    }

    public bool HasTheSameAttributeConfiguration(LanguageString otherItem)
    {
        if (Configuration.Attributes.Length != otherItem.Configuration.Attributes.Length)
        {
            return false;
        }

        for (var index = 0; index < Configuration.Attributes.Length; index++)
        {
            var attribute1 = Configuration.Attributes[index];
            var attribute2 = otherItem.Configuration.Attributes[index];
            if (attribute1.Name == attribute2.Name
                && attribute1.Type.ToLower() == attribute2.Type.ToLower()
                && CompareLists(attribute1.EnumValues, attribute2.EnumValues))
            {
                continue;
            }

            return false;
        }

        return true;
    }

    public bool Validate(string[] existingKeys)
    {
        var t = !KeyAreEmpty() && !KeyAlreadyExist() && ItemHasAllAttributes() && AllAttributesAreValid();
        return t;
        bool KeyAreEmpty() => string.IsNullOrEmpty(Key);
        bool KeyAlreadyExist() => existingKeys.Contains(Key);

        bool ItemHasAllAttributes() => Configuration
            .Attributes
            .Select(attributeConfig => attributeConfig.Name)
            .All(nameOfAttribute => _attributes.ContainsKey(nameOfAttribute));

        bool AllAttributesAreValid() => _attributes.All(x => x.Value.IsValid);
    }

    private static bool CompareLists<T>(IEnumerable<T>? collection1, IEnumerable<T>? collection2)
    {
        if (collection1 == null)
        {
            return collection2 == null;
        }
        else if (collection2 == null)
        {
            return false;
        }

        List<T> list1 = collection1.ToList();
        List<T> list2 = collection2.ToList();
        List<T> firstNotSecond = list1.Except(list2).ToList();
        List<T> secondNotFirst = list2.Except(list1).ToList();
        return !firstNotSecond.Any() && !secondNotFirst.Any();
    }

    private static ILanguageStringAttributeType CreateAttributeType(LanguageFileConfigurationAttribute attributeConfiguration)
    {
        return attributeConfiguration.Type.ToLower() switch
        {
            "int" => new IntAttributeType(),
            "float" => new FloatAttributeType(),
            "string" => new StringAttributeType(),
            "enum" => new ListAttributeType(attributeConfiguration),
            var _ => throw new ArgumentOutOfRangeException()
        };
    }

    private void SubscribeAttributeChangeEvent(LanguageStringAttribute attribute, bool isKey)
    {
        attribute.AttributeValueChanged += OnAttributeValueChanged;
        return;

        void OnAttributeValueChanged(LanguageStringAttribute attr, string oldValue, string newValue)
        {
            if (isKey)
            {
                LanguageFileHelper.Script.ChangeKey(oldValue, newValue);
            }
            else
            {
                LanguageFileHelper.Script.SaveAttribute(this, attr);
            }
        }
    }

    private void SubscribeValueChanged(LanguageStringValue value, string path)
    {
        value.ValueChanged += OnValueChanged;
        return;

        void OnValueChanged(LanguageStringValue val, string oldValue, string newValue)
        {
            LanguageFileHelper.Script.SaveValue(this, val, path);
        }
    }
}