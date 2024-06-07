using Newtonsoft.Json;

namespace cfnLanguageFileChanger.Script.LanguageFile;

public class LanguageFileConfiguration
{
    [JsonProperty(nameof(Name))] public string Name { get; private set; }

    [JsonProperty(nameof(LanguageFileFolderPath))]
    public string LanguageFileFolderPath { get; private set; }

    [JsonProperty(nameof(LanguageTagRegexPattern))]
    public string LanguageTagRegexPattern { get; private set; }

    [JsonProperty(nameof(ItemTagName))] public string ItemTagName { get; private set; }

    [JsonProperty(nameof(KeyAttributeIndex))]
    public int KeyAttributeIndex { get; private set; }

    [JsonProperty(nameof(Attributes))] public LanguageFileConfigurationAttribute[] Attributes { get; private set; }
}