class_name UI extends Control

@onready var value_changer_dialog = %ValueChangerDialog
@onready var key_selection_ui = %KeySelectionUi

func _on_key_selection_ui_open_value_changer_dialog(title, is_new, is_software, files, change_key):
	value_changer_dialog.init(title, is_new, is_software, files, change_key)

func _on_value_changer_dialog_closed():
	key_selection_ui.on_value_changer_dialog_closed()
