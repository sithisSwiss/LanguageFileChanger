class_name CommonInputField extends Object

signal value_changed(new_value: String)

var _field: Node

var value: String:
	get:
		return _field.get("value")
	set(value_):
		_field.set("value", value_)

var editable: bool:
	get:
		return _field.get("editable")
	set(value_):
		_field.set("editable", value_)
		
var valid: bool:
	get:
		return _field.get("valid")
	set(value_):
		_field.set("valid", value_)

func init(node: Node) -> CommonInputField:
	var list_of_property := node.get_property_list().map(func(x): return x.name)
	if not ("value" in list_of_property and node.value is String):
		print("Error with " + str(node) + " - value property")
	if not ("editable" in list_of_property and node.editable is bool):
		print("Error with " + str(node) + " - editable property")
	if not ("valid" in list_of_property and node.valid is bool):
		print("Error with " + str(node) + " - editable property")
	if not (!node.has_user_signal("value_changed")):
		print("Error with " + str(node) + " - value_chagned signal")

	_field = node
	_field.connect("value_changed", func(x): value_changed.emit(x))
	return self

func show():
	_field.show()
