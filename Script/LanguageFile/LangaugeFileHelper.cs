#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Godot;
using Newtonsoft.Json;
using Array = Godot.Collections.Array;
using FileAccess = Godot.FileAccess;

namespace cfnLanguageFileChanger.Script.LanguageFile;

[GlobalClass]
public sealed partial class LangaugeFileHelper : GodotObject
{
    private static LanguageFileConfiguration[]? _configurations;
    public static string[] GetConfigurationNames() => _configurations?.Select(x => x.Name).ToArray() ?? System.Array.Empty<string>();

    public static string[] GetLanguageFilePaths() =>
        Directory.GetFiles(GetCurrentConfiguration()?.LanguageFileFolderPath ?? string.Empty).Where(path => Path.GetExtension(path) == ".xml").ToArray();

    public static string GetEnglishLanguageFilePath() => GetLanguageFilePaths().FirstOrDefault(x => x.Contains("en")) ?? GetLanguageFilePaths().First();

    public static LanguageFileConfiguration? GetCurrentConfiguration() => _configurations?[Math.Clamp(
        Persistent.GetPersistent().SelectedConfigIndex,
        0,
        _configurations.Length - 1)];

    public static void LoadConfiguration(string path)
    {
        var globalizePath = ProjectSettings.GlobalizePath(path);
        using StreamReader reader = new(globalizePath);
        var json = reader.ReadToEnd();
        var itemConfiguration = JsonConvert.DeserializeObject<List<LanguageFileConfiguration>>(json);
        _configurations = itemConfiguration!.ToArray();
    }
}