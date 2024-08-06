extends Area2D

@export var max_health = 1
@export var sprite_anim: AnimatedSprite2D
@export var collision_pos = Vector2(0, 0)

@onready var parent_ship = get_node("..") 
@onready var collision_shape_2d = $CollisionShape2D

var health

func _ready():
	var rect = RectangleShape2D.new()
	rect.size = sprite_anim.sprite_frames.get_frame_texture("default", 0).get_image().get_used_rect().size
	collision_shape_2d.shape = rect
	collision_shape_2d.position = collision_pos
	health = max_health

func _on_area_entered(area):
	var bullet = area.get_node("..")
	if not bullet.enemy_bullet:
		take_damage(bullet.damage)
		bullet.queue_free()

func take_damage(amount):
	health -= amount
	if health <= 0.0:
		parent_ship.death.emit()
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
