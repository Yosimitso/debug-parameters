@tool
extends Node

class_name DebugParameterHelper

const TYPES = [TYPE_CHECKBOX, TYPE_LIST, TYPE_TEXT, TYPE_NUMBER]
const TYPE_CHECKBOX = 0
const TYPE_TEXT = 1
const TYPE_NUMBER = 2
const TYPE_LIST = 3
const TYPE_BUTTON = 4
const CAST_AS_INT = 0
const CAST_AS_FLOAT = 0

static func generate_conf(debug_parameter: DebugParameter):
	var generated_conf = {}
	match debug_parameter.get_type():
		DebugParameterHelper.TYPE_NUMBER:
			generated_conf = {
				'min_enabled': false,
				'max_enabled': false,
				'min_value': 0,
				'max_value': 0,
				'cast_as': 0
			}
		DebugParameterHelper.TYPE_LIST:
			generated_conf = {
				'available_values': '',
				'expose_index': false
			}
	var conf = debug_parameter.get_config()	
	for key in generated_conf.keys():
		if not conf.has(key):
			conf[key] = generated_conf[key]
	
	debug_parameter.set_config(conf)
	return conf
