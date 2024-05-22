class_name ValueChangerDialog extends ColorRect

@onready var title_value := %TitleValue
@onready var attributes_grid := %AttributesGrid
@onready var values_grid := %ValuesGrid

@onready var key_label := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/KeyLabel
@onready var key_edit := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/KeyContainer/KeyEdit
@onready var create_key := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/KeyContainer/CreateKey
@onready var info_label := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/InfoLabel
@onready var info_edit := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/InfoEdit
@onready var field_label := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/FieldLabel
@onready var field_edit := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/FieldEdit
@onready var layout_label := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/LayoutLabel
@onready var layout_edit := $MarginContainer/ScrollContainer/VBoxContainer/AttributesGrid/LayoutEdit

@onready var xml_class = preload("res://Script/XmlScript.cs")
@onready var xml_object = xml_class.new()


signal added_new_key

var _is_new: bool
var _is_software: bool
var _files: Array

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

func init(title: String, is_new: bool, is_software: bool, files: Array, change_key: String):
	title_value.text = title
	_is_new = is_new
	_is_software = is_software
	_files = files
	key_edit.text = change_key
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
			add_value_field(file, "", file, false)
	else:
		create_key.hide()
		for file in _files:
			var language = Array((file as String).split("/")).back()
			add_value_field(language, xml_class.GetValue(change_key, file), file, true)
	_set_disable_create_button()
	show()

func add_value_field(label: String, edit: String, file: String, is_editable:bool):
	var label_node = Label.new()
	label_node.text = label
	values_grid.add_child(label_node)
	var edit_node = LineEdit.new()
	edit_node.editable = is_editable
	edit_node.text = edit
	edit_node.size_flags_horizontal = SIZE_EXPAND_FILL
	edit_node.text_changed.connect(func(new_text:String): xml_class.SaveValue(key_edit.text, file, new_text))
	values_grid.add_child(edit_node)
	
func _set_disable_create_button():
	var keys = xml_class.GetKeys(_files.front())
	create_key.disabled = key_edit.text.length() < 5 or key_edit.text in keys
	if !_is_software:
		create_key.disabled = create_key.disabled or !key_edit.text.is_valid_int()
	
func _on_close_button_pressed():
	added_new_key.emit()
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
	for child in values_grid.get_children().filter(func(c): return c is LineEdit):
		child.editable = true
	create_key.hide()
	key_edit.editable = false
	info_edit.editable = false
	field_edit.editable = false
	layout_edit.disabled = true

func _on_key_edit_text_changed(_new_text:String):
	_set_disable_create_button()
