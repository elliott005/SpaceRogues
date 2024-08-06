extends CanvasLayer

@onready var engine_select = %EngineSelect
@onready var weapon_select = %WeaponSelect
@onready var shield_select = %ShieldSelect
@onready var engine = $Node2D/Engine
@onready var weapon = $Node2D/Weapon
@onready var shield = $Node2D/Shield
@onready var audio_stream_player = $AudioStreamPlayer
@onready var settings = $CenterContainer/Settings
@onready var music_vol_slider = %MusicVolSlider
@onready var h_box_container = $CenterContainer/HBoxContainer
@onready var sfx_vol_slider = %SfxVolSlider
@onready var rebind_label = %RebindLabel
@onready var controls = %Controls
@onready var left_stick_check = %LeftStickCheck

var audio_volume_start = -20

var rebinding = ""
var buttons = [
	"A",
	"B",
	"X",
	"Y",
	"Back",
	"Guide",
	"Start",
	"Left Stick",
	"Right Stick",
	"lb",
	"rb",
	"dpad up",
	"dpad down",
	"dpad left",
	"dpad right",
]

var just_bound = false

func _ready():
	
	settings.hide()
	Globals.load_settings()
	Globals.update_left_stick_movement()
	
	audio_stream_player.volume_db = audio_volume_start
	var audio_tween = get_tree().create_tween()
	audio_tween.tween_property(audio_stream_player, "volume_db", Globals.settings["music"]["music_vol"], 1.0)
	engine_select.grab_focus()
	update_sprite()
	
	update_settings_sliders()
	
	get_tree().paused = false

func _process(delta):
	if Input.is_action_just_pressed("quit") and not settings.visible:
		get_tree().quit()
	if settings.visible:
		if Input.is_action_just_pressed("next_tab"):
			settings.current_tab = clamp(settings.current_tab + 1, 0, settings.get_tab_count() - 1)
			focus_first_in_tab()
		elif Input.is_action_just_pressed("previous_tab"):
			settings.current_tab = clamp(settings.current_tab - 1, 0, settings.get_tab_count() - 1)
			focus_first_in_tab()
		
		if Input.is_action_just_pressed("reset"):
			var focused_node = get_viewport().gui_get_focus_owner()
			InputMap.action_erase_events(focused_node.name)
			update_settings_sliders()
		
		if Input.is_action_just_pressed("back") and not rebinding and not just_bound:
			Globals.save_settings()
			settings.hide()
			engine_select.grab_focus()
			h_box_container.show()
		just_bound = false

func update_sprite():
	engine.texture = Globals.presets["engines"][engine_select.selected]["sprite"]
	weapon.texture = Globals.presets["weapons"][weapon_select.selected]["sprite"]
	shield.texture = Globals.presets["shields"][shield_select.selected]["sprite"]

func update_settings_sliders():
	music_vol_slider.value = Globals.settings["music"]["music_vol"]
	sfx_vol_slider.value = Globals.settings["music"]["sfx_vol"]
	
	for child in controls.get_children():
		if child is Label:
			if child.name != "HowToRebindLabel" and child.name != "RebindLabel":
				child.text = ""
	
	var idx = 0
	for child in controls.get_children():
		if child is Button:
			if child.name != "ResetControlsButton":
				for bind in InputMap.action_get_events(child.name):
					if bind is InputEventJoypadButton and idx + 1 < controls.get_child_count():
						controls.get_child(idx + 1).text += buttons[bind.button_index] + "   "
		idx += 1
	
	left_stick_check.button_pressed = Globals.settings["movement"]["left_stick_movement"]

func show_rebind_text(action):
	for child in controls.get_children():
		child.hide()
	rebind_label.show()
	rebind_label.text = "press button to bind to: " + action
func hide_rebind_text():
	for child in controls.get_children():
		child.show()
	rebind_label.hide()

func focus_first_in_tab():
	for child in settings.get_child(settings.current_tab).get_children():
		if child.focus_mode == Control.FOCUS_ALL:
			child.grab_focus()
			break

func _input(event):
	if rebinding and event is InputEventJoypadButton and event.is_pressed():
		InputMap.action_add_event(rebinding, event)
		rebinding = ""
		hide_rebind_text()
		update_settings_sliders()
		focus_first_in_tab()
		just_bound = true
		get_viewport().set_input_as_handled()

func _on_engine_select_item_selected(index):
	update_sprite()


func _on_weapon_select_item_selected(index):
	update_sprite()


func _on_shield_select_item_selected(index):
	update_sprite()


func _on_start_button_pressed():
	Globals.engine = engine_select.selected
	Globals.weapon = weapon_select.selected
	Globals.shield = shield_select.selected
	var audio_tween = get_tree().create_tween()
	audio_tween.tween_property(audio_stream_player, "volume_db", audio_volume_start, 0.5)
	audio_tween.finished.connect(start)

func start():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_quit_button_pressed():
	get_tree().quit()


func _on_settings_button_pressed():
	settings.show()
	focus_first_in_tab()
	h_box_container.hide()


func _on_music_vol_slider_value_changed(value):
	Globals.settings["music"]["music_vol"] = value
	audio_stream_player.volume_db = value


func _on_sfx_vol_slider_value_changed(value):
	Globals.settings["music"]["sfx_vol"] = value


func _on_button_pressed():
	Globals.reset_settings("music")
	update_settings_sliders()


func _on_reset_controls_button_pressed():
	Globals.reset_settings("controls")
	Globals.reset_settings("movement")
	update_settings_sliders()


func _on_shoot_pressed():
	rebinding = "shoot"
	show_rebind_text(rebinding)


func _on_accelerate_pressed():
	rebinding = "accelerate"
	show_rebind_text(rebinding)


func _on_brake_pressed():
	rebinding = "brake"
	show_rebind_text(rebinding)


func _on_left_stick_check_toggled(toggled_on):
	Globals.settings["movement"]["left_stick_movement"] = toggled_on
	Globals.update_left_stick_movement()
	update_settings_sliders()


func _on_toggle_overlay_pressed():
	rebinding = "toggle_overlay"
	show_rebind_text(rebinding)
