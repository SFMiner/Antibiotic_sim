extends Control

const POPULATION_CAP := 1000
const START_POP := 400
const GENERATIONS_PER_DOSE := 2
const BASE_DEATH_CHANCE := 0.8
const IMMUNE_RESPONSE := 15

@onready var bacteria_layer: Node2D = $BacteriaLayer
@onready var gen_label: Label = $UI/TopPanel/HBoxContainer/GenerationLabel
@onready var pop_label: Label = $UI/TopPanel/HBoxContainer/PopulationLabel
@onready var dose_label: Label = $UI/TopPanel/HBoxContainer/LastDoseLabel
@onready var next_gen_button: Button = $UI/Buttons/NextGenButton
@onready var graph: Control = $UI/GraphDisplay

@onready var buttons : VBoxContainer = $UI/Buttons

@onready var augamentin_button : Button = $UI/Buttons/AugmentinButton
@onready var ceph1_button : Button = $UI/Buttons/Ceph1Button
@onready var ceph2_button : Button = $UI/Buttons/Ceph2Button
@onready var tetra_button : Button = $UI/Buttons/TetraButton
@onready var cipro_button : Button = $UI/Buttons/CiproButton

@onready var title_page : Node2D = $UI/TitlePage
@onready var start_button : Button = $UI/TitlePage/StartButton



var population: Array = []
var generation := 0
var last_dose_gen := -GENERATIONS_PER_DOSE

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
	_spawn_initial_population()
	_update_ui()

func _spawn_initial_population():
	for i in range(START_POP):
		var org = organism_scene.instantiate()
		bacteria_layer.add_child(org)
		org.position = _rand_pos()
		population.append(org)

func _next_generation():
	generation += 1
	population = genetic_system.reproduce_population(bacteria_layer, organism_scene, population, POPULATION_CAP)
	_apply_immune_response()
	_randomize_positions()
	graph.update_graph(population)
	_update_ui()

func _apply_immune_response():
	# Immune system randomly eliminates bacteria each generation
	var to_remove = min(IMMUNE_RESPONSE, population.size())
	if to_remove <= 0:
		return

	# Shuffle and remove random bacteria
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
	if generation - last_dose_gen < GENERATIONS_PER_DOSE:
		return
	last_dose_gen = generation
	dose_label.text = "Last Dose: %s" % name

	var survivors: Array = []
	for org in population:
		if not is_instance_valid(org):
			continue
		if org.check_survival(name, BASE_DEATH_CHANCE, antibiotic_config.CROSS_RESIST):
			survivors.append(org)
		else:
			org.queue_free()
	population = survivors
	_update_ui()

func _update_ui():
	gen_label.text = "Generation: %d" % generation
	pop_label.text = "Population: %d" % population.size()

func _rand_pos() -> Vector2:
	# Keep within a safe margin of the 1280x720 window (adjust if you change resolution)
	return Vector2(randi_range(30, 1250), randi_range(90, 680))
