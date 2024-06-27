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

@onready var _value_window_scene: PackedScene = preload("res://Scene/Dialog/values_window.tscn")

func get_selected_key() -> String:
	return key_list.selected_key

func _ready():
	$VBoxContainer/PanelContainer/HBoxContainer/GridContainer/TypeLabel.custom_minimum_size = Vector2(Globals.Label_Width,0)
	$VBoxContainer/PanelContainer3/HBoxContainer3/ValueLabel.custom_minimum_size = Vector2(Globals.Label_Width,0)
	$VBoxContainer/ButtonHBoxContainer/Spacer.custom_minimum_size = Vector2(Globals.Label_Width,0)
	for config_name in LanguageFileHelper.GetConfigurationNames():
		type_option_button.add_item(config_name)
	type_option_button.select(clamp(Globals.persistent.SelectedConfigIndex, 0, type_option_button.item_count-1))
	_reload_language_file_path()
	_reload_language_file_found()
	_refresh_buttons()
	Globals.set_new_item(self)
	Globals.language_string_changed.connect(_on_language_string_changed)

func _on_language_string_changed(_caller: Object, _old_item: LanguageString, _new_item: LanguageString):
	_reload_value_field()
	_refresh_buttons()
	
func _refresh_buttons():
	add_button.disabled = LanguageFileHelper.GetAllKeysFromFirstFile().size() == 0
	change_button.disabled = get_selected_key() == ""
	remove_button.disabled = get_selected_key() == ""

func _reload_language_file_path():
	specific_path.text = LanguageFileHelper.GetCurrentLanguageFolderPath()

func _reload_language_file_found():
	language_file_found.text = str(Array(LanguageFileHelper.GetCurrentLanguageFilePaths()).size())

func _reload_value_field():
	value_label_value.text = Globals.language_string.GetValueFromEnglishFile()

func _on_add_button_pressed():
	var win := Ui.instance.open_window(_value_window_scene) as ValuesWindow
	win.init_add()
	win.close_requested.connect(_on_values_window_closed)

func _on_change_button_pressed():
	var win := Ui.instance.open_window(_value_window_scene) as ValuesWindow
	win.init_change()
	win.close_requested.connect(_on_values_window_closed)

func _on_values_window_closed():
	_refresh_buttons()

func _on_remove_button_pressed():
	Globals.language_string.RemoveItemFromFile()
	Globals.set_new_item(self)

func _on_type_option_button_item_selected(index: int) -> void:
	Globals.persistent.SelectedConfigIndex = index
	Globals.set_new_item(self)
	_reload_language_file_path()
	_reload_language_file_found()
	_reload_value_field()
	_refresh_buttons()
