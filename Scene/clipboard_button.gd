class_name ClipboardButton extends Button

func _ready():
	pass
	
func init(copy_to: LineEdit) -> ClipboardButton:
	pressed.connect(func(): on_pressed(copy_to, DisplayServer.clipboard_get()))
	return self
	
func on_pressed(copy_to: LineEdit, copy_text: String):
	copy_to.text = copy_text
	copy_to.text_changed.emit(copy_text)
