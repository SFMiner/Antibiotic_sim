# CLAUDE.md - Project Context for AI Assistants

## Project Overview

**Antibiotic Resistance Simulator** is an educational simulation built in Godot 4.5 that demonstrates bacterial evolution under antibiotic pressure. It visualizes natural selection, random mutation, and the development of antibiotic resistance in a population of bacteria over multiple generations.

**Purpose:** Educational tool for students to observe and understand evolutionary principles, specifically how selection pressure drives adaptation in populations.

**Technology:** Godot 4.5, GDScript, GL Compatibility renderer

---

## Project Architecture

### Core Systems

1. **Main Controller** (`main.gd`)
   - Manages simulation lifecycle and generation advancement
   - Handles UI state and user interactions
   - Coordinates between genetic system, organisms, and visualization
   - Applies antibiotics and filters survivors

2. **Organism System** (`organism.gd`, `organism.tscn`)
   - Represents individual bacteria as colored dots
   - Stores resistance levels for each antibiotic
   - Handles survival checks with cross-resistance logic
   - Updates visual appearance based on resistance profile
   - Color blending shows multi-resistant phenotypes

3. **Genetic System** (`genetic_system.gd`)
   - Manages asexual reproduction (cloning)
   - Implements mutation during reproduction
   - Population growth logic (doubling with cap)
   - Pure logic, no scene dependencies

4. **Antibiotic Configuration** (`antibiotics_config.gd`)
   - Defines cross-resistance relationships
   - Cephalexin-1 and Cephalexin-2 have 50% cross-resistance
   - Extensible structure for adding new antibiotic interactions

5. **Graph Display** (`graph_display.gd`)
   - Real-time visualization of average resistance levels
   - Color-coded lines for each antibiotic
   - Stores up to 100 generations of history
   - Automatically scrolls as simulation progresses

---

## File Structure

```
antibiotics-sim/
├── main.gd                    # Main simulation controller
├── main.tscn                  # Main simulation scene
├── main_menu.tscn             # Title screen scene
├── organism.gd                # Bacteria behavior script
├── organism.tscn              # Bacteria scene (Sprite2D dot)
├── genetic_system.gd          # Reproduction and mutation logic
├── antibiotics_config.gd      # Cross-resistance configuration
├── graph_display.gd           # Resistance graph visualization
├── project.godot              # Godot project configuration
├── icon.svg                   # Project icon
├── blank transparent.png      # Transparent image asset
└── README.md                  # User-facing documentation
```

---

## Key Constants and Configuration

### Main Simulation (`main.gd`)
- `POPULATION_CAP = 1000` - Maximum number of bacteria
- `START_POP = 100` - Initial population size
- `GENERATIONS_PER_DOSE = 2` - Cooldown between antibiotic applications
- `BASE_DEATH_CHANCE = 0.8` - 80% kill rate for non-resistant bacteria

### Genetic System (`genetic_system.gd`)
- `MUTATION_RATE = 0.01` - 1% chance per offspring to gain resistance mutation

### Survival Mechanics (`organism.gd:25-31`)
Death chance formula:
```gdscript
death_chance = BASE_DEATH_CHANCE / pow(2.0, effective_resistance)
```
Each resistance level halves the death risk (0.8 → 0.4 → 0.2 → 0.1...)

---

## Data Structures

### Resistance Dictionary
Each organism stores resistance as:
```gdscript
resistances = {
    "Augmentin": 0,
    "Cephalexin-1": 0,
    "Cephalexin-2": 0,
    "Tetracycline": 0,
    "Ciprofloxacin": 0
}
```
Values are integers representing resistance levels (0 = no resistance, higher = more resistant)

### Cross-Resistance Map
```gdscript
CROSS_RESIST = {
    "Cephalexin-1": [ { "target": "Cephalexin-2", "factor": 0.5 } ],
    "Cephalexin-2": [ { "target": "Cephalexin-1", "factor": 0.5 } ]
}
```
When calculating survival, related resistances contribute fractionally.

---

## Code Conventions

### Style
- **Language:** GDScript (Godot 4.x syntax)
- **Indentation:** Tabs (standard Godot convention)
- **Typing:** Static typing used throughout (`: Type` annotations)
- **Constants:** SCREAMING_SNAKE_CASE
- **Variables:** snake_case
- **Functions:** snake_case with leading underscore for private methods

### Patterns
- **Node references:** `@onready var` for scene tree nodes
- **Preloading:** Resources preloaded as constants
- **Signal connections:** Lambda functions for simple button handlers
- **Validation:** `is_instance_valid()` checks before accessing organisms
- **Memory management:** `queue_free()` for removing bacteria from scene

---

## Antibiotic System Details

### Available Antibiotics
Each antibiotic has:
- **Name:** Display text on button
- **Color family:** Visual representation on bacteria
- **Resistance gene:** Separate entry in resistance dictionary
- **Cross-resistance:** Optional relationships with other antibiotics

### Color Families
Colors blend when bacteria have multiple resistances:
```gdscript
"Augmentin": Color(0.55, 0.35, 0.70)      # Lavender → Purple
"Cephalexin-1": Color(0.90, 0.25, 0.35)   # Pink → Red
"Cephalexin-2": Color(0.85, 0.45, 0.20)   # Peach → Rust
"Tetracycline": Color(0.55, 0.75, 0.30)   # Yellow-green → Forest
"Ciprofloxacin": Color(0.30, 0.55, 0.90)  # Sky → Navy
```
Base color is light gray (0.82, 0.82, 0.82), lerped toward antibiotic colors proportionally.

---

## Common Modification Tasks

### Adding a New Antibiotic
1. **Update resistance dictionary** in `organism.gd:5-11`
   - Add new key-value pair with default 0
2. **Add color family** in `organism.gd:41-47`
   - Define color in `_update_color()` function
3. **Update graph colors** in `graph_display.gd:3-9`
   - Add matching color for visualization
4. **Add UI button** in `main.tscn`
   - Create new Button node in UI/Buttons
   - Connect signal in `main.gd:_ready()`
5. **Optional: Add cross-resistance** in `antibiotics_config.gd:3-6`

### Adjusting Simulation Parameters
- **Mutation rate:** Change `MUTATION_RATE` in `genetic_system.gd:3`
- **Population dynamics:** Modify `POPULATION_CAP`, `START_POP` in `main.gd:3-4`
- **Antibiotic strength:** Adjust `BASE_DEATH_CHANCE` in `main.gd:6`
- **Dosing frequency:** Change `GENERATIONS_PER_DOSE` in `main.gd:5`

### Modifying Survival Logic
The survival check is in `organism.gd:25-31`. Key factors:
1. Base resistance level for the applied antibiotic
2. Cross-resistance contributions (additive with factor)
3. Exponential reduction of death chance
4. Random roll determines individual survival

---

## Scene Hierarchy

### main.tscn
```
Control (Main)
├── BacteriaLayer (Node2D) - Container for organism instances
├── UI (Control)
│   ├── TopPanel - Generation/Population/Dose labels
│   ├── Buttons - Next Gen + Antibiotic buttons
│   ├── GraphDisplay - Resistance visualization
│   └── TitlePage - Initial start screen
```

### organism.tscn
```
Node2D (Organism)
└── Sprite (Sprite2D) - 6x6 pixel white dot, modulated by resistance
```

---

## Simulation Flow

1. **Initialization:** 100 bacteria spawn at random positions with zero resistances
2. **Generation Advance:**
   - Each survivor asexually clones itself
   - Population doubles (up to cap)
   - Each offspring has 1% chance to gain +1 resistance in one random antibiotic
   - Positions randomized
   - Graph updated
3. **Antibiotic Application:**
   - Each bacterium rolls survival check
   - Death chance inversely proportional to resistance level
   - Non-survivors removed from scene
   - Survivors continue to next generation
4. **Repeat:** Over time, resistant strains dominate after repeated antibiotic exposure

---

## Testing and Validation

### Expected Behaviors
- **Without antibiotics:** Population grows exponentially to cap, colors stay mostly gray
- **Single antibiotic:** Corresponding color should increase over generations
- **Alternating antibiotics:** Multiple colors emerge, multi-resistant strains appear
- **Cross-resistance:** Using Cephalexin-1 should partially select for Cephalexin-2 resistance

### Edge Cases Handled
- **Zero population:** Reproduction returns empty array, simulation can't recover
- **Invalid organisms:** `is_instance_valid()` checks prevent null reference errors
- **Cap enforcement:** Population size clamped in reproduction logic
- **Graph overflow:** History limited to 100 entries

---

## Performance Considerations

- **Organism rendering:** Each bacterium is a simple Sprite2D node (low overhead)
- **Population cap:** Hard limit of 1000 prevents runaway growth
- **Graph drawing:** Only redraws when population changes
- **Texture caching:** Single 6x6 white texture reused for all bacteria
- **Position randomization:** Simple 2D coordinates, no physics engine

---

## Educational Value

### Learning Objectives
- Observe natural selection in real-time
- Understand mutation as random, non-directed process
- Recognize selection pressure as driver of adaptation
- Explore trade-offs (cross-resistance vs. specificity)
- Predict outcomes based on antibiotic usage patterns

### Extension Ideas
- Experiment with different mutation rates
- Test various antibiotic application strategies
- Add fitness costs for resistance (slower reproduction)
- Implement antibiotic cycling protocols
- Compare single vs. combination therapy

---

## Development Notes

- **Godot version:** 4.5+ required (uses modern GDScript syntax)
- **No external dependencies:** Self-contained simulation
- **Renderer:** GL Compatibility for broad device support
- **Entry point:** `main_menu.tscn` loads first, transitions to `main.tscn`
- **No persistence:** Simulation state resets on reload
- **No networking:** Single-player, local-only

---

## Debugging Tips

### Common Issues
- **Bacteria not visible:** Check `bacteria_layer` z-index and camera position
- **Population not growing:** Verify `reproduce_population()` is called in `_next_generation()`
- **Graph not updating:** Ensure `queue_redraw()` is called after history changes
- **Buttons not working:** Check signal connections in `main.gd:_ready()`
- **Colors not changing:** Confirm `_update_color()` is called after mutation

### Useful Debug Points
- Print population size in `_update_ui()` to track growth
- Log survival rolls in `check_survival()` to verify death chance formula
- Output resistance levels before/after mutation
- Check `history` array size in graph display

---

## AI Assistant Guidelines

When working with this codebase:

1. **Respect the educational purpose** - Keep modifications pedagogically sound
2. **Maintain visual clarity** - Colors should remain distinguishable
3. **Preserve simulation accuracy** - Ensure biology logic remains realistic
4. **Test with edge cases** - What happens at population 0, 1, or 1000?
5. **Document constants** - If changing parameters, explain educational impact
6. **Keep it self-contained** - Avoid external dependencies when possible
7. **Follow GDScript conventions** - Use tabs, static typing, Godot patterns

### When Adding Features
- Consider impact on learning objectives
- Maintain performance with 1000+ organisms
- Update graph visualization if adding new resistance types
- Ensure UI remains uncluttered for classroom use
- Test across multiple generations for emergent behaviors

---

**Last Updated:** 2025-10-14
**Godot Version:** 4.5
**Target Audience:** Middle/High school students, Biology education
