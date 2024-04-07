extends Node
class_name DebugParameterProfile

var profile_name: String
var params : Array[DebugParameter] = []

func _init(_profile_name):
	profile_name = _profile_name

func get_profile_name() -> String:
	return profile_name

func set_profile_name(_name: String):
	profile_name = _name
	
func add_param(param: DebugParameter):
	params.append(param)

func get_params() -> Array[DebugParameter]:
	return params

func to_dict() -> Dictionary:
	return {
		'profile_name': get_profile_name(),
		'params': params.map(func(param): return param.to_dict())
	}
