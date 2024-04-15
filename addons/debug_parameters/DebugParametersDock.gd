@tool
extends ScrollContainer

var profiles : Array[DebugParameterProfile] = []
@onready var params_container : GridContainer = $Params
var add_param_block: Node
var profile_block: Node
var settings_block: Node
var current_profile_index = 0
var ingame_mode: bool
var settings_raw : JSON
var dock_is_ready: bool

signal profiles_built()
signal dock_ready()

func _enter_tree():
	load_profiles()

func load_profiles():
	var settings_file = get_settings_file()
	if settings_file:
		print("Load settings file")
		settings_raw = JSON.new()
		settings_raw.parse(settings_file.get_as_text())
		profiles = []
		if settings_raw.get_data() != null:
			for profile_dict in settings_raw.get_data()['profiles']:
				var profile = DebugParameterProfile.new(profile_dict['profile_name'])
				for param_raw in profile_dict['params']:
					var new_param = DebugParameter.new(param_raw['slug'], param_raw['type'], param_raw['label'], param_raw['tooltip'], param_raw['config'], param_raw['value'])
					profile.add_param(new_param)
					new_param.got_new_connection.connect(refresh)
					
				profiles.append(profile)
			current_profile_index = settings_raw.get_data()['current_profile_index']
		settings_file.close()
	profiles_built.emit()
	
func load_profile(profile_index: int = 0):
	current_profile_index = profile_index
	refresh()

func create_profile(profile_name: String):
	profiles.append(DebugParameterProfile.new(profile_name))
	load_profile(profiles.size()-1)
	refresh()
	save()

func rename_profile(profile_name: String):
	get_current_profile().set_profile_name(profile_name)
	refresh()
	save()
	
func delete_profile():
	profiles.remove_at(current_profile_index)
	current_profile_index = 0
	refresh()
	save()
	
func get_current_profile() -> DebugParameterProfile:
	var current_profile = profiles[current_profile_index]
	return current_profile

func get_profile(index: int) -> DebugParameterProfile:
	return profiles[index]

func _ready():
	add_param_block = preload('AddParamBlock.tscn').instantiate()
	add_param_block.add_setting.connect(add_setting)
	add_param_block.edit_setting.connect(edit_setting)
	add_param_block.cancel_edit.connect(cancel_edit)
	
	profile_block = preload('ProfileBlock.tscn').instantiate()
	profile_block.on_select_profile.connect(load_profile)
	profile_block.on_create_profile.connect(create_profile)
	profile_block.on_rename_profile.connect(rename_profile)
	profile_block.on_delete_profile.connect(delete_profile)
	
	
	if profiles.size() == 0:
		create_profile('global')
	settings_block = preload('DebugParameterSettings.tscn').instantiate()
	settings_block.load_data(settings_raw.get_data()['settings'])
	ingame_mode = is_in_group("ingame_mode")
	refresh()
	dock_ready.emit()
	dock_is_ready = true
	
func _exit_tree():
	pass

func refresh():
	for node in params_container.get_children():
		params_container.remove_child(node)
	params_container.add_child(settings_block)
	params_container.add_child(profile_block)	
	var position = 0
	if not add_param_block.edit_debug_parameter:
		for param in get_current_profile().get_params():
			var node
			match param.get_type():
				DebugParameterHelper.TYPE_CHECKBOX:
					node = preload("TypeBlock/ParamBlockCheckbox.tscn").instantiate()
					node.init(param.get_label(), param.get_tooltip(), param.get_value())
				DebugParameterHelper.TYPE_TEXT:
					node = preload("TypeBlock/ParamBlockText.tscn").instantiate()
					node.init(param.get_label(), param.get_tooltip(), param.get_value())
				DebugParameterHelper.TYPE_NUMBER:
					node = preload("TypeBlock/ParamBlockNumber.tscn").instantiate()
					node.init(param.get_label(), param.get_tooltip(), DebugParameterHelper.generate_conf(param), param.get_value())
				DebugParameterHelper.TYPE_LIST:
					node = preload("TypeBlock/ParamBlockList.tscn").instantiate()
					node.init(param.get_label(), param.get_tooltip(), param.get_config()['available_values'], param.get_value())
				DebugParameterHelper.TYPE_BUTTON:
					node = preload("TypeBlock/ParamBlockButton.tscn").instantiate()
					node.init(param.get_label(), param.get_tooltip())
				_:
					push_error(str(param.get_type())+' not handled')
					return
			param.set_node(node)
			params_container.add_child(node)
			node.value_updated.connect(on_value_change.bind(node, param))
			node.remove_block.connect(on_remove_block.bind(position))
			node.move_block_up.connect(on_move_block.bind("up", position, param))
			node.move_block_down.connect(on_move_block.bind("down", position, param))
			node.require_edit.connect(on_require_edit.bind(node, param))
			if ingame_mode:
				node.set_connected(param.value_updated.get_connections().size() != 0)
			position += 1
	params_container.add_child(add_param_block)
	profile_block.set_profiles(profiles, current_profile_index)
	settings_block.set_profile(get_current_profile(), ingame_mode)
	
func on_value_change(node: Node, debug_parameter: DebugParameter):
	debug_parameter.set_value(node.get_value())
	node.drop_focus()
	save()
	
func on_remove_block(position: int):
	get_current_profile().get_params().remove_at(position)
	refresh()
	save()

func on_move_block(dir: String, position: int, debug_parameter: DebugParameter):
	get_current_profile().get_params().remove_at(position)
	get_current_profile().get_params().insert(position-1 if dir == 'up' else position+1, debug_parameter)
	refresh()
	save()

func on_require_edit(node: Node, debug_parameter: DebugParameter):
	add_param_block.edit_mode(debug_parameter)
	refresh()
	
func add_setting(slug, label, tooltip, type, value, config):
	get_current_profile().get_params().append(DebugParameter.new(slug, type, label, tooltip, config, value))
	refresh()
	save()

func edit_setting(debug_parameter: DebugParameter, slug: String, label: String, tooltip: String, type: int, value, config: Dictionary):
	debug_parameter.set_slug(slug).set_label(label).set_tooltip(tooltip).set_type(type).set_value(value).set_config(config)
	add_param_block.edit_debug_parameter = null
	refresh()
	save()
	
func cancel_edit():
	refresh()
	
func save():
	for debug_parameter in get_current_profile().get_params():
		debug_parameter.get_current_node().release_focus()
		if debug_parameter.get_type() != DebugParameterHelper.TYPE_BUTTON:
			debug_parameter.set_value(debug_parameter.get_current_node().get_value())
	save_settings()
	return true
	
func save_settings():
	var data = {'settings': settings_block.to_dict(), 'current_profile_index': current_profile_index, 'profiles': []}
	for profile in profiles:
		data['profiles'].append(profile.to_dict())
	var file = get_settings_file(true)
	file.store_line(JSON.stringify(data))
	file.close()

func get_settings_file(write_and_truncate = false) -> FileAccess:
	var file_name = 'debug_parameters_settings'
	var file_path = "user://"+file_name+".json"
	if not FileAccess.file_exists(file_path):
		initialize_plugin(file_path)
	var file = FileAccess.open(file_path, FileAccess.WRITE_READ if write_and_truncate else FileAccess.READ)
	if not file:
		push_error("Can't "+("create" if write_and_truncate else "open")+" file : "+file_path)
	return file

func initialize_plugin(file_path: String):
	print("Initialize plugin")
	if not FileAccess.file_exists(file_path):
		var file_creation = FileAccess.open(file_path, FileAccess.WRITE_READ)
		file_creation.close()
		settings_block = preload('DebugParameterSettings.tscn').instantiate()
		var global_profile = DebugParameterProfile.new('global')
		profiles.append(global_profile)
		current_profile_index = 0
		save_settings()
		
func is_enabled() -> bool:
	return settings_block.is_enabled()
