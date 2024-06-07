class_name GlobalsClass extends Node

const Label_Width: int = 200

const Title: String = "Language File Changer"

static var persistent := preload("res://Script/Persistent.cs").GetPersistent()

signal language_file_item_changed(caller: Object, old_item: LanguageFileItem, new_item: LanguageFileItem)

var language_file_item : LanguageFileItem

func set_existing_item(caller: Object, key: String) -> void:
	var old_value := language_file_item
	language_file_item = LanguageFileItem.CreateExistingItem(key)
	language_file_item_changed.emit(caller, old_value, language_file_item)

func set_new_item(caller: Object) -> void:
	var old_value := language_file_item
	language_file_item = LanguageFileItem.CreateNewItem()
	language_file_item_changed.emit(caller, old_value, language_file_item)

func _ready():
	const config_path_res := "res://Script/LanguageFile/LanguageFileConfiguration.json"
	if !OS.has_feature("editor"):
		var config_path_system := OS.get_executable_path().get_base_dir() + "/LanguageFileConfiguration.json"
		GlobalsClass._copy_configuration_file_if_not_exist(config_path_system, config_path_res)
		LangaugeFileHelper.LoadConfiguration(config_path_system)
	else:
		LangaugeFileHelper.LoadConfiguration(config_path_res)
	set_new_item(self)

static func _copy_configuration_file_if_not_exist(check_path: String, copy_from: String):
	if !FileAccess.file_exists(check_path):
		_copy_from_res(copy_from, check_path)

static func _copy_from_res(from: String, to: String, chmod_flags: int=-1) -> void:
	var file_from = FileAccess.open(from, FileAccess.READ)
	var file_to = FileAccess.open(to, FileAccess.WRITE)
	file_to.store_buffer(file_from.get_buffer(file_from.get_length()))
	file_to = null
	file_from = null
	if chmod_flags != -1:
		var output = []
		OS.execute("chmod", [chmod_flags, ProjectSettings.globalize_path(to)], output, true)
