extends Control
@onready var animation_player = $AnimationPlayer

func _ready():
	show()

func _process(_delta):
	if Input.is_action_pressed("Click"):
		queue_free()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			queue_free()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "splash_screen":
		hide()


