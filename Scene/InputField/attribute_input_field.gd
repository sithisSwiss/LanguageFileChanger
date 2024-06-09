class_name AttributeInputField extends Control

@onready var label: Label = %Label
@onready var enum_input_field: OptionButton = %OptionButton
@onready var string_input_field: ClipboardLineEdit = %ClipboardLineEdit
@onready var number_input_field: ClipboardSpinBox = %ClipboardSpinBox

@export var label_width: int = Globals.Label_Width

var value: String:
	get:
		return _get_value_from_field()
	set(value_):
		_set_value_to_field(value_)

var valid: bool:
	set(value):
		_set_valid(value)
	get:
		return _get_valid()

var attribute_name: String
var _attribute: LanguageStringAttribute:
	get:
		return Globals.language_string.GetAttribute(attribute_name)

var editable: bool:
	get:
		return editable
	set(value):
		editable = value
		_set_editable(number_input_field, editable)
		_set_editable(string_input_field, editable)
		_set_editable(enum_input_field, editable)

func _ready() -> void:
	enum_input_field.hide()
	string_input_field.hide()
	number_input_field.hide()
	label.custom_minimum_size = Vector2(label_width,0)

func init(attribute_name_: String) -> void:
	attribute_name = attribute_name_
	_set_value_to_field(Globals.language_string.GetAttribute(attribute_name).Value)
	_init_fields()
	label.text = _attribute.DisplayName + ":"

func _init_fields():
	if _is_type_of_int():
		number_input_field.show()
		number_input_field.rounded = true
		number_input_field.value_changed.connect(func(x): _on_field_value_changed(str(x)))
	elif _is_type_of_float():
		number_input_field.show()
		number_input_field.rounded = false
		number_input_field.value_changed.connect(func(x):  _on_field_value_changed(str(x)))
	elif _is_type_of_string():
		string_input_field.show()
		string_input_field.text_changed.connect(func(x): _on_field_value_changed(x))
	elif _is_type_of_list():
		enum_input_field.show()
		for enum_value in _attribute.EnumValues:
			enum_input_field.add_item(enum_value)
		enum_input_field.item_selected.connect(func(index):  _on_field_value_changed(enum_input_field.get_item_text(index)))

func _on_field_value_changed(new_value: String):
	Globals.language_string.SetAttributeValue(_attribute.Name, new_value)

func _get_value_from_field() -> String:
	if _is_type_of_int():
		return str(number_input_field.value)
	elif _is_type_of_float():
		return str(number_input_field.value)
	elif _is_type_of_string():
		return string_input_field.text
	elif _is_type_of_list():
		var index = enum_input_field.selected
		return enum_input_field.get_item_text(index)
	return ""

func _set_value_to_field(value_: String):
	if _is_type_of_int():
		number_input_field.value = int(value_)
	elif _is_type_of_float():
		number_input_field.value = float(value_)
	elif _is_type_of_string():
		string_input_field.text = value_
	elif _is_type_of_list():
		_select_list_input_by_value(value_)

func _select_list_input_by_value(value_: String):
	for index in range(enum_input_field.item_count):
		var value_at_index = enum_input_field.get_item_text(index)
		if value_at_index == value_:
			enum_input_field.select(index)
			return

func _set_valid(is_valid: bool):
	if _is_type_of_int():
		number_input_field.valid = is_valid
	elif _is_type_of_float():
		number_input_field.valid = is_valid
	elif _is_type_of_string():
		string_input_field.valid = is_valid
	elif _is_type_of_list():
		pass

func _get_valid():
	if _is_type_of_int():
		return number_input_field.valid
	elif _is_type_of_float():
		return number_input_field.valid
	elif _is_type_of_string():
		return string_input_field.valid
	elif _is_type_of_list():
		pass
	return true

func _set_editable(node: Node, editable_: bool):
	if node is LineEdit or node is ClipboardLineEdit or node is ClipboardSpinBox:
		node.editable = editable_
	elif node is Button:
		node.disabled = !editable_

func _is_type_of_int() -> bool:
	return _attribute.IsTypeOf("Int")
func _is_type_of_float() -> bool:
	return _attribute.IsTypeOf("Float")
func _is_type_of_string() -> bool:
	return _attribute.IsTypeOf("String")
func _is_type_of_list() -> bool:
	return _attribute.IsTypeOf("List")
