extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $Area2D/CollisionShape2D


var velocity = Vector2.ZERO
var enemy_bullet = true
var damage = 1

var sprite_frames: SpriteFrames

func _ready():
	animated_sprite_2d.sprite_frames = sprite_frames
	animated_sprite_2d.play("default")
	var sprite: Texture2D = sprite_frames.get_frame_texture("default", 0)
	var rect = RectangleShape2D.new()
	if enemy_bullet:
		rect.size = sprite.get_size() / 1.5
	collision_shape_2d.shape = rect
	
	rotate(Vector2.UP.angle_to(velocity))

func _process(delta):
	position += velocity * delta
	
	var viewport_size = get_viewport_rect().size
	if position.x > viewport_size.x or 0 > position.x or position.y > viewport_size.y or 0 > position.y:
		queue_free()
