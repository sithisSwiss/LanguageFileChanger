using Godot;

namespace cfnLanguageFileChanger.Script.LanguageFile;

[GlobalClass]
public sealed partial class LanguageStringValue : GodotObject
{
    private string _value;

    public LanguageStringValue(string value)
    {
        _value = value;
    }
    [Signal]
    public delegate void ValueChangedEventHandler(LanguageStringValue value, string oldValue, string newValue);

    public string Value
    {
        get => _value;
        set
        {
            var oldValue = _value;
            _value = value;
            EmitSignal(SignalName.ValueChanged, this, value, oldValue);
        }
    }
}