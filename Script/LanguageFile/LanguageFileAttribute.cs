using System.Linq;
using Godot;
using Godot.Collections;

namespace cfnLanguageFileChanger.Script.LanguageFile;

[GlobalClass]
public sealed partial class LanguageFileAttribute : GodotObject
{
    public readonly LanguageFileConfigurationAttribute Configuration;

    // Cannot be an Enum, because gdscript doesnt support enums
    public Dictionary<string, int> Types = new()
    {
        { "Int", 0 },
        { "Float", 1 },
        { "Bool", 2 },
        { "String", 3 },
        { "List", 4 }
    };
    private readonly LanguageFileItem _parent;

    private string _value;

    public LanguageFileAttribute(LanguageFileItem parent, LanguageFileConfigurationAttribute configuration, string value)
    {
        Configuration = configuration;
        _parent = parent;
        _value = value;
    }

    public LanguageFileAttribute() { }

    [Signal]
    public delegate void AttributeValueChangedEventHandler(LanguageFileAttribute attribute, string oldValue, string newValue);

    public int Type => Configuration switch
    {
        { IsInt: true } => Types["Int"],
        { IsFloat: true } => Types["Float"],
        { IsBool: true } => Types["Bool"],
        { IsString: true } => Types["String"],
        var _ => Types["List"]
    };

    public string[] EnumValues => Configuration.EnumValues;

    public string Name => Configuration.Name;
    public string DisplayName => Configuration.DisplayName;

    public bool IsValid => ValidateAttribute();

    public string Value
    {
        get => _value;
        set
        {
            if (_value == value)
            {
                return;
            }

            var oldValue = _value;
            _value = value;
            if (IsValid)
            {
                if (!string.IsNullOrEmpty(_parent.Key))
                {
                    if (_parent.KeyAttribute == this)
                    {
                        XmlScript.ChangeKey(oldValue, value);
                    }
                    else
                    {
                        XmlScript.SaveAttribute(_parent, this);
                    }
                }
            }

            EmitSignal(SignalName.AttributeValueChanged, this, value, oldValue);
        }
    }

    private bool ValidateAttribute()
    {
        return Configuration switch
        {
            { IsInt: true } => int.TryParse(_value, out var _),
            { IsFloat: true } => float.TryParse(_value, out var _),
            { IsBool: true } => bool.TryParse(_value, out var _),
            { IsString: true } => _value.Length > 0,
            var _ => Configuration.EnumValues.Contains(_value)
        };
    }

    private void Save() { }
}