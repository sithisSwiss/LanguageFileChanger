class_name ClipboardLineEdit extends HBoxContainer

@onready var clipboard_button := %ClipboardButton
@onready var line_edit := %LineEdit
@onready var valid_border_panel_container: ValidBorderPanelContainer = %ValidBorderPanelContainer

signal value_changed(new_value: String)

var value: String = "":
	set(value_):
		line_edit.text = value_
	get:
		return line_edit.text

var editable: bool = true:
	set(value):
		line_edit.editable = value
		clipboard_button.disabled = !value
	get:
		return line_edit.editable

var valid: bool:
	set(value):
		valid_border_panel_container.valid = value
	get:
		return valid_border_panel_container.valid

func on_pressed():
	var clipboard_text = DisplayServer.clipboard_get()
	line_edit.text = clipboard_text
	value_changed.emit(clipboard_text)

func _on_line_edit_text_changed(new_text):
	value_changed.emit(new_text)
