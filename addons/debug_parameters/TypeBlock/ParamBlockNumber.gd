@tool
extends ParamBlock

func init(label: String, tooltip: String, config, value):
	$Label.set_text(label)
	$SpinBox.tooltip_text = tooltip
	$SpinBox.set_value(value)
	$SpinBox.min_value = float(config['min_value']) if config['min_enabled'] else -999999999
	$SpinBox.max_value = float(config['max_value']) if config['max_enabled'] else 999999999
	$SpinBox.value_changed.connect(focus_exited)

func focus_exited(_value):
	value_updated.emit()

func drop_focus():
	$SpinBox.release_focus()
	
func get_value():
	return $SpinBox.get_value()
