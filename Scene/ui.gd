class_name Ui extends Control

@onready var windows: MarginContainer = %Windows

static var instance: Ui

func _ready():
	instance = self

func add_window(scene: PackedScene) -> Node:
	for node in windows.get_children():
		node.hide()
	
	var node = scene.instantiate()
	windows.add_child(node)
	return node

func _on_close_button_pressed():
	if  windows.get_child_count() == 1:
		get_tree().quit()
	
	windows.get_children()[windows.get_child_count()-2].show()
	windows.get_children()[windows.get_child_count()-1].queue_free()
