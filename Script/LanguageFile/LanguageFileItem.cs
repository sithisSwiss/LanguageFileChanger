using System.Linq;
using Godot;
using Godot.Collections;

[GlobalClass]
public sealed partial class LanguageFileItem : GodotObject
{
	private Dictionary<string, string> _attributes = new();
	public Dictionary<string, string> Attributes => Clone(_attributes);
	private static LanguageFileConfiguration Configuration => LanguageFileConfiguration.GetConfiguration();

	private string _value;

	[Signal]
	public delegate void ItemChangedEventHandler(LanguageFileItem item);

	public string Value
	{
		get => _value;
		set
		{
			_value = value;
			EmitSignal(nameof(ItemChanged), this);
		}
	}
	public string Key => _attributes[Configuration.Attributes[Configuration.KeyAttributeIndex].Name];

	public static LanguageFileItem CreateItemFromFile(string key, string path)
	{
		var item = new LanguageFileItem();
		foreach(var attributeConfiguration in Configuration.Attributes)
		{
			var name = attributeConfiguration.Name;
			var value = XmlScript.GetAttribute(key, name, path);
			item._attributes[name] = value;
		}
		item._value = XmlScript.GetValue(key, path);
		return item;
	}

	public static LanguageFileItem CreateItem(Dictionary<string, string> attributes, string value = "")
	{
		var item = new LanguageFileItem();
		item._attributes = attributes;
		item._value = value;
		return item;
	}

	public void SetAttributeValue(string key, string value)
	{
		_attributes[key] = value;
		EmitSignal(nameof(ItemChanged), this);
	}
	public string GetAttributeValue(string key)
	{
		return _attributes.TryGetValue(key, out var value) ? value : string.Empty;
	}

	public bool Validate(string[] existingKeys)
	{
		var isValid = true;

		if (!_attributes.TryGetValue(Configuration.Attributes[Configuration.KeyAttributeIndex].Name, out var key))
		{
			return false;
		}

		if (!existingKeys.Contains(_attributes[key]))
		{
			return false;
		}

		foreach (var attributeConfiguration in Configuration.Attributes)
		{
			var name = attributeConfiguration.Name;
			if (!_attributes.TryGetValue(name, out var value))
			{
				return false;
			}

			isValid &= attributeConfiguration switch
			{
				{ IsInt: true } => int.TryParse(value, out var _),
				{ IsFloat: true } => float.TryParse(value, out var _),
				{ IsBool: true } => bool.TryParse(value, out var _),
				{ IsString: true } => value.Length > 0,
				var _ => attributeConfiguration.EnumValues.Contains(value)
			};
		}

		return isValid;
	}

	private static Dictionary<string, string> Clone(Dictionary<string, string> attributes)
	{
		var clone = new Dictionary<string, string>();
		foreach (var (key, value) in attributes)
		{
			clone[key] = value;
		}

		return clone;
	}
}
