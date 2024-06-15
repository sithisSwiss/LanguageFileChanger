using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Godot;
using Newtonsoft.Json;

namespace languageFileChanger.Script;

[GlobalClass]
public partial class Persistent : Resource
{
    private static readonly Persistent Instance = LoadPersistent();
    private int _selectedConfigIndex;

    private string _stepSizeAsJson;

    [Export]
    public int SelectedConfigIndex
    {
        get => _selectedConfigIndex;
        set
        {
            _selectedConfigIndex = value;
            SaveData();
        }
    }

    [Export]
    public string StepSizeAsJson
    {
        get => _stepSizeAsJson;
        set
        {
            _stepSizeAsJson = value;
            SaveData();
        }
    }

    private static string FilePath => OS.HasFeature("editor")
        ? ProjectSettings.GlobalizePath("res://Script/LanguageFileChanger_Setting.tres")
        : OS.GetExecutablePath().GetBaseDir() + "/LanguageFileChanger_Setting.tres";

    private IReadOnlyDictionary<string, float> StepSizes
    {
        get => string.IsNullOrEmpty(StepSizeAsJson)
            ? new Dictionary<string, float>()
            : JsonConvert.DeserializeObject<Dictionary<string, float>>(StepSizeAsJson);
        set => StepSizeAsJson = JsonConvert.SerializeObject(value);
    }

    public static Persistent GetPersistent() => Instance;

    public float GetStepSize(string fieldName, float defaultValue) => StepSizes.GetValueOrDefault(fieldName, defaultValue);

    public void SetStepSize(string fieldName, float stepSize)
    {
        Dictionary<string, float> dict = StepSizes.ToDictionary(x => x.Key, x => x.Value);
        dict[fieldName] = stepSize;
        StepSizes = dict;
    }

    private static Persistent LoadPersistent()
    {
        if (!File.Exists(FilePath))
        {
            return new Persistent();
        }

        var loaded = ResourceLoader.Load(FilePath);
        return loaded as Persistent ?? new Persistent();
    }

    private void SaveData() => ResourceSaver.Save(this, FilePath);
}