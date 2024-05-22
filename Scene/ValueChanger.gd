class_name ValueChanger extends VBoxContainer

@onready var title_value := %TitleValue
@onready var value_base := %ValueBase

# Called when the node enters the scene tree for the first time.
func _ready():
	value_base.hide()

func set_title(title: String):
	title_value.text = title
	
func init(is_new: bool):
	pass
	
