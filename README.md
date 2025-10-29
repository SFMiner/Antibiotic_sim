# 🧟 Zombie Defense: Evolution Simulator

_A Godot 4.5 project demonstrating evolutionary adaptation through zombie horde selection under ordnance pressure._

---

## 🎯 Overview

This simulation visualizes how zombie populations evolve toughness to different ordnance types through natural selection. Each dot represents a single zombie. Some carry mutations that make them tough to specific weapon types; others do not.

Students can advance infection cycles, deploy different ordnance strikes, and watch the zombie horde adapt and survive. This metaphor illustrates how real-world pathogens develop resistance through repeated exposure to selective pressures.

---

## ▶️ How to Run

1. Open the folder in **Godot 4.5+**.
2. Press **▶ Run** — the project starts on a simple title screen.
3. Click **Start Simulation** to load the main view.
4. Use the **Next Cycle** button to step through time.
5. After **two infection cycles**, you may apply an ordnance strike by clicking its button.
6. Observe:
	- Zombie count
	- Survivors after strikes
	- Toughness-frequency graph (upper left)
	- Statistics panel (left side, toggleable)


---

## 🧪 Simulation Flow

|Stage|What Happens|
|---|---|
|**Start**|400 randomly placed zombies appear.|
|**Each "Next Cycle" click**|Surviving zombies infect new victims → horde roughly doubles (up to 1000). Mutations may add new toughness to different ordnance types.|
|**Ordnance strike applied**|Every zombie rolls a survival check. Non-tough ones usually perish; tough ones survive to infect more victims.|
|**Repeat**|Over successive strikes, tough strains dominate the horde.|

---

## 💣 Ordnance System

Defined in `antibiotics_config.gd`.

|Ordnance Type|Color Family|Toughness Effect|
|---|---|---|
|**Fire**|Orange/Red|Combustion-based weapon, pure attack|
|**Shrapnel**|Gray Metallic|Projectile weapon, partial cross-toughness with Acid|
|**Acid**|Green Bubbling|Chemical corrosive weapon, partial cross-toughness with Shrapnel|
|**Electricity**|Blue Crackling|Energy-based weapon, pure attack|
|**Freeze**|Icy Blue|Cryogenic weapon, pure attack|

**Cross-toughness:**
Shrapnel and Acid share partial cross-toughness (½ strength).
When one is applied, toughness to the other contributes half its value to survival.

**Survival rule (in `organism.gd`):**

`death_chance = BASE_DEATH_CHANCE / 2^effective_toughness`

Base death chance = 0.8 (80%).
Each toughness level halves the risk (0.8 → 0.4 → 0.2 → 0.1 …).

---

## 🧬 Genetic System (Infection Spread)

Implemented in `genetic_system.gd`.

|Process|Description|
|---|---|
|**Infection Spread**|Asexual propagation of surviving zombies each cycle.|
|**Growth rule**|Horde doubles each cycle (until cap = 1000).|
|**Mutation**|Each newly infected victim has 1% chance to randomly gain +1 toughness to one ordnance type.|
|**Inheritance**|Offspring inherit the parent's current toughness levels.|

Result: toughness mutations slowly appear and spread only if they improve survival against applied strikes.

---

## 🧟 Zombie System

Script: `organism.gd`
Scene: `organism.tscn`

|Feature|Behavior|
|---|---|
|**Representation**|Simple 6–8 px colored `AnimatedSprite2D` dot.|
|**Data**|Dictionary of toughness levels per ordnance type.|
|**Mutation**|Randomly increases one toughness entry by +1.|
|**Color blending**|Each ordnance's color family contributes proportionally; multi-tough zombies appear mixed colors.|
|**Survival check**|Computes effective toughness including cross-resistance, then randomizes survival vs. death chance.|
|**Wandering behavior**|Zombies patrol within their spawn area, adding visual liveliness.|

---

## 📈 Graph System

Script: `graph_display.gd`
- Draws one colored line per ordnance type.
- Each data point = average toughness level across the zombie horde.
- Stores up to 100 infection cycles (scrolls left as new data arrive).

---

## 📊 Statistics Tracking Panel

Script additions in `main.gd`
- Toggleable statistics panel on the left side.
- Displays cycle-by-cycle breakdown:
	- Infection cycle number
	- Zombie count per cycle
	- Ordnance strikes applied
	- Casualties from each strike
- Auto-scrolls to bottom to show latest data.

---

## ⚙️ Constants Summary

|Constant|File|Default|Meaning|
|---|---|---|---|
|`POPULATION_CAP`|main.gd|1000|Max zombie horde size|
|`START_POP`|main.gd|400|Initial zombie population|
|`GENERATIONS_PER_DOSE`|main.gd|2|Cycles between ordnance strikes|
|`BASE_DEATH_CHANCE`|main.gd|0.8|Baseline casualty rate per strike|
|`SURVIVOR_DEFENSE`|main.gd|15|Random zombie casualties per cycle (natural attrition)|
|`MUTATION_RATE`|genetic_system.gd|0.01|Chance to gain new toughness mutation|

---

## 🧑‍🏫 Teaching Ideas

**Zombie Analogy for Evolution:**
This simulation uses zombies as a vivid metaphor for how pathogens (bacteria, viruses) develop resistance. The "strikes" represent antibiotics or immune challenges. Just as we observe the horde adapt to survive repeated ordnance, real pathogens evolve defenses against medications and host immunity. The zombie theme engages students' attention while teaching rigorous evolutionary concepts.

**Discussion Prompts:**
- **Prediction:** Which ordnance strike will eliminate the most zombies initially? Why?
- **Observation:** How do the colors shift across generations? What does that tell you?
- **Analysis:**
	- Why does the horde recover so quickly after a strike?
	- What happens if you use the same ordnance repeatedly?
	- How does cross-toughness (Shrapnel ↔ Acid) speed up adaptation?
- **Experimentation:** Edit constants to explore mutation rates, strike timing, or horde size effects.
- **Real-World Connection:** How does this model actual antibiotic resistance in hospitals or agriculture?

---

## 🧰 Technical Notes

- Written entirely in **GDScript**, tab-indented.
- Fully self-contained; no external assets required.
- Compatible with **Godot 4.5+** (GL Compatibility renderer).
- Scene startup: `main_menu.tscn` → `main.tscn`.
- Statistics system uses asynchronous updates for smooth performance.

---

**Created for educational use — freely modifiable for classroom experiments.**
