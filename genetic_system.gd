# Zombie Infection Spread System
# Represents how surviving zombies infect new victims as the horde grows
# Each infection cycle, survivors create new infected victims (mutations possible)

extends Node

const MUTATION_RATE := 0.01

# Reproduces the zombie horde: survivors infect new victims, population doubles (up to cap)
# Each new infected may randomly develop toughness to one ordnance type
static func reproduce_population(layer: Node, organism_scene: PackedScene, pop: Array, cap: int) -> Array:
	# Filter: Keep surviving zombies that still exist in scene
	var survivors: Array = []
	for org in pop:
		if is_instance_valid(org):
			survivors.append(org)

	# If no survivors remain, horde is exterminated
	if survivors.is_empty():
		return []

	# Infection spread: target population doubles survivors, but never exceed horde cap
	var target_size = min(cap, survivors.size() * 2)
	var new_infected = target_size - survivors.size()

	# Start with surviving zombies
	var new_horde: Array = []
	new_horde.append_array(survivors)

	# Each surviving zombie infects new victims
	var i := 0
	while i < new_infected:
		var parent = survivors[i % survivors.size()]
		var infected: Node2D = organism_scene.instantiate()
		# Copy toughness from parent zombie
		infected.resistances = parent.resistances.duplicate(true)
		# Update color to reflect inherited toughness
		infected._update_color()
		# Infection roll: 1% chance new infected develops random ordnance toughness mutation
		if randf() < MUTATION_RATE:
			infected.mutate_one()
		# Temp position near parent; main.gd will randomize layout after spread
		infected.position = parent.position
		layer.add_child(infected)
		new_horde.append(infected)
		i += 1

	return new_horde
