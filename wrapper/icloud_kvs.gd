class_name ICloudKVS
extends RefCounted


const _PLUGIN_CLASS := &"GodotICloudKVS"


static func set_string(key: String, value: String) -> void:
	if _has_plugin():
		ClassDB.class_call_static(_PLUGIN_CLASS, "set_string", key, value)


static func get_string(key: String) -> String:
	if _has_plugin():
		return ClassDB.class_call_static(_PLUGIN_CLASS, "get_string", key) as String
	return ""


static func set_int(key: String, value: int) -> void:
	if _has_plugin():
		ClassDB.class_call_static(_PLUGIN_CLASS, "set_int", key, value)


static func get_int(key: String) -> int:
	if _has_plugin():
		return ClassDB.class_call_static(_PLUGIN_CLASS, "get_int", key) as int
	return 0

static func set_float(key: String, value: float) -> void:
	if _has_plugin():
		ClassDB.class_call_static(_PLUGIN_CLASS, "set_float", key, value)


static func get_float(key: String) -> float:
	if _has_plugin():
		return ClassDB.class_call_static(_PLUGIN_CLASS, "get_float", key) as float
	return 0.0


static func set_bool(key: String, value: bool) -> void:
	if _has_plugin():
		ClassDB.class_call_static(_PLUGIN_CLASS, "set_bool", key, value)


static func get_bool(key: String) -> bool:
	if _has_plugin():
		return ClassDB.class_call_static(_PLUGIN_CLASS, "get_bool", key) as bool
	return false


static func set_data(key: String, value: PackedByteArray) -> void:
	if _has_plugin():
		ClassDB.class_call_static(_PLUGIN_CLASS, "set_data", key, value)


static func get_data(key: String) -> PackedByteArray:
	if _has_plugin():
		return ClassDB.class_call_static(_PLUGIN_CLASS, "get_data", key) as PackedByteArray
	return PackedByteArray()


static func dictionary_representation() -> Dictionary:
	if _has_plugin():
		return ClassDB.class_call_static(_PLUGIN_CLASS, "dictionary_representation") as Dictionary
	return Dictionary()


static func synchronize() -> bool:
	if _has_plugin():
		return ClassDB.class_call_static(_PLUGIN_CLASS, "synchronize") as bool
	return false


static func make_listener() -> Listener:
	var internal_listener: RefCounted
	if _has_plugin():
		internal_listener = ClassDB.class_call_static(_PLUGIN_CLASS, "make_listener") as RefCounted

	return Listener.new(internal_listener)


static func _has_plugin() -> bool:
	return ClassDB.class_exists(_PLUGIN_CLASS)


class Listener:
	enum Reason {
		SERVER_CHANGE = 0,
		INITIAL_SYNC = 1,
		QUOTA_VIOLATION = 2,
		ACCOUNT_CHANGE = 3,
	}
	signal data_changed(reason: Reason, keys: Array[String])


	var _listener: RefCounted


	func _init(listener: RefCounted):
		_listener = listener
		if _listener:
			_listener.data_changed.connect(func(reason: int, keys: Array[String]) -> void: data_changed.emit(reason, keys))
