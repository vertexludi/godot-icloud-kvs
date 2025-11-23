extends Control


var listener: ICloudKVS.Listener


func _ready() -> void:
	listener = ICloudKVS.make_listener()
	listener.data_changed.connect(_on_data_changed)

	# Call this once at startup.
	var did_sync := ICloudKVS.synchronize()
	print("Synchronized!" if did_sync else "NOT synchronized")

	($Margin/List/String/Set as Button).pressed.connect(_on_string_set_pressed)
	($Margin/List/String/Get as Button).pressed.connect(_on_string_get_pressed)
	($Margin/List/String/Clear as Button).pressed.connect(_clear_line_edit.bind($Margin/List/String/Value as LineEdit))

	($Margin/List/Int/Set as Button).pressed.connect(_on_int_set_pressed)
	($Margin/List/Int/Get as Button).pressed.connect(_on_int_get_pressed)
	($Margin/List/Int/Clear as Button).pressed.connect(_clear_line_edit.bind($Margin/List/Int/Value as LineEdit))

	($Margin/List/Float/Set as Button).pressed.connect(_on_float_set_pressed)
	($Margin/List/Float/Get as Button).pressed.connect(_on_float_get_pressed)
	($Margin/List/Float/Clear as Button).pressed.connect(_clear_line_edit.bind($Margin/List/Float/Value as LineEdit))

	($Margin/List/Bool/Set as Button).pressed.connect(_on_bool_set_pressed)
	($Margin/List/Bool/Get as Button).pressed.connect(_on_bool_get_pressed)
	($Margin/List/Bool/Clear as Button).pressed.connect(_clear_line_edit.bind($Margin/List/Bool/Value as LineEdit))

	($Margin/List/Data/Set as Button).pressed.connect(_on_data_set_pressed)
	($Margin/List/Data/Get as Button).pressed.connect(_on_data_get_pressed)
	($Margin/List/Data/Clear as Button).pressed.connect(_clear_line_edit.bind($Margin/List/Data/Value as LineEdit))

	($Margin/List/Synchronize as Button).pressed.connect(_on_synchronized_pressed)
	($Margin/List/GetAll as Button).pressed.connect(_on_get_all_pressed)


func _on_string_set_pressed() -> void:
	var value := ($Margin/List/String/Value as LineEdit).text
	var key := ($Margin/List/String/Key as LineEdit).text

	ICloudKVS.set_string(key, value)
	($Margin/List/String/Value as LineEdit).text = ""


func _on_string_get_pressed() -> void:
	var key := ($Margin/List/String/Key as LineEdit).text

	var value := ICloudKVS.get_string(key)
	($Margin/List/String/Value as LineEdit).text = value


func _on_int_set_pressed() -> void:
	var value := ($Margin/List/Int/Value as LineEdit).text
	var key := ($Margin/List/Int/Key as LineEdit).text

	ICloudKVS.set_int(key, int(value))
	($Margin/List/Int/Value as LineEdit).text = ""


func _on_int_get_pressed() -> void:
	var key := ($Margin/List/Int/Key as LineEdit).text

	var value := ICloudKVS.get_int(key)
	($Margin/List/Int/Value as LineEdit).text = str(value)


func _on_float_set_pressed() -> void:
	var value := ($Margin/List/Float/Value as LineEdit).text
	var key := ($Margin/List/Float/Key as LineEdit).text

	ICloudKVS.set_float(key, float(value))
	($Margin/List/Float/Value as LineEdit).text = ""


func _on_float_get_pressed() -> void:
	var key := ($Margin/List/Float/Key as LineEdit).text

	var value := ICloudKVS.get_float(key)
	($Margin/List/Float/Value as LineEdit).text = str(value)


func _on_bool_set_pressed() -> void:
	var value := ($Margin/List/Bool/Value as LineEdit).text
	var key := ($Margin/List/Bool/Key as LineEdit).text

	ICloudKVS.set_bool(key, value.to_lower() == "true")
	($Margin/List/Bool/Value as LineEdit).text = ""


func _on_bool_get_pressed() -> void:
	var key := ($Margin/List/Bool/Key as LineEdit).text

	var value := ICloudKVS.get_bool(key)
	($Margin/List/Bool/Value as LineEdit).text = "true" if value else "false"


func _on_data_set_pressed() -> void:
	var value := ($Margin/List/Data/Value as LineEdit).text
	var key := ($Margin/List/Data/Key as LineEdit).text

	ICloudKVS.set_data(key, value.to_utf8_buffer())
	($Margin/List/Data/Value as LineEdit).text = ""


func _on_data_get_pressed() -> void:
	var key := ($Margin/List/Data/Key as LineEdit).text

	var value := ICloudKVS.get_data(key)
	($Margin/List/Data/Value as LineEdit).text = value.get_string_from_utf8()


func _on_synchronized_pressed() -> void:
	var did_sync := ICloudKVS.synchronize()
	prints("Syncronized", did_sync)


func _on_get_all_pressed() -> void:
	var all := ICloudKVS.dictionary_representation()
	print(all)


func _on_data_changed(reason: ICloudKVS.Listener.Reason, keys: Array[String]) -> void:
	var popup := $DataChanged as AcceptDialog
	popup.dialog_text = "Data changed: %s, Keys: %s" % [ICloudKVS.Listener.Reason.keys()[reason], keys]
	print(popup.dialog_text)
	popup.popup_centered()


func _clear_line_edit(line_edit: LineEdit) -> void:
	line_edit.text = ""
