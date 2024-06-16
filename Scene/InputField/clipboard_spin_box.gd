class_name ClipboardSpinBox extends HBoxContainer

@onready var clipboard_button := %ClipboardButton
@onready var spin_box := %SpinBox
@onready var valid_border_panel_container: ValidBorderPanelContainer = %ValidBorderPanelContainer
@onready var step_size_box: SpinBox = %StepSize
@onready var step_size_container: HBoxContainer = %StepSizeContainer

signal value_changed(new_value: String)

var value: String:
	set(value):
		spin_box.value = float(value)
	get:
		return str(spin_box.value)
		
var editable: bool = true:
	set(value):
		spin_box.editable = value
		clipboard_button.disabled = !value
		if(value):
			step_size_container.show()
		else:
			step_size_container.hide()
	get:
		return spin_box.editable

var valid: bool:
	get:
		return valid_border_panel_container.valid
	set(value):
		valid_border_panel_container.valid = value

var _fieldName: String

func _ready() -> void:
	pass

func init(is_int: bool, fieldName: String) -> ClipboardSpinBox:
	_fieldName = fieldName
	var step_size
	if is_int:
		spin_box.rounded = true
		step_size_box.step = 1
		step_size_box.min_value = 1
		step_size_box.rounded = true
		step_size = GlobalsClass.persistent.GetStepSize(fieldName, 1)
	else:
		spin_box.rounded = false
		step_size_box.step = 0.001
		step_size_box.min_value = 0.001
		step_size_box.rounded = false
		step_size = GlobalsClass.persistent.GetStepSize(fieldName, 0.001)
	spin_box.step = step_size
	step_size_box.value = step_size
	
	return self

func on_pressed():
	var clipboard_text := DisplayServer.clipboard_get()
	spin_box.value = float(clipboard_text)
	value_changed.emit(clipboard_text)

func _on_spin_box_value_changed(new_value: float):
	value_changed.emit(str(new_value))


func _on_step_size_value_changed(value_: float) -> void:
	spin_box.step = value_
	GlobalsClass.persistent.SetStepSize(_fieldName, value_)
