extends AcceptDialog

signal key_remapped(key, old_code, new_code)

onready var n_key_icon := $"%KeyIcon"
onready var n_key_label := $"%KeyLabel"

onready var base_text : String = n_key_label.text

var key := ""
var oldcode := 0
var scancode := 0

func start(_key: String):
	key = _key
	self.scancode = 0
	self.oldcode = find_old_keycode(key)
	n_key_icon.texture = null
	n_key_label.text = base_text
	popup_centered()

func _input(event):
	if visible and event is InputEventKey:
		get_tree().set_input_as_handled()
		scancode = (event as InputEventKey).physical_scancode
		n_key_icon.texture = ControllerIcons.parse_event(event)
		n_key_label.text = OS.get_scancode_string(scancode)

func find_old_keycode(raw_key: String):
	for ev in InputMap.get_action_list(raw_key):
		if ev is InputEventKey:
			return ev.physical_scancode if ev.scancode == 0 else ev.scancode
	return 0

func _on_KeyboardRemap_confirmed():
	if scancode != 0:
		emit_signal("key_remapped", key, oldcode, scancode)

