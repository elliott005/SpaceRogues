extends Node2D

@onready var enemies = $Enemies
@onready var audio_stream_player = $AudioStreamPlayer

var level = 0
var max_level = 0

var enemies_types = [
	{"strength": 1, "scene": preload("res://scenes/actors/nairan_fighter.tscn")},
	{"strength": 2, "scene": preload("res://scenes/actors/nairan_torpedo_ship.tscn")},
	{"strength": 3, "scene": preload("res://scenes/actors/nairan_battlecruiser.tscn")},
	{"strength": 1, "scene": preload("res://scenes/actors/nairan_scout.tscn")},
	{"strength": 2, "scene": preload("res://scenes/actors/nairan_frigate.tscn")},
	{"strength": 3, "scene": preload("res://scenes/actors/nairan_dreadnought.tscn")},
	{"strength": 2, "scene": preload("res://scenes/actors/nairan_bomber.tscn")},
	{"strength": 4, "scene": preload("res://scenes/actors/klaed_fighter.tscn")}
]


func _ready():
	var audio_tween = get_tree().create_tween()
	audio_stream_player.volume_db = Globals.settings["music"]["music_vol"] - 30
	audio_tween.tween_property(audio_stream_player, "volume_db", Globals.settings["music"]["music_vol"] - 20, 1.0)

func _process(delta):
	if enemies.get_child_count() == 0:
		level += 1
		var spawnable_enemies = []
		for enemy in enemies_types:
			if enemy["strength"] == level or enemy["strength"] == level - 1 or enemy["strength"] == level + 1:
				spawnable_enemies.append(enemy)
		if spawnable_enemies:
			spawn_enemies(spawnable_enemies)
		else:
			if max_level == 0:
				max_level = level
			for enemy in enemies_types:
				if enemy["strength"] == ceil(float(level) / float(max_level)) or enemy["strength"] == ceil(float(level) / float(max_level)) - 1 or enemy["strength"] == ceil(float(level) / float(max_level)) + 1:
					spawnable_enemies.append(enemy)
			spawn_enemies(spawnable_enemies, float(level) / float(max_level))


func spawn_enemies(spawnable_enemies, multiplier=1):
	var viewport_size = get_viewport_rect().size
	for i in range(level + 1, level + 5):
		var enemy = spawnable_enemies.pick_random()["scene"].instantiate()
		enemy.position = Vector2(randi_range(10, viewport_size.x - 10), randi_range(10, viewport_size.y - 10))
		enemy.multiplier = multiplier
		enemies.add_child(enemy)
