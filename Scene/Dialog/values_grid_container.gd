class_name ValuesGridContainer extends GridContainer

@onready var clipboard_line_edit_scene := preload("res://Scene/InputField/clipboard_line_edit.tscn")

func init():
	for file in LanguageFileHelper.GetLanguageFilePaths():
		_add_value_field(file)

func _add_value_field(file: String):
	var label_node := Label.new()
	label_node.text = Globals.language_string.GetLanguage(file)
	label_node.set_custom_minimum_size(Vector2(Globals.Label_Width, 0))
	add_child(label_node)

	var edit_node := clipboard_line_edit_scene.instantiate() as ClipboardLineEdit
	add_child(edit_node)
	edit_node.text = Globals.language_string.GetValueFromFile(file)
	edit_node.size_flags_horizontal = SIZE_EXPAND_FILL
	edit_node.text_changed.connect(func(new_text:String): Globals.language_string.SetValueToFile(file, new_text))

func clear():
	for child in get_children():
		remove_child(child)
