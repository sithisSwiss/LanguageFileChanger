class_name AttributesGridContainer extends GridContainer

@onready var key_label := %KeyLabel
@onready var key_clipboard_line_edit := %KeyClipboardLineEdit
@onready var info_label := %InfoLabel
@onready var info_clipboard_line_edit = %InfoClipboardLineEdit
@onready var field_label := %FieldLabel
@onready var field_edit := %FieldEdit
@onready var layout_label := %LayoutLabel
@onready var layout_edit := %LayoutEdit

signal attribute_item_changed(item: XmlItem)

@export var label_width: int = Globals.Label_Width

const edit_group: String = "edit"
const firmware_group: String = "firmware"

var _item: XmlItem:
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

func _ready():
	key_label.set_custom_minimum_size(Vector2(label_width, 0))
	for type in XmlItem.LAYOUT_TYPES:
		layout_edit.add_item(type)
	layout_edit.select(0)

func init(is_software: bool, item: XmlItem):
	_item = item
	editable = false
	for node in get_tree().get_nodes_in_group(firmware_group):
		if is_software:
			node.hide()
		else:
			node.show()

func _on_attribute_changed(_new_text: String):
	_on_input_chagned()

func _on_layout_edit_selected(_index):
	_on_input_chagned()

func _on_input_chagned():
	_item.key = key_clipboard_line_edit.text
	_item.info = info_clipboard_line_edit.text
	_item.field = field_edit.text
	_item.layout = layout_edit.selected
	attribute_item_changed.emit(_item)
	
func _on_item_attribute_changed():
	key_clipboard_line_edit.text = _item.key
	info_clipboard_line_edit.text = _item.info
	field_edit.text = _item.field
	layout_edit.select(_item.layout)
	pass
