extends Node2D

#signal destroyed()
@onready var canvas_layer := $CanvasLayer
@onready var dock := $CanvasLayer/DebugParametersDock

func _ready():
	if not dock.dock_is_ready:
		await dock.dock_ready
	if not dock.is_enabled():
		disable()
	DebugParameters.on_enable.connect(enable)
	DebugParameters.on_disable.connect(disable)
	DebugParameters.on_new_param_connection.connect(on_new_param_connection)

func enable():
	add_child(canvas_layer)
	dock.refresh()
	set_process(true)

func disable():
	set_process(false)
	remove_child(canvas_layer)

func on_new_param_connection():
	dock.refresh()
	
func get_dock():
	return dock

func _process(delta):
	$CanvasLayer/FPSLabel.set_text(str(Engine.get_frames_per_second())+' FPS')


func _on_hide_button_pressed():
	dock.set_visible(!dock.visible)
	$CanvasLayer/Background.set_visible(!$CanvasLayer/Background.visible)
	$CanvasLayer/HideButton.release_focus()

