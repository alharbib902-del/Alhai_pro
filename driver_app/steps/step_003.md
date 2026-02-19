# Driver App - Step 003: Navigation + Delivery Proof

> **المرحلة:** Phase 3 | **المدة:** 2 أسبوع | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- شاشة الملاحة مع Google Maps
- إثبات التسليم (4 طبقات)
- GPS tracking

---

## 📋 المهام

### NAV-001: Navigation Screen (16h)

**Route:** `/navigate/:orderId`

**الميزات:**
- Google Maps integration
- Turn-by-turn directions
- ETA display
- Driver location (blue dot)
- Destination marker
- "Arrived" button

```dart
// Google Maps Widget
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(lat, lng),
    zoom: 15,
  ),
  markers: {pickupMarker, destinationMarker},
  polylines: {routePolyline},
  myLocationEnabled: true,
)
```

### NAV-002: GPS Tracking Service (8h)

**المتطلبات:**
- Background location tracking
- Throttle when stationary
- < 5% battery per hour
- Update server every 30s

### DELV-001: Delivery Proof Screen (16h)

**Route:** `/deliver/:orderId`

**4 طبقات الإثبات:**

1. **كود التأكيد:**
   ```
   ┌───┬───┬───┬───┐
   │ 5 │ 2 │ 7 │ 9 │ ✅
   └───┴───┴───┴───┘
   ```

2. **صورة:**
   - Camera capture
   - Retake option
   - Image compression

3. **توقيع:**
   - Signature pad
   - Clear button
   - Confirm

4. **GPS:**
   - Auto-verification
   - Location display

### DELV-002: Photo Capture (4h)

```dart
// Camera integration
final image = await ImagePicker().pickImage(
  source: ImageSource.camera,
  imageQuality: 70,
);
```

### DELV-003: Signature Pad (4h)

```bash
flutter pub add signature
```

---

## ✅ معايير الإنجاز

- [ ] Navigation يعمل مع Google Maps
- [ ] GPS tracking في الخلفية
- [ ] 4 طبقات الإثبات تعمل
- [ ] Battery usage < 5%/hour

---

## 📚 المراجع

- [PROD.json](../PROD.json) - NAV-001, DELV-001
- [DRIVER_UX_WIREFRAMES.md](../DRIVER_UX_WIREFRAMES.md)
