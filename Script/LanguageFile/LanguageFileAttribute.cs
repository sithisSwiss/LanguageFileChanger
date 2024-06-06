using System.Linq;
using Godot;

namespace cfnLanguageFileChanger.Script.LanguageFile;

[GlobalClass]
public partial class LanguageFileAttribute : GodotObject
{
    public readonly LanguageFileConfigurationAttribute Configuration;
    private readonly LanguageFileItem _parent;

    private string _value;
    
    [Signal]
    public delegate void AttributeValueChangedEventHandler(LanguageFileAttribute attribute, string oldValue, string newValue);

    public LanguageFileAttribute(LanguageFileItem parent, LanguageFileConfigurationAttribute configuration, string value)
    {
        Configuration = configuration;
        _parent = parent;
        _value = value;
    }

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

            string oldValue = _value;
            _value = value;
            if (IsValid)
            {
                if (!string.IsNullOrEmpty(_parent.Key))
                {
                    if (_parent.KeyAttribute == this)
                    {
                        XmlScript.ChangeKey(oldValue, value); }
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

    private void Save()
    {
        
    }
}