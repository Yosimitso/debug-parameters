@tool
extends EditorPlugin

var dock
const AUTOLOAD_NAME = "DebugParameters"
var detect_changes_timer : Timer
var editor_plugin: EditorPlugin

func _enter_tree():
	dock = preload("res://addons/debug_parameters/DebugParametersDock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/debug_parameters/DebugParameters.gd")
	detect_changes_timer = Timer.new()
	detect_changes_timer.autostart = false
	detect_changes_timer.one_shot = false
	detect_changes_timer.wait_time = 3
	detect_changes_timer.timeout.connect(detect_changes)
	add_child(detect_changes_timer)
	editor_plugin = EditorPlugin.new()
	
func _build():
	if dock.save():
		detect_changes_timer.start()
		return true
	else:
		return false

func detect_changes():
	if not editor_plugin.get_editor_interface().is_playing_scene():
		print('reload profiles')
		detect_changes_timer.stop()
		dock.load_profiles()
		dock.refresh()

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
	remove_autoload_singleton(AUTOLOAD_NAME)


