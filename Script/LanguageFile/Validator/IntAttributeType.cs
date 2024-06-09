namespace cfnLanguageFileChanger.Script.LanguageFile.Validator;

public class IntAttributeType : ILanguageStringAttributeType
{
    public bool Validate(string value) => int.TryParse(value, out var _);
    public string Name => "Int";
}