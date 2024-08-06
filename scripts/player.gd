extends Node2D

@onready var hurt_box = $HurtBox
@onready var bullets = $Bullets
@onready var bullet_spawn_points = $BulletSpawnPoints
var bullet_spawn_points_1_2
@onready var upgrade_choices = %UpgradeChoices
@onready var shield = $Sprites/Shield
@onready var weapon = $Sprites/Weapon
@onready var engine = $Sprites/Engine
@onready var base = $Sprites/Base
@onready var shield_area_2d = $ShieldArea2D
@onready var hit_box = $HitBox
@onready var over_under_timer = $OverUnderTimer
@onready var audio_stream_player = $AudioStreamPlayer
@onready var level_up_particles = $LevelUpParticles
@onready var big_bullet_timer = $BigBulletTimer
@onready var heal_timer = $HealTimer
@onready var AOE_damage = $AOEs/AOEdamage
@onready var AOEs = $AOEs
@onready var AOE_damage_timer = $AOEDamageTimer
@onready var overlay = %Overlay
@onready var pause_menu = $CanvasLayer/CenterContainer/PauseMenu
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var death_menu = $CanvasLayer/CenterContainer/DeathMenu
@onready var death_return_button = %DeathReturnButton
@onready var sprites = $Sprites
@onready var level_label = %LevelLabel
@onready var xp_sfx = $XpSfx


var sfx = {
	"level_up": preload("res://assets/Level Up!/orchestra.wav"),
	"shoot": preload("res://assets/alienshoot1.wav")
}

var attributes = {
	"max_speed": -400.0,
	"acceleration": 500.0,
	"brake_force": 300.0,
	"bullet_speed": Vector2(0, -1000),
	"bullet_damage": 1.0,
	"AOEmultiplier": 1.0,
	"bullet_size_multiplier": 1.0,
	"crit_chance": 5.0,
	"crit_damage": 2.0,
	"health": 20,
	"max_health": 20
}

var presets_modifiers = {
	"engines": {
		"base": {},
		"big_pulse": {"acceleration": 100, "max_speed": -50},
		"burst": {"acceleration": 500, "max_speed": -100},
		"supercharged": {
			"acceleration": 100, 
			"max_speed": -50, 
			"brake_force": 200,
		}
	},
	"weapons": {
		"auto_cannon": {},
		"big_space_gun": {"bullet_damage": 1, "bullet_speed": Vector2(0, 200)},
		"rockets": {"bullet_damage": 0.5, "bullet_speed": Vector2(0, -300)},
		"zapper": {"bullet_damage": 1, "bullet_speed": Vector2(0, -500)}
	},
	"shields": {
		"front_and_side": {"health": 10},
		"front": {"health": 30},
		"invincibility": {"health": 10},
		"round": {"health": 5}
	}
}

var velocity = Vector2.ZERO
var ship_rotation = 0.0

var bullet_scene = preload("res://scenes/actors/bullet.tscn")
var bullet_sprite_frames = {
	"auto_cannon": preload("res://resources/bullet_auto_cannon.tres"),
	"big_space_gun": preload("res://resources/bullet_bolt.tres"),
	"rockets": preload("res://resources/bullet_rocket.tres"),
	"zapper": preload("res://resources/bullet_ray.tres")
}
var current_weapon = "auto_cannon"

var dead = false
var damage_sprites = [
	preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Bases/PNGs/Main Ship - Base - Very damaged.png"),
	preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Bases/PNGs/Main Ship - Base - Damaged.png"),
	preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Bases/PNGs/Main Ship - Base - Slight damage.png"),
	preload("res://assets/Foozle_2DS0011_Void_MainShip/Main Ship/Main Ship - Bases/PNGs/Main Ship - Base - Full health.png"),
]

var xp = 0
var level = 0
var upgrades = {
	"bullet_damage": {
		"common": {
			"dir": "multiply", "effect": 10.0, "text": "Increase bullet damage by 10%", "rarity": 1.5
		},
		"uncommon": {
			"dir": "multiply", "effect": 25.0, "text": "Increase bullet damage by 25%", "rarity": 1
		},
		"rare": {
			"dir": "multiply", "effect": 50.0, "text": "Increase bullet damage by 50%", "rarity": 0.5
		},
	},
	"health": {
		"common": {
			"dir": "increase", "effect": 5.0, "text": "Increase health by 5 points", "rarity": 1.5, "secondary": {"max_health": {"dir": "increase", "effect": 5.0}}
		},
		"uncommon": {
			"dir": "increase", "effect": 10.0, "text": "Increase health by 10 points", "rarity": 1, "secondary": {"max_health": {"dir": "increase", "effect": 10.0}}
		},
		"rare": {
			"dir": "increase", "effect": 20.0, "text": "Increase health by 20 points", "rarity": 0.5, "secondary": {"max_health": {"dir": "increase", "effect": 20.0}}
		},
	},
	"max_speed": {
		"common": {
			"dir": "multiply", "effect": 20, "text": "Increase speed by 20%", "rarity": 1.5, "secondary": {"acceleration": {"dir": "multiply", "effect": 20.0}}
		},
		"uncommon": {
			"dir": "multiply", "effect": 30, "text": "Increase speed by 30%", "rarity": 1, "secondary": {"acceleration": {"dir": "multiply", "effect": 30.0}}
		},
		"rare": {
			"dir": "multiply", "effect": 50, "text": "Increase speed by 50%", "rarity": 0.5, "secondary": {"acceleration": {"dir": "multiply", "effect": 50.0}}
		},
	},
	"AOEmultiplier": {
		"common": {
			"dir": "multiply", "effect": 20, "text": "Increase AOE size by 20%", "rarity": 1.5,
		},
		"uncommon": {
			"dir": "multiply", "effect": 30, "text": "Increase AOE size by 30%", "rarity": 1,
		},
		"rare": {
			"dir": "multiply", "effect": 50, "text": "Increase AOE size by 50%", "rarity": 0.5,
		},
	},
	"bullet_size_multiplier": {
		"common": {
			"dir": "multiply", "effect": 20, "text": "Increase bullet size by 20%", "rarity": 1.5,
		},
		"uncommon": {
			"dir": "multiply", "effect": 30, "text": "Increase bullet size by 30%", "rarity": 1,
		},
		"rare": {
			"dir": "multiply", "effect": 50, "text": "Increase bullet size by 50%", "rarity": 0.5,
		},
	},
	"crit_chance": {
		"common": {
			"dir": "increase", "effect": 5.0, "text": "Increase crit chance by 5%", "rarity": 1.5,
		},
		"uncommon": {
			"dir": "increase", "effect": 10.0, "text": "Increase crit chance by 10%", "rarity": 1,
		},
		"rare": {
			"dir": "increase", "effect": 15.0, "text": "Increase crit chance by 15%", "rarity": 0.5,
		},
	},
	"crit_damage": {
		"common": {
			"dir": "increase", "effect": 0.5, "text": "Increase crit damage by 0.5x", "rarity": 1.5,
		},
		"uncommon": {
			"dir": "increase", "effect": 1.0, "text": "Increase crit damage by 1x", "rarity": 1,
		},
		"rare": {
			"dir": "increase", "effect": 2.0, "text": "Increase crit damage by 2x", "rarity": 0.5,
		},
	}
}
@onready var special_upgrades = [
	{"function": shoot_behind, "text": "Also shoot behind you"},
	{"function": random_big_bullet, "text": "Randomly shoot a HUGE projectile every 0.5 seconds"},
	{"function": auto_heal, "text": "Heal 1 point every 2 seconds"},
	{"function": AOEdamage, "text": "Slowly damage enemies around you"}
]
var special_upgrade_chance = 0.1

var rarity_colors = {
	"common": Color8(200, 200, 200),
	"uncommon": Color8(0, 255, 255),
	"rare": Color8(255, 0, 255)
}

var special_upgrades_unlocked = []

func _ready():
	audio_stream_player.volume_db = Globals.settings["music"]["sfx_vol"]
	xp_sfx.volume_db = Globals.settings["music"]["sfx_vol"]
	
	bullet_spawn_points_1_2 = bullet_spawn_points.get_children()
	
	for shield_collision in shield_area_2d.get_children():
		if shield_collision.name == Globals.presets["shields"][Globals.shield]["name"] + "_Collision":
			shield_collision.disabled = false
		else:
			shield_collision.disabled = true
	
	engine.texture = Globals.presets["engines"][Globals.engine]["sprite"]
	weapon.texture = Globals.presets["weapons"][Globals.weapon]["sprite"]
	shield.texture = Globals.presets["shields"][Globals.shield]["sprite"]
	
	var engine_modifiers = presets_modifiers["engines"][Globals.presets["engines"][Globals.engine]["name"]]
	for i in engine_modifiers.keys():
		attributes[i] += engine_modifiers[i]
	var weapon_modifiers = presets_modifiers["weapons"][Globals.presets["weapons"][Globals.weapon]["name"]]
	for i in weapon_modifiers.keys():
		attributes[i] += weapon_modifiers[i]
	
	current_weapon = Globals.presets["weapons"][Globals.weapon]["name"]
	
	upgrade_choices.hide()
	Globals.upgrade_chosen.connect(upgrade_chosen)
	Globals.special_upgrade_chosen.connect(special_upgrade_chosen)
	
	overlay.hide()
	for attribute in attributes.keys():
		var label = Label.new()
		label.add_theme_color_override("font_color", Color8(255, 255, 255))
		overlay.add_child(label)
	
	pause_menu.hide()
	death_menu.hide()
	animated_sprite_2d.hide()
	

func _process(delta):
	handle_movement(delta)
	
	handle_wrap_around()
	
	handle_shooting()
	
	handle_special_abilities()
	
	handle_overlay()

func handle_movement(delta):
	var accelerate_input = Input.is_action_pressed("accelerate")
	var brake_input = Input.is_action_pressed("brake")
	if accelerate_input:
		velocity.y = move_toward(velocity.y, attributes["max_speed"], attributes["acceleration"] * delta)
	elif brake_input:
		velocity.y = move_toward(velocity.y, 0, attributes["brake_force"] * delta)
	
	#var turn_input = Input.get_axis("turn_left", "turn_right")
	#if accelerate_input and brake_input:
		#ship_rotation += attributes["super_turn_radius"] * turn_input * delta
	#else:
		#ship_rotation += attributes["turn_radius"] * turn_input * delta
	
	var input_vector = Input.get_vector("left", "right", "up", "down")
	if input_vector:
		ship_rotation = Vector2.UP.angle_to(input_vector)
	
	rotation = ship_rotation
	
	position += velocity.rotated(ship_rotation) * delta

func handle_wrap_around():
	var viewport_size = get_viewport_rect().size
	if position.x < 0.0:
		position.x = viewport_size.x
	elif position.x > viewport_size.x:
		position.x = 0.0
	if position.y < 0.0:
		position.y = viewport_size.y
	elif position.y > viewport_size.y:
		position.y = 0.0

func handle_shooting():
	if Input.is_action_just_pressed("shoot"):
		audio_stream_player.stream = sfx["shoot"]
		audio_stream_player.play()
		for spawn_point in bullet_spawn_points_1_2:
			shoot(1.0, attributes["bullet_speed"].rotated(ship_rotation), spawn_point.global_position)

func shoot(damage_multiplier, velocity, p_position, p_scale=Vector2.ONE):
	var bullet = bullet_scene.instantiate()
	if randf() < attributes["crit_chance"] / 100:
		bullet.damage = attributes["bullet_damage"] * damage_multiplier * attributes["crit_damage"]
		bullet.modulate = Color8(100, 0, 0)
	else:
		bullet.damage = attributes["bullet_damage"] * damage_multiplier
	bullet.enemy_bullet = false
	bullet.sprite_frames = bullet_sprite_frames[current_weapon]
	bullet.velocity = velocity
	bullet.position = p_position
	bullet.scale = p_scale * attributes["bullet_size_multiplier"]
	bullets.add_child(bullet)


func apply_upgrade(upgrade_type, rarity):
	if upgrades[upgrade_type][rarity]["dir"] == "multiply":
		attributes[upgrade_type] += attributes[upgrade_type] * upgrades[upgrade_type][rarity]["effect"] / 100
	elif upgrades[upgrade_type][rarity]["dir"] == "increase":
		attributes[upgrade_type] += upgrades[upgrade_type][rarity]["effect"]
	else:
		attributes[upgrade_type] -= attributes[upgrade_type] * upgrades[upgrade_type][rarity]["effect"] / 100
	if upgrades[upgrade_type][rarity].has("secondary"):
		for secondary_type in upgrades[upgrade_type][rarity]["secondary"].keys():
			var secondary = upgrades[upgrade_type][rarity]["secondary"][secondary_type]
			if secondary["dir"] == "multiply":
				attributes[secondary_type] += attributes[secondary_type] * secondary["effect"] / 100
			elif upgrades[upgrade_type][rarity]["dir"] == "increase":
				attributes[secondary_type] += secondary["effect"]
			else:
				attributes[secondary_type] -= attributes[secondary_type] * secondary["effect"] / 100
	update_damage_sprite()

func level_xp_cost(level):
	return level ** 2 + 10.0

func choose_upgrade():
	audio_stream_player.stream = sfx["level_up"]
	audio_stream_player.play()
	level_up_particles.global_position = get_viewport_rect().size / 2
	level_up_particles.emitting = true
	level_up_particles.show()
	get_tree().paused = true
	upgrade_choices.show()
	var idx = 0
	for choice in upgrade_choices.get_children():
		if idx > 0:
			choice.set_focus_neighbor(SIDE_TOP, upgrade_choices.get_child(idx - 1).get_path())
		if idx < upgrade_choices.get_child_count() - 1:
			choice.set_focus_neighbor(SIDE_BOTTOM, upgrade_choices.get_child(idx + 1).get_path())
		
		idx += 1
		
		if randf() > special_upgrade_chance or not special_upgrades:
			var type = upgrades.keys().pick_random()
			var choices = upgrades[type]
			var n = randf()
			var rarity = "common"
			for r in choices.keys():
				if choices[r]["rarity"] / choices.keys().size() >= n:
					rarity = r
					break
				n -= choices[r]["rarity"] / choices.keys().size()
			choice.update(upgrades[type][rarity]["text"], rarity_colors[rarity], type, rarity)
		else:
			var type = special_upgrades.pick_random()
			choice.update_special(type["text"], Color8(255, 100, 0), type["function"])
	
	upgrade_choices.get_child(0).grab_focus()

func upgrade_chosen(type, rarity):
	level_up_particles.emitting = false
	level_up_particles.hide()
	apply_upgrade(type, rarity)
	upgrade_choices.hide()
	get_tree().paused = false

func special_upgrade_chosen(special):
	level_up_particles.emitting = false
	level_up_particles.hide()
	
	for upgrade in special_upgrades:
		if upgrade["function"] == special:
			special_upgrades.erase(upgrade)
			break
	special_upgrades_unlocked.append(special)
	
	upgrade_choices.hide()
	get_tree().paused = false

func handle_special_abilities():
	for upgrade in special_upgrades_unlocked:
		upgrade.call()
	AOEs.scale = Vector2(attributes["AOEmultiplier"], attributes["AOEmultiplier"])

func shoot_behind():
	if Input.is_action_just_pressed("shoot"):
		shoot(1.0, -attributes["bullet_speed"].rotated(ship_rotation), position + Vector2(0, 16).rotated(ship_rotation))

func random_big_bullet():
	if big_bullet_timer.time_left <= 0.0:
		big_bullet_timer.start()
		if not big_bullet_timer.timeout.is_connected(fire_random_big_bullet):
			big_bullet_timer.timeout.connect(fire_random_big_bullet)

func fire_random_big_bullet():
	shoot(2.0, attributes["bullet_speed"].rotated(deg_to_rad(randi_range(-180, 180))), position, Vector2(3, 3))

func auto_heal():
	if heal_timer.time_left <= 0.0:
		heal_timer.start()
		if not heal_timer.timeout.is_connected(trigger_auto_heal):
			heal_timer.timeout.connect(trigger_auto_heal)

func trigger_auto_heal():
	attributes["health"] = clamp(attributes["health"] + 1, 0, attributes["max_health"])
	update_damage_sprite()

func AOEdamage():
	AOE_damage.monitoring = true
	if AOE_damage_timer.time_left <= 0.0:
		AOE_damage_timer.start()
		if not AOE_damage_timer.timeout.is_connected(apply_AOE_damage):
			AOE_damage_timer.timeout.connect(apply_AOE_damage)

func apply_AOE_damage():
	for enemy in AOE_damage.get_overlapping_areas():
		enemy.take_damage(attributes["bullet_damage"] / 2)

func update_damage_sprite():
	base.texture = damage_sprites[remap(attributes["health"], 0, attributes["max_health"], 0, damage_sprites.size() - 1)]

func handle_overlay():
	if Input.is_action_just_pressed("toggle_overlay"):
		overlay.visible = not overlay.visible
	if overlay.visible:
		update_overlay()
	if Input.is_action_just_pressed("quit"):
		toggle_pause_menu()

func update_overlay():
	if overlay.visible:
		var keys = attributes.keys()
		var idx = 0
		for child in overlay.get_children():
			child.text = keys[idx] + ": " + str(attributes[keys[idx]])
			idx += 1

func toggle_pause_menu():
	pause_menu.visible = not pause_menu.visible
	get_tree().paused = pause_menu.visible
	overlay.visible = pause_menu.visible
	if overlay.visible:
		update_overlay()
	if pause_menu.visible:
		pause_menu.get_child(0).grab_focus()

func _on_hurt_box_area_entered(area):
	var bullet = area.get_node("..")
	if bullet.enemy_bullet and not dead:
		attributes["health"] -= bullet.damage
		Input.start_joy_vibration(0, 0, 0.8, 0.1)
		if attributes["health"] <= 0.0:
			sprites.hide()
			get_tree().paused = true
			animated_sprite_2d.show()
			animated_sprite_2d.play("death")
			death_menu.show()
			death_return_button.grab_focus()
			level_label.text = "level attained: " + str(get_node("..").level)
			dead = true
			hurt_box.set_deferred("monitoring", false)
		else:
			bullet.queue_free.call_deferred()
			update_damage_sprite()

func _on_collect_box_area_entered(area):
	var xp_bubble = area.get_node("..")
	xp += xp_bubble.xp_amount
	xp_sfx.play()
	xp_bubble.queue_free()
	if xp >= level_xp_cost(level + 1):
		level += 1
		xp -= level_xp_cost(level)
		choose_upgrade()


func _on_shield_area_2d_area_entered(area):
	var bullet = area.get_node("..")
	if bullet.enemy_bullet and not dead:
		Input.start_joy_vibration(0, 0, 0.5, 0.1)
		var shield_attributes = presets_modifiers["shields"][Globals.presets["shields"][Globals.shield]["name"]]
		shield_attributes["health"] -= bullet.damage
		if shield_attributes["health"] <= 0.0:
			shield.hide()
			for shield_collision in shield_area_2d.get_children():
				if shield_collision.name == Globals.presets["shields"][Globals.shield]["name"] + "_Collision":
					shield_collision.set_deferred("disabled", true)
					break
		bullet.queue_free()


func _on_over_under_timer_timeout():
	over_under_timer.start()
	if hit_box.get_overlapping_areas(): return
	z_index = randi_range(0, 1)


func _on_resume_button_pressed():
	toggle_pause_menu()


func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_death_return_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "death":
		animated_sprite_2d.hide()
