# Team Workflow - 6 Accounts Setup

**Version:** 1.0.0  
**Date:** 2026-01-20

---

## 📊 Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    Alhai Platform                             │
├─────────────────────────────┬────────────────────────────────┤
│         Device A            │          Device B              │
│         POS App             │        Customer App            │
├─────────────────────────────┼────────────────────────────────┤
│  Account A1  A2  A3         │  Account B1  B2  B3            │
│     ↓    ↓    ↓             │     ↓    ↓    ↓                │
│  [Rotate when quota runs]   │  [Rotate when quota runs]      │
└─────────────────────────────┴────────────────────────────────┘
```

---

## 🔑 Account Rotation Strategy

### Device A (POS App):
| Account | Context File | Usage |
|---------|--------------|-------|
| A1 | `cashier/.context/A1_SESSION.md` | Active |
| A2 | `cashier/.context/A2_SESSION.md` | Standby |
| A3 | `cashier/.context/A3_SESSION.md` | Standby |

### Device B (Customer App):
| Account | Context File | Usage |
|---------|--------------|-------|
| B1 | `customer_app/.context/B1_SESSION.md` | Active |
| B2 | `customer_app/.context/B2_SESSION.md` | Standby |
| B3 | `customer_app/.context/B3_SESSION.md` | Standby |

---

## 📋 Handoff Protocol (عند التبديل بين الحسابات)

### Before Switching:
```bash
# 1. Save current progress
git add .
git commit -m "wip(pos): checkpoint before account switch"

# 2. Update session file
# Write current status in SESSION.md
```

### Session File Template:
```markdown
# Session Status - [Account ID]

## Last Updated: [DateTime]

## Current Task:
- Working on: [Feature Name]
- Story: [US-X.X]
- Branch: [Branch Name]

## Files Modified:
- `path/to/file1.dart` - [What changed]
- `path/to/file2.dart` - [What changed]

## Next Steps:
1. [ ] Complete [specific task]
2. [ ] Test [specific functionality]
3. [ ] Commit and push

## Blockers:
- [Any issues to note]

## Context for Next Account:
[Brief explanation of current state]
```

---

## 📁 Folder Ownership

### Device A Owns:
```
cashier/
├── lib/
├── test/
├── pubspec.yaml
├── .context/           ← Session files for A1/A2/A3
│   ├── A1_SESSION.md
│   ├── A2_SESSION.md
│   └── A3_SESSION.md
└── ...
```

### Device B Owns:
```
customer_app/
├── lib/
├── test/
├── pubspec.yaml
├── .context/           ← Session files for B1/B2/B3
│   ├── B1_SESSION.md
│   ├── B2_SESSION.md
│   └── B3_SESSION.md
└── ...
```

### Shared (Coordinate!):
```
alhai_core/
alhai_design_system/
docs/
```

---

## 🔄 Daily Workflow

### Start of Session:
```bash
# 1. Pull latest
git pull origin develop

# 2. Read session file
cat cashier/.context/CURRENT_SESSION.md

# 3. Continue work
git checkout pos/feat-xxx
```

### End of Session:
```bash
# 1. Save progress
git add .
git commit -m "wip(pos): [brief description]"
git push origin pos/feat-xxx

# 2. Update session file
# Edit SESSION.md with current status
```

---

## 🏷️ Branch Naming

```
pos/feat-login                    # Device A feature
pos/fix-cart                      # Device A fix
customer/feat-catalog             # Device B feature
customer/fix-checkout             # Device B fix
shared/core-update                # Coordinated change
```

---

## 📨 Communication Protocol

### Device A ↔ Device B:
```
📢 "أحتاج تعديل alhai_core - هل عندك تعديلات؟"
✅ "واضح، تفضل"
📢 "تم الدمج - اعمل git pull"
```

### Within Same Device (A1 → A2 → A3):
```
Session files auto-communicate:
- A1 updates SESSION.md before switching
- A2 reads SESSION.md on start
```

---

## ✅ Rules Summary

| Rule | Description |
|------|-------------|
| **File Ownership** | A = cashier only, B = customer_app only |
| **Shared Changes** | Coordinate before editing |
| **Session Handoff** | Update SESSION.md before switching |
| **Git Branch** | pos/* for A, customer/* for B |
| **Commit Prefix** | `feat(pos):`, `feat(customer):`, `feat(core):` |

---

*Document maintained by both devices*
