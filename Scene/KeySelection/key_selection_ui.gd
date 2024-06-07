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
	$VBoxContainer/PanelContainer/GridContainer/TypeLabel.custom_minimum_size = Vector2(Globals.Label_Width,0)
	$VBoxContainer/PanelContainer3/HBoxContainer3/ValueLabel.custom_minimum_size = Vector2(Globals.Label_Width,0)
	$VBoxContainer/ButtonHBoxContainer/Spacer.custom_minimum_size = Vector2(Globals.Label_Width,0)
	for config_name in LangaugeFileHelper.GetConfigurationNames():
		type_option_button.add_item(config_name)
	type_option_button.select(clamp(Globals.persistent.SelectedConfigIndex, 0, type_option_button.item_count-1))

	specific_path.text = Globals.language_file_item.GetFolderPath()
	_reload_language_file()
	_refresh_buttons()
	Globals.set_new_item(self)

func _refresh_buttons():
	change_button.disabled = get_selected_key() == ""
	remove_button.disabled = get_selected_key() == ""

func _reload_language_file():
	language_file_found.text = str(Array(Globals.language_file_item.GetFilePaths()).size())

func _reload_value_field():
	value_label_value.text = Globals.language_file_item.GetValueFromEnglishFile()

func _on_key_list_item_selection_changed():
	_reload_value_field()
	_refresh_buttons()

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
	XmlScript.RemoveItem(get_selected_key())
	_refresh_buttons()

func _on_type_option_button_item_selected(index: int) -> void:
	Globals.persistent.SelectedConfigIndex = index
	specific_path.text = Globals.language_file_item.GetFolderPath()
	_reload_language_file()
	Globals.set_new_item(self)
	_reload_value_field()
	_refresh_buttons()
