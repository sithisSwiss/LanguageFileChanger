extends Control

@export var main_scene : PackedScene

func _ready():
	_resize_window()
	_reposition_window()
	
	var scene = main_scene.instantiate()
	add_child(scene)
	

func _resize_window():
	var new_width = DisplayServer.screen_get_size().x / 1.5
	get_window().size = Vector2i(new_width, new_width/16*9)

func _reposition_window():
	var screen_size := DisplayServer.screen_get_size()
	var win = get_window()
	var current_screen = DisplayServer.window_get_current_screen(win.get_window_id())
	win.position = Vector2(screen_size.x / 2 - win.size.x / 2, screen_size.y / 2 - win.size.y / 2)
	DisplayServer.window_set_current_screen(current_screen, win.get_window_id())
