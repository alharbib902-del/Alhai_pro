# App Store Metadata — Driver App

## App Store Connect (iOS)

| Field | Value |
|-------|-------|
| **App Name** | حي — السائقين |
| **Subtitle** | تطبيق التوصيل للسائقين |
| **Bundle ID** | `com.alhai.driver` |
| **SKU** | `alhai-driver-ios` |
| **Primary Language** | Arabic |
| **Category** | Navigation |
| **Secondary Category** | Business |
| **Content Rating** | 4+ |
| **Pricing** | Free |
| **Availability** | Saudi Arabia |
| **Version** | 1.0.0 |
| **Build** | 1 |
| **Copyright** | © 2026 BLTech Solutions |
| **Privacy Policy URL** | `https://alhai.store/privacy` |
| **Support URL** | `https://alhai.store/support` |
| **Marketing URL** | `https://alhai.store/drivers` |

### Age Rating: 4+

Same questionnaire as customer_app — all "None".

### App Privacy (Data Collection)

| Data Type | Collected | Linked to Identity | Tracking |
|-----------|----------|-------------------|----------|
| Contact Info (phone) | Yes | Yes | No |
| Precise Location | Yes | Yes | No |
| Coarse Location | Yes | Yes | No |
| Photos (delivery proof) | Yes | No | No |
| Identifiers (device ID) | Yes | No | No |
| Diagnostics (crash data) | Yes | No | No |
| Financial Info (earnings) | Yes | Yes | No |

### Background Location Declaration

> "This app uses background location to track the driver's position during active deliveries, enabling real-time delivery tracking for customers and dispatchers. Location tracking stops when no delivery is active."

---

## Google Play Console (Android)

| Field | Value |
|-------|-------|
| **App Name** | حي — السائقين |
| **Short Description** | تطبيق توصيل البقالة للسائقين — استلم واوصل واكسب |
| **Application ID** | `com.alhai.driver_app` |
| **Default Language** | Arabic (ar) |
| **Category** | Maps & Navigation |
| **Content Rating** | Everyone |
| **Pricing** | Free |
| **Countries** | Saudi Arabia |
| **Target SDK** | 34 |
| **Min SDK** | 21 |
| **Privacy Policy URL** | `https://alhai.store/privacy` |
| **Support Email** | support@alhai.store |

### Data Safety Section

| Data Type | Collected | Shared | Purpose |
|-----------|----------|--------|---------|
| Phone number | Yes | No | Account registration |
| Precise location | Yes | Yes (with customer) | Delivery tracking |
| Photos | Yes | No | Proof of delivery |
| Financial info | Yes | No | Earnings tracking |
| App crash logs | Yes | No | App stability |

### Permissions Declaration

| Permission | Purpose |
|-----------|---------|
| `ACCESS_FINE_LOCATION` | Navigation to delivery address |
| `ACCESS_BACKGROUND_LOCATION` | Track driver during active delivery |
| `FOREGROUND_SERVICE` | Maintain delivery tracking notification |
| `CAMERA` | Capture proof-of-delivery photos |
| `INTERNET` | API communication |

### Background Location Play Store Declaration

**Feature:** Real-time delivery tracking
**Use case:** When a driver accepts a delivery order, the app tracks their location in the background to provide real-time updates to the customer. Location tracking automatically stops when the delivery is marked as complete.
**Prominent disclosure:** Yes — shown when driver starts first delivery

---

## Contact Info

| Field | Value |
|-------|-------|
| Developer name | BLTech Solutions |
| Email | support@alhai.store |
| Address | Jeddah, Saudi Arabia |
