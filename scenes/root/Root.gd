extends Control

onready var n_viewport_container : ViewportContainer = $ViewportContainer
onready var n_viewport : Viewport = $ViewportContainer/Viewport

onready var n_config_popup : Popup = $ConfigPopup
onready var n_filesystem_popup : Popup = $FileSystemPopup
onready var n_keyboard_popup := $"%Keyboard"

onready var popup_nodes := [
	n_config_popup,
	n_filesystem_popup
]

onready var viewport_orig_size := Vector2(1024, 576)

var n_last_focused : Control
var is_popup_open : bool = false

func _ready():
	closed_popup()
	#warning-ignore:return_value_discarded
	RetroHub.connect("_theme_loaded", self, "_on_theme_loaded")
	#warning-ignore:return_value_discarded
	RetroHub.connect("_game_loaded", self, "_on_game_loaded")
	#warning-ignore:return_value_discarded
	RetroHubConfig.connect("config_updated", self, "_on_config_updated")

	# Add popups to UI singleton
	RetroHubUI._n_filesystem_popup = n_filesystem_popup
	RetroHubUI._n_virtual_keyboard = n_keyboard_popup

	# Handle viewport changes
	#warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_on_vp_size_changed")
	#warning-ignore:return_value_discarded
	n_viewport.connect("gui_focus_changed", self, "_on_vp_gui_focus_changed")
	_on_vp_size_changed()

	# Wait an idle frame for the config to load
	yield(get_tree(), "idle_frame")
	if RetroHubConfig.config.is_first_time:
		show_first_time_popup()
	OS.window_fullscreen = RetroHubConfig.config.fullscreen
	OS.set_use_vsync(RetroHubConfig.config.vsync)
	setup_controller_remap(RetroHubConfig.config.custom_input_remap)


func _on_config_updated(key: String, _old, new):
	match key:
		ConfigData.KEY_CUSTOM_INPUT_REMAP:
			setup_controller_remap(new)
		ConfigData.KEY_FULLSCREEN:
			OS.window_fullscreen = new
		ConfigData.KEY_VSYNC:
			OS.set_use_vsync(new)
		ConfigData.KEY_RENDER_RESOLUTION:
			_on_vp_size_changed()

func setup_controller_remap(remap: String):
	if not remap.empty():
		Input.remove_joy_mapping(Input.get_joy_guid(0))
		Input.add_joy_mapping(remap, true)

func show_first_time_popup():
	var first_time_popup : Control = load("res://scenes/popups/first_time/FirstTimePopups.tscn").instance()
	add_child(first_time_popup)
	popup_nodes.push_back(first_time_popup)
	#warning-ignore:return_value_discarded
	first_time_popup.connect("about_to_show", self, "opened_popup")
	#warning-ignore:return_value_discarded
	first_time_popup.connect("popup_hide", self, "closed_popup")
	#warning-ignore:return_value_discarded
	first_time_popup.connect("popup_hide", self, "_on_first_time_popup_closed", [first_time_popup])
	first_time_popup.popup()

func _on_vp_size_changed() -> void:
	var viewport_size := Vector2(
		viewport_orig_size.y * get_viewport().size.aspect(),
		viewport_orig_size.y
	)
	var mult := RetroHubConfig.config.render_resolution / 100.0
	n_viewport.size = get_viewport().size * mult
	n_viewport.set_size_override(true, viewport_size)

func _on_vp_gui_focus_changed(control: Control) -> void:
	if not is_popup_open:
		n_last_focused = control

func _on_theme_loaded(theme_data: RetroHubTheme):
	n_viewport.set_theme(theme_data.entry_scene)
	print("Loaded theme")

func _on_game_loaded(game_data: RetroHubGameData):
	var game_launched_child : Node = load("res://scenes/game_launched/GameLaunched.tscn").instance()
	n_viewport.set_theme(game_launched_child)
	game_launched_child.game_data = game_data
	print("Loaded game")

func set_theme_input_enabled(enabled : bool):
	n_viewport_container.set_process_input(enabled)
	n_viewport_container.set_process_unhandled_input(enabled)

func opened_popup():
	$DarkenOverlay.visible = true
	set_theme_input_enabled(false)
	is_popup_open = true

func closed_popup():
	for node in popup_nodes:
		if node.visible == true:
			return

	$DarkenOverlay.visible = false
	set_theme_input_enabled(true)
	is_popup_open = false
	if is_instance_valid(n_last_focused):
		n_last_focused.grab_focus()

func _on_first_time_popup_closed(popup):
	popup_nodes.remove(popup_nodes.find_last(popup))
