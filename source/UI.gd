extends Node

var _n_filesystem_popup : FileDialog setget _set_filesystem_popup
var _n_virtual_keyboard : PopupPanel setget _set_virtual_keyboard

var color_theme_accent := Color("ffbb89")

var color_success := Color("41eb83")
var color_warning := Color("ffd24a")
var color_error := Color("ff5d5d")
var color_pending := Color("dddddd")
var color_unavailable := Color("999999")

const max_popupmenu_height := 300

enum Icons {
	DOWNLOADING,
	ERROR,
	FAILURE,
	IMAGE_DOWNLOADING,
	LOAD,
	LOADING,
	SETTINGS,
	SUCCESS,
	VISIBILITY_HIDDEN,
	VISIBILITY_VISIBLE,
	WARNING
}

signal path_selected(file)

func _set_filesystem_popup(popup: FileDialog):
	_n_filesystem_popup = popup
	#warning-ignore:return_value_discarded
	_n_filesystem_popup.connect("file_selected", self, "_on_popup_selected")
	#warning-ignore:return_value_discarded
	_n_filesystem_popup.connect("dir_selected", self, "_on_popup_selected")
	#warning-ignore:return_value_discarded
	_n_filesystem_popup.connect("popup_hide", self, "_on_popup_hide")

func _set_virtual_keyboard(keyboard: PopupPanel):
	_n_virtual_keyboard = keyboard

func _on_popup_selected(file: String):
	emit_signal("path_selected", file)

func _on_popup_hide():
	emit_signal("path_selected", "")

func filesystem_filters(filters: Array = []):
	_n_filesystem_popup.filters = filters

func request_file_load(base_path: String) -> void:
	_n_filesystem_popup.mode = FileDialog.MODE_OPEN_FILE
	_n_filesystem_popup.current_dir = base_path
	_n_filesystem_popup.popup()

func request_folder_load(base_path: String) -> void:
	_n_filesystem_popup.mode = FileDialog.MODE_OPEN_DIR
	_n_filesystem_popup.current_dir = base_path
	_n_filesystem_popup.popup()

func load_app_icon(icon: int) -> Texture:
	var path : String = "res://assets/icons/%s.svg" % Icons.keys()[icon].to_lower()
	return (load(path) as Texture)

func show_virtual_keyboard() -> void:
	_n_virtual_keyboard.show()

func is_virtual_keyboard_visible() -> bool:
	return _n_virtual_keyboard.keyboardVisible

func is_event_from_virtual_keyboard() -> bool:
	return _n_virtual_keyboard.sendingEvent

func hide_virtual_keyboard() -> void:
	_n_virtual_keyboard.hide()
