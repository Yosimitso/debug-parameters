@tool
extends ParamBlock

var available_values = []

func init(label: String, tooltip: String, _available_values = [], value = 0):
	$Label.set_text(label)
	$OptionButton.tooltip_text = tooltip
	available_values = _available_values
	for available_value in available_values:
		$OptionButton.add_item(available_value)
	$OptionButton.select(value)
	$OptionButton.item_selected.connect(focus_exited)

func focus_exited(_index):
	value_updated.emit()

func drop_focus():
	$OptionButton.release_focus()
	
func get_value():
	return $OptionButton.get_selected_id()

