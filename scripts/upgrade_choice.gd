extends TextureButton

@onready var label = $Label

var type
var rarity
var special = false

func update(text, color, p_type, p_rarity):
	label.text = text
	self_modulate = color
	type = p_type
	rarity = p_rarity
	special = false

func update_special(text, color, p_special):
	label.text = text
	self_modulate = color
	special = p_special


func _on_pressed():
	if not special:
		Globals.upgrade_chosen.emit(type, rarity)
	else:
		Globals.special_upgrade_chosen.emit(special)


func _on_focus_entered():
	custom_minimum_size = Vector2(320 * 1.5, 96 * 1.5)


func _on_focus_exited():
	custom_minimum_size = Vector2(320, 96)
