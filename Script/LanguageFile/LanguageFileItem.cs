using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using Godot;

namespace cfnLanguageFileChanger.Script.LanguageFile;

[GlobalClass]
public sealed partial class LanguageFileItem : GodotObject
{
	private readonly Dictionary<string, LanguageFileAttribute> _attributes = new();
	private readonly Dictionary<string, LanguageFileValue> _valuePerFile = new();
	public string Key => KeyAttribute.Value;
	public LanguageFileAttribute KeyAttribute => GetAttribute(Configuration.Attributes[Configuration.KeyAttributeIndex].Name);
	public LanguageFileAttribute[] Attributes => _attributes.Values.ToArray();
	public LanguageFileConfiguration Configuration { get; init; }

	public static LanguageFileItem CreateNewItem()
	{
		var configuration = LangaugeFileHelper.GetCurrentConfiguration();
		var item = new LanguageFileItem()
		{
			Configuration = configuration
		};
		foreach (var attributeConfiguration in configuration.Attributes)
		{
			var name = attributeConfiguration.Name;
			var value = attributeConfiguration switch
			{
				{ IsInt: true } => "0",
				{ IsFloat: true} => "0.0",
				{ IsBool: true} => "false",
				{ IsString: true } => string.Empty,
				var _ => attributeConfiguration.EnumValues.First()
			};
			item._attributes[name] = new LanguageFileAttribute(item, attributeConfiguration, value);
		}

		foreach (var filePath in LangaugeFileHelper.GetLanguageFilePaths())
		{
			item._valuePerFile[filePath] = new LanguageFileValue(item, filePath, "");
		}

		return item;
	}
	public static LanguageFileItem CreateExistingItem(string key)
	{
		var configuration = LangaugeFileHelper.GetCurrentConfiguration();
		string pathFirstFile = LangaugeFileHelper.GetLanguageFilePaths().First();
		var item = new LanguageFileItem()
		{
			Configuration = configuration
		};
		foreach (var attributeConfiguration in configuration.Attributes)
		{
			var name = attributeConfiguration.Name;
			var value = XmlScript.GetAttribute(key, name, pathFirstFile);
			item._attributes[name] = new LanguageFileAttribute(item, attributeConfiguration, value);
		}

		foreach (var filePath in LangaugeFileHelper.GetLanguageFilePaths())
		{
			item._valuePerFile[filePath] = new LanguageFileValue(item, filePath, XmlScript.GetValue(key, filePath));
		}
		
		return item;
	}
	public void SetAttributeValue(string key, string value) => _attributes[key].Value = value;

	public LanguageFileAttribute GetAttribute(string key) => _attributes[key];

	public void SetValueToFile(string filePath, string value) => _valuePerFile[filePath].Value = value;

	public string[] GetFilePaths() => _valuePerFile.Keys.ToArray();

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
		catch (CultureNotFoundException ex)
		{
			return fileName;
		}
	}
	public string GetValueFromFile(string filePath)
	{
		return _valuePerFile[filePath].Value;
	}
	
	public bool HasTheSameAttributeConfiguration(LanguageFileConfiguration otherConfiguration)
	{
		if (Configuration.Attributes.Length != otherConfiguration.Attributes.Length)
		{
			return false;
		}

		for (var index = 0; index < Configuration.Attributes.Length; index++)
		{
			var attribute1 = Configuration.Attributes[index];
			var attribute2 = otherConfiguration.Attributes[index];
			if (attribute1.Name == attribute2.Name
			    && attribute1.IsBool == attribute2.IsBool
			    && attribute1.IsFloat == attribute2.IsFloat
			    && attribute1.IsInt == attribute2.IsInt
			    && attribute1.IsString == attribute2.IsString
			    && attribute1.EnumValues.All(x => attribute2.EnumValues.Contains(x)))
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
}