extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

# Toughness levels for each ordnance type
var resistances = {
	"Fire": 0,
	"Shrapnel": 0,
	"Acid": 0,
	"Electricity": 0,
	"Freeze": 0
}

# Cache a 6x6 white texture once

var speed : float
var go_right : bool
var wander_distance : int
var wander_vert : int
var parent_position
var up_down : int
#var _dot_tex: Texture2D

func _ready() -> void:
	# TODO: Human will provide zombie sprite sheet
	# For now, use fallback 6x6 white dot for testing
#	if _dot_tex == null:
#		var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
#		img.fill(Color(1, 1, 1, 1))
#		_dot_tex = ImageTexture.create_from_image(img)
#	sprite.texture = _dot_tex
#	sprite.centered = true

	# When zombie sprite is provided:
	# sprite.texture = preload("res://assets/zombie_sprite.png")
	# sprite.hframes = X  # Set based on sprite sheet
	# sprite.frame = 0    # Default frame
	
	sprite.play()
	go_right = randf() > 0.5
	wander_distance = randi_range(5,10) 
	wander_vert = randi_range(2,4)
	parent_position = get_parent().position.x
	#("parent_position = " + str(parent_position))
	speed = randf_range(0.05,0.2)
	var step1 : int = randi_range(0,2)
	var current_progress = sprite.get_frame_progress()
	sprite.set_frame_and_progress(step1, current_progress)
	_update_color()

func _process(float) -> void:
	if go_right:
		sprite.flip_h = true
		sprite.position += Vector2(speed, 0.02 * wander_vert)
		if sprite.position.x > parent_position + wander_distance: 
			go_right = false
			wander_distance = randi_range(5,10)
			wander_vert = randf_range(-0.04, 0.04)
	 
	else:
		sprite.flip_h = false
		sprite.position -= Vector2(speed, 0.02 * wander_vert)
		if sprite.position.x < parent_position - wander_distance: 
			go_right = true
			wander_distance = randi_range(5,10) 
			wander_vert = randf_range(-0.04, 0.04)
	#print("wander_vert: " + str(wander_vert))
	#print(sprite.position.x)
			 

func check_survival(ordnance: String, base_chance: float, cross_map: Dictionary) -> bool:
	var toughness_level = resistances.get(ordnance, 0)
	# Cross-toughness adjustment: related ordnance types provide partial protection
	for related in cross_map.get(ordnance, []):
		toughness_level += resistances.get(related["target"], 0) * related["factor"]
	var death_chance = base_chance / pow(2.0, toughness_level)
	return randf() > death_chance

func mutate_one():
	var keys = resistances.keys()
	var key = keys[randi_range(0, keys.size() - 1)]
	resistances[key] += 1
	_update_color()

func _update_color():
	# Color families per ordnance type (low → high toughness deepens blend)
	var fam = {
		"Fire": Color(0.816, 0.0, 0.0, 1.0),        # orange/red flames
		"Shrapnel": Color(0.567, 0.148, 0.616, 1.0),    # magent
		"Acid": Color(0.40, 0.80, 0.30),        # green bubbling
		"Electricity": Color(0.59, 0.648, 0.0, 1.0), # blue crackling
		"Freeze": Color(0.50, 0.75, 0.95)       # icy blue
	}
	
	var total = Color(0.75, 0.80, 0.75) # base sickly greenish-gray zombie tone
	for k in resistances.keys():
		var lvl = resistances[k]
		if lvl > 0:
			total = total.lerp(fam[k], clamp(lvl * 0.35, 0.0, 1.0))
	if ! sprite: sprite = $Sprite
	sprite.modulate = total
