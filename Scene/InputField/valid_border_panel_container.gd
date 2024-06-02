class_name ValidBorderPanelContainer extends PanelContainer

var valid: bool = true:
	set(value):
		valid = value
		add_theme_stylebox_override("", preload("res://Asset/valid_flat_style_box.tres") if valid else preload("res://Asset/not_valid_flat_style_box.tres"))
