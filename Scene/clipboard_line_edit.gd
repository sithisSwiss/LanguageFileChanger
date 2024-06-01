class_name ClipboardLineEdit extends Container

@onready var clipboard_button := %ClipboardButton
@onready var line_edit := %LineEdit

signal text_changed(new_text: String)

var text: String = "":
	set(value):
		line_edit.text = value
	get:
		return line_edit.text

var editable: bool = true:
	set(value):
		line_edit.editable = value
		clipboard_button.disabled = !value
	get:
		return line_edit.editable

func on_pressed():
	var clipboard_text = DisplayServer.clipboard_get()
	line_edit.text = clipboard_text
	text_changed.emit(clipboard_text)

func _on_line_edit_text_changed(new_text):
	text_changed.emit(new_text)
