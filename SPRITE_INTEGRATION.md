# Sprite Integration Guide

This guide explains how to integrate a custom zombie sprite sheet into the Zombie Defense: Evolution Simulator.

---

## Current State

The simulator currently uses a **fallback 6x6 white dot** for rendering zombies. This placeholder allows the game to run immediately while you prepare a custom sprite.

**Current sprite code in `organism.gd`:**
```gdscript
# TODO: Human will provide zombie sprite sheet
# For now, use fallback 6x6 white dot for testing
if _dot_tex == null:
    var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
    img.fill(Color(1, 1, 1, 1))
    _dot_tex = ImageTexture.create_from_image(img)
sprite.texture = _dot_tex
sprite.centered = true

# When zombie sprite is provided:
# sprite.texture = preload("res://assets/zombie_sprite.png")
# sprite.hframes = X  # Set based on sprite sheet
# sprite.frame = 0    # Default frame
```

---

## Sprite Sheet Requirements

### Format
- **File format:** PNG (recommended) or JPG
- **Color depth:** RGBA with alpha channel for transparency
- **Location:** `res://assets/zombie_sprite.png`

### Dimensions & Layout
- **Base sprite size:** 16x16 or 32x32 pixels (power of 2 recommended)
- **Sprite sheet layout:** Horizontal strips (frames arranged left-to-right)
- **Animation frames:** 3-8 frames recommended for walking/wandering animation
- **Padding:** 1-2 pixels between frames recommended

### Color Considerations
- **Base color:** Light gray or greenish-gray (matches modulation expectations)
- **Transparency:** Use alpha channel for anti-aliasing, fully transparent background
- **Color modulation:** Sprite should blend well with ordnance colors:
  - Fire: Orange/red
  - Shrapnel: Gray metallic
  - Acid: Green
  - Electricity: Blue
  - Freeze: Icy blue

### Example Dimensions
- **Single frame:** 32x32 px sprite (smallest viable)
- **4-frame animation:** 128x32 px sheet (4 frames × 32 px width, 32 px height)
- **6-frame animation:** 192x32 px sheet (6 frames × 32 px width, 32 px height)

---

## Integration Steps

### Step 1: Prepare Sprite Files

1. Create your zombie sprite artwork (or use existing asset)
2. Ensure sprite is on a transparent background
3. Create sprite sheet with frames arranged horizontally
4. Export as PNG to preserve quality and transparency

### Step 2: Add to Project

1. In Godot editor, create a new folder: `res://assets/`
2. Copy your sprite file into `res://assets/zombie_sprite.png`
3. Godot will auto-import the PNG

### Step 3: Enable Sprite in Code

Edit `organism.gd` and modify the `_ready()` function:

```gdscript
func _ready() -> void:
	# TODO: Human will provide zombie sprite sheet
	# For now, use fallback 6x6 white dot for testing

	# UNCOMMENT THESE LINES after adding zombie sprite:
	sprite.texture = preload("res://assets/zombie_sprite.png")
	sprite.hframes = 4  # Adjust based on your sprite sheet frame count
	sprite.frame = 0    # Default frame

	# COMMENT OUT or DELETE the fallback texture creation:
	#if _dot_tex == null:
	#	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	#	img.fill(Color(1, 1, 1, 1))
	#	_dot_tex = ImageTexture.create_from_image(img)
	#sprite.texture = _dot_tex
	sprite.centered = true

	sprite.play()
	go_right = randf() > 0.5
	wander_distance = randi_range(5,10)
	# ... rest of function
```

### Step 4: Test Animation

The sprite system uses `AnimatedSprite2D` which is already configured in `organism.tscn`:

1. Run the project
2. Observe zombies rendering with your custom sprite
3. Check that color modulation works (zombies change color with toughness)
4. Verify animation plays (walking/wandering motion)

### Step 5: Fine-tune (Optional)

If animation looks wrong or sprite positioning is off:

- **Frame count mismatch:** Update `hframes` value to match your sheet
- **Sprite stretching:** Ensure sprite size is square or adjust `sprite.scale`
- **Color too dark:** Check sprite base color matches expectations (light gray/green)
- **Animation speed:** Adjust in `organism.tscn` if needed
  - Select the Sprite2D node
  - In Inspector, find AnimatedSprite2D
  - Adjust "Speed Scale" value (higher = faster)

---

## Sprite Sheet Layout Examples

### 4-Frame Horizontal Strip
```
[Frame 0] [Frame 1] [Frame 2] [Frame 3]
  32px      32px      32px      32px
  = 128px total width × 32px height
```
In code: `sprite.hframes = 4`

### 6-Frame Horizontal Strip
```
[Frame 0] [Frame 1] [Frame 2] [Frame 3] [Frame 4] [Frame 5]
  32px      32px      32px      32px      32px      32px
  = 192px total width × 32px height
```
In code: `sprite.hframes = 6`

---

## Troubleshooting

### Sprite Not Visible
- Check file path: Should be exactly `res://assets/zombie_sprite.png`
- Verify transparency: Try exporting with explicit alpha channel
- Check import settings: Godot should auto-detect PNG as Texture2D
- Ensure `sprite.centered = true` is set

### Colors Not Blending Correctly
- Verify sprite base color is light (RGB > 0.7)
- Try greenish-gray base: RGB(0.75, 0.80, 0.75) or similar
- Darker sprites will look muddy when modulated

### Animation Not Playing
- Check `hframes` matches actual frame count in sheet
- Verify sprite is `AnimatedSprite2D` type (not static `Sprite2D`)
- Confirm `sprite.play()` is called in `_ready()`

### Sprite Positioning Wrong
- Verify `sprite.centered = true`
- Check sprite dimensions are reasonable (not too large)
- Adjust scale if needed: `sprite.scale = Vector2(0.5, 0.5)`

---

## Color Modulation Details

When a zombie gains toughness, its color shifts toward the corresponding ordnance color:

**Example:** A zombie with Fire toughness will shift from greenish-gray toward orange/red.

**How it works:**
- Base color: `Color(0.75, 0.80, 0.75)` (sickly greenish-gray)
- Fire color: `Color(0.90, 0.35, 0.20)` (orange/red flames)
- Blend factor: 0.35 per toughness level (clamped 0-1)
- Result: Visible color shift with each toughness gain

**For best results:**
- Sprite should be light enough to show color shifts
- Avoid highly saturated base colors (will muddy the blend)
- Test with different toughness levels to verify visibility

---

## Animation Best Practices

### Walking/Wandering Frames
Recommended animation sequence for zombie wandering:
1. **Frame 0:** Neutral stance (body center)
2. **Frame 1:** Left foot forward
3. **Frame 2:** Neutral stance
4. **Frame 3:** Right foot forward

Loop these 4 frames for continuous walking motion.

### Speed Settings
- **Standard speed:** 1.0 (default)
- **Slow shuffle:** 0.5-0.7
- **Fast waddle:** 1.3-1.5
- **Sprinting:** 2.0+

Edit in Godot Inspector on the AnimatedSprite2D node under "Animation" → "Speed Scale".

---

## File Checklist

After integration, verify:

- [ ] `res://assets/` folder exists
- [ ] `res://assets/zombie_sprite.png` file present
- [ ] `organism.gd` has sprite code uncommented
- [ ] `organism.gd` has correct `hframes` value
- [ ] Fallback texture creation is commented out
- [ ] Game runs without errors
- [ ] Zombies appear with custom sprite
- [ ] Color modulation works (colors change with toughness)
- [ ] Animation plays smoothly

---

## Next Steps

After sprite integration:

1. **Test gameplay** with 10+ infection cycles
2. **Apply strikes** and verify color changes
3. **Check performance** with full horde (1000 zombies)
4. **Gather feedback** from classroom use
5. **Iterate** on sprite design if needed

---

## Resources

### Sprite Creation Tools
- **Aseprite** - Professional pixel art tool
- **Piskel** - Free web-based sprite editor
- **GIMP** - Free image editor
- **Krita** - Free digital painting

### Godot Animation Reference
- [AnimatedSprite2D Documentation](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html)
- [Godot 4.5 Sprite Animation Guide](https://docs.godotengine.org/en/stable/tutorials/2d/using_2d_characters.html)

---

**Questions?** Review the sprite code in `organism.gd:_ready()` or `CLAUDE.md` for AI assistant guidance.
