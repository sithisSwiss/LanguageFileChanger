class_name KeySelectionUi extends Control

@onready var type_option_button := %TypeOptionButton
@onready var specific_path = %SpecificPath
@onready var language_file_found := %LanguageFileFound

@onready var key_list := %KeyList

@onready var value_label_value := %ValueLabelValue
@onready var attribute_grid_container := %AttributeGridContainer

@onready var add_button := %AddButton
@onready var change_button := %ChangeButton
@onready var remove_button := %RemoveButton

@onready var _value_changer_dialog_scene: PackedScene = preload("res://Scene/Dialog/value_dialog.tscn")

func get_dir_path() -> String:
	return Globals.language_file_configuration.LanguageFilePath

func get_selected_key() -> String:
	return key_list.selected_key

var _file_paths: Array = []
var _english_item: LanguageFileItem
var _english_file_path: String:
	get:
		return _file_paths.filter(func(file: String): return file.contains("en")).front()

func _ready():
	$VBoxContainer/TitleLabel.text = Globals.Title
	for config in LanguageFileConfiguration.GetConfigurations():
		type_option_button.add_item(config.Name)
	type_option_button.select(Globals.persistent.SelectedConfigIndex)
	
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
		value_label_value.text = _english_item.Value
		attribute_grid_container.init(_english_item)
	else:
		value_label_value.text = ""
		attribute_grid_container.init(LanguageFileItem.new())
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
	key_list.init(_file_paths.front() if _file_paths.size()>0 else "")
	if select_key != "":
		key_list.try_to_select(select_key)

func _reload_english_item():
	_english_item = LanguageFileItem.new() if get_selected_key() == "" else LanguageFileItem.CreateItemFromFile(get_selected_key(), _english_file_path)

func _save_item(item: LanguageFileItem):
	if item.Key != get_selected_key():
		for file_path in _file_paths:
			XmlScript.ChangeKey(get_selected_key(), item.Key, file_path)
		_reload_keys(item.Key)
	else:
		for file_path in _file_paths:
			XmlScript.SaveAttribute(item, file_path)

func _on_value_changer_dialog_closed():
	_reload_keys()
	_reload_attribute_container()
	
func _on_key_list_item_selection_changed():
	value_label_value.text = get_selected_key()
	_reload_english_item()
	_reload_attribute_container()
	_refresh_buttons()

func _on_add_button_pressed():
	await Ui.instance.add_window(_value_changer_dialog_scene).init_add(_file_paths).closed
	_on_value_changer_dialog_closed()

func _on_change_button_pressed():
	var dialog := Ui.instance.add_window(_value_changer_dialog_scene).init_change(_english_item, _file_paths) as ValueDialog
	await dialog.closed
	_on_value_changer_dialog_closed()

func _on_remove_button_pressed():
	for file_path in _file_paths:
		XmlScript.RemoveItem(get_selected_key(), file_path)
	_reload_keys()
	_reload_attribute_container()
	_refresh_buttons()


func _on_type_option_button_item_selected(index: int) -> void:
	Globals.persistent.SelectedConfigIndex = index
	specific_path.text = get_dir_path()
	_reload_language_file()
	_reload_keys()
	_reload_attribute_container()
	_refresh_buttons()
	
