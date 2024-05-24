class_name ValueChangerDialog extends Control

@export var clipboard_icon: Texture2D

@onready var title_value := %TitleValue
@onready var attribute_grid_container := %AttributeGridContainer
@onready var values_grid_container := %ValuesGridContainer
@onready var create_item_container = %CreateItemContainer
@onready var create_item_button = %CreateItemButton

signal closed

var _is_software: bool
var _keys: Array
var _files: Array
var _attribute_item: XmlItem

const edit_node_group: String = "value_changer_dialog_value_edit"

func _ready():
	hide()

func init_change(is_software: bool, attribute_item: XmlItem, files: Array):
	title_value.text = "Change Item"
	attribute_grid_container.init(is_software, attribute_item)
	attribute_grid_container.editable = false
	values_grid_container.add_value_fields(files, attribute_item.key, edit_node_group)
	create_item_container.hide()
	init(is_software, files)
	
func init_add(is_software: bool, files: Array):
	title_value.text = "Add Item"
	attribute_grid_container.init(is_software, XmlItem.create_emtpy_item())
	attribute_grid_container.attribute_item_changed.connect(_on_attribute_changed)
	attribute_grid_container.editable = true
	create_item_container.show()
	create_item_button.disabled = true
	init(is_software, files)
	
func init(is_software: bool, files: Array):
	_is_software = is_software
	_files = files
	_keys = Globals.xml_class.GetKeys(files.front())
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

func _on_attribute_changed(item: XmlItem):
	_attribute_item = item
	create_item_button.disabled = !item.validate(_is_software, _keys)

func _on_create_item_pressed():
	create_item_container.hide()
	attribute_grid_container.editable = false
	_add_item_to_files(_attribute_item)
	values_grid_container.add_value_fields(_files, _attribute_item.key, edit_node_group)
