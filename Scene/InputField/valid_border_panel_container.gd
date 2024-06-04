class_name ValidBorderPanelContainer extends PanelContainer

var valid: bool = true:
	set(value):
		valid = value
		remove_theme_stylebox_override("custom_styles/panel")
		add_theme_stylebox_override("custom_styles/panel", preload("res://Asset/valid_flat_style_box.tres") if value else preload("res://Asset/not_valid_flat_style_box.tres"))
		#var theme = preload("res://Asset/valid_flat_style_box.tres") if value else preload("res://Asset/not_valid_flat_style_box.tres")
		#add_theme_stylebox_override("normal", theme)
		
		pass
