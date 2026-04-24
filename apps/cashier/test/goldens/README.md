# Golden tests

Pixel-exact PNG snapshots for critical cashier screens.

## Running

- **CI (Ubuntu):** `flutter test test/goldens/` — runs normally.
- **Local on Windows / macOS:** tests skip automatically (platform diffs). To
  force locally: `flutter test --dart-define=GOLDEN_FORCE=true test/goldens/`.

## Regenerating masters

Only do this on CI or a Linux dev box:

```bash
flutter test --update-goldens test/goldens/
git add test/goldens/masters/
git commit -m "test(goldens): refresh masters"
```

## Coverage matrix

Target: 20 critical screens × 2 themes × 2 locales × 3 sizes = **240 PNGs**.

Currently seeded:
- POS empty cart (light/dark × ar × desktop, light × en × tablet)

Future (Phase 5.1 completion sweep):
- POS with cart, mid-payment, paid
- Customer accounts (empty, with data)
- Sales history (empty, filtered, detailed)
- Inventory (add, edit, transfer)
- Shift open/close
- Custom report (builder, preview, chart)

## Why goldens are Linux-only

Text rendering, font hinting, and anti-aliasing differ between OSes. A master
PNG generated on Windows will not match the same widget rendered on Ubuntu's
Freetype stack, even at identical sizes. Standardising on the CI runner
(Ubuntu) keeps the suite deterministic. See `golden_config.dart` for the
`shouldRunGoldens` gate.
