class_name ValueChangerDialog extends Control

@export var clipboard_icon: Texture2D

@onready var title_value := %TitleValue
@onready var attributes_grid_container := %AttributesGridContainer
@onready var values_grid_container := %ValuesGridContainer

signal closed

var _is_software: bool
var _files: Array

const edit_node_group: String = "value_changer_dialog_value_edit"

func _ready():
	hide()

func init(title: String, is_new: bool, is_software: bool, files: Array, change_key: String):
	title_value.text = title
	_is_software = is_software
	_files = files
	attributes_grid_container.init(is_software, is_new, change_key, files.front())
	if !is_new:
		values_grid_container.add_value_fields(files, change_key, edit_node_group)
	show()

func _add_item_to_files(item: XmlItem):
	for file in _files:
		if _is_software:
			Globals.xml_class.AddItemSoftware(item.key, file, item.info)
		else:
			Globals.xml_class.AddItemFirmware(item.key, file, item.info, str(item.layout), item.field)

func _on_close_button_pressed():
	closed.emit()
	hide()
	values_grid_container.remove_children()
	_ready()

func _on_new_item_created(item: XmlItem):
	_add_item_to_files(item)
	values_grid_container.add_value_fields(_files, item.key, edit_node_group)
