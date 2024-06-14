namespace languageFileChanger.Script.LanguageFile.Validator;

public class StringAttributeType : ILanguageStringAttributeType
{
    public bool Validate(string value) => value.Length > 0;
    public string Name => "String";
}