class_name Ui extends Control

@onready var windows: MarginContainer = %Windows

static var instance: Ui

func _ready():
	instance = self
	
func open_window(window_scene: PackedScene) -> Window:
	var win := window_scene.instantiate() as Window
	windows.add_child(win)
	win.close_requested.connect(func(): win.queue_free())
	return win
