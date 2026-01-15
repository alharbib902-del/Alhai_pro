# ✅ قرارات تقنية مطلوبة قبل البدء

**التاريخ**: 2026-01-15  
**الأولوية**: حرجة - يجب الحسم قبل اليوم  الأول

---

## 1. State Management 
**القرار**: Riverpod  
**البدائل**: Bloc, GetX, Provider  
**السبب**: توافق مع Clean Architecture + أداء عالي  
**الموعد النهائي**: اليوم 1

---

## 2. Routing
**القرار**: GoRouter  
**البدائل**: Auto Route, Navigator 2.0  
**السبب**: Deep linking + Type safety  
**الموعد النهائي**: اليوم 2

---

## 3. Maps Provider
**القرار المقترح**: Google Maps  
**البدائل**: Mapbox ($0 حتى 50k loads/month), Apple Maps  
**التكلفة**: $7 لكل 1000 map load  
**الموعد النهائي**: قبل أسبوع 2

---

## 4. Push Notifications
**القرار المقترح**: Firebase Cloud Messaging  
**البدائل**: OneSignal  
**التكلفة**: مجاني  
**الموعد النهائي**: قبل أسبوع 5

---

## 5. SMS Provider (OTP)
**الخيارات**:
- Twilio: $0.05/SMS
- AWS SNS: $0.04/SMS  
- Unifonic: أسعار تنافسية للسعودية  

**القرار**: _________  
**الموعد النهائي**: قبل بدء أسبوع 1

---

## 6. Payment Gateway
**الخيارات**:
- **Stripe**: عالمي، 2.9% + SAR 1
- **Tap Payments**: محلي، 2.75%
- **Moyasar**: محلي، 2.5%
- **Hyperpay**: enterprise

**المتطلبات الإلزامية**:
- ✅ 3DS support
- ✅ Apple Pay
- ✅ Mada

**القرار**: _________  
**الموعد النهائي**: قبل أسبوع 7

---

## 7. Translation API
**الخيارات**:
- Google Translate: $20/million chars
- DeepL: $25/million chars (أفضل جودة)
- AWS Translate: $15/million chars

**القرار**: _________  
**الموعد النهائي**: قبل أسبوع 8

---

## 8. Environments

```yaml
development:
  supabase_url: https://dev-xyzabc.supabase.co
  supabase_anon_key: eyJhbGc...
  api_url: https://dev-api.alhai.sa
  cdn_url: https://dev-cdn.alhai.sa
  
staging:
  supabase_url: https://staging-xyzabc.supabase.co
  supabase_anon_key: eyJhbGc...
  api_url: https://staging-api.alhai.sa
  cdn_url: https://staging-cdn.alhai.sa
  
production:
  supabase_url: https://prod-xyzabc.supabase.co
  supabase_anon_key: eyJhbGc...
  api_url: https://api.alhai.sa
  cdn_url: https://cdn.alhai.sa
```

**الموعد النهائي**: اليوم 1

---

## 9. Git & CI/CD

**Branch Strategy**:
```
main (production)
├── develop (staging)
    ├── feature/auth-signup
    ├── feature/stores-list
    └── fix/cart-calculation
```

**CI/CD Pipeline** (GitHub Actions):
```yaml
on: [push, pull_request]
jobs:
  - flutter analyze
  - flutter test
  - build (iOS + Android)
  - deploy to Firebase App Distribution (dev)
```

**الموعد النهائي**: اليوم 1

---

## 10. Naming Conventions

### Routes:
```
✅ /stores/:storeId
✅ /orders/:orderId
✅ /payments/:paymentId

❌ /store/:id
❌ /order/:id
```

### Git Commits:
```
feat: add signup screen
fix: cart total calculation
refactor: extract ProductCard widget
docs: update README
```

---

## Checklist قبل البدء

```
[ ] Supabase project جاهز (dev + staging + prod)
[ ] Cloudflare R2 bucket مُعد
[ ] Firebase project جاهز
[ ] Google Maps API key
[ ] SMS provider account
[ ] Payment gateway account (test mode)
[ ] GitHub repo جاهز
[ ] Slack/Discord channel للفريق
[ ] Design System package جاهز
[ ] PRD approved by stakeholders
```

---

**التوقيع**: _____________  
**التاريخ**: _____________
