using System;

namespace languageFileChanger.Script.LanguageFile.Validator;

public interface ILanguageStringAttributeType
{
    public bool Validate(string value);
    public string Name { get; }
}