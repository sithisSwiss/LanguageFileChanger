extends Node

const Label_Width: int = 200

const Title: String = "Language File Changer"

static var persistent := preload("res://Script/Persistent.cs").GetPersistent()

signal language_file_item_changed(caller: Object, old_item: LanguageFileItem, new_item: LanguageFileItem)

var language_file_item : LanguageFileItem = LanguageFileItem.CreateNewItem()

func set_existing_item(caller: Object, key: String) -> void:
	var old_value := language_file_item
	language_file_item = LanguageFileItem.CreateExistingItem(key)
	language_file_item_changed.emit(caller, old_value, language_file_item)

func set_new_item(caller: Object) -> void:
	var old_value := language_file_item
	language_file_item = LanguageFileItem.CreateNewItem()
	language_file_item_changed.emit(caller, old_value, language_file_item)

static func set_editable_of_group(is_editable: bool, group: String, parent: Node) -> void:
	for node in parent.get_tree().get_nodes_in_group(group):
		if node is LineEdit or node is ClipboardLineEdit or node is ClipboardSpinBox:
			node.editable = is_editable
		elif node is Button:
			node.disabled = !is_editable
