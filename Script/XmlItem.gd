class_name XmlItem extends Object

#const LAYOUT_TYPES = [ "A", "A1", "B", "B1", "C", "C1", "D", "E", "F", "G", "UNKNOWN", "unknown"]
enum LAYOUT_TYPES { A, A1, B, B1, C, C1, D, E, F, G, UNKNOWN, unknown}

signal item_changed(new_item: XmlItem)

var key: String:
	set(value):
		key = value
		item_changed.emit(self)
var info: String:
	set(value):
		info = value
		item_changed.emit(self)
var field: String:
	set(value):
		field = value
		item_changed.emit(self)
var layout: LAYOUT_TYPES:
	set(value):
		layout = value
		item_changed.emit(self)
var value: String:
	set(value_):
		value = value_
		item_changed.emit(self)

static func create_item(key_: String, info_: String, field_: String, layout_: LAYOUT_TYPES, value_: String) -> XmlItem:
	var item = XmlItem.new()
	item.key = key_
	item.info = info_
	item.field = field_
	item.layout = layout_
	item.value = value_
	return item

static func create_item_from_file(key_: String, file: String) -> XmlItem:
	var info_ = Globals.xml_class.GetInfo(key_, file)
	var field_ = Globals.xml_class.GetField(key_, file)
	var layout_ = Globals.xml_class.GetLayout(key_, file)
	layout_ = LAYOUT_TYPES.A if layout_ == "" else XmlItem.LAYOUT_TYPES[layout_]
	var value_ = Globals.xml_class.GetValue(key_, file)
	return XmlItem.create_item(key_, info_, field_, layout_, value_)

static func create_emtpy_item() -> XmlItem:
	return create_item("", "", "", LAYOUT_TYPES.A, "")

func validate(is_software: bool, keys: Array) -> bool:
	var key_is_valid: bool = key.length() > 0 and !(key in keys)
	if !is_software:
		key_is_valid = key_is_valid and key.is_valid_int()
	var info_is_valid: bool = info.length() > 0
	var field_is_valid: bool = true if is_software else field.length() > 0
	var layout_is_valid: bool = true if is_software else layout < LAYOUT_TYPES.size()
	return key_is_valid and info_is_valid and field_is_valid and layout_is_valid
