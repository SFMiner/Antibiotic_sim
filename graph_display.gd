extends Control

# Ordnance toughness graph colors (matches organism color families)
const COLORS = {
	"Fire": Color(0.9, 0.4, 0.3),
	"Shrapnel": Color(0.567, 0.148, 0.616, 1.0),
	"Acid": Color(0.5, 0.8, 0.4),
	"Electricity": Color(0.59, 0.648, 0.0, 1.0),
	"Freeze": Color(0.5, 0.75, 0.95)
}

var history := []  # Each entry: { "ordnance": String, "avg_toughness": float }

func update_graph(population: Array):
	var avg = {}
	for ord_name in COLORS.keys():
		avg[ord_name] = 0.0
	if population.size() == 0:
		queue_redraw()
		return
	for org in population:
		for ord_name in COLORS.keys():
			avg[ord_name] += org.resistances[ord_name]
	for ord_name in COLORS.keys():
		avg[ord_name] /= float(population.size())
	history.append(avg)
	if history.size() > 100:
		history.pop_front()
	queue_redraw()

func _draw():
	var step_x = size.x / max(1, history.size())
	for i in range(1, history.size()):
		for ord_name in COLORS.keys():
			var c = COLORS[ord_name]
			var y_prev = size.y - (history[i - 1][ord_name] * 50)
			var y_cur = size.y - (history[i][ord_name] * 50)
			draw_line(Vector2((i - 1) * step_x, y_prev), Vector2(i * step_x, y_cur), c, 2)
