class_name Ui extends Control

@onready var windows: MarginContainer = %Windows

static var instance: Ui

var following = false
var dragging_start_position = Vector2()

func _ready():
	instance = self

func _process(_delta):
	if following:
		var win = get_window()
		win.position = ((win.position*1.0) + get_global_mouse_position() - dragging_start_position)

func add_window(scene: PackedScene) -> Node:
	var node = scene.instantiate()
	windows.add_child(node)
	return node

func _on_close_button_pressed():
	var size := windows.get_child_count()
	if  windows.get_child_count() == 1:
		get_tree().quit()
	var win = windows.get_children()[windows.get_child_count()-1]
	if win.has_method("close"):
		win.close()
	win.queue_free()

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			dragging_start_position = get_local_mouse_position()
