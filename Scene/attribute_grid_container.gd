class_name AttributesGridContainer extends GridContainer

signal attribute_item_changed(item: LanguageFileItem)

@export var label_width: int = Globals.Label_Width

const edit_group: String = "edit"

var _input_fields : Dictionary

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
	_set_item_to_fields(item)
	editable = false

func _on_SpinBox_value_changed(_new_text: float):
	_on_input_chagned()
	
func _on_ClipboardLineEdit_changed(_new_text: String):
	_on_input_chagned()

func _on_OptionButton_selection_changed(_index):
	_on_input_chagned()

func _on_input_chagned():
	for key in _input_fields:
		if _input_fields[key] is ClipboardLineEdit:
			_item.SetAttributeValue(key, (_input_fields[key] as ClipboardLineEdit).text)
		elif _input_fields[key] is ClipboardSpinBox:
			_item.SetAttributeValue(key, str((_input_fields[key] as ClipboardSpinBox).value))
		elif _input_fields[key] is OptionButton:
			var index = (_input_fields[key] as OptionButton).selected
			_item.SetAttributeValue(key, (_input_fields[key] as OptionButton).get_item_text(index))
	attribute_item_changed.emit(_item)

func _on_item_attribute_changed():
	_set_item_to_fields(_item)

func _add_attribute_fields():
	_input_fields.clear()
	for attribute_config_untyped in Globals.language_file_configuration.Attributes:
		var attribute_config := attribute_config_untyped as LanguageFileConfigurationAttribute
		var label := Label.new()
		add_child(label)
		label.text = attribute_config.DisplayName
		label.custom_minimum_size = Vector2(label_width, 0)
		var input_field: Control
		if attribute_config.IsInt or attribute_config.IsFloat:
			input_field = preload("res://Scene/clipboard_spin_box.tscn").instantiate()
			(input_field as ClipboardSpinBox).value_changed.connect(_on_SpinBox_value_changed)
		elif attribute_config.IsString:
			input_field = preload("res://Scene/clipboard_line_edit.tscn").instantiate()
			(input_field as ClipboardLineEdit).text_changed.connect(_on_ClipboardLineEdit_changed)
		elif attribute_config.EnumValues.size() > 0:
			input_field = OptionButton.new()
			(input_field as OptionButton).item_selected.connect(_on_OptionButton_selection_changed)
			for index in range(attribute_config.EnumValues.size()):
				(input_field as OptionButton).add_item(attribute_config.EnumValues[index])
		input_field.name = input_field.name + str(input_field.get_instance_id())
		add_child(input_field)
		input_field.add_to_group(edit_group)
		input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_input_fields[attribute_config.Name] = input_field

func _set_item_to_fields(item: LanguageFileItem):
	for key in _input_fields:
		if _input_fields[key] is ClipboardLineEdit:
			(_input_fields[key] as ClipboardLineEdit).text = item.GetAttributeValue(key)
		elif _input_fields[key] is ClipboardSpinBox:
			(_input_fields[key] as ClipboardSpinBox).value = float(item.GetAttributeValue(key))
			#(input_field as ClipboardSpinBox).rounded = true if attribute_config.IsInt else false
		elif _input_fields[key] is OptionButton:
			var value = item.GetAttributeValue(key)
			_select_by_value(value, (_input_fields[key] as OptionButton))

func _select_by_value(value: String, option_button: OptionButton):
	for index in range(option_button.item_count):
		var value_at_index = option_button.get_item_text(index)
		if value_at_index == value:
			option_button.select(index)
			return
