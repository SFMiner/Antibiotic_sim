# CLAUDE.md - Project Context for AI Assistants

## Project Overview

**Zombie Defense: Evolution Simulator** is an educational simulation built in Godot 4.5 that demonstrates zombie population evolution through selection under ordnance pressure. It visualizes natural selection, random mutation, and the development of ordnance toughness in a population of zombies over multiple infection cycles.

The zombie theme is a vivid metaphor for how real pathogens (bacteria, viruses) develop resistance to treatments. Students observe the horde adapt to survive repeated strikes, directly mirroring how antibiotics face resistance in clinical settings.

**Purpose:** Educational tool for students to observe and understand evolutionary principles, specifically how selection pressure drives adaptation in populations.

**Technology:** Godot 4.5, GDScript, GL Compatibility renderer

---

## Project Architecture

### Core Systems

1. **Main Controller** (`main.gd`)
   - Manages simulation lifecycle and infection cycle advancement
   - Handles UI state and user interactions
   - Coordinates between genetic system, organisms, and visualization
   - Applies ordnance strikes and filters survivors
   - Tracks cycle-by-cycle statistics

2. **Zombie System** (`organism.gd`, `organism.tscn`)
   - Represents individual zombies as colored animated dots
   - Stores toughness levels for each ordnance type
   - Handles survival checks with cross-toughness logic
   - Updates visual appearance based on toughness profile
   - Color blending shows multi-tough phenotypes
   - Wandering behavior for visual engagement

3. **Genetic System (Infection Spread)** (`genetic_system.gd`)
   - Manages infection propagation (asexual cloning)
   - Implements mutation during infection
   - Population growth logic (doubling with cap)
   - Pure logic, no scene dependencies

4. **Ordnance Configuration** (`antibiotics_config.gd`)
   - Defines cross-toughness relationships
   - Shrapnel and Acid have 50% cross-toughness
   - Extensible structure for adding new ordnance interactions

5. **Graph Display** (`graph_display.gd`)
   - Real-time visualization of average toughness levels
   - Color-coded lines for each ordnance type
   - Stores up to 100 infection cycles of history
   - Automatically scrolls as simulation progresses

6. **Statistics Panel** (additions in `main.gd`)
   - Toggleable left-side panel tracking cycle data
   - Displays cycle-by-cycle zombie counts and strike casualties
   - Auto-scrolls to show latest recorded data

---

## File Structure

```
Zombie_Defense_Evolution/
├── main.gd                    # Main simulation controller
├── main.tscn                  # Main simulation scene
├── main_menu.tscn             # Title screen scene
├── organism.gd                # Zombie behavior script
├── organism.tscn              # Zombie scene (AnimatedSprite2D dot)
├── genetic_system.gd          # Infection spread and mutation logic
├── antibiotics_config.gd      # Cross-toughness configuration
├── graph_display.gd           # Toughness graph visualization
├── project.godot              # Godot project configuration
├── icon.svg                   # Project icon
├── blank transparent.png      # Transparent image asset
├── README.md                  # User-facing documentation
└── CLAUDE.md                  # This file - AI assistant context
```

---

## Key Constants and Configuration

### Main Simulation (`main.gd`)
- `POPULATION_CAP = 1000` - Maximum zombie horde size
- `START_POP = 400` - Initial zombie population
- `GENERATIONS_PER_DOSE = 2` - Infection cycles between ordnance strikes
- `BASE_DEATH_CHANCE = 0.8` - 80% casualty rate for non-tough zombies
- `SURVIVOR_DEFENSE = 15` - Random casualties per infection cycle (environmental attrition)

### Genetic System (`genetic_system.gd`)
- `MUTATION_RATE = 0.01` - 1% chance per new infected to gain toughness mutation

### Survival Mechanics (`organism.gd:68-74`)
Death chance formula:
```gdscript
death_chance = BASE_DEATH_CHANCE / pow(2.0, effective_toughness)
```
Each toughness level halves the death risk (0.8 → 0.4 → 0.2 → 0.1...)

---

## Data Structures

### Toughness Dictionary
Each zombie stores toughness to ordnance as:
```gdscript
resistances = {
    "Fire": 0,
    "Shrapnel": 0,
    "Acid": 0,
    "Electricity": 0,
    "Freeze": 0
}
```
Values are integers representing toughness levels (0 = no toughness, higher = more tough).

### Cross-Toughness Map
```gdscript
CROSS_TOUGHNESS = {
    "Shrapnel": [ { "target": "Acid", "factor": 0.5 } ],
    "Acid": [ { "target": "Shrapnel", "factor": 0.5 } ]
}
```
When calculating survival, related toughness contributes fractionally (cross-protection).

### Cycle Statistics Structure
```gdscript
cycle_stats = [
    {
        "cycle": int,
        "zombie_count": int,
        "strike": String or null,
        "killed": int
    }
]
```

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
- **Validation:** `is_instance_valid()` checks before accessing zombies
- **Memory management:** `queue_free()` for removing zombies from scene
- **Async operations:** `await` for scroll-to-bottom in stats display

---

## Ordnance System Details

### Available Ordnance Types
Each ordnance has:
- **Name:** Display text on strike button
- **Color family:** Visual representation on zombies
- **Toughness gene:** Separate entry in toughness dictionary
- **Cross-toughness:** Optional relationships with other ordnance types

### Color Families
Colors blend when zombies have multiple toughness levels:
```gdscript
"Fire": Color(0.90, 0.35, 0.20)        # Orange/red flames
"Shrapnel": Color(0.60, 0.60, 0.65)    # Gray metallic
"Acid": Color(0.40, 0.80, 0.30)        # Green bubbling
"Electricity": Color(0.30, 0.50, 0.95) # Blue crackling
"Freeze": Color(0.50, 0.75, 0.95)      # Icy blue
```
Base color is sickly greenish-gray zombie tone (0.75, 0.80, 0.75), lerped toward ordnance colors proportionally.

---

## Common Modification Tasks

### Adding a New Ordnance Type
1. **Update toughness dictionary** in `organism.gd:6-12`
   - Add new key-value pair with default 0
2. **Add color family** in `organism.gd:42-48`
   - Define color in `_update_color()` function
3. **Update graph colors** in `graph_display.gd:4-10`
   - Add matching color for visualization
4. **Add UI button** in `main.tscn`
   - Create new Button node in UI/Buttons
   - Connect signal in `main.gd:_ready()`
5. **Optional: Add cross-toughness** in `antibiotics_config.gd`

### Adjusting Simulation Parameters
- **Mutation rate:** Change `MUTATION_RATE` in `genetic_system.gd:7`
- **Horde dynamics:** Modify `POPULATION_CAP`, `START_POP` in `main.gd:4-6`
- **Strike strength:** Adjust `BASE_DEATH_CHANCE` in `main.gd:10`
- **Strike frequency:** Change `GENERATIONS_PER_DOSE` in `main.gd:8`
- **Natural attrition:** Modify `SURVIVOR_DEFENSE` in `main.gd:12`

### Modifying Survival Logic
The survival check is in `organism.gd:68-74`. Key factors:
1. Base toughness level for the applied ordnance
2. Cross-toughness contributions (additive with factor)
3. Exponential reduction of death chance
4. Random roll determines individual survival

---

## Scene Hierarchy

### main.tscn
```
Control (Main)
├── BacteriaLayer (Node2D) - Container for zombie instances
├── UI (CanvasLayer)
│   ├── TopPanel - Infection Cycle/Zombie Count/Last Strike labels
│   ├── Buttons - Next Cycle + Ordnance strike buttons
│   ├── GraphDisplay - Toughness visualization
│   ├── LeftPanel - Statistics tracking panel (toggleable)
│   └── TitlePage - Initial title screen
```

### organism.tscn
```
Node2D (Organism)
└── Sprite (AnimatedSprite2D) - Zombie sprite, modulated by toughness
```

---

## Simulation Flow

1. **Initialization:** 400 zombies spawn at random positions with zero toughness
2. **Infection Cycle Advance:**
   - Each surviving zombie infects new victims (cloning)
   - Horde roughly doubles (up to cap of 1000)
   - Each newly infected has 1% chance to gain +1 toughness in one random ordnance
   - Positions randomized
   - Graph updated
   - Statistics recorded
3. **Ordnance Strike Application:**
   - Each zombie rolls survival check
   - Death chance inversely proportional to toughness level
   - Non-survivors removed from scene
   - Strike casualties recorded in statistics
   - Survivors continue to next cycle
4. **Repeat:** Over time, tough strains dominate after repeated ordnance exposure

---

## Testing and Validation

### Expected Behaviors
- **Without strikes:** Horde grows exponentially to cap, colors stay mostly greenish-gray
- **Single ordnance:** Corresponding color should increase over cycles
- **Alternating ordnance:** Multiple colors emerge, multi-tough strains appear
- **Cross-toughness:** Using Shrapnel should partially select for Acid toughness
- **Statistics panel:** Should track all cycles and strikes with accurate casualty counts

### Edge Cases Handled
- **Zero population:** Reproduction returns empty array, simulation pauses
- **Invalid zombies:** `is_instance_valid()` checks prevent null reference errors
- **Cap enforcement:** Population size clamped in reproduction logic
- **Graph overflow:** History limited to 100 entries
- **Statistics accumulation:** Panel scrolls as new data arrives

---

## Performance Considerations

- **Zombie rendering:** Each zombie is an AnimatedSprite2D node (low overhead)
- **Population cap:** Hard limit of 1000 prevents runaway growth
- **Graph drawing:** Only redraws when population changes
- **Texture reuse:** Single animated sprite reused for all zombies
- **Position randomization:** Simple 2D coordinates, no physics engine
- **Async scrolling:** Statistics panel uses `await` to prevent frame stutters

---

## Educational Value

### Learning Objectives
- Observe natural selection in real-time
- Understand mutation as random, non-directed process
- Recognize selection pressure as driver of adaptation
- Explore trade-offs (cross-toughness vs. specificity)
- Predict outcomes based on strike patterns
- Connect evolutionary concepts to real-world resistance

### Zombie Theme Rationale
The zombie metaphor makes evolutionary concepts visceral and memorable:
- Students naturally engage with "horde survival"
- Ordnance "strikes" feel like antibiotic treatments
- Visible color changes mirror phenotypic adaptation
- Statistics panel mirrors epidemiological tracking
- Classroom discussions shift from abstract to concrete

### Extension Ideas
- Experiment with different mutation rates
- Test various strike application strategies
- Add fitness costs for toughness (slower infection)
- Implement strike cycling protocols
- Compare single vs. combination strikes
- Analyze statistics patterns for emergent behaviors

---

## Development Notes

- **Godot version:** 4.5+ required (uses modern GDScript syntax, async/await)
- **No external dependencies:** Self-contained simulation
- **Renderer:** GL Compatibility for broad device support
- **Entry point:** `main_menu.tscn` loads first, transitions to `main.tscn`
- **No persistence:** Simulation state resets on reload
- **No networking:** Single-player, local-only
- **Statistics:** Fully tracked in memory, persists for session

---

## Debugging Tips

### Common Issues
- **Zombies not visible:** Check `bacteria_layer` z-index and camera position
- **Horde not growing:** Verify `reproduce_population()` is called in `_next_generation()`
- **Graph not updating:** Ensure `queue_redraw()` is called after history changes
- **Buttons not working:** Check signal connections in `main.gd:_ready()`
- **Colors not changing:** Confirm `_update_color()` is called after mutation
- **Stats panel empty:** Check `_update_stats_display()` is called after cycles/strikes
- **Scroll not working:** Verify `ScrollContainer` is configured with vertical scrolling enabled

### Useful Debug Points
- Print horde size in `_update_ui()` to track growth
- Log survival rolls in `check_survival()` to verify death chance formula
- Output toughness levels before/after mutation
- Check `cycle_stats` array size and structure
- Monitor graph `history` array for overflow
- Verify stats panel visibility toggle state

---

## AI Assistant Guidelines

When working with this codebase:

1. **Respect the educational purpose** - Keep modifications pedagogically sound
2. **Maintain visual clarity** - Colors should remain distinguishable
3. **Preserve simulation accuracy** - Ensure evolutionary logic remains realistic
4. **Test with edge cases** - What happens at population 0, 1, or 1000?
5. **Document constants** - If changing parameters, explain educational impact
6. **Keep it self-contained** - Avoid external dependencies when possible
7. **Follow GDScript conventions** - Use tabs, static typing, Godot patterns
8. **Update statistics** - Any new cycles/strikes must update statistics tracking

### When Adding Features
- Consider impact on learning objectives
- Maintain performance with 1000+ organisms
- Update graph visualization if adding new toughness types
- Ensure UI remains uncluttered for classroom use
- Test across multiple generations for emergent behaviors
- Update statistics tracking if adding new strike types
- Maintain zombie theme consistency in terminology

---

**Last Updated:** 2025-10-28
**Godot Version:** 4.5+
**Target Audience:** Middle/High school students, Biology education
**Theme:** Zombie Defense: Evolution Simulator
