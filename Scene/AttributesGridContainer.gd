class_name AttributesGridContainer extends GridContainer

@onready var key_label := %KeyLabel
@onready var key_clipboard_line_edit := %KeyClipboardLineEdit
@onready var create_key := %CreateKey
@onready var info_label := %InfoLabel
@onready var info_clipboard_line_edit = %InfoClipboardLineEdit
@onready var field_label := %FieldLabel
@onready var field_edit := %FieldEdit
@onready var layout_label := %LayoutLabel
@onready var layout_edit := %LayoutEdit

signal new_item_created(item: XmlItem)

const new_item_group: String = "new_item"
const firmware_group: String = "firmware"

var validate_all_attributes: Callable

func _ready():
	key_label.set_custom_minimum_size(Vector2(Globals.Label_Width, 0))
	for type in XmlItem.LAYOUT_TYPES:
		layout_edit.add_item(type)
	layout_edit.select(0)
	
func init(is_software: bool, is_new: bool, key: String, file: String):
	validate_all_attributes = func() : return _validate(is_software, Globals.xml_class.GetKeys(file))
	
	key_clipboard_line_edit.text = key
	info_clipboard_line_edit.text = "" if is_new else Globals.xml_class.GetInfo(key, file)
	
	for node in get_tree().get_nodes_in_group(firmware_group):
		if is_software:
			node.hide()
		else:
			node.show()
	if not is_software:
		field_edit.text = "" if is_new else Globals.xml_class.GetField(key, file)
		layout_edit.select(0 if is_new else XmlItem.LAYOUT_TYPES[Globals.xml_class.GetLayout(key, file)])
	
	Globals.set_editable_of_group(is_new, new_item_group, self)
	_refresh_state_of_create_button(is_new)
	

func _refresh_state_of_create_button(is_new: bool):
	if !is_new:
		create_key.hide()
		return
	create_key.show()
	create_key.disabled = !(validate_all_attributes.call())
	
func _validate(is_software: bool, keys: Array) -> bool:
	var key_is_valid: bool = key_clipboard_line_edit.text.length() > 0 and !(key_clipboard_line_edit.text in keys)
	if !is_software:
		key_is_valid = key_is_valid and key_clipboard_line_edit.text.is_valid_int()
	var info_is_valid: bool = info_clipboard_line_edit.text.length() > 0
	var field_is_valid: bool = true if is_software else field_edit.text.length() > 0
	var layout_is_valid: bool = true if is_software else layout_edit.text != ""
	return key_is_valid and info_is_valid and field_is_valid and layout_is_valid
	

func _on_create_key_pressed():
	_refresh_state_of_create_button(false)
	Globals.set_editable_of_group(false, new_item_group, self)
	new_item_created.emit(XmlItem.create_item(key_clipboard_line_edit.text, info_clipboard_line_edit.text, field_edit.text, layout_edit.selected, ""))
	
func _on_attribute_changed(_new_text: String):
	_refresh_state_of_create_button(true)

func _on_layout_edit_selected(_index):
	_refresh_state_of_create_button(true)
