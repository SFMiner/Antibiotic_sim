# FINAL TESTING CHECKLIST:
# [ ] All UI shows zombie/ordnance terminology
# [ ] Zombies spawn and are visible
# [ ] Color modulation shows toughness correctly
# [ ] Statistics panel tracks cycles and strikes
# [ ] Graph displays ordnance toughness levels
# [ ] All 5 ordnance types work correctly
# [ ] Cross-toughness (Shrapnel/Acid) functions
# [ ] Performance good with 1000 zombies
# [ ] No console errors or warnings
# [ ] Statistics panel auto-scrolls to bottom
# [ ] Toggle button switches between Show/Hide Stats

extends Control

# Maximum zombie horde size
const POPULATION_CAP := 1000
const FIRE_SOUND = preload("res://fireball-impact-351961.mp3")
const FREEZE_SOUND = preload("res://freeze.mp3")
const ELECTRICITY_SOUND = preload("res://lightning-spell-impact-393920.mp3")
const ACID_SOUND = preload("res://acid.mp3")
const SHRAPNEL_SOUND = preload("res://shrapnel.mp3")

# Initial zombie horde population
const START_POP := 400
# Infection cycles between ordnance strikes (1 = every round)
const GENERATIONS_PER_DOSE := 1
# Base casualty rate from ordnance (without toughness)
const BASE_DEATH_CHANCE := 0.598
# Random survivor defense per infection cycle (natural attrition)
const SURVIVOR_DEFENSE := 15

@onready var bacteria_layer: Node2D = $BacteriaLayer
@onready var gen_label: Label = $UI/TopPanel/HBoxContainer/GenerationLabel
@onready var pop_label: Label = $UI/TopPanel/HBoxContainer/PopulationLabel
@onready var dose_label: Label = $UI/TopPanel/HBoxContainer/LastDoseLabel
@onready var next_gen_button: Button = $UI/Buttons/NextGenButton
@onready var graph: Control = $UI/Panel/GraphDisplay
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@onready var buttons : VBoxContainer = $UI/Buttons

@onready var augamentin_button : Button = $UI/Buttons/FireButton
@onready var ceph1_button : Button = $UI/Buttons/ShrapnelButton
@onready var ceph2_button : Button = $UI/Buttons/AcidButton
@onready var tetra_button : Button = $UI/Buttons/ElectricityButton
@onready var cipro_button : Button = $UI/Buttons/FreezeButton

@onready var title_page : Node2D = $UI/TitlePage
@onready var start_button : Button = $UI/TitlePage/StartButton

@onready var stats_panel: PanelContainer = $UI/LeftPanel
@onready var stats_toggle: Button = $UI/LeftPanel/VBoxContainer/ToggleButton
@onready var stats_scroll: ScrollContainer = $UI/LeftPanel/VBoxContainer/StatsScroll
@onready var stats_label: Label = $UI/LeftPanel/VBoxContainer/StatsScroll/StatsLabel

# Zombie horde
var population: Array = []
# Current infection cycle number
var generation := 0
# Last strike cycle (for cooldown)
var last_dose_gen := -GENERATIONS_PER_DOSE
# Statistics tracking: array of cycle data dictionaries
var cycle_stats: Array = []

var antibiotic_config = preload("res://antibiotics_config.gd")
var genetic_system = preload("res://genetic_system.gd")
var organism_scene: PackedScene = preload("res://organism.tscn")

func _ready() -> void:
	augamentin_button.pressed.connect(func(): _apply_antibiotic(augamentin_button.text))
	ceph1_button.pressed.connect(func(): _apply_antibiotic(ceph1_button.text))
	ceph2_button.pressed.connect(func(): _apply_antibiotic(ceph2_button.text))
	tetra_button.pressed.connect(func(): _apply_antibiotic(tetra_button.text))
	cipro_button.pressed.connect(func(): _apply_antibiotic(cipro_button.text))
	next_gen_button.pressed.connect(_next_generation)
	start_button.pressed.connect(_start_game)

	# Statistics panel toggle
	stats_toggle.pressed.connect(_toggle_stats_panel)
	stats_scroll.visible = false  # Start collapsed

	_spawn_initial_population()
	_update_ui()

func _spawn_initial_population():
	# Seed initial population with at least one zombie of each toughness type
	var ordnance_types = ["Fire", "Shrapnel", "Acid", "Electricity", "Freeze"]

	for ordnance in ordnance_types:
		var org = organism_scene.instantiate()
		org.resistances[ordnance] = 1  # Give toughness 1 to this ordnance type
		org._update_color()  # Update visual color
		bacteria_layer.add_child(org)
		org.position = _rand_pos()
		population.append(org)

	# Fill rest of population with zero-resistance zombies
	for i in range(START_POP - ordnance_types.size()):
		var org = organism_scene.instantiate()
		bacteria_layer.add_child(org)
		org.position = _rand_pos()
		population.append(org)

	# Debug: verify seeding worked
	print("=== INITIAL POPULATION SEEDED ===")
	var resistance_count = {"Fire": 0, "Shrapnel": 0, "Acid": 0, "Electricity": 0, "Freeze": 0}
	for org in population:
		for ordnance in ordnance_types:
			if org.resistances[ordnance] > 0:
				resistance_count[ordnance] += 1
	print("Zombies with resistance - Fire: %d, Shrapnel: %d, Acid: %d, Electricity: %d, Freeze: %d" % [
		resistance_count["Fire"], resistance_count["Shrapnel"], resistance_count["Acid"],
		resistance_count["Electricity"], resistance_count["Freeze"]
	])

func _next_generation():
	print("DEBUG: Next Generation button clicked!")
	generation += 1
	population = genetic_system.reproduce_population(bacteria_layer, organism_scene, population, POPULATION_CAP)
	_apply_survivor_defense()
	_randomize_positions()
	graph.update_graph(population)

	# Record cycle statistics
	var cycle_entry = {
		"cycle": generation,
		"zombie_count": population.size(),
		"strike": null,
		"killed": 0
	}
	cycle_stats.append(cycle_entry)

	# Debug: Track resistance evolution
	var ordnance_types = ["Fire", "Shrapnel", "Acid", "Electricity", "Freeze"]
	var avg_toughness = {}
	for ordnance in ordnance_types:
		var total_toughness = 0.0
		for org in population:
			total_toughness += org.resistances[ordnance]
		avg_toughness[ordnance] = total_toughness / max(1, population.size())

	print("Cycle %d - Pop: %d | Avg Toughness - Fire: %.2f, Shrapnel: %.2f, Acid: %.2f, Elec: %.2f, Freeze: %.2f" % [
		generation, population.size(),
		avg_toughness["Fire"], avg_toughness["Shrapnel"], avg_toughness["Acid"],
		avg_toughness["Electricity"], avg_toughness["Freeze"]
	])

	_update_ui()
	_update_stats_display()

func _apply_survivor_defense():
	# Random zombie casualties per infection cycle (natural attrition from environment)
	var to_remove = min(SURVIVOR_DEFENSE, population.size())
	if to_remove <= 0:
		return

	# Shuffle and remove random zombies
	population.shuffle()
	for i in range(to_remove):
		var org = population.pop_back()
		if is_instance_valid(org):
			org.queue_free()

func _start_game():
	title_page.visible = false
	buttons.visible = true

func _randomize_positions():
	for org in population:
		if is_instance_valid(org):
			org.position = _rand_pos() 

func _apply_antibiotic(name: String):
	# Ordnance strike targeting zombie horde
	match name:
		"Fire": audio.stream = FIRE_SOUND
		"Electricity": audio.stream = ELECTRICITY_SOUND
		"Acid": audio.stream = ACID_SOUND
		"Shrapnel": audio.stream = SHRAPNEL_SOUND
		"Freeze": audio.stream = FREEZE_SOUND
	audio.play()
	if generation - last_dose_gen < GENERATIONS_PER_DOSE:
		return
	last_dose_gen = generation
	dose_label.text = "Last Strike: %s" % name

	# Track zombies before strike
	var zombies_before = population.size()

	var survivors: Array = []
	for org in population:
		if not is_instance_valid(org):
			continue
		if org.check_survival(name, BASE_DEATH_CHANCE, antibiotic_config.CROSS_TOUGHNESS):
			survivors.append(org)
		else:
			org.queue_free()
	population = survivors

	# Calculate and record strike casualties
	var killed = zombies_before - population.size()
	if cycle_stats.size() > 0:
		var most_recent = cycle_stats[cycle_stats.size() - 1]
		most_recent["strike"] = name
		most_recent["killed"] = killed

	_update_ui()
	_update_stats_display()

func _update_ui():
	gen_label.text = "Infection Cycle: %d" % generation
	pop_label.text = "Zombie Count: %d" % population.size()

func _toggle_stats_panel():
	stats_scroll.visible = !stats_scroll.visible
	stats_toggle.text = "Hide Stats" if stats_scroll.visible else "Show Stats"

func _update_stats_display():
	# Format cycle-by-cycle statistics for display
	var text = "=== INFECTION LOG ===\n\n"
	for stat in cycle_stats:
		text += "Cycle %d: %d zombies\n" % [stat["cycle"], stat["zombie_count"]]
		if stat["strike"] != null:
			text += "  → Strike: %s\n" % stat["strike"]
			text += "  → Eliminated: %d\n" % stat["killed"]
		text += "\n"
	stats_label.text = text

	# Auto-scroll to bottom
	await get_tree().process_frame
	stats_scroll.scroll_vertical = int(stats_scroll.get_v_scroll_bar().max_value)

func _rand_pos() -> Vector2:
	# Keep within a safe margin of the 1280x720 window (adjust if you change resolution)
	return Vector2(randi_range(30, 1250), randi_range(90, 680))
