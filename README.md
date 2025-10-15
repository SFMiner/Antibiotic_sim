# 🧬 Antibiotic Resistance Simulator

_A Godot 4.5 project demonstrating bacterial evolution under antibiotic pressure._
---

## 🎯 Overview

This simulation shows how random mutation and selection pressure can change a bacterial population over time.  
Each dot represents a single bacterium. Some carry genes that make them resistant to specific antibiotics; others do not.  
Students can advance generations, apply different antibiotics, and watch the population adapt.

---

## ▶️ How to Run
1. Open the folder in **Godot 4.5+**.
2. Press **▶ Run** — the project starts on a simple title screen.
3. Click **Start Simulation** to load the main view.
4. Use the **Next Generation** button to step through time.
5. After **two generations**, you may apply an antibiotic by clicking its button.
6. Observe:
	- Population size
	- Survivors after doses
	- Resistance-frequency graph (right side)
		

---

## 🧪 Simulation Flow

|Stage|What Happens|
|---|---|
|**Start**|100 randomly placed bacteria appear.|
|**Each “Next Generation” click**|Survivors asexually reproduce → population roughly doubles (up to 1000). Mutations may add new resistance genes.|
|**Antibiotic applied**|Every bacterium rolls a survival check. Non-resistant ones usually die; resistant ones survive and reproduce.|
|**Repeat**|Over successive doses, resistant strains dominate.|

---

## 💊 Antibiotic System

Defined in `antibiotics_config.gd`.

|Antibiotic|Color family|Notes|
|---|---|---|
|**Augmentin**|Lavender → Purple|Broad-spectrum reference drug|
|**Cephalexin-1**|Pink → Red|β-lactam type 1|
|**Cephalexin-2**|Peach → Rust|β-lactam type 2|
|**Tetracycline**|Yellow-green → Forest|Distinct mechanism|
|**Ciprofloxacin**|Sky → Navy|Fluoroquinolone|

**Cross-resistance:**  
Cephalexin-1 and Cephalexin-2 share partial cross-resistance (½ strength).  
When one is applied, resistance to the other contributes half its value to survival.

**Survival rule (in `organism.gd`):**

`death_chance = BASE_DEATH_CHANCE / 2^effective_resistance`

Base death chance = 0.8 (80%).  
Each resistance level halves the risk (0.8 → 0.4 → 0.2 → 0.1 …).

---

## 🧬 Genetic System

Implemented in `genetic_system.gd`.

|Process|Description|
|---|---|
|**Reproduction**|Asexual cloning of survivors each generation.|
|**Growth rule**|Population doubles each step (until cap = 1000).|
|**Mutation**|Each new bacterium has a 0.1 % chance per antibiotic to gain +1 resistance level.|
|**Inheritance**|Offspring copy the parent’s current resistances.|

Result: resistance genes slowly appear and spread only if they improve survival.

---

## 🦠 Organism System

Script: `organism.gd`  
Scene: `organism.tscn`

|Feature|Behavior|
|---|---|
|**Representation**|Simple 6–8 px colored `Sprite2D` dot.|
|**Data**|Dictionary of resistance levels per antibiotic.|
|**Mutation**|Randomly increases one resistance entry by +1.|
|**Color blending**|Each antibiotic’s color family contributes proportionally; multi-resistant cells appear mixed.|
|**Survival check**|Computes effective resistance including cross-links, then randomizes survival vs. death chance.|

---

## 📈 Graph System

Script: `graph_display.gd`
- Draws one colored line per antibiotic.
- Each frame of data = average resistance level across all bacteria.
- Stores up to 100 generations (scrolls left as new data arrive).
	

---

## ⚙️ Constants Summary

|Constant|File|Default|Meaning|
|---|---|---|---|
|`POPULATION_CAP`|main.gd|1000|Max bacteria visible|
|`START_POP`|main.gd|100|Initial population|
|`GENERATIONS_PER_DOSE`|main.gd|2|Wait before next antibiotic|
|`BASE_DEATH_CHANCE`|main.gd|0.8|Baseline kill rate|
|`MUTATION_RATE`|genetic_system.gd|0.001|Chance to gain new resistance|

---

## 🧑‍🏫 Teaching Ideas

- **Prediction:** Ask students which antibiotic will wipe out most of the population initially.
	
- **Observation:** Track how colors shift across generations.
	
- **Discussion:**
	- Why does population recover after each dose?
	- What happens if the same antibiotic is used repeatedly?
	- How does cross-resistance accelerate adaptation?
		
- **Extension:** Have students edit constants to explore mutation rates or stronger/weaker antibiotics.
	

---

## 🧰 Technical Notes

- Written entirely in **GDScript**, tab-indented.
- Fully self-contained; no external assets.
- Compatible with **Godot 4.5** (Forward+ renderer).
- Scene startup: `main_menu.tscn` → `main.tscn`.
---

**Created for educational use — freely modifiable for classroom experiments.**
# Antibiotic_sim
