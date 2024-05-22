class_name Persistent extends Resource


@export var base_path: String = "C:/Git/cfn/"

func save_data():
	ResourceSaver.save(self, Persistent.get_persistent_file())

static func get_persistent() -> Persistent:
	if ResourceLoader.exists(get_persistent_file()):
		var p = ResourceLoader.load(get_persistent_file())
		if p is Persistent:
			return p
	return Persistent.new()

static func get_persistent_file():
	return OS.get_executable_path().get_base_dir() + "/cfn-languageFileChanger.tres"
