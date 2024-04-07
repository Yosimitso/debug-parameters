@tool
extends Panel

@onready var label_block := $GridContainer/Label
@onready var slug_text_edit = $GridContainer/SlugTextEdit
@onready var type_item_list : OptionButton = $GridContainer/TypeItemList
@onready var label_text_edit = $GridContainer/LabelTextEdit
@onready var tooltip_text_edit = $GridContainer/TooltipTextEdit
@onready var available_values := $GridContainer/AvailableValues
@onready var expose_index := $GridContainer/ExposeIndex
@onready var number_constraint := $GridContainer/NumberContraint
@onready var number_constraint_min_enabled = $GridContainer/NumberContraint/MinCheckBox
@onready var number_constraint_max_enabled = $GridContainer/NumberContraint/MaxCheckBox
@onready var number_constraint_min_value = $GridContainer/NumberContraint/MinSpinBox
@onready var number_constraint_max_value = $GridContainer/NumberContraint/MaxSpinBox
@onready var number_constraint_cast_as = $GridContainer/NumberContraint/CastAs
@onready var add_button := $GridContainer/AddButton
@onready var cancel_button := $GridContainer/CancelButton
var edit_debug_parameter: DebugParameter

signal add_setting(slug, label, tooltip, type, value, config)
signal edit_setting(debug_parameter, slug, label, tooltip, type, value, config)
signal cancel_edit()

func _ready():
	type_item_list.clear()
	type_item_list.add_item('Checkbox')
	type_item_list.add_item('Text')
	type_item_list.add_item('Number')
	type_item_list.add_item('List')
	type_item_list.add_item('Button')
	type_item_list.item_selected.connect(on_change_type)
	available_values.set_visible(false)
	expose_index.set_visible(false)
	number_constraint.set_visible(false)
	cancel_button.set_visible(false)
	
func on_change_type(index: int):
	available_values.set_visible(index == DebugParameterHelper.TYPE_LIST)
	expose_index.set_visible(index == DebugParameterHelper.TYPE_LIST)
	number_constraint.set_visible(index == DebugParameterHelper.TYPE_NUMBER)
	
func _on_button_pressed():
	var slug = slug_text_edit.get_text()
	if not slug:
		return
	var type = type_item_list.get_selected_id()
	var label = label_text_edit.get_text() if label_text_edit.get_text() != '' else slug
	var tooltip = tooltip_text_edit.get_text()
	var default_value
	var config = {}
	match type:
		DebugParameterHelper.TYPE_CHECKBOX:
			default_value = false
		DebugParameterHelper.TYPE_TEXT:
			default_value = ''
		DebugParameterHelper.TYPE_NUMBER:
			default_value = 0
			config = {
				'min_enabled': number_constraint_min_enabled.button_pressed,
				'max_enabled': number_constraint_max_enabled.button_pressed,
				'min_value': number_constraint_min_value.value,
				'max_value': number_constraint_max_value.value,
				'cast_as': number_constraint_cast_as.get_selected_id()
			}
		DebugParameterHelper.TYPE_LIST:
			default_value = 0
			config['available_values'] = available_values.get_text().split(',', true)	
			config['expose_index'] = expose_index.button_pressed
		DebugParameterHelper.TYPE_BUTTON:
			default_value = null
	
	if edit_debug_parameter:
		edit_setting.emit(edit_debug_parameter, slug, label, tooltip, type, default_value, config)
	else:	
		add_setting.emit(slug, label, tooltip, type, default_value, config)
	clear()

func edit_mode(debug_parameter: DebugParameter):
	edit_debug_parameter = debug_parameter
	type_item_list.select(debug_parameter.get_type())
	on_change_type(debug_parameter.get_type())
	slug_text_edit.set_text(debug_parameter.get_slug())
	label_text_edit.set_text(debug_parameter.get_label())
	if debug_parameter.get_type() == DebugParameterHelper.TYPE_LIST:
		available_values.set_text(','.join(debug_parameter.get_config()['available_values']))
		expose_index.button_pressed = debug_parameter.get_config()['expose_index']
	add_button.set_text('Confirm edit')
	label_block.set_text('Edit parameter')
	cancel_button.set_visible(true)
	
func clear():
	slug_text_edit.set_text('')
	label_text_edit.set_text('')
	available_values.set_text('')
	expose_index.button_pressed = false
	add_button.set_text('Add')
	label_block.set_text('Add a parameter')
	edit_debug_parameter = null
	cancel_button.set_visible(false)


func _on_cancel_button_pressed():
	edit_debug_parameter = null
	clear()
	cancel_edit.emit()
