#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Godot;
using Newtonsoft.Json;

namespace languageFileChanger.Script.LanguageFile;

[GlobalClass]
public sealed partial class LanguageFileHelper : GodotObject
{
    private static LanguageFileConfiguration[]? _configurations;

    public static BaseParseScript Script => BaseParseScript.GetScript(GetCurrentConfiguration());

    public static LanguageFileConfiguration GetCurrentConfiguration() => _configurations?[Math.Clamp(
        Persistent.GetPersistent().SelectedConfigIndex,
        0,
        _configurations.Length - 1)] ?? new LanguageFileConfiguration();

    public static string[] GetConfigurationNames() => _configurations?.Select(x => x.Name).ToArray() ?? Array.Empty<string>();

    public static string GetCurrentLanguageFolderPath() => GetCurrentConfiguration().LanguageFileFolderPath;
    public static string[] GetCurrentLanguageFilePaths()
    {
        if (string.IsNullOrEmpty(GetCurrentConfiguration().LanguageFileFolderPath) || !Directory.Exists(GetCurrentConfiguration().LanguageFileFolderPath))
        {
            return Array.Empty<string>();
        }
        var t = Directory.GetFiles(GetCurrentConfiguration().LanguageFileFolderPath)
            .Where(path => Path.GetExtension(path) == ".xml").ToArray();
        return t;
    }

    public static string[] GetAllKeysFromFirstFile() => GetCurrentLanguageFilePaths().IsEmpty() ? Array.Empty<string>() : Script.GetKeys(GetCurrentLanguageFilePaths().First());

    public static void LoadConfiguration(string path)
    {
        var globalizeFilePath = ProjectSettings.GlobalizePath(path);
        if (!File.Exists(globalizeFilePath))
        {
            return;
        }
        using StreamReader reader = new(globalizeFilePath);
        var json = reader.ReadToEnd();
        var itemConfiguration = JsonConvert.DeserializeObject<List<LanguageFileConfiguration>>(json);
        _configurations = itemConfiguration!.ToArray();

        // ConvertToJson(globalizeFilePath);
    }

    // public static void ConvertToJson(string path)
    // {
    //     XmlDocument doc = new XmlDocument();
    //     var file = Directory.GetFiles(GetCurrentConfiguration().LanguageFileFolderPath).First();
    //     var t = File.ReadAllText(file);
    //     doc.LoadXml(t);
    //     string jsonText = JsonConvert.SerializeXmlNode(doc);
    //     ;
    // }
}