extends Node2D

@onready var sprite: Sprite2D = $Sprite

var resistances = {
	"Augmentin": 0,
	"Cephalexin-1": 0,
	"Cephalexin-2": 0,
	"Tetracycline": 0,
	"Ciprofloxacin": 0
}

# Cache a 6x6 white texture once
var _dot_tex: Texture2D

func _ready() -> void:
	if _dot_tex == null:
		var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 1))
		_dot_tex = ImageTexture.create_from_image(img)
	sprite.texture = _dot_tex
	sprite.centered = true
	_update_color()

func check_survival(antibiotic: String, base_chance: float, cross_map: Dictionary) -> bool:
	var resist_level = resistances.get(antibiotic, 0)
	# Cross resistance adjustment
	for related in cross_map.get(antibiotic, []):
		resist_level += resistances.get(related["target"], 0) * related["factor"]
	var death_chance = base_chance / pow(2.0, resist_level)
	return randf() > death_chance

func mutate_one():
	var keys = resistances.keys()
	var key = keys[randi_range(0, keys.size() - 1)]
	resistances[key] += 1
	_update_color()

func _update_color():
	# Color families per antibiotic (low → high resistance deepens blend)
	var fam = {
		"Augmentin": Color(0.55, 0.35, 0.70),      # lavender→purple
		"Cephalexin-1": Color(0.90, 0.25, 0.35),   # pink→red
		"Cephalexin-2": Color(0.85, 0.45, 0.20),   # peach→rust
		"Tetracycline": Color(0.55, 0.75, 0.30),   # yellow-green→forest
		"Ciprofloxacin": Color(0.30, 0.55, 0.90)   # sky→navy
	}
	var total = Color(0.82, 0.82, 0.82) # base gray
	for k in resistances.keys():
		var lvl = resistances[k]
		if lvl > 0:
			total = total.lerp(fam[k], clamp(lvl * 0.35, 0.0, 1.0))
	if ! sprite: sprite = $Sprite
	sprite.modulate = total
