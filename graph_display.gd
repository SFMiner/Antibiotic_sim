extends Control

const COLORS = {
	"Augmentin": Color(0.7, 0.6, 0.8),
	"Cephalexin-1": Color(0.9, 0.4, 0.5),
	"Cephalexin-2": Color(0.9, 0.6, 0.4),
	"Tetracycline": Color(0.7, 0.8, 0.4),
	"Ciprofloxacin": Color(0.4, 0.6, 0.9)
}

var history := []  # Each entry: { "antibiotic": String, "avg_level": float }

func update_graph(population: Array):
	var avg = {}
	for name in COLORS.keys():
		avg[name] = 0.0
	if population.size() == 0:
		queue_redraw()
		return
	for org in population:
		for name in COLORS.keys():
			avg[name] += org.resistances[name]
	for name in COLORS.keys():
		avg[name] /= float(population.size())
	history.append(avg)
	if history.size() > 100:
		history.pop_front()
	queue_redraw()

func _draw():
	var step_x = size.x / max(1, history.size())
	for i in range(1, history.size()):
		for name in COLORS.keys():
			var c = COLORS[name]
			var y_prev = size.y - (history[i - 1][name] * 50)
			var y_cur = size.y - (history[i][name] * 50)
			draw_line(Vector2((i - 1) * step_x, y_prev), Vector2(i * step_x, y_cur), c, 2)
