class_name AttributesGridContainer extends GridContainer

signal attribute_item_changed(item: LanguageFileItem)

@export var label_width: int = Globals.Label_Width

const edit_group: String = "edit"

var input_fields : Dictionary

var _item: LanguageFileItem:
	set(value):
		_item = value
		_on_item_attribute_changed()
	get:
		return _item

var editable: bool:
	set(value):
		editable = value
		Globals.set_editable_of_group(editable, edit_group, self)
	get:
		return editable

func init(item: LanguageFileItem):
	_item = item
	for child in get_children():
		remove_child(child)
	_add_attribute_fields()
	editable = false

func _on_ClipboardLineEdit_changed(_new_text: String):
	_on_input_chagned()

func _on_OptionButton_selection_changed(_index):
	_on_input_chagned()

func _on_input_chagned():
	for key in input_fields:
		if input_fields[key] is ClipboardLineEdit:
			_item.SetAttributeValue(key, (input_fields[key] as ClipboardLineEdit).text)
		elif input_fields[key] is OptionButton:
			var index = (input_fields[key] as OptionButton).selected
			_item.SetAttributeValue(key, (input_fields[key] as OptionButton).get_item_text(index))
	attribute_item_changed.emit(_item)

func _on_item_attribute_changed():
	for key in input_fields:
		if input_fields[key] is ClipboardLineEdit:
			(input_fields[key] as ClipboardLineEdit).text = _item.GetAttributeValue(key)
		elif input_fields[key] is OptionButton:
			var value = _item.Attributes[key]
			var input_field := (input_fields[key] as OptionButton)
			# ToDo get index
			var index = 0
			input_field.select(index)

func _add_attribute_fields():
	input_fields.clear()
	for attribute_config_untyped in Globals.language_file_configuration.Attributes:
		var attribute_config := attribute_config_untyped as LanguageFileConfigurationAttribute
		var label := Label.new()
		add_child(label)
		label.text = attribute_config.DisplayName
		label.custom_minimum_size = Vector2(label_width, 0)

		var input_field: Control
		if attribute_config.IsInt or attribute_config.IsString or attribute_config.IsFloat:
			input_field = preload("res://Scene/clipboard_line_edit.tscn").instantiate()
			(input_field as ClipboardLineEdit).text_changed.connect(_on_ClipboardLineEdit_changed)
		elif attribute_config.EnumValues.size > 0:
			input_field = OptionButton.new()
			(input_field as OptionButton).item_selected.connect(_on_OptionButton_selection_changed)
			for value in attribute_config.EnumValues:
				(input_field as OptionButton).add_item(value)
		add_child(input_field)
		input_field.add_to_group(edit_group)
		input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		input_fields[attribute_config.Name] = input_field
