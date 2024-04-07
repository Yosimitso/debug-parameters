extends Panel
class_name ParamBlock

signal value_updated(new_value)
signal remove_block()
signal move_block_up()
signal move_block_down()
signal require_edit()

func _ready():
	$RemoveButton.pressed.connect(remove)
	$MoveUpButton.pressed.connect(move_up)
	$MoveDownButton.pressed.connect(move_down)
	$EditButton.pressed.connect(edit)
	$WarningNotConnected.set_visible(false)
	
func remove():
	remove_block.emit()

func move_up():
	move_block_up.emit()
	
func move_down():
	move_block_down.emit()

func edit():
	require_edit.emit()

func set_connected(is_connected: bool):
	$WarningNotConnected.set_visible(is_connected == false)
	
