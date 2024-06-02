class_name Globals extends Node

const Label_Width: int = 200

const Title: String = "Language File Changer"

static var language_file_configuration: LanguageFileConfiguration:
	get:
		return LanguageFileConfiguration.GetCurrentConfiguration()

static var persistent := preload("res://Script/Persistent.cs").GetPersistent()


static func set_editable_of_group(is_editable: bool, group: String, parent: Node):
	for node in parent.get_tree().get_nodes_in_group(group):
		if node is LineEdit or node is ClipboardLineEdit or node is ClipboardSpinBox:
			node.editable = is_editable
		elif node is Button:
			node.disabled = !is_editable
