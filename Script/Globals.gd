class_name GlobalsClass extends Node

const Label_Width: int = 200

const Title: String = "Language File Changer"

static var persistent := preload("res://Script/Persistent.cs").GetPersistent()

signal language_string_changed(caller: Object, old_item: LanguageString, new_item: LanguageString)

var language_string : LanguageString

func fire_language_string_changed():
	language_string_changed.emit(self, language_string, language_string)

func set_existing_item(caller: Object, key: String) -> void:
	var old_value := language_string
	language_string = LanguageString.CreateExistingItem(key)
	language_string_changed.emit(caller, old_value, language_string)

func set_new_item(caller: Object) -> void:
	var old_value := language_string
	language_string = LanguageString.CreateNewItem()
	language_string_changed.emit(caller, old_value, language_string)

func _ready():
	const config_path_res := "res://Script/LanguageFile/LanguageFileChanger_Configuration.json"
	if !OS.has_feature("editor"):
		var config_path_system := OS.get_executable_path().get_base_dir() + "/LanguageFileChanger_Configuration.json"
		GlobalsClass._copy_configuration_file_if_not_exist(config_path_system, config_path_res)
		LanguageFileHelper.LoadConfiguration(config_path_system)
	else:
		LanguageFileHelper.LoadConfiguration(config_path_res)
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
