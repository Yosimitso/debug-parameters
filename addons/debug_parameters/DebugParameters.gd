extends Node
class_name DebugParametersClass
var regex: RegEx
var panel
var values_updated_signal := {}
var enabled: bool = true
signal initialized() 
signal on_enable()
signal on_disable()
signal on_new_param_connection()

func _ready():
	regex = RegEx.new()
	regex.compile("([A-z]+)(\\.|::)([A-z]+)\\(([A-z]*)\\)")
	panel = preload('res://addons/debug_parameters/DebugParameterRun.tscn').instantiate()
	#panel.destroyed.connect(func(): enabled = false)
	add_child(panel)
	enabled = get_param_value("debug_enabled")

"""start public functions"""

func is_enabled():
	return enabled

func enable():
	if not enabled:
		enabled = true
		on_enable.emit()

func disable():
	if enabled:
		enabled = false
		on_disable.emit()
		
"""Get a param value"""
func get_param_value(slug: String) -> Variant:
#	if not is_enabled():
#		#push_warning("Debug Parameters is disabled")
#		return
	return get_value_for_build(get_param(slug))

"""Shortcut for get_param_value()"""
func get_value(slug: String) -> Variant:
	return get_param_value(slug)

"""Set a param value"""	
func set_param_value(slug: String, value):
	get_param(slug).set_value(value)

"""Called from in game code to get update of a parameter's value"""	
func get_param_update_signal(slug: String) -> Signal:
#	if not is_enabled():
#		#push_warning("Debug Parameters is disabled")
#		return Signal()
		
	var param
	
	for profile_param in get_current_params():
		if profile_param.get_slug() == slug:
			param = profile_param
	
	if param:
		param.call_deferred('new_connection')
		var signal_to_return: Signal
		if has_user_signal('value_updated_'+slug):
			return Signal(self, 'value_updated_'+slug)
		else:
			add_user_signal('value_updated_'+slug, ['value']) # CREATE A MIDDLEWARE SIGNAL TO BUILD THE VALUE
			param.value_updated.connect(on_value_updated.bind(param))
			on_new_param_connection.emit()
			return Signal(self, 'value_updated_'+slug)
	else:
		push_error('DebugParameters : param "'+slug+'" does not exist')
		return Signal()

"""end public functions"""

func get_param(slug: String):
	for profile_param in get_current_params():
		if profile_param.get_slug() == slug:
			return profile_param
	push_error('Param "'+slug+'" not found')		
	return null
	
func on_value_updated(value, param: DebugParameter):
	var signal_to_emit = Signal(self, 'value_updated_'+param.get_slug())
	signal_to_emit.emit(get_value_for_build(param))
	
func get_value_for_build(param: DebugParameter):
	match param.get_type():
		DebugParameterHelper.TYPE_LIST:
			return param.get_value() if param.get_config()['expose_index'] else build_value(param.get_config()['available_values'][param.get_value()])
		DebugParameterHelper.TYPE_TEXT:
			return build_value(param.get_value())
		DebugParameterHelper.TYPE_NUMBER:
			return int(param.get_value()) if param.get_config()['cast_as'] == DebugParameterHelper.CAST_AS_INT else float(param.get_value())
		_:
			return param.get_value()
			
func build_value(value_raw: String):
	var result = regex.search(value_raw)
	if result: # VALUE IS A CALLABLE
		var provider_class = result.get_string(1)
		var provider_calling_method = result.get_string(2)
		var provider_fct = result.get_string(3)
		var provider_arguments = result.get_string(4).split(',', true) if result.get_string(4) else []
		var callable = Callable(get_node('/root/'+provider_class), provider_fct)
		if callable.is_valid():
			return callable.callv(provider_arguments)
		else:
			push_error('DebugParameters : method is not callable')
			return null
	else:
		return value_raw

func show_panel():
	panel.set_visible(true)

func get_dock():
	return panel.get_dock()

"""
Concatenate global profile params + current profile params
"""
func get_current_params():
	var params = get_dock().get_profile(0).get_params().duplicate(true) # GLOBAL PROFILE
	params.append_array(get_dock().get_current_profile().get_params().duplicate(true)) # CURRENT PROFILE
	return params
