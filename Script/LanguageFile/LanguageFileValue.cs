namespace cfnLanguageFileChanger.Script.LanguageFile;

public class LanguageFileValue
{
    private readonly LanguageFileItem _parent;
    private string _value;

    public LanguageFileValue(LanguageFileItem parent, string filePath, string value)
    {
        _parent = parent;
        FilePath = filePath;
        _value = value;
    }

    public string FilePath { get; }

    public string Value
    {
        get => _value;
        set
        {
            _value = value;
            Save();
        }
    }

    private void Save()
    {
        if (!string.IsNullOrEmpty(_parent.Key))
        {
            XmlScript.SaveValue(_parent, this);
        }
    }
}