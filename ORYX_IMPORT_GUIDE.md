# 🎹 EZOverlay - Oryx Import Guide

EZOverlay now supports importing your actual Ergodox EZ keyboard layout directly from ZSA's Oryx configurator!

## 📥 How to Download Your Layout from Oryx

### Step 1: Access Oryx
1. Go to **[configure.zsa.io](https://configure.zsa.io/)**
2. Log in to your ZSA account
3. Load your Ergodox EZ keyboard layout

### Step 2: Export Your Layout
You mentioned seeing these options:
- **Download firmware** (for flashing to keyboard)
- **Download source** ← **This is what you need!**
- **Download flashing tool**

1. Click **"Download source"**
2. Choose either:
   - **Glow** (if you have glow/shine effects)
   - **Original & Shine** (standard version)
3. This downloads a ZIP file

### Step 3: Extract and Locate JSON
1. Extract the downloaded ZIP file
2. Look for `keymap.json` file in the source folder
3. This contains your complete layout data

## 🔄 How to Import into EZOverlay

### Method 1: Through Preferences UI
1. Launch EZOverlay
2. Press `Cmd+,` to open preferences (or go to EZOverlay > Settings)
3. Find the **"Layout Import"** section
4. Click **"Import Oryx JSON"**
5. Select your `keymap.json` file
6. Done! Your layout will replace the default one

### Method 2: Using "How to Export" Helper
1. In preferences, click **"How to Export"** 
2. This shows detailed instructions
3. Click **"Open Oryx"** to go directly to the configurator

## 🎯 What Gets Imported

EZOverlay imports:
- **All your layers** (up to 32 if you have them)
- **Every key mapping** including:
  - Letters, numbers, symbols
  - Function keys (F1-F20)
  - Modifiers (Shift, Ctrl, Alt, GUI)
  - Layer switching keys
  - Special keys (Space, Enter, Tab, etc.)
  - Arrow keys and navigation

## 🔍 Key Mapping Examples

Your Oryx keys are automatically converted:
- `KC_A` → `A`
- `KC_LSHIFT` → `LSft` 
- `KC_SPACE` → `Space`
- `MO(1)` → `L1` (momentary layer 1)
- `TO(2)` → `→L2` (switch to layer 2)
- `KC_LEFT` → `←`
- `LCTL(KC_C)` → `Ctl+C`

## 🚀 Testing Your Import

After importing:
1. Press `Cmd+Option+Ctrl+L` to show the overlay
2. Use the arrow buttons (← →) to switch between your layers
3. Press F13-F20 to auto-switch layers (if you have Input Monitoring permission)
4. Check that all your custom key mappings appear correctly

## 🔧 Troubleshooting

**Import Failed Error:**
- Make sure you selected `keymap.json` (not other files)
- Ensure the file is from a recent Oryx download
- Try re-downloading from Oryx

**Keys Look Wrong:**
- Some complex macros may display as shortened text
- Layer switching keys use symbols (→L1, ⇄L2, etc.)
- Empty keys show as "▽"

**Missing Layers:**
- EZOverlay shows all layers from your Oryx export
- Use the layer counter to see "Layer X/Y"

## ✨ Benefits of Using Your Real Layout

Instead of the hardcoded demo layouts, you get:
- **Your actual key mappings** from your physical keyboard
- **Your custom layers** exactly as configured
- **Your macros and special functions** 
- **Real-time sync** when you update Oryx (just re-import)

## 🔄 Updating Your Layout

When you make changes in Oryx:
1. Download source again from Oryx
2. Re-import the new `keymap.json` 
3. EZOverlay will replace the old layout with your updates

---

**Happy typing with your personalized Ergodox EZ overlay!** 🎉