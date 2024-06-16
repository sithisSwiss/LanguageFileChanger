class_name LanguageChange extends HBoxContainer

@onready var option_button: OptionButton = $OptionButton

var lang_tag = [
	"en",
	"de"
	]
var lang_name = [
	"English",
	"Deutsch"
	]
	
func _ready() -> void:
	for name_ in lang_name:
		option_button.add_item(name_)
	option_button.selected = GlobalsClass.persistent.SelectedLanguageIndex
	TranslationServer.set_locale(lang_tag[GlobalsClass.persistent.SelectedLanguageIndex])

func _on_option_button_item_selected(index: int) -> void:
	TranslationServer.set_locale(lang_tag[index])
	GlobalsClass.persistent.SelectedLanguageIndex = index
