class_name AttributeInputField extends Control

@onready var label: Label = %Label
@onready var enum_input_field: OptionButton = %OptionButton
@onready var string_input_field: ClipboardLineEdit = %ClipboardLineEdit
@onready var number_input_field: ClipboardSpinBox = %ClipboardSpinBox

@export var label_width: int = Globals.Label_Width

signal value_changed(name:String, new_value: String, is_valid: bool)
var _attribute_configuration: LanguageFileConfigurationAttribute

var value: String:
	get:
		return _get_value_from_field()
	set(value):
		_set_value_to_field(value)
		valid = LanguageFileItem.ValidateAttribute(value, _attribute_configuration)
		value_changed.emit(attribute_name, value, valid)

var valid: bool:
	set(value):
		_set_valid(value)
	get:
		return _get_valid()
		
enum Input_Type_Enum {Int, Float, Str, List, Not_Set}

var _input_type: Input_Type_Enum = Input_Type_Enum.Not_Set
var attribute_name: String

func _ready() -> void:
	enum_input_field.hide()
	string_input_field.hide()
	number_input_field.hide()
	
	label.custom_minimum_size = Vector2(label_width,0)
	
func init(attribute_configuration: LanguageFileConfigurationAttribute, init_value: String) -> void:
	_attribute_configuration = attribute_configuration
	_init_input_type(attribute_configuration)
	_init_based_on_configuration(attribute_configuration)
	label.text = attribute_configuration.DisplayName + ":"
	attribute_name = attribute_configuration.Name
	value = init_value

func _init_input_type(config: LanguageFileConfigurationAttribute):
	if config.IsInt:
		_input_type = Input_Type_Enum.Int
	elif config.IsFloat:
		_input_type = Input_Type_Enum.Float
	elif config.IsString:
		_input_type = Input_Type_Enum.Str
	elif config.EnumValues.size()>0:
		_input_type = Input_Type_Enum.List
		
func _init_based_on_configuration(config: LanguageFileConfigurationAttribute):
	match _input_type:
		Input_Type_Enum.Int:
			number_input_field.show()
			number_input_field.rounded = true
			number_input_field.value_changed.connect(func(x): _on_field_value_changed(str(x)))
		Input_Type_Enum.Float:
			number_input_field.show()
			number_input_field.rounded = false
			number_input_field.value_changed.connect(func(x):  _on_field_value_changed(str(x)))
		Input_Type_Enum.Str:
			string_input_field.show()
			string_input_field.text_changed.connect(func(x): _on_field_value_changed(x))
		Input_Type_Enum.List:
			enum_input_field.show()
			for enum_value in config.EnumValues:
				enum_input_field.add_item(enum_value)
			enum_input_field.item_selected.connect(func(index):  _on_field_value_changed(enum_input_field.get_item_text(index)))

func _on_field_value_changed(new_value: String):
	valid = LanguageFileItem.ValidateAttribute(value, _attribute_configuration)
	value_changed.emit(attribute_name, value, valid)

func _get_value_from_field() -> String:
	match _input_type:
		Input_Type_Enum.Int:
			return str(number_input_field.value)
		Input_Type_Enum.Float:
			return str(number_input_field.value)
		Input_Type_Enum.Str:
			return string_input_field.text
		Input_Type_Enum.List:
			var index = enum_input_field.selected
			return enum_input_field.get_item_text(index)
	return ""

func _set_value_to_field(value_: String):
	match _input_type:
		Input_Type_Enum.Int:
			number_input_field.value = int(value_)
		Input_Type_Enum.Float:
			number_input_field.value = float(value_)
		Input_Type_Enum.Str:
			string_input_field.text = value_
		Input_Type_Enum.List:
			_select_list_input_by_value(value_)
	

func _select_list_input_by_value(value_: String):
	for index in range(enum_input_field.item_count):
		var value_at_index = enum_input_field.get_item_text(index)
		if value_at_index == value_:
			enum_input_field.select(index)
			return

func _set_valid(is_valid: bool):
	match _input_type:
		Input_Type_Enum.Int:
			number_input_field.valid = is_valid
		Input_Type_Enum.Float:
			number_input_field.valid = is_valid
		Input_Type_Enum.Str:
			string_input_field.valid = is_valid
		Input_Type_Enum.List:
			pass

func _get_valid():
	match _input_type:
		Input_Type_Enum.Int:
			return number_input_field.valid
		Input_Type_Enum.Float:
			return number_input_field.valid
		Input_Type_Enum.Str:
			return string_input_field.valid
		Input_Type_Enum.Int:
			pass
	return true
