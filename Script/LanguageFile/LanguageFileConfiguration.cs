#nullable enable
using System;
using Newtonsoft.Json;

namespace cfnLanguageFileChanger.Script.LanguageFile;

public class LanguageFileConfiguration
{
    [JsonProperty(nameof(FileType))] public string FileType { get; private set; } = string.Empty;
    [JsonProperty(nameof(Name))] public string Name { get; private set; } = string.Empty;

    [JsonProperty(nameof(LanguageFileFolderPath))]
    public string LanguageFileFolderPath { get; private set; } = string.Empty;

    [JsonProperty(nameof(LanguageTagRegexPattern))]
    public string LanguageTagRegexPattern { get; private set; } = string.Empty;

    [JsonProperty(nameof(ItemTagName))] public string ItemTagName { get; set; } = string.Empty;
    [JsonProperty(nameof(RootTagName))] public string RootTagName { get; set; } = string.Empty;

    [JsonProperty(nameof(KeyAttributeIndex))]
    public int KeyAttributeIndex { get; private set; }

    [JsonProperty(nameof(Attributes))]
    public LanguageFileConfigurationAttribute[] Attributes { get; private set; } = Array.Empty<LanguageFileConfigurationAttribute>();
}