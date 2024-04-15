@tool
extends Panel

@onready var profiles_item_list := $GridContainer/ProfilesItemList
@onready var create_button := $GridContainer/GridContainer/CreateButton
@onready var rename_button := $GridContainer/GridContainer/RenameButton
@onready var delete_button := $GridContainer/GridContainer/DeleteButton

signal on_select_profile(index)
signal on_create_profile(profile_name)
signal on_rename_profile(profile_name)
signal on_delete_profile()

func _ready():
	profiles_item_list.item_selected.connect(profile_selected)
	create_button.pressed.connect(launch_create_profile)
	rename_button.pressed.connect(ask_rename_profile)
	delete_button.pressed.connect(ask_delete_profile)

func set_profiles(profiles: Array[DebugParameterProfile], current_profile_index: int):
	profiles_item_list.clear()
	for profile in profiles:
		profiles_item_list.add_item(profile.get_profile_name())
	profiles_item_list.select(current_profile_index)
	delete_button.set_disabled(current_profile_index == 0)
	rename_button.set_disabled(current_profile_index == 0)
	
func profile_selected(index):
	on_select_profile.emit(index)

func launch_create_profile():
	var popup = preload('EditProfile.tscn').instantiate()
	add_child(popup)
	popup.on_close.connect(cancel_create_profile)
	popup.on_validate.connect(create_profile)

func cancel_create_profile(popup):
	remove_child(popup)

func create_profile(profile_name, popup):
	on_create_profile.emit(profile_name)
	remove_child(popup)

func ask_rename_profile():
	var popup = preload('EditProfile.tscn').instantiate()
	add_child(popup)
	popup.on_close.connect(cancel_create_profile)
	popup.on_validate.connect(rename_profile)

func rename_profile(profile_name, popup):
	on_rename_profile.emit(profile_name)
	remove_child(popup)
	
func ask_delete_profile():
	var confirmation = ConfirmationDialog.new()
	confirmation.dialog_text = 'Are you sure you want to delete the current profile ?'
	confirmation.confirmed.connect(delete_profile)
	add_child(confirmation)
	confirmation.popup_centered()

func delete_profile():
	on_delete_profile.emit()
