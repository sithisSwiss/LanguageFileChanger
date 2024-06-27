class_name ValuesWindow extends Window

@onready var attribute_grid_container: AttributesGridContainer = %AttributeGridContainer
@onready var values_grid_container: ValuesGridContainer = %ValuesGridContainer
@onready var values_panel_container: PanelContainer = %ValuesPanelContainer
@onready var create_item_container: CenterContainer = %CreateItemContainer
@onready var create_item_button: Button = %CreateItemButton

signal item_created()

var _keys: Array

func _ready():
	hide()
	values_panel_container.hide()
	min_size = Vector2(800,400)

func init_change():
	title = tr("TITLE_CHANGE_ITEM") % Globals.language_string.Key
	attribute_grid_container.editable = false
	values_grid_container.init()
	values_panel_container.show()
	create_item_container.hide()
	init()
	return self

func init_add():
	title = tr("TITLE_ADD_ITEM")
	attribute_grid_container.editable = true
	create_item_container.show()
	create_item_button.disabled = true
	Globals.language_string.CanBeSaved = false
	init()
	Globals.language_string.ItemChanged.connect(func(x): _on_attribute_changed(x))
	return self

func init():
	_keys = LanguageFileHelper.GetAllKeysFromFirstFile()
	show()

func _on_attribute_changed(item: LanguageString):
	create_item_button.disabled = !item.Validate(_keys)

func _on_create_item_pressed():
	Globals.language_string.CanBeSaved = true
	Globals.language_string.AddItemToFiles()
	Globals.fire_language_string_changed()
	item_created.emit()
	init_change()
