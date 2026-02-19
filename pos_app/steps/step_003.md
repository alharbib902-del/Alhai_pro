# POS App - Step 003: Auth & Core Sales

> **المرحلة:** Phase 1 | **المدة:** 4-5 أيام | **الأولوية:** P0

---

## 🎯 الهدف

إنشاء:
- Auth flow (Splash → Login → Store Select)
- Home Dashboard
- Payment flow
- Receipt printing

---

## 📋 المهام

### AUTH-001, AUTH-002, AUTH-003: Auth Flow (10h)

**الشاشات:**
1. `/splash` - Check auth status
2. `/login` - OTP login
3. `/store-select` - Select store

**User Stories:**
- US-1.1: Splash Screen
- US-1.2: Login with OTP
- US-1.3: Store Select

### POS-001: Home Dashboard (5h)

**العناصر:**
- Connection status (Online/Offline)
- Shift status (Open/Closed)
- Pending transactions badge
- Today's sales total
- Quick actions

### POS-002, POS-003: Payment & Sale (16h)

**Payment Screen:**
- Cash/Card/Mixed selection
- Amount input
- Change calculation

**Sale Creation:**
- Save sale with receiptNo
- Deduct inventory
- Handle credit sales

### POS-004, POS-005: Receipt & Printer (10h)

**Receipt Screen:**
- Order details
- Print button
- New Sale button

**Printer Settings:**
- Printer type selection
- Test print
- Auto-print toggle

---

## ✅ معايير الإنجاز

- [ ] Login → Store Select → Home يعمل
- [ ] إتمام عملية بيع كاملة
- [ ] طباعة الفاتورة
- [ ] Shift open/close

---

## 📚 المراجع

- [PROD.json](../PROD.json) - Phase 1 tasks
- [POS_BACKLOG.md](../POS_BACKLOG.md) - User Stories
