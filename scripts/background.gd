extends Node2D

@onready var parallax_background = $ParallaxBackground

func _process(delta):
	parallax_background.scroll_offset.x -= 100.0 * delta
