class_name ValuesGridContainer extends GridContainer

@onready var clipboard_line_edit_scene := preload("res://Scene/InputField/clipboard_line_edit.tscn")

const _value_group := "value_group"
var apply_to_all_edit_line : ClipboardLineEdit

func init():
	var apply_to_all_btn = Button.new()
	add_child(apply_to_all_btn)
	apply_to_all_btn.text = tr("BUTTON_APPLY_TO_ALL")
	apply_to_all_btn.size_flags_horizontal = SIZE_FILL
	apply_to_all_btn.pressed.connect(_apply_to_all)
	apply_to_all_btn.focus_mode = Control.FOCUS_NONE
	
	apply_to_all_edit_line = clipboard_line_edit_scene.instantiate() as ClipboardLineEdit
	add_child(apply_to_all_edit_line)
	apply_to_all_edit_line.size_flags_horizontal = SIZE_EXPAND_FILL
	
	for file in LanguageFileHelper.GetCurrentLanguageFilePaths():
		_add_value_field(file)

func _add_value_field(file: String):
	var label_node := Label.new()
	label_node.text = Globals.language_string.GetLanguage(file)
	label_node.set_custom_minimum_size(Vector2(Globals.Label_Width, 0))
	add_child(label_node)

	var edit_node := clipboard_line_edit_scene.instantiate() as ClipboardLineEdit
	add_child(edit_node)
	edit_node.add_to_group(_value_group)
	edit_node.value = Globals.language_string.GetValueFromFile(file)
	edit_node.size_flags_horizontal = SIZE_EXPAND_FILL
	edit_node.value_changed.connect(func(new_text:String): Globals.language_string.SetValueToFile(file, new_text))

func clear():
	for child in get_children():
		remove_child(child)
		
func _apply_to_all():
	var value = apply_to_all_edit_line.value
	for child in get_children():
		if child.is_in_group(_value_group):
			var typed_child := child as ClipboardLineEdit
			typed_child.value = value
			typed_child._on_line_edit_text_changed(value)
