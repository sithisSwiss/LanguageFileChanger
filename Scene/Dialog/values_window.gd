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

func init_change(attribute_item: LanguageFileItem, file_paths: Array):
	title = "Change Item (" + attribute_item.Key +")"
	attribute_grid_container.init(attribute_item)
	attribute_grid_container.editable = false
	values_grid_container.add_value_fields(file_paths, attribute_item.Key, edit_node_group)
	values_panel_container.show()
	create_item_container.hide()
	init(file_paths)
	return self

func init_add(file_paths: Array):
	title = "Add Item"
	attribute_grid_container.init(LanguageFileItem.new())
	attribute_grid_container.attribute_item_changed.connect(_on_attribute_changed)
	attribute_grid_container.editable = true
	create_item_container.show()
	create_item_button.disabled = true
	init(file_paths)
	return self

func init(file_paths: Array):
	_file_paths = file_paths
	_keys = XmlScript.GetKeys(file_paths.front())
	show()

func _on_attribute_changed(item: LanguageFileItem):
	_attribute_item = item
	create_item_button.disabled = !item.Validate(_keys)

func _on_create_item_pressed():
	item_created.emit(_attribute_item)
	init_change(_attribute_item, _file_paths)
