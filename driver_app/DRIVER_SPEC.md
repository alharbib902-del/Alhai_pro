# 🔧 Driver App - Technical Specification

**Version:** 1.0.0  
**Date:** 2026-01-15

---

## 📱 Platform

**Mobile Only:**
- iOS 14.0+
- Android 8.0+ (API 26+)

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State**: Riverpod / Bloc
- **Navigation**: GoRouter
- **Storage**: Hive (offline), Shared Preferences

### Backend
- **BaaS**: Supabase
- **Database**: PostgreSQL
- **Auth**: Supabase Auth
- **Real-time**: Supabase Realtime
- **Storage**: Cloudflare R2

### Maps & Location
- **Maps**: Google Maps SDK
- **Directions**: Google Directions API
- **Geocoding**: Google Geocoding API

### Translation
- **Text**: Google Cloud Translation API
- **Speech-to-Text**: Google Speech API

### Notifications
- **Android**: FCM
- **iOS**: APNs

---

## 📊 Data Models

### From alhai_core:
```dart
Delivery (existing)
Order (existing)
DeliveryStatus enum
OrderStatus enum
```

### New Models:
```dart
Shift
DriverEarnings
DeliveryProof
Achievement
```

---

## 🔋 Performance

### Targets:
- **App Launch**: < 2 seconds
- **GPS Accuracy**: ±10 meters
- **Battery Usage**: < 5% per hour
- **Network**: Works on 3G+

### Optimizations:
- GPS throttling when idle
- Image compression
- Lazy loading
- Caching strategy

---

## 🔒 Security

- **Auth**: JWT tokens
- **Storage**: Encrypted (Hive)
- **API**: HTTPS only
- **Permissions**: GPS, Camera, Mic

---

## 🌍 Languages

**Supported:** 6 languages  
**RTL:** Arabic, Urdu  
**LTR:** English, Hindi, Indonesian, Bengali

---

**For complete specifications, see full document.**

**📅 Last Updated**: 2026-01-15
