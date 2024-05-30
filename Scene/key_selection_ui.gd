class_name KeySelectionUi extends Control

@onready var category_switch := %CategorySwitch
@onready var base_path := %BasePath
@onready var specific_path = %SpecificPath
@onready var language_file_found := %LanguageFileFound

@onready var key_list := %KeyList

@onready var value_label_value := %ValueLabelValue
@onready var attribute_grid_container := %AttributeGridContainer

@onready var add_button := %AddButton
@onready var change_button := %ChangeButton
@onready var remove_button := %RemoveButton

@onready var _value_changer_dialog_scene: PackedScene = preload("res://Scene/Dialog/value_dialog.tscn")

const sw_path := "cfn-code/150_Software/10_SW/i18n/"
const fw_path := "cfn-code/140_Firmware/Oetiker_Control_Unit/i18n/"

@onready var persistent: Persistent = Persistent.get_persistent()

var _is_software: bool:
	get:
		return category_switch.button_pressed

func get_dir_path() -> String:
	var path = sw_path if _is_software else fw_path
	return persistent.base_path + path

func get_selected_key() -> String:
	return key_list.selected_key

var _file_paths: Array = []
var _english_item: XmlItem
var _english_file_path: String:
	get:
		return _file_paths.filter(func(file: String): return file.contains("en")).front()

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
		value_label_value.text = (_english_item).value
		attribute_grid_container.init(_is_software, _english_item)
	else:
		value_label_value.text = ""
		attribute_grid_container.init(_is_software, XmlItem.create_emtpy_item())
	attribute_grid_container.editable = get_selected_key() != ""

func _reload_language_file():
	var path = get_dir_path()
	_file_paths = []
	if DirAccess.dir_exists_absolute(path):
		_file_paths = Array(DirAccess.get_files_at(path)).map(func(file_path): return get_dir_path()+file_path)
		_file_paths = _file_paths.filter(func(x: String): return x.ends_with(".xml"))
	language_file_found.text = str(_file_paths.size())
	_reload_english_item()

func _reload_keys(select_key:String = ""):
	key_list.init(_file_paths.front() if _file_paths.size()>0 else "", _is_software)
	if select_key != "":
		key_list.try_to_select(select_key)

func _reload_english_item():
	_english_item =XmlItem.create_emtpy_item() if get_selected_key() == "" else XmlItem.create_item_from_file(get_selected_key(), _english_file_path)

func _save_item(item: XmlItem):
	if item.key != get_selected_key():
		for file_path in _file_paths:
			Globals.xml_class.ChangeKey(get_selected_key(), item.key, file_path)
		_reload_keys(item.key)
	else:
		for file_path in _file_paths:
			Globals.xml_class.SaveAttribute(item, file_path, _is_software)

func _on_value_changer_dialog_closed():
	_reload_keys()
	_reload_attribute_container()

func _on_category_switch_pressed():
	persistent.is_software = _is_software
	specific_path.text = get_dir_path()
	_reload_language_file()
	category_switch.text = "Software" if _is_software else "Firmware"
	_reload_keys()
	_reload_attribute_container()
	_refresh_buttons()

func _on_key_list_item_selection_changed():
	value_label_value.text = get_selected_key()
	_reload_english_item()
	_reload_attribute_container()
	_refresh_buttons()

func _on_add_button_pressed():
	await Ui.instance.add_window(_value_changer_dialog_scene).init_add(_is_software, _file_paths).closed
	_on_value_changer_dialog_closed()

func _on_change_button_pressed():
	var dialog := Ui.instance.add_window(_value_changer_dialog_scene).init_change(_is_software, _english_item, _file_paths) as ValueDialog
	await dialog.closed
	_on_value_changer_dialog_closed()

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
	_refresh_buttons()
	attribute_grid_container.init(_is_software, XmlItem.create_emtpy_item())
