class_name KeyList extends GridContainer
@onready var search_label = %SearchLabel
@onready var search_clipboard_line_edit = %SearchClipboardLineEdit
@onready var item_list = %ItemList

@export var label_width:int = Globals.Label_Width

signal key_selection_changed()
var selected_key: String = ""

var _init_keys: Array = []

func _ready():
	search_label.custom_minimum_size = Vector2(label_width, 0)

func init(file_path: String):
	_init_keys = Array(XmlScript.GetKeys(file_path)) if file_path != "" else []
	_load_keys(_init_keys)
	search_clipboard_line_edit.text = ""

func try_to_select(key:String):
	for index in range(item_list.item_count):
		if item_list.get_item_text(index) == key:
			item_list.select(index)
			selected_key = key
			return

func _load_keys(keys: Array):
	item_list.deselect_all()
	item_list.clear()
	#keys.sort_custom(func(a,b): return a < b if _is_software else int(a)<int(b))
	for key in keys:
		item_list.add_item(key)
	_select_key_if_only_one()

func _on_item_list_item_selected(index):
	if index != null:
		selected_key = item_list.get_item_text(index)
		key_selection_changed.emit()

func _on_search_clipboard_line_edit_text_changed(new_text):
	var filtered_keys = _init_keys.filter(func(key:String): return new_text == "" or new_text in key)
	_load_keys(filtered_keys)

func _select_key_if_only_one():
	if item_list.item_count == 1:
		item_list.select(0)
	selected_key = item_list.get_item_text(0) if item_list.item_count == 1 else ""
	key_selection_changed.emit()
