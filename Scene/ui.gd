class_name UI extends Control

@onready var value_changer_dialog = %ValueChangerDialog
@onready var key_selection_ui = %KeySelectionUi

func _on_key_selection_ui_open_value_changer_dialog(is_new, is_software, item_for_attribute, files):
	if is_new:
		value_changer_dialog.init_add(is_software, files)
	else:
		value_changer_dialog.init_change(is_software, item_for_attribute, files)
	await value_changer_dialog.closed
	key_selection_ui.on_value_changer_dialog_closed()
