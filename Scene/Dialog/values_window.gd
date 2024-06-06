class_name ValuesWindow extends Window

@onready var attribute_grid_container: AttributesGridContainer = %AttributeGridContainer
@onready var values_grid_container: ValuesGridContainer = %ValuesGridContainer
@onready var values_panel_container: PanelContainer = %ValuesPanelContainer
@onready var create_item_container: CenterContainer = %CreateItemContainer
@onready var create_item_button: Button = %CreateItemButton

signal item_created(item: LanguageFileItem)

var _keys: Array
var _file_paths: Array
var _attribute_item: LanguageFileItem

const edit_node_group: String = "value_dialog_value_edit"

func _ready():
	hide()
	values_panel_container.hide()
	min_size = Vector2(800,400)

func init_change():
	title = "Change Item (" + Globals.language_file_item.Key +")"
	attribute_grid_container.reload()
	attribute_grid_container.editable = false
	values_grid_container.init(edit_node_group)
	values_panel_container.show()
	create_item_container.hide()
	init()
	return self

func init_add():
	title = "Add Item"
	Globals.set_new_item(self)
	attribute_grid_container.reload()
	attribute_grid_container.editable = true
	create_item_container.show()
	create_item_button.disabled = true
	init()
	return self

func init():
	var file_paths = Globals.language_file_item.GetFilePaths()
	_keys = XmlScript.GetKeys(file_paths.front())
	show()

func _on_attribute_changed(item: LanguageFileItem):
	_attribute_item = item
	create_item_button.disabled = !item.Validate(_keys)

func _on_create_item_pressed():
	item_created.emit(_attribute_item)
	init_change()
