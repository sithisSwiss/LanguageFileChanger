namespace cfnLanguageFileChanger.Script.LanguageFile.Validator;

public class FloatAttributeType : ILanguageStringAttributeType
{
    public bool Validate(string value) => float.TryParse(value, out var _);
    public string Name => "Float";
}