#nullable enable
using System;
using Newtonsoft.Json;

namespace cfnLanguageFileChanger.Script.LanguageFile;

public sealed class LanguageFileConfigurationAttribute
{
    [JsonProperty(nameof(Name))] public string Name { get; set; } = null!;
    [JsonProperty(nameof(DisplayName))] public string DisplayName { get; set; } = null!;
    [JsonProperty(nameof(Type))] public string Type { get; set; } = null!;
    [JsonProperty(nameof(EnumValues))] public string[]? EnumValues { get; set; }
}