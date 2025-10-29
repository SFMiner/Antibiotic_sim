# FINAL TESTING CHECKLIST:
# [X] All UI shows zombie/ordnance terminology
# [X] Zombies spawn and are visible
# [?] Color modulation shows toughness correctly
# [X] Statistics panel tracks cycles and strikes
# [X] Graph displays ordnance toughness levels
# [X] All 5 ordnance types work correctly
# [?] Cross-toughness (Shrapnel/Acid) functions
# [X] Performance good with 1000 zombies
# [X] No console errors or warnings
# [ ] Statistics panel auto-scrolls to bottom
# [X] Toggle button switches between Show/Hide Stats

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
const BASE_DEATH_CHANCE := 0.5# 0.598
# Random survivor defense per infection cycle (natural attrition)
const SURVIVOR_DEFENSE := 15
# Cycles between unlocking new ordnance types
const ORDNANCE_UNLOCK_INTERVAL := 10

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

@onready var success_screen: Node2D = $UI/SuccessScreen
@onready var regular_restart_button: Button = $UI/SuccessScreen/PanelContainer/VBoxContainer/HBoxContainer/RegularButton
@onready var sandbox_restart_button: Button = $UI/SuccessScreen/PanelContainer/VBoxContainer/HBoxContainer/SandboxButton

@onready var auto_cycle_checkbox: CheckBox = $UI/AutoCycleCheckbox

# Zombie horde
var population: Array = []
# Current infection cycle number
var generation := 0
# Last strike cycle (for cooldown)
var last_dose_gen := -GENERATIONS_PER_DOSE
# Statistics tracking: array of cycle data dictionaries
var cycle_stats: Array = []
# Game mode: true for sandbox (all ordnance available), false for regular (staged unlock)
# Using static so it persists across scene reloads
static var sandbox_mode := false

# Auto-cycle timer management
var auto_cycle_timer: Timer = null
const AUTO_CYCLE_DELAY := 5.0  # Seconds before auto-advancing to next cycle

var antibiotic_config = preload("res://antibiotics_config.gd")
var genetic_system = preload("res://genetic_system.gd")
var organism_scene: PackedScene = preload("res://organism.tscn")

# Ordnance progression: unlocked in order, one every ORDNANCE_UNLOCK_INTERVAL cycles
var ordnance_sequence: Array = ["Fire", "Shrapnel", "Acid", "Electricity", "Freeze"]

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
	stats_scroll.visible = true  # Start collapsed

	# Success screen buttons
	regular_restart_button.pressed.connect(func(): _restart_game(false))
	sandbox_restart_button.pressed.connect(func(): _restart_game(true))

	_spawn_initial_population()
	_update_ui()
	_update_ordnance_buttons()

func _get_unlock_cycle_for_ordnance(ordnance: String) -> int:
	# Returns the cycle at which an ordnance becomes available
	var index = ordnance_sequence.find(ordnance)
	if index == -1:
		return 999  # Never unlock if not in sequence
	return index * ORDNANCE_UNLOCK_INTERVAL

func _is_ordnance_unlocked(ordnance: String) -> bool:
	# In sandbox mode, all ordnance is available immediately
	if sandbox_mode:
		return true
	# Check if an ordnance is currently available
	return generation >= _get_unlock_cycle_for_ordnance(ordnance)

func _update_ordnance_buttons():
	# Update button states based on unlocked ordnance types
	augamentin_button.disabled = !_is_ordnance_unlocked("Fire")
	ceph1_button.disabled = !_is_ordnance_unlocked("Shrapnel")
	ceph2_button.disabled = !_is_ordnance_unlocked("Acid")
	tetra_button.disabled = !_is_ordnance_unlocked("Electricity")
	cipro_button.disabled = !_is_ordnance_unlocked("Freeze")

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

	# Create initial cycle entry for generation 0
	var initial_cycle = {
		"cycle": 0,
		"zombie_count": population.size(),
		"strike": null,
		"killed": 0
	}
	cycle_stats.append(initial_cycle)
	_update_stats_display()

func _next_generation():
	print("DEBUG: Next Generation button clicked!")
	# Cancel any pending auto-cycle timer
	_cancel_auto_cycle_timer()
	generation += 1

	# Check if new ordnance unlocked at this cycle
	var newly_unlocked_ordnance: Array = []
	for ordnance in ordnance_sequence:
		var unlock_cycle = _get_unlock_cycle_for_ordnance(ordnance)
		if generation == unlock_cycle:
			newly_unlocked_ordnance.append(ordnance)

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
	if newly_unlocked_ordnance.size() > 0:
		cycle_entry["new_ordnance"] = newly_unlocked_ordnance
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

	# Notify player of newly unlocked ordnance
	if newly_unlocked_ordnance.size() > 0:
		print("*** NEW ORDNANCE AVAILABLE: %s ***" % ", ".join(newly_unlocked_ordnance))

	_update_ui()
	_update_ordnance_buttons()
	_update_stats_display()
	_check_victory()

func _check_victory():
	# Check if all zombies have been eliminated
	if population.size() == 0:
		print("=== VICTORY! HORDE ELIMINATED ===")
		success_screen.visible = true

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
	# Reset sandbox mode when starting fresh from title screen
	sandbox_mode = false
	title_page.visible = false
	buttons.visible = true

func _randomize_positions():
	for org in population:
		if is_instance_valid(org):
			org.position = _rand_pos() 

func _apply_antibiotic(name: String):
	# Check if ordnance is unlocked
	if not _is_ordnance_unlocked(name):
		print("Ordnance '%s' not yet available. Unlocks at cycle %d" % [name, _get_unlock_cycle_for_ordnance(name)])
		return

	# Ordnance strike targeting zombie horde
	if generation - last_dose_gen < GENERATIONS_PER_DOSE:
		return
	match name:
		"Fire": audio.stream = FIRE_SOUND
		"Electricity": audio.stream = ELECTRICITY_SOUND
		"Acid": audio.stream = ACID_SOUND
		"Shrapnel": audio.stream = SHRAPNEL_SOUND
		"Freeze": audio.stream = FREEZE_SOUND
	audio.play()
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
		most_recent["population_before_strike"] = zombies_before

	_update_ui()
	_update_stats_display()
	_check_victory()

	# Start auto-cycle timer if enabled
	if auto_cycle_checkbox.button_pressed:
		_start_auto_cycle_timer()

func _update_ui():
	gen_label.text = "Infection Cycle: %d" % generation
	pop_label.text = "Zombie Count: %d" % population.size()

func _toggle_stats_panel():
	stats_scroll.visible = !stats_scroll.visible
	stats_toggle.text = "Show Stats" if stats_scroll.visible else "Hide Stats"

func _update_stats_display():
	# Format cycle-by-cycle statistics for display
	var text = "=== INFECTION LOG ===\n\n"
	for stat in cycle_stats:
		text += "Cycle %d: %d zombies\n" % [stat["cycle"], stat["zombie_count"]]

		# Show newly unlocked ordnance
		if stat.has("new_ordnance"):
			var ordnance_list = stat["new_ordnance"]
			text += "  ★ NEW ORDNANCE: %s\n" % ", ".join(ordnance_list)

		if stat["strike"] != null:
			text += "  → Strike: %s\n" % stat["strike"]
			var pop_before = stat.get("population_before_strike", 0)
			if pop_before > 0:
				var percentage = (stat["killed"] * 100.0) / pop_before
				text += "  → Eliminated: %d (%.1f%%)\n" % [stat["killed"], percentage]
			else:
				text += "  → Eliminated: %d\n" % stat["killed"]
		text += "\n"
	stats_label.text = text

	# Auto-scroll to bottom
	await get_tree().process_frame
	stats_scroll.scroll_vertical = int(stats_scroll.get_v_scroll_bar().max_value)

func _rand_pos() -> Vector2:
	# Keep within a safe margin of the 1280x720 window (adjust if you change resolution)
	return Vector2(randi_range(30, 1250), randi_range(90, 680))

func _restart_game(sandbox: bool):
	# Set game mode and reload the scene
	sandbox_mode = sandbox
	get_tree().reload_current_scene()

func _start_auto_cycle_timer():
	# Create and start a timer that will trigger next generation after delay
	_cancel_auto_cycle_timer()  # Cancel any existing timer first

	auto_cycle_timer = Timer.new()
	add_child(auto_cycle_timer)
	auto_cycle_timer.wait_time = AUTO_CYCLE_DELAY
	auto_cycle_timer.one_shot = true
	auto_cycle_timer.timeout.connect(_on_auto_cycle_timeout)
	auto_cycle_timer.start()
	print("Auto-cycle timer started: %d seconds" % int(AUTO_CYCLE_DELAY))

func _cancel_auto_cycle_timer():
	# Cancel the auto-cycle timer if it exists
	if auto_cycle_timer != null and is_instance_valid(auto_cycle_timer):
		auto_cycle_timer.queue_free()
		auto_cycle_timer = null
		print("Auto-cycle timer cancelled")

func _on_auto_cycle_timeout():
	# Timer finished, advance to next generation
	print("Auto-cycle timer completed, advancing to next cycle")
	auto_cycle_timer = null
	_next_generation()
