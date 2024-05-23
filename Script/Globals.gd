class_name Globals extends Object

const Label_Width: int = 200

const xml_class = preload("res://Script/XmlScript.cs")



const Language_Dict: Dictionary = {
	"bg": "Bulgarian",
	"cs": "Czech",
	"de": "German",
	"en": "English",
	"es": "Spanish",
	"fr": "French",
	"hu": "Hungarian",
	"it": "Italian",
	"ja": "Japanese",
	"ko": "Korean",
	"nb": "Norwegian Bokmål",
	"nl": "Dutch",
	"pl": "Polish",
	"pt-BR": "Brazil-Portuguese",
	"pt-PT": "Portuguese",
	"ro": "Romanian",
	"sk": "Slovak",
	"sl": "Slovenian",
	"sr-Cyrl": "Serbian Cyrillic",
	"sv": "Swedish",
	"tr": "Turkish",
	"zh": "Chinese",
}

static func set_editable_of_group(is_editable: bool, group: String, parent: Node):
	for node in parent.get_tree().get_nodes_in_group(group):
		if node is LineEdit or node is ClipboardLineEdit:
			node.editable = is_editable
		elif node is Button:
			node.disabled = !is_editable
