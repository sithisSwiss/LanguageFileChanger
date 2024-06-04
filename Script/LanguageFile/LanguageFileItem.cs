using System.Linq;
using Godot;
using Godot.Collections;

[GlobalClass]
public sealed partial class LanguageFileItem : GodotObject
{
	private Dictionary<string, string> _attributes = new();

	private string _value;

	[Signal]
	public delegate void ItemChangedEventHandler(LanguageFileItem item);

	public Dictionary<string, string> Attributes => Clone(_attributes);

	public string Key => GetAttributeValue(Configuration.Attributes[Configuration.KeyAttributeIndex].Name);

	public string Value
	{
		get => _value;
		set
		{
			_value = value;
			EmitSignal(nameof(ItemChanged), this);
		}
	}

	private static LanguageFileConfiguration Configuration => LanguageFileConfiguration.GetCurrentConfiguration();

	public LanguageFileItem()
	{
		foreach (var attributeConfiguration in Configuration.Attributes)
		{
			var name = attributeConfiguration.Name;
			_attributes[name] = attributeConfiguration switch
			{
				{ IsInt: true } => "0",
				{ IsFloat: true} => "0.0",
				{ IsBool: true} => "false",
				{ IsString: true } => string.Empty,
				var _ => attributeConfiguration.EnumValues.First()
			};
		}
	}
	public static LanguageFileItem CreateItemFromFile(string key, string path)
	{
		var item = new LanguageFileItem();
		foreach (var attributeConfiguration in Configuration.Attributes)
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
		//EmitSignal(nameof(ItemChanged), this);
	}

	public string GetAttributeValue(string key)
	{
		var t = _attributes.TryGetValue(key, out var value)
			? value ?? string.Empty
			: string.Empty;
		return t;
	}
	
	public static bool ValidateAttribute(string value, LanguageFileConfigurationAttribute attributeConfiguration)
	{
		return attributeConfiguration switch
		{
			{ IsInt: true } => int.TryParse(value, out var _),
			{ IsFloat: true } => float.TryParse(value, out var _),
			{ IsBool: true } => bool.TryParse(value, out var _),
			{ IsString: true } => value.Length > 0,
			var _ => attributeConfiguration.EnumValues.Contains(value)
		};
	}

	public bool ValidateAttribute(string attributeName)
	{
		var attributeConfiguration = Configuration.Attributes.FirstOrDefault(x => x.Name == attributeName);
		if (attributeConfiguration is null)
		{
			return false;
		}

		var t = ValidateAttribute(_attributes[attributeName], attributeConfiguration);
		return t;
	}

	public bool Validate(string[] existingKeys)
	{
		var t = !KeyAreEmpty() && !KeyAlreadyExist() && ItemHasAllAttributes() && AllAttributesAreValid();
		return t;
		bool KeyAreEmpty() => string.IsNullOrEmpty(Key);
		bool KeyAlreadyExist() => existingKeys.Contains(Key);

		bool ItemHasAllAttributes() => Configuration
			.Attributes
			.Select(attributeConfig => attributeConfig.Name)
			.All(nameOfAttribute => _attributes.ContainsKey(nameOfAttribute));

		bool AllAttributesAreValid() => _attributes.All(x => ValidateAttribute(x.Key));
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
