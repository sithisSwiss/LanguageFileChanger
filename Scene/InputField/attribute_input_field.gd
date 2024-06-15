class_name AttributeInputField extends Control

@onready var label: Label = %Label
@onready var string_input_field: ClipboardLineEdit = %ClipboardLineEdit
@onready var number_input_field: ClipboardSpinBox = %ClipboardSpinBox
@onready var list_input_field: ValueFromListSelector = %ValueFromListSelector

@export var label_width: int = Globals.Label_Width

var common_input_field_class = preload("res://Scene/InputField/common_input_field.gd")

var _field: CommonInputField

var value: String:
	get:
		return _field.value
	set(value_):
		_field.value = value_

var valid: bool:
	set(value):
		_field.valid = value
	get:
		return _field.valid

var attribute_name: String
var _attribute: LanguageStringAttribute:
	get:
		return Globals.language_string.GetAttribute(attribute_name)

var editable: bool:
	get:
		return _field.editable
	set(value):
		_field.editable = value

func _ready() -> void:
	string_input_field.hide()
	number_input_field.hide()
	list_input_field.hide()
	label.custom_minimum_size = Vector2(label_width,0)

func init(attribute_name_: String) -> void:
	attribute_name = attribute_name_
	var f = _get_initiated_current_field()
	_field = common_input_field_class.new().init(f)
	_field.value = Globals.language_string.GetAttribute(attribute_name).Value
	_field.value_changed.connect(func(x): Globals.language_string.SetAttributeValue(_attribute.Name, str(x)))
	_field.show()
	_queue_free_all_hidden_fields()
	label.text = _attribute.DisplayName + ":"

func _get_initiated_current_field() -> Node:
	if _attribute.IsTypeOf("Int"):
		return number_input_field.init(true, attribute_name)
	elif _attribute.IsTypeOf("Float"):
		return number_input_field.init(false,attribute_name)
	elif _attribute.IsTypeOf("String"):
		return string_input_field
	elif _attribute.IsTypeOf("List"):
		list_input_field.init(_attribute.EnumValues)
		return list_input_field
	return null

func _queue_free_all_hidden_fields():
	if !number_input_field.visible:
		number_input_field.queue_free()
	if !string_input_field.visible:
		string_input_field.queue_free()
	if !list_input_field.visible:
		list_input_field.queue_free()
