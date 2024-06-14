using System;
using System.Linq;
using Godot;
using Godot.Collections;
using languageFileChanger.Script.LanguageFile.Validator;

namespace languageFileChanger.Script.LanguageFile;

[GlobalClass]
public sealed partial class LanguageStringAttribute : GodotObject
{
    public readonly LanguageFileConfigurationAttribute AttributeConfiguration;

    public readonly ILanguageStringAttributeType AttributeType;

    private string _value;

    public LanguageStringAttribute(ILanguageStringAttributeType attributeType, LanguageFileConfigurationAttribute attributeConfiguration, string value)
    {
        AttributeConfiguration = attributeConfiguration;
        AttributeType = attributeType;
        _value = value;
    }

    public LanguageStringAttribute() { }

    [Signal]
    public delegate void AttributeValueChangedEventHandler(LanguageStringAttribute attribute, string oldValue, string newValue);
    
    public string[] EnumValues => AttributeConfiguration.EnumValues;

    public string Name => AttributeConfiguration.Name;
    public string DisplayName => AttributeConfiguration.DisplayName;

    public bool IsValid => AttributeType.Validate(_value);

    public bool IsTypeOf(string type) => string.Equals(type, AttributeType.Name, StringComparison.CurrentCultureIgnoreCase);
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
                EmitSignal(SignalName.AttributeValueChanged, this, oldValue, value);
            }

        }
    }
}