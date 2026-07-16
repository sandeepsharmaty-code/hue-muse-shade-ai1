# Hue Muse Shade AI — Release Notes
## Version 1.0.0 (Candidate)

**Status: source-complete, build-unverified.** See
`docs/sprints/SPR-DEP-012-completion-report.md` for exactly what
"unverified" means and what's needed to close the gap.

---

## What's in this release

**Offline cosmetic colour shade development app.** No internet, no
cloud, no login — all data stays on-device in a local SQLite
database.

### Core workflow
- **New Shade**: pick a product, capture or select a gallery image,
  get deterministic colour analysis (dominant colours, average
  colour, brightness/saturation/lightness, CIELAB colour-distance
  data) and shade classification (family, undertone, dark/light,
  single/multiple dominant colour) — then jump straight to ranked
  trial recommendations for that shade.
- **Trial Recommendations**: Top 5 ranked trial formulas per request,
  each with a confidence score, matched/failed rule breakdown,
  material-availability and alternative-material data, conflict
  detection (product/shade mismatch, inactive/missing material,
  disabled rule, low confidence), and a side-by-side comparison
  report.
- **Lab Workflow**: trials move through Draft -> Ready for Lab -> Lab
  Testing -> Approved/Rejected -> Archived, with every transition
  permanently recorded in an audit trail (who, when, from/to status,
  reason).
- **Knowledge Base**: approved formulas, configurable business rules,
  and general knowledge records, all searchable.
- **Search**: across shades, products, materials (all six raw-material
  categories), formulas, and knowledge in one place.
- **Settings**: Backup/Restore Database (with corruption validation
  and a pre-restore safety snapshot), Export/Import Knowledge, Clear
  Cache, and a full data reset.

### Configurable business rules
Every recommendation decision — product match, shade family match,
finish match, coverage match, per-material-type approval, alternative-
material fallback — is driven by editable rules with priority, weight,
and enabled/disabled state, not hardcoded thresholds.

### Data Layer
14 approved tables covering products, shades, six raw-material
categories, trial formulas, approved formulas, knowledge base, and
settings (which also hosts configurable rules, recommendation
history, and the trial audit trail — see Technical Documentation for
why).

---

## What's *not* in this release

- No formulation chemistry, pigment-ratio calculation, or ingredient
  estimation anywhere — by design. This app organizes and ranks
  existing formulas; it never invents new ones.
- No AI, no machine learning, no camera-based object/face detection.
  Colour analysis is deterministic pixel sampling and colour-space
  math.
- No file picker for Import Knowledge (reads a fixed conventional
  path instead — see User Manual).
- No screen-level widget tests, no integration tests, no
  repository-backed tests for most engines (see Known Issues).

## Known limitations at ship time

See `docs/release/KNOWN_ISSUES.md` for the full list. Headline item:
**this build has never been compiled** — no Flutter SDK has been
available in the environment that produced this code across any of
its twelve sprints. Section-by-section detail in the SPR-DEP-012
completion report.

## Requirements

- Android 8.0 (API 26) or later (per the approved target range;
  untested on any specific version — see Device Compatibility).
- No internet connection required or used at any point.
- Camera and/or photo library permission for shade image capture.
