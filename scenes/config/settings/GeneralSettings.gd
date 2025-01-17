extends Control

onready var n_game_lib_dir := $"%GameLibDir"
onready var n_set_game_path := $"%SetGamePath"
onready var n_themes := $"%Themes"
onready var n_language := $"%Language"
onready var n_first_time_wizard_warning := $"%FirstTimeWizardWarning"

onready var n_graphics_mode := $"%GraphicsMode"
onready var n_vsync := $"%VSync"
onready var n_render_res_label := $"%RenderResLabel"
onready var n_render_res := $"%RenderRes"

var theme_id_map := {}

func _ready():
	#warning-ignore:return_value_discarded
	RetroHubConfig.connect("config_ready", self, "_on_config_ready")
	#warning-ignore:return_value_discarded
	RetroHubConfig.connect("config_updated", self, "_on_config_updated")

func grab_focus():
	n_set_game_path.grab_focus()

func set_themes():
	n_themes.clear()
	theme_id_map.clear()
	var id := 0
	var file := File.new()
	# Default themes
	if not file.open("res://default_themes/themes.txt", File.READ):
		# Skip first line
		#warning-ignore:return_value_discarded
		file.get_line()
		while file.get_position() < file.get_len():
			var theme := file.get_line()
			if theme.ends_with(".pck"):
				n_themes.add_item(theme.get_file().get_basename(), id)
				if RetroHubConfig.get_default_themes_dir() in RetroHubConfig.theme_path and \
					theme in RetroHubConfig.theme_path:
					n_themes.selected = id
				theme_id_map[id] = "res://default_themes/" + theme
				id += 1
	n_themes.add_separator()
	id += 1
	# User themes
	var dir := Directory.new()
	if not dir.open(RetroHubConfig.get_themes_dir()) and not dir.list_dir_begin(true):
		var next := dir.get_next()
		while not next.empty():
			if not dir.current_is_dir() and next.ends_with(".pck"):
				n_themes.add_item(next, id)
				if not RetroHubConfig.get_default_themes_dir() in RetroHubConfig.theme_path and \
					next in RetroHubConfig.theme_path:
					n_themes.selected = id
				theme_id_map[id] = next
				id += 1
			next = dir.get_next()

func set_language(lang: String):
	match lang:
		"en":
			n_language.selected = 0

func _on_config_ready(config_data: ConfigData):
	n_game_lib_dir.text = config_data.games_dir
	n_graphics_mode.selected = 1 if config_data.fullscreen else 0
	n_vsync.pressed = config_data.vsync
	n_render_res.value = config_data.render_resolution
	set_language(config_data.lang)

func _on_config_updated(key: String, _old_value, new_value):
	match key:
		ConfigData.KEY_GAMES_DIR:
			n_game_lib_dir.text = new_value
		ConfigData.KEY_LANG:
			set_language(new_value)

func _on_Themes_item_selected(index):
	var theme_path : String = theme_id_map[index]
	RetroHubConfig.config.current_theme = theme_path

func _on_SetThemePath_pressed():
	#warning-ignore:return_value_discarded
	OS.shell_open(RetroHubConfig.get_themes_dir())

func _on_SetGamePath_pressed():
	RetroHubUI.filesystem_filters([])
	RetroHubUI.request_folder_load(FileUtils.get_home_dir() if n_game_lib_dir.text.empty() else n_game_lib_dir.text)
	var path : String = yield(RetroHubUI, "path_selected")
	# Only save if path is different and existent, to prevent theme reloads
	if not path.empty() and n_game_lib_dir.text != path:
		n_game_lib_dir.text = path
		RetroHubConfig.config.games_dir = path

func _on_Language_item_selected(index):
	match index:
		0:	# English (en)
			RetroHubConfig.config.lang = "en"

func _on_AppSettings_hide():
	RetroHubConfig.save_config()


func _on_AppSettings_visibility_changed():
	if is_visible_in_tree():
		set_themes()


func _on_FirstTimeWizardWarning_confirmed():
	RetroHubConfig.config.is_first_time = true
	RetroHub.quit()


func _on_SetupWizardButton_pressed():
	n_first_time_wizard_warning.popup_centered()


func _on_GraphicsMode_item_selected(index):
	RetroHubConfig.config.fullscreen = index == 1
	RetroHubConfig.save_config()


func _on_VSync_toggled(button_pressed):
	RetroHubConfig.config.vsync = button_pressed
	RetroHubConfig.save_config()


func _on_RenderRes_value_changed(value):
	RetroHubConfig.config.render_resolution = value
	n_render_res_label.text = str(value) + "%"

