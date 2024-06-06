using System.Collections.Generic;
using System.IO;
using System.Linq;
using cfnLanguageFileChanger.Script;
using Godot;
using Newtonsoft.Json;

[GlobalClass]
public partial class LangaugeFileHelper : GodotObject
{
    public static LanguageFileConfiguration[] GetConfigurations() => Configurations;
    private static readonly LanguageFileConfiguration[] Configurations = LoadConfiguration();

    public static string[] GetLanguageFilePaths() =>
        Directory.GetFiles(GetCurrentConfiguration().LanguageFileFolderPath).Where(path => Path.GetExtension(path) == ".xml").ToArray();

    public static LanguageFileConfiguration GetCurrentConfiguration() => Configurations[Persistent.GetPersistent().SelectedConfigIndex];

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