extends Node

const MUTATION_RATE := 0.01

static func reproduce_population(layer: Node, organism_scene: PackedScene, pop: Array, cap: int) -> Array:
	# Keep survivors that still exist
	var survivors: Array = []
	for org in pop:
		if is_instance_valid(org):
			survivors.append(org)

	# If no survivors, population stays zero
	if survivors.is_empty():
		return []

	# Target = double the survivors, but never exceed cap
	var target_size = min(cap, survivors.size() * 2)
	var children_to_add = target_size - survivors.size()

	# Start with survivors
	var new_pop: Array = []
	new_pop.append_array(survivors)

	# Make exactly the number of children needed to reach target_size
	var i := 0
	while i < children_to_add:
		var parent = survivors[i % survivors.size()]
		var child: Node2D = organism_scene.instantiate()
		# Copy resistance state
		child.resistances = parent.resistances.duplicate(true)
		# Mutation roll
		if randf() < MUTATION_RATE:
			child.mutate_one()
		# Temp position near parent; main.gd will randomize layout after
		child.position = parent.position
		layer.add_child(child)
		new_pop.append(child)
		i += 1

	return new_pop
