extends Node2D

@onready var timer = $Timer
@onready var parent_ship = get_node("..")
@onready var bullets = $Bullets
@onready var bullet_spawn_points = $BulletSpawnPoints.get_children()

@export var shoot_cooldown = 0.7
@export var bullet_damage = 1
@export var bullet_speed = Vector2(0, -800)
@export_enum("bolt", "rocket", "torpedo", "ray", "big", "klaed") var bullet_type = "bolt"

var bullet_scene = preload("res://scenes/actors/bullet.tscn")
var bullet_sprite_frames = {
	"bolt": preload("res://resources/bullet_bolt.tres"),
	"rocket": preload("res://resources/bullet_rocket.tres"),
	"torpedo": preload("res://resources/bullet_torpedo.tres"),
	"ray": preload("res://resources/bullet_ray.tres"),
	"big": preload("res://resources/bullet_big.tres"),
	"klaed": preload("res://resources/bullet_klaed.tres")
}


func _ready():
	timer.start(shoot_cooldown)




func _on_timer_timeout():
	if parent_ship.dead: return
	timer.start(shoot_cooldown)
	for spawn_point in bullet_spawn_points:
		var bullet = bullet_scene.instantiate()
		if bullet_type != "ray":
			bullet.scale = Vector2(3, 3)
		else:
			bullet.scale = Vector2(2, 2)
		bullet.damage = bullet_damage
		bullet.sprite_frames = bullet_sprite_frames[bullet_type]
		bullet.velocity = bullet_speed.rotated(parent_ship.rotation)
		bullet.position = spawn_point.global_position
		bullets.add_child(bullet)
	
