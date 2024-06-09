using System.Linq;

namespace cfnLanguageFileChanger.Script.LanguageFile.Validator;

public class ListAttributeType : ILanguageStringAttributeType
{
    private readonly LanguageFileConfigurationAttribute _attributeConfiguration;

    public ListAttributeType(LanguageFileConfigurationAttribute attributeConfiguration) => _attributeConfiguration = attributeConfiguration;

    public bool Validate(string value) => _attributeConfiguration.EnumValues.Contains(value);
    public string Name => "List";
}