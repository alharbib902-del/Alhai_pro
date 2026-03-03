# Fix 08 — ESC/POS Printing Integration Log

## Summary
Implemented real ESC/POS thermal printer integration for the Alhai POS cashier app. Added Bluetooth, Network TCP, and Sunmi built-in printer support with auto-print after payment.

## Changes Made

### 1. Added Printing Libraries (`pubspec.yaml`)
- `esc_pos_utils: ^1.1.0` — ESC/POS command generation
- `esc_pos_printer: ^4.1.0` — Network TCP printing (port 9100)
- `esc_pos_bluetooth: ^4.1.0` — Bluetooth printer support
- `sunmi_printer_plus: ^4.1.0` — Sunmi built-in device printer

### 2. Created `lib/services/printing/` (6 files)

| File | Description |
|------|-------------|
| `print_service.dart` | Abstract `ThermalPrintService` interface with connect/disconnect/printReceipt/openCashDrawer |
| `bluetooth_print_service.dart` | Bluetooth implementation using `esc_pos_bluetooth` |
| `network_print_service.dart` | Network TCP implementation using `esc_pos_printer` |
| `sunmi_print_service.dart` | Sunmi built-in printer implementation using `sunmi_printer_plus` |
| `receipt_builder.dart` | ESC/POS receipt formatter: header + items + totals + ZATCA QR + footer |
| `receipt_data.dart` | Structured receipt data model (`ReceiptData`, `ReceiptItem`, `ReceiptStoreInfo`) |
| `printing_providers.dart` | Riverpod providers: `printServiceProvider`, `autoPrintEnabledProvider`, saved printer persistence |
| `auto_print_setup.dart` | Bridge between cashier app printing and alhai_pos payment flow |

### 3. Connected Printing to Payment Flow

**Modified files:**
- `packages/alhai_shared_ui/lib/src/providers/print_providers.dart`
  - Added `AutoPrintCallback` typedef
  - Added `autoPrintCallbackProvider` — allows the cashier app to inject its ESC/POS print function
  - Added `autoPrintEnabledProvider` — toggle for auto-print

- `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart`
  - Modified `_handlePaymentComplete()` to call `autoPrintCallbackProvider` after successful sale
  - Auto-prints before showing the success dialog

- `lib/main.dart`
  - Converted `CashierApp` from `ConsumerWidget` to `ConsumerStatefulWidget`
  - Calls `initializeAutoPrint(ref)` on first frame to register the callback and load saved printer

### 4. Rewrote Printer Settings Screen

**File:** `lib/screens/settings/printer_settings_screen.dart`

Complete rewrite with real printer integration:
- **Connection status card** — shows connected/disconnected with printer name
- **Printer discovery** — Bluetooth scan, Network IP input, Sunmi auto-detect
- **Discovered printers list** — tap to connect, shows connected state
- **Test print** — sends real ESC/POS test page to connected printer
- **Open cash drawer** — ESC/POS drawer kick command
- **Disconnect** — properly disconnects and clears saved preferences
- **Auto-print toggle** — enable/disable automatic printing after payment
- **Paper size selector** — 58mm or 80mm thermal paper width

### Architecture

```
┌─────────────────┐
│   POS Screen    │ (alhai_pos package)
│  Payment Flow   │
└───────┬─────────┘
        │ autoPrintCallbackProvider
        ▼
┌─────────────────┐
│ auto_print_setup│ (cashier app)
│ initializeAuto  │
│ Print(ref)      │
└───────┬─────────┘
        │ printServiceProvider
        ▼
┌─────────────────┐
│ThermalPrintSvc  │ (abstract)
├─────────────────┤
│ Bluetooth       │ esc_pos_bluetooth
│ Network TCP     │ esc_pos_printer
│ Sunmi Built-in  │ sunmi_printer_plus
└───────┬─────────┘
        │
        ▼
┌─────────────────┐
│ ReceiptBuilder  │ ESC/POS byte generation
│ (esc_pos_utils) │ receipt_data.dart model
└─────────────────┘
```

## Files Changed
- `pubspec.yaml` — added 4 printing packages
- `lib/main.dart` — auto-print initialization
- `lib/screens/settings/printer_settings_screen.dart` — full rewrite
- `lib/services/printing/` — 8 new files (service layer)
- `packages/alhai_shared_ui/.../print_providers.dart` — auto-print providers
- `packages/alhai_pos/.../pos_screen.dart` — auto-print after payment
