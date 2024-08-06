extends Node2D

@export var max_speed = -150.0
@export var acceleration = 300.0
@export var turn_radius = 20.0
@export var super_turn_radius = 45.0
@export var brake_force = 300.0
@export var drift_speed = -100.0

@onready var parent_ship = get_node("..")
@onready var timer = $Timer

var velocity = Vector2.ZERO
var ship_rotation = 0.0

func _ready():
	max_speed += randi_range(-20, 20)
	turn_radius += randi_range(-3, 3)
	turn_radius = deg_to_rad(turn_radius)
	super_turn_radius = deg_to_rad(super_turn_radius)
	position = parent_ship.position

func _process(delta):
	if not parent_ship.dead:
		handle_movement(delta)
		handle_wrap_around()

func handle_movement(delta):
	var player_position: Vector2 = get_tree().get_first_node_in_group("Player").position
	if player_position.distance_to(global_position) < 100 or timer.time_left > 0.0:
		if timer.time_left <= 0.0:
			var viewport_size = get_viewport_rect().size
			player_position = Vector2(randi_range(10, viewport_size.x - 10), randi_range(10, viewport_size.y - 10))
		timer.start()
	
	var angle = velocity.rotated(ship_rotation).angle_to(player_position - position)
	
	var brake_input = angle > deg_to_rad(90.0)
	if brake_input:
		velocity.y = move_toward(velocity.y, drift_speed, acceleration * delta)
	else:
		velocity.y = move_toward(velocity.y, max_speed, acceleration * delta)
	
	var turn_input = remap(rad_to_deg(angle), -15, 15, -1, 1)
	if brake_input:
		ship_rotation += super_turn_radius * turn_input * delta
	else:
		ship_rotation += turn_radius * turn_input * delta
	
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
