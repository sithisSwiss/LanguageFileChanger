class_name Persistent extends Resource


@export var base_path: String = "C:/Git/cfn/" :
	set(value):
		base_path = value
		save_data()
@export var is_software: bool = true :
	set(value):
		is_software = value
		save_data()

func save_data():
	ResourceSaver.save(self, Persistent._get_persistent_file())

static func get_persistent() -> Persistent:
	if ResourceLoader.exists(Persistent._get_persistent_file()):
		var p = ResourceLoader.load(Persistent._get_persistent_file())
		if p is Persistent:
			return p
	return Persistent.new()

static func _get_persistent_file():
	return OS.get_executable_path().get_base_dir() + "/cfn-languageFileChanger.tres"
