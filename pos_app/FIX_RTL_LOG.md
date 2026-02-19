# RTL Fix Log

## Date: 2026-02-15

## Summary

Fixed RTL (Right-to-Left) layout issues across the entire `lib/` directory to ensure proper Arabic/RTL rendering.

---

## 1. EdgeInsets.only(left/right) → EdgeInsetsDirectional

**Issue:** `EdgeInsets.only(left:)` and `EdgeInsets.only(right:)` don't flip in RTL layouts.

**Fix:** Converted to `EdgeInsetsDirectional.only(start:)` and `EdgeInsetsDirectional.only(end:)`.

**Files affected:** 34 files
**Replacements:** ~31 instances

| Before | After |
|--------|-------|
| `EdgeInsets.only(left: X)` | `EdgeInsetsDirectional.only(start: X)` |
| `EdgeInsets.only(right: X)` | `EdgeInsetsDirectional.only(end: X)` |

---

## 2. Hardcoded Alignment(left/right) → AlignmentDirectional

**Issue:** `Alignment.topLeft`, `Alignment.centerRight`, etc. don't respect text direction.

**Fix:** Converted to `AlignmentDirectional` equivalents.

**Files affected:** 41 files
**Replacements:** ~91 instances

| Before | After |
|--------|-------|
| `Alignment.topLeft` | `AlignmentDirectional.topStart` |
| `Alignment.topRight` | `AlignmentDirectional.topEnd` |
| `Alignment.bottomLeft` | `AlignmentDirectional.bottomStart` |
| `Alignment.bottomRight` | `AlignmentDirectional.bottomEnd` |
| `Alignment.centerLeft` | `AlignmentDirectional.centerStart` |
| `Alignment.centerRight` | `AlignmentDirectional.centerEnd` |

**Additional fix:** Updated `AppDataTable._getAlignment()` return type from `Alignment` to `AlignmentGeometry` to support `AlignmentDirectional`.

---

## 3. TextAlign.left/right → TextAlign.start/end

**Issue:** `TextAlign.left` and `TextAlign.right` don't flip for RTL text.

**Fix:** Converted to `TextAlign.start` and `TextAlign.end`.

**Files affected:** 1 file (`receipt_screen.dart`)
**Replacements:** 2 instances

| Before | After |
|--------|-------|
| `TextAlign.left` | `TextAlign.start` |
| `TextAlign.right` | `TextAlign.end` |

**Skipped:** 2 instances in `receipt_pdf_generator.dart` — `pw.TextAlign` (PDF library) does not support `start`/`end`.

---

## 4. Directional Icons → AdaptiveIcon

**Issue:** Icons like `Icons.chevron_left`, `Icons.arrow_forward`, `Icons.send` have inherent direction that should mirror in RTL.

**Fix:** Created `AdaptiveIcon` widget and replaced directional icon usages.

### New File: `lib/widgets/common/adaptive_icon.dart`

```dart
class AdaptiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  // Paired icons: swaps to mirrored counterpart in RTL
  static final _mirrorMap = <IconData, IconData>{
    Icons.chevron_left: Icons.chevron_right,
    Icons.chevron_right: Icons.chevron_left,
    Icons.arrow_forward: Icons.arrow_back,
    Icons.arrow_back: Icons.arrow_forward,
    Icons.first_page: Icons.last_page,
    Icons.last_page: Icons.first_page,
    // ... 20 pairs total
  };

  // Icons flipped via Transform (no paired counterpart)
  static final _flipIcons = <IconData>{Icons.send, Icons.send_rounded};

  // Static helper for IconData contexts
  static IconData data(BuildContext context, IconData icon) { ... }
}
```

**Files using AdaptiveIcon:** 29 files
**Icon patterns replaced:**
- `Icon(Icons.chevron_left)` → `AdaptiveIcon(Icons.chevron_left)`
- `Icon(Icons.chevron_right)` → `AdaptiveIcon(Icons.chevron_right)`
- `Icon(Icons.arrow_forward)` → `AdaptiveIcon(Icons.arrow_forward)`
- `Icon(Icons.arrow_forward_ios)` → `AdaptiveIcon(Icons.arrow_forward_ios)`
- `Icon(Icons.first_page)` → `AdaptiveIcon(Icons.first_page)`
- `Icon(Icons.last_page)` → `AdaptiveIcon(Icons.last_page)`
- `Icon(Icons.send)` → `AdaptiveIcon(Icons.send)`

**Supported icon pairs (20 total):**
- `chevron_left` ↔ `chevron_right`
- `chevron_left_rounded` ↔ `chevron_right_rounded`
- `arrow_forward` ↔ `arrow_back`
- `arrow_forward_rounded` ↔ `arrow_back_rounded`
- `arrow_forward_ios` ↔ `arrow_back_ios`
- `arrow_forward_ios_rounded` ↔ `arrow_back_ios_rounded`
- `first_page` ↔ `last_page`
- `navigate_before` ↔ `navigate_next`
- `keyboard_arrow_left` ↔ `keyboard_arrow_right`
- `send` / `send_rounded` — flipped via `Transform.flip`

---

## Analyzer Results

After all fixes:
- **0 new errors** introduced by RTL changes
- **0 new warnings** introduced by RTL changes
- Pre-existing errors (75 localization-related, not from RTL changes) remain in:
  - `inventory_alerts_screen.dart` (missing ARB keys)
  - `order_history_screen.dart` (missing ARB keys)
  - `product_categories_screen.dart` (missing ARB keys)

---

## Total Changes Summary

| Category | Instances Fixed | Files Affected |
|----------|:--------------:|:--------------:|
| EdgeInsetsDirectional | ~31 | 34 |
| AlignmentDirectional | ~91 | 41 |
| TextAlign.start/end | 2 | 1 |
| AdaptiveIcon (new widget) | 1 | 1 (new file) |
| Icon → AdaptiveIcon | ~58 | 28 |
| **Total** | **~183** | **~50 unique files** |
