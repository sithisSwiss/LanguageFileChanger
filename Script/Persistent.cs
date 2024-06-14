using System.IO;
using Godot;

namespace languageFileChanger.Script;

[GlobalClass]
public partial class Persistent : Resource
{
    private static readonly Persistent Instance = LoadPersistent();
    private int _selectedConfigIndex;

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

#if DEBUG
    private static string FilePath => ProjectSettings.GlobalizePath("res://Script/cfn-languageFileChanger.tres");
#else
    private static string FilePath => OS.GetExecutablePath().GetBaseDir() + "/cfn-languageFileChanger.tres";
#endif

    public static Persistent GetPersistent() => Instance;

    public static Persistent LoadPersistent()
    {
        if (!File.Exists(FilePath))
        {
            return new Persistent();
        }

        var loaded = ResourceLoader.Load(FilePath);
        return loaded as Persistent ?? new Persistent();
    }

    private void SaveData()
    {
        ResourceSaver.Save(this, FilePath);
    }
}