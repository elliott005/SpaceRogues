extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D

signal death

@onready var ai_component = get_node_or_null("AIComponent")

var dead = false
var multiplier = 1

@export var xp_drop = 1

func _ready():
	animated_sprite_2d.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	animated_sprite_2d.play("default")
	var health_component = get_node_or_null("HealthComponent")
	if health_component:
		health_component.max_health *= multiplier
		health_component.health *= multiplier
	var gun_component = get_node_or_null("GunComponent")
	if gun_component:
		gun_component.bullet_damage *= multiplier
	death.connect(die)

func _process(delta):
	if ai_component:
		rotation = ai_component.ship_rotation
		position = ai_component.position


func die():
	dead = true
	animated_sprite_2d.play("death")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "death":
		var xp_scene = preload("res://scenes/actors/xp.tscn").instantiate()
		xp_scene.xp_amount = xp_drop
		xp_scene.position = position
		get_node("/root/World/XP").add_child(xp_scene)
		queue_free()
