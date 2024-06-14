class_name AttributesGridContainer extends PanelContainer
@onready var v_box_container: VBoxContainer = %VBoxContainer

var editable: bool:
	set(value):
		editable = value
		for child in v_box_container.get_children():
			if child is AttributeInputField:
				(child as AttributeInputField).editable = value
	get:
		return editable

func _ready() -> void:
	_add_attribute_fields()
	editable = false
	Globals.language_string_changed.connect(_on_language_string_changed)

func _on_language_string_changed(caller: Object, old_item: LanguageString, new_item: LanguageString):
	if caller == self or caller is AttributeInputField:
		return

	if !old_item.HasTheSameAttributeConfiguration(new_item):
		for node in v_box_container.get_children():
			v_box_container.remove_child(node)
		_add_attribute_fields()
	elif old_item.Key != new_item.Key:
		_set_value(new_item)
	editable = Globals.language_string.Key != ""

func _add_attribute_fields():
	for attribute in Globals.language_string.Attributes:
		var input_field = preload("res://Scene/InputField/attribute_input_field.tscn").instantiate()
		v_box_container.add_child(input_field)
		input_field.init(attribute.Name)

func _set_value(item_: LanguageString):
	for field in v_box_container.get_children():
		if field is AttributeInputField:
			field.value = item_.GetAttribute(field.attribute_name).Value
