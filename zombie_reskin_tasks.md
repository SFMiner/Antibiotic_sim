# Zombie Reskin - Haiku Task List

## PHASE 1: Core Terminology & Data Structure Changes
**Goal:** Update all internal references from bacteria/antibiotic to zombie/ordnance terminology

### Task 1.1: Update antibiotics_config.gd terminology
**Dependencies:** None
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. Rename dictionary keys from antibiotic names to ordnance names:
   - "Augmentin" → "Fire"
   - "Cephalexin-1" → "Shrapnel"
   - "Cephalexin-2" → "Acid"
   - "Tetracycline" → "Electricity"
   - "Ciprofloxacin" → "Freeze"
2. Update cross-resistance mapping to reflect Shrapnel ↔ Acid relationship
3. Add comments explaining ordnance types and cross-resistance logic
4. Update constant name if needed (CROSS_RESIST → CROSS_TOUGHNESS or similar)

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify file compiles without errors
- [ ] Check that cross-resistance still maps Shrapnel ↔ Acid with 0.5 factor
- [ ] Confirm comments clearly explain ordnance relationships

---

### Task 1.2: Update organism.gd resistance dictionary and terminology
**Dependencies:** Task 1.1
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. Update the resistances dictionary keys to match new ordnance names:
   ```gdscript
   var resistances = {
   	"Fire": 0,
   	"Shrapnel": 0,
   	"Acid": 0,
   	"Electricity": 0,
   	"Freeze": 0
   }
   ```
2. Add comment above dictionary: `# Toughness levels for each ordnance type`
3. Update all comments in the file:
   - "resistance" → "toughness"
   - "antibiotic" → "ordnance"
   - "bacteria" → "zombie"
4. Update function names if they reference antibiotics (keep internal logic same)
5. Update `check_survival()` parameter name: `antibiotic` → `ordnance`

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify file compiles without errors
- [ ] Check that resistances dictionary has all 5 ordnance types
- [ ] Confirm comments use zombie/ordnance terminology

---

### Task 1.3: Update main.gd constants and variable names
**Dependencies:** Task 1.2
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. Update constant comments to use zombie terminology
2. Rename `IMMUNE_RESPONSE` → `SURVIVOR_DEFENSE` (or keep name but update comment)
3. Update variable names:
   - `last_dose_gen` can stay but add comment `# Last strike cycle`
   - `population` can stay but add comment `# Zombie horde`
4. Update all inline comments to use zombie/ordnance language
5. Update function comments for `_apply_antibiotic()` and `_apply_immune_response()`
6. Update the `_apply_antibiotic()` function parameter: `name: String` comment to indicate ordnance type

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify file compiles without errors
- [ ] Check that all comments use zombie terminology
- [ ] Confirm function logic unchanged (only comments/names changed)

---

### Task 1.4: Update genetic_system.gd terminology
**Dependencies:** None (can run parallel with other tasks)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. Update all comments to use zombie terminology:
   - "bacteria" → "zombie"
   - "survivors" → "surviving zombies"
   - "population" → "horde"
   - "children" → "infected victims" or "new zombies"
2. Add comment at top explaining the infection spread mechanic
3. Update function comments for `reproduce_population()` to explain zombie infection
4. Keep variable names the same (survivors, new_pop, etc.) for code clarity

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify file compiles without errors
- [ ] Check that comments tell a clear zombie infection story
- [ ] Confirm no logic changes, only comment updates

---

## PHASE 2: Visual Changes (Sprite & Colors)
**Goal:** Replace bacteria dots with zombie sprites and update color scheme to match ordnance types

### Task 2.1: Prepare for zombie sprite integration
**Dependencies:** Task 1.2 (organism.gd updated)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `organism.gd`, update the `_ready()` function to prepare for external sprite:
   - Keep the fallback texture creation (6x6 white dot) for testing
   - Add comment: `# TODO: Human will provide zombie sprite sheet`
2. Ensure sprite node reference is correct: `@onready var sprite: Sprite2D = $Sprite`
3. Add placeholder for future sprite sheet handling (commented out):
   ```gdscript
   # When zombie sprite is provided:
   # sprite.texture = preload("res://assets/zombie_sprite.png")
   # sprite.hframes = X  # Set based on sprite sheet
   # sprite.frame = 0    # Default frame
   ```

**Human Checkpoint:** When done, remind the user to:
- [ ] Test that current white dots still render correctly
- [ ] Prepare to add zombie sprite sheet to `res://assets/` folder
- [ ] Verify sprite node structure is ready for sprite sheet

---

### Task 2.2: Update color scheme for ordnance types
**Dependencies:** Task 1.2 (organism.gd resistances updated)
**Extended thinking:** ON
**Reminder:** Ask human - "Is extended thinking turned on? It should be ON for this task."

**Implementation:**
1. In `organism.gd`, update the `_update_color()` function's color families:
   ```gdscript
   var fam = {
   	"Fire": Color(0.90, 0.35, 0.20),        # Orange/red flames
   	"Shrapnel": Color(0.60, 0.60, 0.65),    # Gray metallic
   	"Acid": Color(0.40, 0.80, 0.30),        # Green bubbling
   	"Electricity": Color(0.30, 0.50, 0.95),  # Blue crackling
   	"Freeze": Color(0.50, 0.75, 0.95)       # Icy blue
   }
   ```
2. Update base color from gray to a slightly greenish zombie tone:
   ```gdscript
   var total = Color(0.75, 0.80, 0.75) # base sickly greenish-gray
   ```
3. Update comments to explain ordnance resistance visual indicators
4. Test color blending to ensure multi-resistant zombies look distinct

**Human Checkpoint:** When done, remind the user to:
- [ ] Run the game and verify base zombies look greenish-gray
- [ ] Apply different ordnances and check color changes are visible
- [ ] Test multi-resistant zombies show color blending
- [ ] Verify colors are distinguishable (including color-blind test if possible)

---

### Task 2.3: Update graph_display.gd colors
**Dependencies:** Task 1.1 (antibiotics_config.gd updated)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. Update the COLORS constant in `graph_display.gd`:
   ```gdscript
   const COLORS = {
   	"Fire": Color(0.9, 0.4, 0.3),
   	"Shrapnel": Color(0.6, 0.6, 0.65),
   	"Acid": Color(0.5, 0.8, 0.4),
   	"Electricity": Color(0.4, 0.6, 0.95),
   	"Freeze": Color(0.5, 0.75, 0.95)
   }
   ```
2. Update comments to reference ordnance types instead of antibiotics
3. Ensure these colors match (or are slightly brighter than) the organism colors for consistency

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify file compiles without errors
- [ ] Run game and check graph shows all 5 colored lines
- [ ] Confirm graph colors match ordnance button colors
- [ ] Test that graph updates correctly after strikes

---

## PHASE 3: UI Reskin
**Goal:** Update all visible UI elements to match zombie defense theme

### Task 3.1: Update main scene title and info text
**Dependencies:** None (can run parallel)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `main.tscn`, update the Title label text:
   - Old: "Antibiotic Resistance Simulator"
   - New: "Zombie Defense: Evolution Simulator"
2. Update the Info label text to explain zombie mechanics:
   ```
   Watch how zombie hordes evolve toughness to ordnance.
   Strikes can be applied every 2 infection cycles.
   Each color shows toughness to a different weapon type.
   Click Start to begin.
   ```
3. Update StartButton text if needed (currently "Start Simulation" is fine)

**Human Checkpoint:** When done, remind the user to:
- [ ] Open project in Godot editor
- [ ] Verify title screen shows new text
- [ ] Check that info text is clear and fits in the label
- [ ] Ensure text is readable and properly aligned

---

### Task 3.2: Update ordnance button labels and layout
**Dependencies:** Task 1.1 (ordnance names defined)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `main.tscn`, update button text labels in UI/Buttons:
   - AugmentinButton → "Fire Strike"
   - Ceph1Button → "Shrapnel Bomb"
   - Ceph2Button → "Acid Rain"
   - TetraButton → "EMP Blast"
   - CiproButton → "Cryo Bomb"
2. Update button modulate colors to match ordnance themes (already mostly done, verify):
   - Fire: Orange/red tone
   - Shrapnel: Gray metallic
   - Acid: Green
   - Electricity: Blue
   - Freeze: Icy blue
3. Update node names in scene tree to match (optional but recommended):
   - AugmentinButton → FireButton
   - Ceph1Button → ShrapnelButton
   - Ceph2Button → AcidButton
   - TetraButton → ElectricityButton
   - CiproButton → FreezeButton

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify all button labels show new ordnance names
- [ ] Check button colors match ordnance themes
- [ ] Test button click functionality (should still work)
- [ ] Confirm button layout and spacing looks good

---

### Task 3.3: Update top panel labels
**Dependencies:** None (can run parallel)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `main.gd`, update the `_update_ui()` function:
   ```gdscript
   func _update_ui():
   	gen_label.text = "Infection Cycle: %d" % generation
   	pop_label.text = "Zombie Count: %d" % population.size()
   ```
2. Update the label update in `_apply_antibiotic()`:
   ```gdscript
   dose_label.text = "Last Strike: %s" % name
   ```
3. Update initial label text in `_ready()` if needed

**Human Checkpoint:** When done, remind the user to:
- [ ] Run game and verify labels show new terminology
- [ ] Check that labels update correctly during gameplay
- [ ] Advance cycles and apply strikes to test all label updates
- [ ] Verify text fits in label areas without overflow

---

### Task 3.4: Update "Next Generation" button
**Dependencies:** None (can run parallel)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `main.tscn`, update NextGenButton text:
   - Old: "Next Generation"
   - New: "Next Infection Cycle" or "Time Passes"
   - Recommended: "Next Cycle" (shorter, clearer)
2. Adjust button size if needed to fit new text
3. Keep button functionality unchanged

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify button shows new text
- [ ] Check that text fits on button without wrapping
- [ ] Test button still advances cycle correctly
- [ ] Confirm button placement looks good

---

## PHASE 4: Statistics Tracking Panel
**Goal:** Add collapsible panel on left side showing cycle-by-cycle zombie counts and strike casualties

### Task 4.1: Create statistics tracking data structure
**Dependencies:** Task 3.3 (label updates working)
**Extended thinking:** ON
**Reminder:** Ask human - "Is extended thinking turned on? It should be ON for this task."

**Implementation:**
1. In `main.gd`, add new data structure to track statistics:
   ```gdscript
   var cycle_stats: Array = []  # Array of dictionaries with cycle data
   ```
2. Create stats dictionary structure:
   ```gdscript
   # Each entry: {
   #   "cycle": int,
   #   "zombie_count": int,
   #   "strike": String or null,
   #   "killed": int
   # }
   ```
3. Update `_next_generation()` to record cycle data:
   - Add entry with current cycle number and zombie count
   - Set strike to null and killed to 0
4. Update `_apply_antibiotic()` to record strike data:
   - Update most recent cycle_stats entry
   - Set strike name and killed count

**Human Checkpoint:** When done, remind the user to:
- [ ] Add debug print to verify cycle_stats array populates correctly
- [ ] Run game for several cycles and check printed data
- [ ] Apply strikes and verify killed counts are recorded
- [ ] Confirm data structure is ready for UI display

---

### Task 4.2: Create statistics panel UI structure
**Dependencies:** Task 4.1 (data structure ready)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `main.tscn`, create new UI structure:
   ```
   UI (CanvasLayer)
   └── LeftPanel (PanelContainer) - new
       └── VBoxContainer - new
           ├── ToggleButton (Button) - "Show/Hide Stats"
           └── StatsScroll (ScrollContainer)
               └── StatsLabel (Label)
   ```
2. Position LeftPanel:
   - Anchor left side of screen
   - Below TopPanel
   - Set reasonable width (200-250 pixels)
3. Configure ScrollContainer:
   - Enable vertical scroll
   - Set minimum size
4. Configure StatsLabel:
   - Set to expand
   - Enable autowrap if needed
   - Use monospace font if available

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify panel appears on left side of screen
- [ ] Check that toggle button is visible and clickable
- [ ] Test scroll container with placeholder text
- [ ] Confirm panel doesn't overlap with zombies or other UI

---

### Task 4.3: Implement statistics panel toggle functionality
**Dependencies:** Task 4.2 (UI structure created)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `main.gd`, add node references:
   ```gdscript
   @onready var stats_panel: PanelContainer = $UI/LeftPanel
   @onready var stats_toggle: Button = $UI/LeftPanel/VBoxContainer/ToggleButton
   @onready var stats_scroll: ScrollContainer = $UI/LeftPanel/VBoxContainer/StatsScroll
   @onready var stats_label: Label = $UI/LeftPanel/VBoxContainer/StatsScroll/StatsLabel
   ```
2. Add toggle functionality in `_ready()`:
   ```gdscript
   stats_toggle.pressed.connect(_toggle_stats_panel)
   stats_scroll.visible = false  # Start collapsed
   ```
3. Implement toggle function:
   ```gdscript
   func _toggle_stats_panel():
   	stats_scroll.visible = !stats_scroll.visible
   	stats_toggle.text = "Hide Stats" if stats_scroll.visible else "Show Stats"
   ```

**Human Checkpoint:** When done, remind the user to:
- [ ] Test toggle button shows/hides scroll container
- [ ] Verify button text changes between "Show Stats" and "Hide Stats"
- [ ] Check that panel starts collapsed
- [ ] Confirm toggle functionality is smooth

---

### Task 4.4: Implement statistics label update function
**Dependencies:** Task 4.1 (data structure), Task 4.3 (UI references)
**Extended thinking:** ON
**Reminder:** Ask human - "Is extended thinking turned on? It should be ON for this task."

**Implementation:**
1. In `main.gd`, create function to format statistics:
   ```gdscript
   func _update_stats_display():
   	var text = "=== INFECTION LOG ===\n\n"
   	for stat in cycle_stats:
   		text += "Cycle %d: %d zombies\n" % [stat["cycle"], stat["zombie_count"]]
   		if stat["strike"] != null:
   			text += "  → Strike: %s\n" % stat["strike"]
   			text += "  → Eliminated: %d\n" % stat["killed"]
   		text += "\n"
   	stats_label.text = text
   ```
2. Call `_update_stats_display()` at end of `_next_generation()`
3. Call `_update_stats_display()` at end of `_apply_antibiotic()`
4. Consider adding scroll-to-bottom functionality:
   ```gdscript
   await get_tree().process_frame
   stats_scroll.scroll_vertical = stats_scroll.get_v_scroll_bar().max_value
   ```

**Human Checkpoint:** When done, remind the user to:
- [ ] Run game and open stats panel
- [ ] Advance several cycles and verify counts appear
- [ ] Apply strikes and verify casualties are recorded
- [ ] Check that scroll auto-scrolls to bottom (or manually scroll to verify)
- [ ] Test with 10+ cycles to ensure scroll works properly

---

## PHASE 5: Documentation Updates
**Goal:** Update all documentation to reflect zombie theme and new terminology

### Task 5.1: Update README.md with zombie theme
**Dependencies:** All gameplay tasks complete (Phase 1-4)
**Extended thinking:** ON
**Reminder:** Ask human - "Is extended thinking turned on? It should be ON for this task."

**Implementation:**
1. Update title and overview section:
   - Change project name to "Zombie Defense: Evolution Simulator"
   - Rewrite overview to explain zombie infection and adaptation
2. Update "How to Run" section (minimal changes needed)
3. Rewrite "Simulation Flow" table:
   - Replace bacteria → zombies
   - Replace antibiotics → ordnance strikes
   - Explain infection spread mechanic
4. Update "Antibiotic System" section → "Ordnance System":
   - Replace all 5 antibiotics with ordnance types
   - Update color family descriptions
   - Keep cross-resistance explanation (Shrapnel ↔ Acid)
   - Update survival rule explanation
5. Update "Genetic System" section:
   - Change "reproduction" to "infection spread"
   - Explain how survivors infect new victims
   - Keep mutation mechanics explanation
6. Update "Organism System" section → "Zombie System":
   - Replace bacteria references with zombies
   - Update color blending explanation
7. Update "Constants Summary" table with new terminology
8. Rewrite "Teaching Ideas" section:
   - Add the zombie analogy you used in class
   - Update discussion questions to use zombie context
   - Keep core evolutionary concepts

**Human Checkpoint:** When done, remind the user to:
- [ ] Read through entire README
- [ ] Verify no "bacteria" or "antibiotic" references remain
- [ ] Check that zombie analogy is clear and pedagogically sound
- [ ] Test that code examples still make sense in context
- [ ] Confirm teaching ideas align with classroom goals

---

### Task 5.2: Update CLAUDE.md context document
**Dependencies:** Task 5.1 (README updated)
**Extended thinking:** ON
**Reminder:** Ask human - "Is extended thinking turned on? It should be ON for this task."

**Implementation:**
1. Update "Project Overview" section:
   - Change title to "Zombie Defense: Evolution Simulator"
   - Rewrite purpose to reflect zombie theme
   - Update educational context
2. Update "Core Systems" descriptions:
   - Main Controller: Update terminology
   - Organism System → Zombie System: Rewrite description
   - Update all bullet points to use zombie/ordnance language
3. Update "Key Constants and Configuration" section:
   - Update constant names and descriptions
   - Update survival mechanics formula explanation
4. Update "Data Structures" section:
   - Rename "Resistance Dictionary" → "Toughness Dictionary"
   - Update "Cross-Resistance Map" → "Cross-Toughness Map"
5. Update "Antibiotic System Details" → "Ordnance System Details"
6. Update "Common Modification Tasks" section:
   - "Adding a New Antibiotic" → "Adding a New Ordnance Type"
   - Update all step descriptions
7. Update "Simulation Flow" section with zombie terminology
8. Update "Educational Value" section:
   - Add zombie analogy explanation
   - Update learning objectives to mention zombie context
9. Update file modification dates and version info at bottom

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify document accurately reflects new zombie theme
- [ ] Check that all technical details remain accurate
- [ ] Confirm AI assistant guidelines still make sense
- [ ] Test that document serves as good context for future Claude sessions

---

### Task 5.3: Update project.godot metadata
**Dependencies:** None (can run anytime)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. In `project.godot`, update project name:
   ```
   config/name="Zombie_Defense_Evolution"
   ```
2. Keep other settings unchanged (scene paths, renderer, etc.)
3. Consider updating description if one exists

**Human Checkpoint:** When done, remind the user to:
- [ ] Verify project opens correctly after change
- [ ] Check that window title shows new name when running
- [ ] Confirm no other project settings were affected

---

## PHASE 6: Final Testing & Polish
**Goal:** Comprehensive testing to ensure all changes work together

### Task 6.1: Add human sprite integration instructions
**Dependencies:** Task 2.1 (sprite prep complete)
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. Create a new file `SPRITE_INTEGRATION.md` with instructions:
   - Expected sprite format (PNG, size, layout)
   - Where to place file (`res://assets/zombie_sprite.png`)
   - Code changes needed in `organism.gd` to load sprite
   - Testing steps after sprite added
2. Include code snippet for human to uncomment in `organism.gd`:
   ```gdscript
   # Uncomment these lines after adding zombie sprite:
   # sprite.texture = preload("res://assets/zombie_sprite.png")
   # If using sprite sheet:
   # sprite.hframes = 1  # Adjust if multiple frames
   # sprite.frame = 0
   ```

**Human Checkpoint:** When done, remind the user to:
- [ ] Review SPRITE_INTEGRATION.md instructions
- [ ] Prepare zombie sprite sheet (light gray base color)
- [ ] Place sprite in assets folder
- [ ] Follow integration instructions
- [ ] Test that zombies render with new sprite and color modulation works

---

### Task 6.2: Final gameplay verification
**Dependencies:** All previous tasks complete
**Extended thinking:** OFF
**Reminder:** Ask human - "Is extended thinking turned on? It should be OFF for this task."

**Implementation:**
1. Create a testing checklist comment in `main.gd`:
   ```gdscript
   # FINAL TESTING CHECKLIST:
   # [ ] All UI shows zombie/ordnance terminology
   # [ ] Zombies spawn and are visible
   # [ ] Color modulation shows toughness correctly
   # [ ] Statistics panel tracks cycles and strikes
   # [ ] Graph displays ordnance toughness levels
   # [ ] All 5 ordnance types work correctly
   # [ ] Cross-toughness (Shrapnel/Acid) functions
   # [ ] Performance good with 1000 zombies
   # [ ] No console errors or warnings
   ```

**Human Checkpoint:** When done, remind the user to:
- [ ] Run complete gameplay session (10+ cycles, multiple strikes)
- [ ] Test all 5 ordnance types
- [ ] Verify statistics panel updates correctly
- [ ] Check graph visualization
- [ ] Test toggle functionality
- [ ] Monitor performance with full horde
- [ ] Take screenshots for classroom demo
- [ ] Note any issues or refinements needed

---

## SUMMARY

**Total Tasks:** 22 tasks across 6 phases
**Estimated Time:** 2-3 hours for Haiku (depending on extended thinking usage)
**Human Time Required:** ~30-45 minutes total for checkpoints and testing

**Key Deliverables:**
1. ✅ Fully themed zombie defense simulator
2. ✅ Updated documentation (README, CLAUDE.md)
3. ✅ Statistics tracking panel
4. ✅ All original functionality preserved
5. ✅ Ready for sprite integration
6. ✅ Tested and verified

**Next Steps After Completion:**
1. Add zombie sprite sheet
2. Test with students
3. Gather feedback
4. Consider Phase 2: Area-effect targeting (future project)
