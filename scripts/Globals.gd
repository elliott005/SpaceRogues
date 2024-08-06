extends Node

signal upgrade_chosen
signal special_upgrade_chosen

# todo:
#   landing screen
#   high score screen
#   damage flash
#   better ai component
#   live coding !!!
#   devlog
#   local co-op

var presets = {
	"engines": [
		{"name": "base", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Engines/PNGs/Main Ship - Engines - Base Engine.png")},
		{"name": "big_pulse", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Engines/PNGs/Main Ship - Engines - Big Pulse Engine.png")},
		{"name": "burst", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Engines/PNGs/Main Ship - Engines - Burst Engine.png")},
		{"name": "supercharged", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Engines/PNGs/Main Ship - Engines - Supercharged Engine.png")}
	],
	"weapons": [
		{"name": "auto_cannon", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Weapons/PNGs/Main Ship - Weapons - Auto Cannon cropped.png")},
		{"name": "big_space_gun", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Weapons/PNGs/Main Ship - Weapons - Big Space Gun cropped.png")},
		{"name": "rockets", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Weapons/PNGs/Main Ship - Weapons - Rockets cropped.png")},
		{"name": "zapper", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Weapons/PNGs/Main Ship - Weapons - Zapper cropped.png")},
	],
	"shields": [
		{"name": "front_and_side", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Shields/PNGs/Main Ship - Shields - Front and Side Shield cropped.png")},
		{"name": "front", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Shields/PNGs/Main Ship - Shields - Front Shield cropped.png")},
		{"name": "invincibility", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Shields/PNGs/Main Ship - Shields - Invincibility Shield cropped.png")},
		{"name": "round", "sprite": preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Shields/PNGs/Main Ship - Shields - Round Shield cropped.png")},
	]
}

var engine = 0
var weapon = 0
var shield = 0

var settings_base = {
	"music": {
		"music_vol": -10,
		"sfx_vol": 0
	},
	"controls": {
		"shoot": [JOY_BUTTON_B],
		"accelerate": [JOY_BUTTON_RIGHT_SHOULDER],
		"brake": [JOY_BUTTON_LEFT_SHOULDER],
		"toggle_overlay": [JOY_BUTTON_DPAD_DOWN],
	},
	"movement": {
		"left_stick_movement": true
	}
}
var settings: Dictionary

var save_path = "user://settings.save"

func save_settings():
	for key in settings["controls"].keys():
		var events = InputMap.action_get_events(key)
		settings["controls"][key] = []
		for event in events:
			settings["controls"][key].append(event.button_index)
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(settings)

func load_settings():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		settings = file.get_var()
		for key in settings_base.keys():
			if not key in settings:
				settings[key] = settings_base[key]
		
		for key in settings_base["controls"].keys():
			if key in settings["controls"].keys():
				InputMap.action_erase_events(key)
				for button in settings["controls"][key]:
					var event = InputEventJoypadButton.new()
					event.button_index = button
					InputMap.action_add_event(key, event)
			else:
				settings["controls"][key] = settings_base["controls"][key]
	else:
		settings = settings_base.duplicate(true)

func reset_settings(section):
	settings[section] = settings_base[section].duplicate(true)
	if section == "controls":
		for key in settings["controls"].keys():
			InputMap.action_erase_events(key)
			for button in settings["controls"][key]:
				var event = InputEventJoypadButton.new()
				event.button_index = button
				InputMap.action_add_event(key, event)

func update_left_stick_movement():
	var mod = 0
	if not settings["movement"]["left_stick_movement"]:
		mod = 2
	
	var event = InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_X + mod
	event.axis_value = -1.0
	InputMap.action_erase_events("left")
	InputMap.action_add_event("left", event)
	
	event = InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_X + mod
	event.axis_value = 1.0
	InputMap.action_erase_events("right")
	InputMap.action_add_event("right", event)
	
	event = InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_Y + mod
	event.axis_value = -1.0
	InputMap.action_erase_events("up")
	InputMap.action_add_event("up", event)
	
	event = InputEventJoypadMotion.new()
	event.axis = JOY_AXIS_LEFT_Y + mod
	event.axis_value = 1.0
	InputMap.action_erase_events("down")
	InputMap.action_add_event("down", event)
