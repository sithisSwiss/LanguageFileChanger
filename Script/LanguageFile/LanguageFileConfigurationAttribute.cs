using System;
using Newtonsoft.Json;

namespace cfnLanguageFileChanger.Script.LanguageFile;

public sealed class LanguageFileConfigurationAttribute
{
    [JsonProperty(nameof(Name))] public string Name { get; set; }
    [JsonProperty(nameof(DisplayName))] public string DisplayName { get; set; }
    [JsonProperty(nameof(IsInt))] public bool IsInt { get; set; }
    [JsonProperty(nameof(IsString))] public bool IsString { get; set; }
    [JsonProperty(nameof(IsBool))] public bool IsBool { get; set; }
    [JsonProperty(nameof(IsFloat))] public bool IsFloat { get; set; }
    [JsonProperty(nameof(EnumValues))] public string[] EnumValues { get; set; } = Array.Empty<string>();
}