class_name AttributesGridContainer extends PanelContainer
@onready var v_box_container: VBoxContainer = %VBoxContainer

signal attribute_item_changed(item: LanguageFileItem)

const edit_group: String = "edit"

var _item: LanguageFileItem = LanguageFileItem.new()

var editable: bool:
	set(value):
		editable = value
		Globals.set_editable_of_group(editable, edit_group, self)
	get:
		return editable

func _ready() -> void:
	_add_attribute_fields()
	editable = false

func init(item: LanguageFileItem):
	_item = item
	_set_value(_item)

func _add_attribute_fields():
	for attribute_config_untyped in Globals.language_file_configuration.Attributes:
		var attribute_config := attribute_config_untyped as LanguageFileConfigurationAttribute
		var input_field = preload("res://Scene/InputField/attribute_input_field.tscn").instantiate()
		v_box_container.add_child(input_field)
		input_field.value_changed.connect(_on_attribute_input_field_value_changed)
		input_field.init(attribute_config, _item.GetAttributeValue(attribute_config.Name))
		
func _on_attribute_input_field_value_changed(name_: String, new_value: String, is_valid: bool):
	_item.SetAttributeValue(name_, new_value)
	attribute_item_changed.emit(_item)

func _set_value(item: LanguageFileItem):
	for field in v_box_container.get_children():
		if field is AttributeInputField:
			field.value = item.GetAttributeValue(field.attribute_name)
