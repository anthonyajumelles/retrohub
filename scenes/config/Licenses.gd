extends Control

const LICENSE_PATH := "res://assets/copyright/licenses/"

onready var n_names := $"%Names"
onready var n_content := $"%Content"

var licenses := {}
var root : TreeItem

func _ready():
	# Load licenses
	var license_files := [
		["GPLv3", "gpl3.txt"],
		["MIT (RetroHub)", "mit_retrohub.txt"],
		["MIT (Godot Engine)", "mit_godot.txt"],
		["MIT (godot-videodecoder)", "mit_videodecoder.txt"],
		["MIT (Controller Icons)", "mit_controllericons.txt"],
		["MIT (Onscreenkeyboard)", "mit_onscreenkeyboard.txt"],
		["CC0", "cc0.txt"],
		["CC BY 4.0", "ccby40.txt"],
		["CC BY NC SA 4.0", "ccbyncsa40.txt"]
	]
	var file := File.new()
	for license in license_files:
		if not file.open(LICENSE_PATH + license[1], File.READ):
			licenses[license[0]] = file.get_as_text()
			file.close()
		else:
			push_error("Error reading license file %s!" % LICENSE_PATH + license[1])

	# Populate tree
	root = n_names.create_item()
	for key in licenses:
		var child : TreeItem = n_names.create_item(root)
		child.set_text(0, key)

	if root.get_children() != null:
		root.get_children().select(0)
		_on_Names_item_selected()

func _on_Names_item_selected():
	var item : TreeItem = n_names.get_selected()
	n_content.text = licenses[item.get_text(0)]
	(n_content.get_parent() as ScrollContainer).scroll_vertical = 0

func select_license(license_key: String) -> bool:
	var license := convert_license_key(license_key)
	if license.empty():
		return false
	var child : TreeItem = root.get_children()
	while child != null:
		if child.get_text(0) == license:
			child.select(0)
			_on_Names_item_selected()
			return true
		child = child.get_next()
	return false

func convert_license_key(key: String) -> String:
	match key:
		"gpl3":
			return "GPLv3"
		"mit_retrohub":
			return "MIT (RetroHub)"
		"mit_godot":
			return "MIT (Godot Engine)"
		"mit_videodecoder":
			return "MIT (godot-videodecoder)"
		"mit_controllericons":
			return "MIT (Controller Icons)"
		"mit_onscreenkeyboard":
			return "MIT (Onscreenkeyboard)"
		"cc0":
			return "CC0"
		"ccby40":
			return "CC BY 4.0"
		"ccbyncsa40":
			return "CC BY NC SA 4.0"
		_:
			return ""
