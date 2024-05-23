class_name XmlItem extends Object

#const LAYOUT_TYPES = [ "A", "A1", "B", "B1", "C", "C1", "D", "E", "F", "G", "UNKNOWN", "unknown"]
enum LAYOUT_TYPES { A, A1, B, B1, C, C1, D, E, F, G, UNKNOWN, unknown}

var key: String
var info: String
var field: String
var layout: LAYOUT_TYPES
var value: String

static func create_item(key_: String, info_: String, field_: String, layout_: LAYOUT_TYPES, value_: String) -> XmlItem:
	var item = XmlItem.new()
	item.key = key_
	item.info = info_
	item.field = field_
	item.layout = layout_
	item.value = value_
	return item
