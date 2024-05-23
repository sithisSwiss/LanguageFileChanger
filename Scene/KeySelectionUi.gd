class_name KeySelectionUi extends Control

@onready var category_switch := %CategorySwitch
@onready var base_path := %BasePath
@onready var specific_path = %SpecificPath
@onready var language_file_found := %LanguageFileFound

@onready var search_clipboard_line_edit := %SearchClipboardLineEdit
@onready var key_list := %KeyList

@onready var add_button := %AddButton
@onready var change_button := %ChangeButton
@onready var remove_button := %RemoveButton

@onready var value_label_value := %ValueLabelValue
@onready var info_clipboard_line_edit := %InfoClipboardLineEdit
@onready var layout_label = %LayoutLabel
@onready var layout_edit := %LayoutEdit
@onready var field_label = %FieldLabel
@onready var field_edit := %FieldEdit

signal open_value_changer_dialog(title: String, is_new: bool, is_software: bool, files: Array, change_key: String)

const sw_path := "cfn-code/150_Software/10_SW/i18n/"
const fw_path := "cfn-code/140_Firmware/Oetiker_Control_Unit/i18n/"

@onready var persistent: Persistent = Persistent.get_persistent()

var selected_key: String:
	set(value):
		selected_key = value
		_reload_input_fields()
		_refresh_buttons()
	get:
		return selected_key

func on_value_changer_dialog_closed():
	_reset_xml_specifics()

func _refresh_buttons():
	change_button.disabled = selected_key == ""
	remove_button.disabled = selected_key == ""

func _reload_input_fields():
	info_clipboard_line_edit.editable = selected_key != ""
	info_clipboard_line_edit.text = "" if selected_key == "" else Globals.xml_class.GetInfo(selected_key, files.front())
	for node in get_tree().get_nodes_in_group("firmware"):
		if get_category() != CATEGORY_ENUM.FIRMWARE:
			node.hide()
		else:
			node.show()
	
	if get_category() == CATEGORY_ENUM.FIRMWARE:
		layout_edit.disabled = selected_key == ""
		var layout = Globals.xml_class.GetLayout(selected_key, files.front())
		var layout_index = 0 if selected_key == "" else XmlItem.LAYOUT_TYPES[layout]
		layout_edit.select(layout_index)
		field_edit.editable = selected_key != ""
		field_edit.text = "" if selected_key == "" else Globals.xml_class.GetField(selected_key, files.front())
	
enum CATEGORY_ENUM {SOFTWARE, FIRMWARE}
func get_category() -> CATEGORY_ENUM:
	return CATEGORY_ENUM.SOFTWARE if category_switch.button_pressed else CATEGORY_ENUM.FIRMWARE
		
func get_dir_path() -> String:
	var path = sw_path if get_category() == CATEGORY_ENUM.SOFTWARE else fw_path
	return persistent.base_path + path

var files: Array = []

func _ready():
	base_path.text = persistent.base_path
	category_switch.button_pressed = persistent.is_software
	specific_path.text = get_dir_path()
	for type in XmlItem.LAYOUT_TYPES:
		layout_edit.add_item(type)
	_reload_language_file()
	_reset_xml_specifics()

func _reload_language_file():
	var path = get_dir_path()
	files = Array(DirAccess.get_files_at(path)).map(func(file): return get_dir_path()+file)
	files = files.filter(func(x: String): return x.ends_with(".xml"))
	language_file_found.text = str(files.size())

func _reset_xml_specifics():
	selected_key = ""
	_reload_keys()
	_reload_input_fields()
	
func _reload_keys():
	selected_key = ""
	var keys = []
	if files.size() > 0:
		keys = Array(Globals.xml_class.GetKeys(files.front()))
		keys = keys.filter(func(key:String): return search_clipboard_line_edit.text == "" or search_clipboard_line_edit.text in key)
		keys.sort_custom(func(a,b): return a < b if get_category() == CATEGORY_ENUM.SOFTWARE else int(a)<int(b))
	key_list.deselect_all()
	key_list.clear()
	for key in keys:
		key_list.add_item(key)

func _save_inputs():
	var is_Software = get_category() == CATEGORY_ENUM.SOFTWARE
	for file in files:
		if is_Software:
			Globals.xml_class.SaveAttributeSoftware(selected_key, file, info_clipboard_line_edit.text)
		else:
			Globals.xml_class.SaveAttributeFirmware(selected_key, file, info_clipboard_line_edit.text, field_edit.text, layout_edit.text)

func _on_category_switch_pressed():
	persistent.is_software = get_category() == CATEGORY_ENUM.SOFTWARE
	specific_path.text = get_dir_path()
	search_clipboard_line_edit.text = ""
	_reload_language_file()
	category_switch.text = "Software" if get_category() == CATEGORY_ENUM.SOFTWARE else "Firmware"
	_reset_xml_specifics()

func _on_key_list_item_selected(index):
	selected_key = key_list.get_item_text(index)
	value_label_value.text = ""
	if selected_key != "":
		var english_file = files.filter(func(file: String): return file.contains("en")).front()
		if english_file != null:
			value_label_value.text = Globals.xml_class.GetValue(selected_key,english_file)
	_reload_input_fields()

func _on_input_changed(_value: String):
	_save_inputs()

func _on_layout_edit_item_selected(_index):
	_save_inputs()

func _on_search_input_text_changed(_new_text: String):
	_reload_keys()
	
func _on_add_button_pressed():
	open_value_changer_dialog.emit("Add Value", true, get_category()==CATEGORY_ENUM.SOFTWARE, files, "")
	
func _on_change_button_pressed():
	open_value_changer_dialog.emit("Change Value", false, get_category()==CATEGORY_ENUM.SOFTWARE, files, selected_key)
	
func _on_remove_button_pressed():
	for file in files:
		Globals.xml_class.RemoveItem(selected_key, file)
	_reset_xml_specifics()

func _on_base_path_text_changed(new_text:String):
	persistent.base_path = new_text
	specific_path.text = get_dir_path()
	_reload_language_file()
	_reset_xml_specifics()
