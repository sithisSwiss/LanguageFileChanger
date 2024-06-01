using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text.RegularExpressions;
using cfnLanguageFileChanger.Script;
using Godot;
using Newtonsoft.Json;

[GlobalClass]
public partial class LanguageFileConfiguration : GodotObject
{
	private static readonly LanguageFileConfiguration[] Configurations = LoadConfiguration();
	[JsonProperty(nameof(Name))] public string Name { get; private set; }

	[JsonProperty(nameof(LanguageFilePath))]
	public string LanguageFilePath { get; private set; }

	[JsonProperty(nameof(LanguageTagRegexPattern))]
	public string LanguageTagRegexPattern { get; private set; }

	[JsonProperty(nameof(ItemTagName))] public string ItemTagName { get; private set; }

	[JsonProperty(nameof(KeyAttributeIndex))]
	public int KeyAttributeIndex { get; private set; }

	[JsonProperty(nameof(Attributes))] public LanguageFileConfigurationAttribute[] Attributes { get; private set; }
	public static LanguageFileConfiguration[] GetConfigurations() => Configurations;

	public static LanguageFileConfiguration GetCurrentConfiguration() => Configurations[Persistent.GetPersistent().SelectedConfigIndex];

	public static string GetLanguage(string fileName, LanguageFileConfiguration configuration)
	{
		var languageTag = Regex.Match(fileName, configuration.LanguageTagRegexPattern).Groups[1].Value;

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

	private static LanguageFileConfiguration[] LoadConfiguration()
	{
		var newConfigurationPath = ProjectSettings.GlobalizePath("res://Script/LanguageFile/LanguageFileConfiguration.json");
#if DEBUG
		using StreamReader reader = new(newConfigurationPath);
#else
		string configurationPath = OS.GetExecutablePath().GetBaseDir() + "/LanguageFileConfiguration.json"; 
		if (!File.Exists(configurationPath))
		{
			File.Copy(newConfigurationPath, configurationPath);
		}
		using StreamReader reader = new(configurationPath);
#endif

		var json = reader.ReadToEnd();
		var itemConfiguration = JsonConvert.DeserializeObject<List<LanguageFileConfiguration>>(json);
		return itemConfiguration.ToArray();
	}
}
