class_name ValueFromListSelector extends VBoxContainer

@onready var decrease: Button = %decrease
@onready var value_label: Label = %ValueLabel
@onready var increase: Button = %increase
@onready var h_slider: HSlider = %HSlider

signal value_changed(index: int)

var index: int = 0:
	get:
		return index
	set(value):
		index = clamp(value, 0, _max_index())
		value_label.text = _values[index]
		h_slider.value = index
		value_changed.emit(index)
		
var _values: Array

var editable: bool = true:
	set(value):
		decrease.disabled = !value
		increase.disabled = !value
		h_slider.editable = value
	get:
		return h_slider.editable


func init(values: Array):
	_values = values
	h_slider.max_value = _max_index()
	h_slider.tick_count = _values.size()

func get_value(index_: int):
	return _values[clamp(index_, 0, _max_index())]

func set_index_based_on_value(value_: String):
	var index_ = _values.find(value_)
	if index_ != -1:
		index = index_

func _max_index():
	return _values.size()-1

func _on_decrease_pressed() -> void:
	if index <= 0:
		index = _max_index()
	else:
		index -= 1


func _on_increase_pressed() -> void:
	if index >= _max_index():
		index = 0
	else:
		index += 1

func _on_h_slider_value_changed(value: float) -> void:
	index = int(value)
