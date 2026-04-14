# Changelog - Driver App

All notable changes to the Delivery Driver app.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Dependency injection setup with get_it/Injectable
- Router configuration with GoRouter

## [1.0.0] - 2026-01-25

### Added
- Initial release: 18 screens across 9 feature modules
- Delivery queue with assigned orders and new-order alerts
- Real-time GPS tracking and background location sharing (flutter_background_service)
- Order acceptance and status update workflow
- Delivery proof: photo capture (camera) and signature pad
- Turn-by-turn navigation integration via Google Maps and url_launcher
- Delivery history and earnings summary with daily stats
- Driver profile and vehicle management screens
- Push notifications for new delivery assignments (Firebase Messaging)
- In-app chat between driver and dispatcher
- Shift toggle (online/offline) with shift data tracking
- Multi-language (7 languages) and full RTL support
- Riverpod + get_it/Injectable dependency injection
- GoRouter declarative navigation
- Supabase backend with Dio HTTP client
- Sentry crash reporting integration
- Connectivity-aware offline handling (connectivity_plus)
- Secure token storage (flutter_secure_storage)
