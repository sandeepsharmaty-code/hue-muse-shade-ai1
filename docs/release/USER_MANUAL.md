# Hue Muse Shade AI — User Manual

## Getting Started

The app opens to a splash screen while it sets up its local database,
then lands on **Home**. Five tabs sit at the bottom: Home, New Shade,
Knowledge, Search, Settings.

## Home

Shows a quick summary (product/shade/pending-trial counts), your most
recent recommendations, any trials waiting on lab work, and three
quick-action buttons that jump straight to New Shade, Search, or
Knowledge. Pull down to refresh.

## New Shade — the main workflow

1. **Pick a product** from the dropdown at the top. If none exist
   yet, you'll see a message asking you to add one first (this
   version doesn't include a product-creation screen — products are
   set up at the data layer; ask your development team if you need
   one added).
2. **Capture or select a shade image** using the camera/gallery
   buttons.
3. Tap **Analyze Image**. You'll see:
   - A **Color Profile**: the average colour swatch, up to five
     dominant colour dots, and brightness/saturation/lightness
     percentages.
   - A **Shade Detection** result: colour family (e.g. Red, Nude,
     Blue), undertone (Warm/Cool/Neutral), whether it's dark, light,
     or mid-tone, and whether the image has one dominant colour or
     several.
4. Tap **View Top 5 Recommendations** to move to the Trial screen.

## Trial Screen

Shows up to five ranked trial formulas for your product/shade. Each
card shows a rank, confidence percentage, status, and any conflicts
found. Tap a card to reveal four actions:

- **Explanation** — why this trial was selected, why its confidence
  is what it is, which rules matched and which failed, what material
  alternatives exist, and what conflicts were found.
- **Validation** — a pass/fail checklist against 8 criteria (product/
  shade/finish/coverage compatibility, material availability, rule
  compliance, confidence threshold).
- **History** — every status change this trial has ever had.
- **Mark Ready for Lab** — moves the trial into the lab workflow and
  records the change.

Tap the compare icon in the top bar to see all five trials side by
side, with differences flagged.

## Knowledge

Four tabs:
- **Knowledge** — general knowledge base entries.
- **Approved Formulas** — every trial that's reached Approved status.
- **Rules** — every configurable business rule, with its type,
  priority, weight, and enabled/disabled state.
- **Recent Updates** — the five most recently edited knowledge
  entries.

## Search

Choose a category (Shades, Products, Materials, Formulas, Knowledge)
with the chips at the top, then type a query. Materials search covers
all six raw-material types at once.

## Settings

- **Backup Database** — saves a timestamped copy of your local
  database.
- **Restore Database** — pick a previous backup to restore. The app
  checks the file is a genuine, uncorrupted database first and
  refuses to restore anything that fails that check. A safety copy of
  your *current* database is taken automatically before restoring, in
  case you change your mind. **You must restart the app afterward**
  for the restored data to take effect.
- **Export Knowledge** — saves all Knowledge Base entries as a JSON
  file.
- **Import Knowledge** — place a file named `knowledge_import.json`
  in the app's `Documents/imports/` folder, then tap Import. (There's
  no in-app file browser in this version — you'll need a file manager
  app or a computer connection to place the file there.)
- **Clear Cache** — frees temporary storage; doesn't touch your data.
- **About Application** — version and offline-only confirmation.
- **Reset Local Data** — permanently erases everything. Requires
  confirmation; cannot be undone (there's no cloud copy — it's an
  offline app).

## Offline by design

Nothing in this app ever makes a network request. You can use it on
a plane, in a basement lab, anywhere.
