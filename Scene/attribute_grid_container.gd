class_name AttributesGridContainer extends PanelContainer
@onready var v_box_container: VBoxContainer = %VBoxContainer

signal attribute_item_changed(item: LanguageFileItem)

const edit_group: String = "edit"

var _item: LanguageFileItem

var editable: bool:
	set(value):
		editable = value
		Globals.set_editable_of_group(editable, edit_group, self)
	get:
		return editable

func init(item: LanguageFileItem):
	_item = item
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)
	_add_attribute_fields()
	editable = false

func _add_attribute_fields():
	for attribute_config_untyped in Globals.language_file_configuration.Attributes:
		var attribute_config := attribute_config_untyped as LanguageFileConfigurationAttribute
		var input_field = preload("res://Scene/InputField/attribute_input_field.tscn").instantiate()
		v_box_container.add_child(input_field)
		input_field.init(attribute_config, _item.GetAttributeValue(attribute_config.Name), false)
		input_field.value_changed.connect(_on_attribute_input_field_value_changed)
		
func _on_attribute_input_field_value_changed(name_: String, new_value: String):
	_item.SetAttributeValue(name_, new_value)
	attribute_item_changed.emit(_item)
