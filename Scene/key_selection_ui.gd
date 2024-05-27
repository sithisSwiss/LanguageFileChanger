class_name KeySelectionUi extends Control

@onready var category_switch := %CategorySwitch
@onready var base_path := %BasePath
@onready var specific_path = %SpecificPath
@onready var language_file_found := %LanguageFileFound

@onready var search_label = %SearchLabel
@onready var search_clipboard_line_edit := %SearchClipboardLineEdit
@onready var key_list := %KeyList

@onready var value_label_value := %ValueLabelValue
@onready var attribute_grid_container := %AttributeGridContainer

@onready var add_button := %AddButton
@onready var change_button := %ChangeButton
@onready var remove_button := %RemoveButton


signal open_value_changer_dialog(is_new: bool, is_software: bool, files: Array, change_key: String)

const sw_path := "cfn-code/150_Software/10_SW/i18n/"
const fw_path := "cfn-code/140_Firmware/Oetiker_Control_Unit/i18n/"

@onready var persistent: Persistent = Persistent.get_persistent()

var _items: Dictionary
var _is_software: bool:
	get:
		return category_switch.button_pressed

func get_dir_path() -> String:
	var path = sw_path if _is_software else fw_path
	return persistent.base_path + path

var _file_paths: Array = []
var _english_file_path: String:
	get:
		return _file_paths.filter(func(file: String): return file.contains("en")).front()

func get_selected_key() -> String:
	var selected_items = key_list.get_selected_items()
	return key_list.get_item_text(selected_items[0]) if selected_items.size()>0 else ""

func _ready():
	base_path.text = persistent.base_path
	category_switch.button_pressed = persistent.is_software
	specific_path.text = get_dir_path()
	_reload_language_file()
	_reload_keys()
	_reload_attribute_container()
	_refresh_buttons()
	attribute_grid_container.attribute_item_changed.connect(func(item): _save_item(item))

func _refresh_buttons():
	change_button.disabled = get_selected_key() == ""
	remove_button.disabled = get_selected_key() == ""
	
func _reload_attribute_container():
	if get_selected_key() != "":
		value_label_value.text = (_items[_english_file_path] as XmlItem).value
		attribute_grid_container.init(_is_software, _items[_english_file_path])
	else:
		value_label_value.text = ""
		attribute_grid_container.init(_is_software, XmlItem.create_emtpy_item())
	attribute_grid_container.editable = get_selected_key() != ""

func _reload_language_file():
	var path = get_dir_path()
	_file_paths = Array(DirAccess.get_files_at(path)).map(func(file_path): return get_dir_path()+file_path)
	_file_paths = _file_paths.filter(func(x: String): return x.ends_with(".xml"))
	language_file_found.text = str(_file_paths.size())
	_reload_items()
	
func _reload_keys():
	var keys = []
	if _file_paths.size() > 0:
		keys = Array(Globals.xml_class.GetKeys(_file_paths.front()))
		keys = keys.filter(func(key:String): return search_clipboard_line_edit.text == "" or search_clipboard_line_edit.text in key)
		keys.sort_custom(func(a,b): return a < b if _is_software else int(a)<int(b))
	key_list.deselect_all()
	key_list.clear()
	for key in keys:
		key_list.add_item(key)

func _reload_items():
	_items.clear()
	for file_path in _file_paths:
		_items[file_path] = XmlItem.create_emtpy_item() if get_selected_key() == "" else XmlItem.create_item_from_file(get_selected_key(), file_path)

func _save_item(item: XmlItem):
	if item.key != get_selected_key():
		for file_path in _file_paths:
			Globals.xml_class.ChangeKey(get_selected_key(), item.key, file_path)
		_reload_keys()
		_reload_attribute_container()
	else:
		for file_path in _file_paths:
			Globals.xml_class.SaveAttribute(item, file_path, _is_software)

func on_value_changer_dialog_closed():
	_reload_keys()
	_reload_attribute_container()

func _on_category_switch_pressed():
	persistent.is_software = _is_software
	specific_path.text = get_dir_path()
	search_clipboard_line_edit.text = ""
	_reload_language_file()
	category_switch.text = "Software" if _is_software else "Firmware"
	_reload_keys()
	_reload_attribute_container()

func _on_key_list_item_selected(_index):
	value_label_value.text = ""
	if key_list.get_selected_items().size() > 0:
		value_label_value.text = Globals.xml_class.GetValue(get_selected_key(), _english_file_path)
		_reload_items()
	_reload_attribute_container()
	_refresh_buttons()

func _on_search_input_text_changed(_new_text: String):
	_reload_keys()
	_reload_attribute_container()
	
func _on_add_button_pressed():
	open_value_changer_dialog.emit(true, _is_software, XmlItem.create_emtpy_item(), _file_paths)
	
func _on_change_button_pressed():
	open_value_changer_dialog.emit(false, _is_software, _items[_english_file_path], _file_paths)
	
func _on_remove_button_pressed():
	for file_path in _file_paths:
		Globals.xml_class.RemoveItem(get_selected_key(), file_path)
	_reload_keys()
	_reload_attribute_container()
	_refresh_buttons()

func _on_base_path_text_changed(new_text:String):
	persistent.base_path = new_text
	specific_path.text = get_dir_path()
	_reload_language_file()
	_reload_keys()
	_reload_attribute_container()
	attribute_grid_container.init(_is_software, XmlItem.create_emtpy_item())
