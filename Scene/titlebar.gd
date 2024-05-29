extends ColorRect

var following = false
var dragging_start_position = Vector2()

signal close_pressed()

func _process(_delta):
	if following:
		var win = get_window()
		win.position = ((win.position*1.0) + get_global_mouse_position() - dragging_start_position)

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			dragging_start_position = get_local_mouse_position()

func _on_close_button_pressed():
	close_pressed.emit()
