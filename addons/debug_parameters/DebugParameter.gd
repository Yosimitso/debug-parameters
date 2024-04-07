extends Node
class_name DebugParameter

var slug: String
var type: int
var label: String
var tooltip: String
var value
var config = {}
var node: Node
signal value_updated(new_value)
signal got_new_connection()
	
func _init(_slug: String, _type: int, _label: String, _tooltip: String, _config = {}, _value = null):
	slug = _slug
	type = _type
	label = _label
	tooltip = _tooltip
	config = _config
	value = _value
	
func get_slug() -> String:
	return slug

func set_slug(_slug: String):
	slug = _slug
	return self
	
func get_type() -> int:
	return type

func set_type(_type: int):
	type = _type
	return self
	
func get_label() -> String:
	return label

func set_label(_label: String):
	label = _label
	return self
	
func get_tooltip() -> String:
	return tooltip

func set_tooltip(_tooltip: String):
	tooltip = _tooltip
	return self

func get_config() -> Dictionary:
	return config

func set_config(_config: Dictionary):
	config = _config
	return self
	
func get_value():
	return value

func get_value_for_build():
	match get_type():
		DebugParameterHelper.TYPE_LIST:
			return get_value() if config['expose_index'] else config['available_values'][get_value()]
		_:
			return get_value()
	
func set_value(new_value) -> DebugParameter:
	if value != new_value or type == DebugParameterHelper.TYPE_BUTTON:
		value = new_value
		value_updated.emit(get_value_for_build())
	else:
		value = new_value
	return self

func get_current_node() -> Node:
	return node

func set_node(new_node) -> DebugParameter:
	node = new_node
	return self

func new_connection():
	got_new_connection.emit() 
	
func to_dict() -> Dictionary:
	return {
	   'slug': get_slug(),
		'type': get_type(),
		'label': get_label(),
		'tooltip': get_tooltip(),
		'config': get_config(),
		'value': get_value()
	}
