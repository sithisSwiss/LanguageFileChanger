using System.Collections.Generic;
using System.IO;
using Godot;
using Newtonsoft.Json;

[GlobalClass]
public partial class LanguageFileConfiguration : GodotObject
{
    public static int CurrentLanguageFileConfigurationIndex { get; set; } = 0;
    public string Name { get; set; }
    public string RootTagName { get; set; }
    public string ItemTagName { get; set; }
    public int KeyAttributeIndex { get; set; }
    public LanguageFileConfigurationAttribute[] Attributes { get; set; }
    private static string ConfigurationPath => OS.GetExecutablePath().GetBaseDir() + "/LanguageFileConfiguration.json";
    private static LanguageFileConfiguration[] Configurations => LoadConfiguration(ConfigurationPath);
    public static LanguageFileConfiguration GetConfiguration() => Configurations[CurrentLanguageFileConfigurationIndex];

    private static LanguageFileConfiguration[] LoadConfiguration(string path)
    {
        using StreamReader reader = new(path);
        var json = reader.ReadToEnd();
        var itemConfiguration = JsonConvert.DeserializeObject<List<LanguageFileConfiguration>>(json);
        return itemConfiguration.ToArray();
    }
}