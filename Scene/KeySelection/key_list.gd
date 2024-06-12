class_name KeyList extends GridContainer
@onready var search_label = %SearchLabel
@onready var search_clipboard_line_edit = %SearchClipboardLineEdit
@onready var item_list = %ItemList

signal key_selection_changed()
var selected_key: String = ""

var _init_keys: Array = []

func _ready():
	search_label.custom_minimum_size = Vector2(Globals.Label_Width, 0)
	Globals.language_string_changed.connect(_on_language_string_changed)
	init()

func _on_language_string_changed(caller: Object, _old_item: LanguageString, _new_item: LanguageString):
	if caller != self:
		init()
	else:
		if !(Globals.language_string.KeyAttribute.AttributeValueChanged as Signal).is_connected(_on_key_attribute_changed):
			Globals.language_string.KeyAttribute.AttributeValueChanged.connect(_on_key_attribute_changed)

func _on_key_attribute_changed(_attribute, _old_value, _new_value) -> void:
	init()

func init():
	search_clipboard_line_edit.text = ""
	if !(Globals.language_string.KeyAttribute.AttributeValueChanged as Signal).is_connected(_on_key_attribute_changed):
		Globals.language_string.KeyAttribute.AttributeValueChanged.connect(_on_key_attribute_changed)
	_init_keys = _get_keys()
	_load_keys(_init_keys)
	search_clipboard_line_edit.text = ""
	_try_to_select(Globals.language_string.Key)

func _try_to_select(key:String):
	for index in range(item_list.item_count):
		if item_list.get_item_text(index) == key:
			item_list.select(index)
			selected_key = key
			return

func _load_keys(keys: Array):
	item_list.deselect_all()
	item_list.release_focus()
	item_list.clear()
	#keys.sort_custom(func(a,b): return a < b if _is_software else int(a)<int(b))
	for key in keys:
		item_list.add_item(key)
	_select_key_if_only_one()

func _on_item_list_item_selected(index):
	if index != null:
		selected_key = item_list.get_item_text(index)
		Globals.set_existing_item(self, selected_key)
		key_selection_changed.emit()

func _on_search_clipboard_line_edit_text_changed(new_text):
	var filtered_keys = _init_keys.filter(func(key:String): return new_text == "" or new_text in key)
	_load_keys(filtered_keys)

func _select_key_if_only_one():
	if item_list.item_count != 1:
		selected_key = ""
		return
	item_list.select(0)
	selected_key = item_list.get_item_text(0)
	key_selection_changed.emit()

func _get_keys(_item: LanguageString = Globals.language_string) -> Array:
	return LanguageFileHelper.GetAllKeysFromFirstFile()
