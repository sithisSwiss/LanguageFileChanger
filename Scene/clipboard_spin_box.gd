class_name ClipboardSpinBox extends Container

@onready var clipboard_button := %ClipboardButton
@onready var spin_box := %SpinBox

signal value_changed(new_value: float)

var value: float = 0:
	set(value):
		spin_box.value = value
	get:
		return spin_box.value
		
var rounded: bool = false:
	set(value):
		spin_box.rounded = value
	get:
		return spin_box.rounded
		
var editable: bool = true:
	set(value):
		spin_box.editable = value
		clipboard_button.disabled = !value
	get:
		return spin_box.editable

func _ready() -> void:
	spin_box.allow_greater = true
	spin_box.allow_lesser = true

func on_pressed():
	var clipboard_text = DisplayServer.clipboard_get()
	spin_box.value = float(clipboard_text)
	value_changed.emit(float(clipboard_text))

func _on_spin_box_value_changed(new_value: float):
	value_changed.emit(new_value)
