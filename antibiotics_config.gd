extends Node

# Cross-toughness map: defines how toughness to one ordnance type
# provides partial protection against related ordnance types
# Example: Shrapnel toughness gives 50% effectiveness toward Acid resistance
const CROSS_TOUGHNESS := {
	"Shrapnel": [ { "target": "Acid", "factor": 0.5 } ],
	"Acid": [ { "target": "Shrapnel", "factor": 0.5 } ]
}

# Ordnance types and their characteristics:
# - Fire: Combustion-based weapon, pure attack
# - Shrapnel: Projectile weapon, shares some crossover with Acid
# - Acid: Chemical corrosive weapon, shares some crossover with Shrapnel
# - Electricity: Energy-based weapon, pure attack
# - Freeze: Cryogenic weapon, pure attack
