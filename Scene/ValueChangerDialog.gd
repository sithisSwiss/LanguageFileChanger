class_name ValueChangerDialog extends Control

@export var clipboard_icon: Texture2D

@onready var title_value := %TitleValue
@onready var attributes_grid := %AttributesGrid
@onready var values_grid := %ValuesGrid

@onready var xml_class = preload("res://Script/XmlScript.cs")
@export var clipboard_btn_scene := preload("res://Scene/clipboard_button.tscn")

@onready var key_label := %KeyLabel
@onready var key_clipboard_button := %KeyClipboardButton
@onready var key_edit := %KeyEdit
@onready var create_key := %CreateKey
@onready var info_label := %InfoLabel
@onready var info_clipboard_button := %InfoClipboardButton
@onready var info_edit := %InfoEdit
@onready var field_label := %FieldLabel
@onready var field_edit := %FieldEdit
@onready var layout_label := %LayoutLabel
@onready var layout_edit := %LayoutEdit

signal closed

var _is_new: bool
var _is_software: bool
var _files: Array

const edit_node_group: String = "value_changer_dialog_edit_node"

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	info_edit.editable = false
	key_edit.editable = false
	field_label.hide()
	field_edit.hide()
	layout_label.hide()
	layout_edit.hide()
	for type in Globals.LAYOUT_TYPES:
		layout_edit.add_item(type)
	key_clipboard_button.init(key_edit)
	info_clipboard_button.init(info_edit)

func init(title: String, is_new: bool, is_software: bool, files: Array, change_key: String):
	title_value.text = title
	_is_new = is_new
	_is_software = is_software
	_files = files
	key_edit.text = change_key
	info_edit.text = "" if _is_new else xml_class.GetInfo(change_key, files.front())
	if not _is_software:
		field_edit.text = "" if _is_new else xml_class.GetField(change_key, files.front())
		layout_edit.text = "" if _is_new else xml_class.GetLayout(change_key, files.front())
	if is_new:
		create_key.show()
		info_edit.editable = true
		key_edit.editable = true
		if not is_software:
			field_label.show()
			field_edit.show()
			layout_label.show()
			layout_edit.show()
		for file in _files:
			add_value_fields(file, "", file, false)
	else:
		create_key.hide()
		for file in _files:
			var language = Array((file as String).split("/")).back()
			add_value_fields(language, xml_class.GetValue(change_key, file), file, true)
	_set_disable_create_button()
	show()

func add_value_fields(label: String, edit: String, file: String, is_editable:bool):
	var label_node := Label.new()
	label_node.text = label
	values_grid.add_child(label_node)
	
	var h_container := HBoxContainer.new()
	h_container.size_flags_horizontal = SIZE_EXPAND_FILL
	h_container.theme = preload("res://h_box_clipboard_edit.tres")
	values_grid.add_child(h_container)
	
	var edit_node := LineEdit.new()
	var clipboard_btn := (clipboard_btn_scene.instantiate() as ClipboardButton).init(edit_node)
	h_container.add_child(clipboard_btn)

	edit_node.editable = is_editable
	edit_node.text = edit
	edit_node.size_flags_horizontal = SIZE_EXPAND_FILL
	edit_node.add_to_group(edit_node_group)
	edit_node.text_changed.connect(func(new_text:String): xml_class.SaveValue(key_edit.text, file, new_text))
	h_container.add_child(edit_node)
	
	
	
func _set_disable_create_button():
	var keys = xml_class.GetKeys(_files.front())
	create_key.disabled = key_edit.text.length() < 5 or key_edit.text in keys
	if !_is_software:
		create_key.disabled = create_key.disabled or !key_edit.text.is_valid_int()
	
func _on_close_button_pressed():
	closed.emit()
	hide()
	for child in values_grid.get_children():
		values_grid.remove_child(child)
	_ready()

func _on_create_key_pressed():
	for file in _files:
		if _is_software:
			xml_class.AddKeySoftware(key_edit.text, file, info_edit.text)
		else:
			xml_class.AddKeyFirmware(key_edit.text, file, info_edit.text, layout_edit.get_item_text(layout_edit.get_selected_id()), field_edit.text)
	for child in values_grid.get_tree().get_nodes_in_group(edit_node_group):
		child.editable = true
	create_key.hide()
	key_edit.editable = false
	info_edit.editable = false
	field_edit.editable = false
	layout_edit.disabled = true

func _on_key_edit_text_changed(_new_text:String):
	_set_disable_create_button()
