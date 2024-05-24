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


signal open_value_changer_dialog(title: String, is_new: bool, is_software: bool, files: Array, change_key: String)

const sw_path := "cfn-code/150_Software/10_SW/i18n/"
const fw_path := "cfn-code/140_Firmware/Oetiker_Control_Unit/i18n/"

@onready var persistent: Persistent = Persistent.get_persistent()

var _items: Dictionary


func _refresh_buttons():
	change_button.disabled = get_selected_key() == ""
	remove_button.disabled = get_selected_key() == ""
	
enum CATEGORY_ENUM {SOFTWARE, FIRMWARE}
func get_category() -> CATEGORY_ENUM:
	return CATEGORY_ENUM.SOFTWARE if category_switch.button_pressed else CATEGORY_ENUM.FIRMWARE
		
func get_dir_path() -> String:
	var path = sw_path if get_category() == CATEGORY_ENUM.SOFTWARE else fw_path
	return persistent.base_path + path

var _files: Array = []

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
	attribute_grid_container.attribute_item_changed.connect(func(item): _save_item(item))

func _reload_attribute_container():
	if get_selected_key() != "":
		value_label_value.text = (_items[_get_english_file()] as XmlItem).value
		attribute_grid_container.init(get_category()==CATEGORY_ENUM.SOFTWARE, _items[_get_english_file()])
	else:
		value_label_value.text = ""
		attribute_grid_container.init(get_category()==CATEGORY_ENUM.SOFTWARE, XmlItem.create_emtpy_item())
	attribute_grid_container.editable = get_selected_key() != ""

func _reload_language_file():
	var path = get_dir_path()
	_files = Array(DirAccess.get_files_at(path)).map(func(file): return get_dir_path()+file)
	_files = _files.filter(func(x: String): return x.ends_with(".xml"))
	language_file_found.text = str(_files.size())
	_reload_items()
	
func _reload_keys(reselect: bool = false):
	var keys = []
	if _files.size() > 0:
		keys = Array(Globals.xml_class.GetKeys(_files.front()))
		keys = keys.filter(func(key:String): return search_clipboard_line_edit.text == "" or search_clipboard_line_edit.text in key)
		keys.sort_custom(func(a,b): return a < b if get_category() == CATEGORY_ENUM.SOFTWARE else int(a)<int(b))
	var preselected_index = key_list.get_selected_items()[0] if key_list.get_selected_items().size()>0 else null
	key_list.deselect_all()
	key_list.clear()
	for key in keys:
		var i = key_list.add_item(key)
	if reselect and preselected_index != null:
		key_list.select(preselected_index)

func _reload_items():
	_items.clear()
	for file in _files:
		if get_selected_key() == "":
			_items[file] = XmlItem.create_emtpy_item()
		else:
			_items[file] = XmlItem.create_item_from_file(get_selected_key(), file)

func _save_item(item: XmlItem):
	var is_Software = get_category() == CATEGORY_ENUM.SOFTWARE
	if item.key != get_selected_key():
		for file in _files:
			Globals.xml_class.ChangeKey(get_selected_key(), item.key, file)
		_reload_keys(true)
		_reload_attribute_container()
	else:
		for file in _files:
			if is_Software:
				Globals.xml_class.SaveAttributeSoftware(item.key, file, item.info)
			else:
				Globals.xml_class.SaveAttributeFirmware(item.key, file, item.info, item.field, str(item.layout))



func _get_english_file() -> String:
	return _files.filter(func(file: String): return file.contains("en")).front()

func on_value_changer_dialog_closed():
	_reload_keys(true)
	_reload_attribute_container()

func _on_category_switch_pressed():
	persistent.is_software = get_category() == CATEGORY_ENUM.SOFTWARE
	specific_path.text = get_dir_path()
	search_clipboard_line_edit.text = ""
	_reload_language_file()
	category_switch.text = "Software" if get_category() == CATEGORY_ENUM.SOFTWARE else "Firmware"
	_reload_keys()
	_reload_attribute_container()

func _on_key_list_item_selected(index):
	value_label_value.text = ""
	if key_list.get_selected_items().size() > 0:
		var english_file = _files.filter(func(file: String): return file.contains("en")).front()
		if english_file != null:
			value_label_value.text = Globals.xml_class.GetValue(get_selected_key(), english_file)
		_reload_items()
	_reload_attribute_container()
	_refresh_buttons()

func _on_search_input_text_changed(_new_text: String):
	_reload_keys()
	_reload_attribute_container()
	
func _on_add_button_pressed():
	open_value_changer_dialog.emit(true, get_category()==CATEGORY_ENUM.SOFTWARE, _items[_get_english_file()], _files)
	
func _on_change_button_pressed():
	open_value_changer_dialog.emit(false, get_category()==CATEGORY_ENUM.SOFTWARE, _items[_get_english_file()], _files)
	
func _on_remove_button_pressed():
	for file in _files:
		Globals.xml_class.RemoveItem(get_selected_key(), file)
	_reload_keys()
	_reload_attribute_container()

func _on_base_path_text_changed(new_text:String):
	persistent.base_path = new_text
	specific_path.text = get_dir_path()
	_reload_language_file()
	_reload_keys()
	_reload_attribute_container()
	attribute_grid_container.init(get_category()==CATEGORY_ENUM.SOFTWARE, XmlItem.create_emtpy_item())
