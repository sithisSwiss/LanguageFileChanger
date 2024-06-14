class_name ValueFromListSelector extends HBoxContainer

@onready var valid_border_panel_container: ValidBorderPanelContainer = %ValidBorderPanelContainer
@onready var decrease: Button = %decrease
@onready var value_label: Label = %ValueLabel
@onready var increase: Button = %increase
@onready var h_slider: HSlider = %HSlider

signal value_changed(new_value: String)

var value: String:
	get:
		return _values[clamp(_index, 0, _max_index())]
	set(value_):
		var index_ = _values.find(value_)
		if index_ != -1:
			_index = index_

var _index: int = 0:
	get:
		return _index
	set(value):
		_index = clamp(value, 0, _max_index())
		value_label.text = _values[_index]
		h_slider.value = _index
		value_changed.emit(_values[clamp(_index, 0, _max_index())])
		
var _values: Array

var editable: bool = true:
	set(value):
		decrease.disabled = !value
		increase.disabled = !value
		h_slider.editable = value
	get:
		return h_slider.editable

var valid: bool:
	get:
		return valid_border_panel_container.valid
	set(value):
		valid_border_panel_container.valid = value

func init(values: Array):
	_values = values
	h_slider.max_value = _max_index()
	h_slider.tick_count = _values.size()

func _max_index():
	return _values.size()-1

func _on_decrease_pressed() -> void:
	if _index <= 0:
		_index = _max_index()
	else:
		_index -= 1


func _on_increase_pressed() -> void:
	if _index >= _max_index():
		_index = 0
	else:
		_index += 1

func _on_h_slider_value_changed(value_: float) -> void:
	_index = int(value_)
