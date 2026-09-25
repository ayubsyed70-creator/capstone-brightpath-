# Wireframes — BrightPath Learning

Low-fidelity, text-based wireframes (version-controllable, no binary asset needed) for the three
screens the brief names: the parent portal, the coordinator scheduling screen, and the tutor phone view.
Each is followed by its own accessibility review against NFR-4/NFR-004 — reviewed per screen because
WCAG issues are concrete to a layout, not a property of the system in the abstract.

---

## 1. Parent Portal — Schedule & Balance (mobile-first, CON-3/NFR-1)

```
┌─────────────────────────────────┐
│ ☰  BrightPath           EN|ES ▾ │  ← language toggle, NFR-10
├─────────────────────────────────┤
│ Hi, [Guardian name]              │
│                                   │
│ ┌───────────────────────────┐   │
│ │ Credit balance             │   │
│ │        7 credits           │   │  ← FR-037 derived balance,
│ │  (Maya: 5 · Leo: 2)        │   │     cached view per Trap 3
│ │  ⓘ 2 credits expire in     │   │  ← FR-066 60-day expiry warn
│ │     18 days                │   │
│ └───────────────────────────┘   │
│                                   │
│ Upcoming sessions                │
│ ┌───────────────────────────┐   │
│ │ Tue Oct 1 · 4:00pm         │   │
│ │ Maya · Math · Tutor: J.Lee │   │
│ │ [ Request reschedule ]     │   │  ← UC-13: proposes, doesn't
│ └───────────────────────────┘   │     auto-execute UC-6/UC-7
│ ┌───────────────────────────┐   │
│ │ Thu Oct 3 · 5:00pm         │   │
│ │ Leo · Reading (online)     │   │  ← mode shown; no centre
│ │ [ Join link available     │   │     shown for online (Trap 2)
│ │   day-of ]                 │   │
│ │ [ Request reschedule ]     │   │
│ └───────────────────────────┘   │
│                                   │
│ [ View statement ]  [ Buy more ] │  ← D5 invoice / D4 renewal
└─────────────────────────────────┘
```

### Accessibility review — Parent Portal (NFR-004)
| Check | Status | Note |
|---|---|---|
| Programmatic label on every input | Pass (by design) | Language toggle and both buttons need explicit `aria-label`/`<label>`, not icon-only |
| Contrast ≥ 4.5:1 | Needs verification at build | The expiry warning (ⓘ icon) must not rely on colour alone — icon + text carries the meaning, which this layout does |
| Usable on a 5-inch screen | Pass by construction | Single-column, no horizontal scroll, cards stack vertically |
| Screen-reader flow | Needs verification at build | Balance breakdown ("Maya: 5 · Leo: 2") must be one readable sentence to a screen reader, not two visually-adjacent but unrelated text nodes |
| Reschedule request vs. immediate action | Pass | Labelled "Request," not "Change," so a screen-reader user isn't misled into thinking the action is final |

---

## 2. Coordinator Scheduling Screen (desktop/kiosk, CON-4/CON-8/NFR-007)

```
┌───────────────────────────────────────────────────────────────────┐
│ BrightPath — Tempe Centre          [Marcus Webb ▾]   Week of Sep 28 │
├───────────────────────────────────────────────────────────────────┤
│  Mon    Tue    Wed    Thu    Fri            Room A | Room B | Onl. │
│ ┌────┐┌────┐┌────┐┌────┐┌────┐                                     │
│ │3:00││3:00││    ││3:00││    │  ← empty slot = unscheduled          │
│ │J.Lee││— ││R.Kim││J.Lee││— │     time; click to open matcher       │
│ └────┘└────┘└────┘└────┘└────┘                                     │
│ ┌────┐┌────┐┌────┐┌────┐┌────┐                                     │
│ │4:00││4:00││4:00││ ⚠ ││4:00│  ← ⚠ = tutor reported unavailable,     │
│ │A.Diaz││A.Diaz││ — ││cover ││ — │    cover search in progress (FR-023) │
│ └────┘└────┘└────┘└────┘└────┘                                     │
│                                                                       │
│ [ + New session ]                          Balance check: ✓ auto     │
│                                                                       │
│ ── New session panel (opens on click) ───────────────────────────── │
│ │ Student: [search...]      Subject: [Math ▾]  Grade: [8 ▾]        │
│ │ Qualified & available tutors:                                    │
│ │   ○ J. Lee   (Tue/Thu 3–6, qualified)                            │
│ │   ○ A. Diaz  (Mon/Wed/Fri 3–6, qualified)                        │
│ │   — no unqualified tutors shown (FR-010) —                       │
│ │ Balance: 7 credits available   [ Override (0/2 used) ]           │
│ │                          [ Cancel ]   [ Confirm booking ]         │
│ └────────────────────────────────────────────────────────────────  │
└───────────────────────────────────────────────────────────────────┘
```

### Accessibility review — Coordinator Screen (NFR-004)
| Check | Status | Note |
|---|---|---|
| Programmatic label on every input | Needs work | The grid's day/time cells must not be the *only* way to identify a slot — each cell needs a text label ("Monday 3:00pm, Tempe Room A, unscheduled") for screen-reader and keyboard nav, since a shared kiosk (CON-8) may be the only access some coordinators have |
| Contrast ≥ 4.5:1 | Needs verification | The `⚠` cover-search indicator needs a text equivalent, not just colour/icon, consistent with WCAG's "don't rely on colour alone" |
| Keyboard operability | Needs work | CON-4's 3-hour training budget means this screen must be operable without memorizing keyboard shortcuts — the click-to-open matcher pattern shown here is deliberately simple over "efficient," trading power-user speed for NFR-007's 20-minute target with minimal training |
| 5-inch phone usable | N/A by design | This screen is desktop/kiosk-only (CON-8); the tutor's mobile needs are served by the separate phone view below, not a responsive collapse of this grid |

---

## 3. Tutor Phone View (mobile web, CON-3 — no app install)

```
┌─────────────────────┐
│ BrightPath           │
│ [J. Lee ▾]            │
├─────────────────────┤
│ My schedule           │
│                       │
│ Today, Tue Oct 1      │
│ ┌───────────────┐   │
│ │ 3:00–3:55pm    │   │
│ │ Maya R. · Math │   │
│ │ [Mark delivered]│  │  ← leads to UC-9 attendance
│ └───────────────┘   │     + progress note flow
│ ┌───────────────┐   │
│ │ 4:00–4:55pm    │   │
│ │ Group (3) ·    │   │
│ │ Reading        │   │
│ │ [Mark delivered]│  │
│ └───────────────┘   │
│                       │
│ [I can't make a       │
│  session ▾]           │  ← FR-023 trigger for cover
│                       │     search, not a phone call
│ ── My availability ── │
│ Mon-Fri 3-6pm ✓        │
│ [ Edit availability ] │  ← FR-012, no app install
│                       │     required (CON-3)
└─────────────────────┘

── After tapping "Mark delivered" ──
┌─────────────────────┐
│ Session: Maya R.      │
│ Math · 3:00pm         │
├─────────────────────┤
│ Attendance: [Present▾]│
│ Progress note:        │
│ ┌───────────────┐   │
│ │ (free text)    │   │
│ └───────────────┘   │
│ [ Submit ]            │  ← FR-040: both required
│  ⓘ Due within 24h     │     before credit deducts
└─────────────────────┘
```

### Accessibility review — Tutor Phone View (NFR-004)
| Check | Status | Note |
|---|---|---|
| No app install, mobile web only | Pass by construction | Satisfies CON-3 directly |
| Programmatic label on every input | Needs work | The attendance dropdown and progress-note textarea both need explicit labels, not placeholder-text-as-label (a common WCAG failure on compact mobile forms) |
| Contrast ≥ 4.5:1 | Needs verification | Card borders and the "due within 24h" reminder text need contrast checking against whatever background colour is chosen at build |
| 5-inch screen usable | Pass by construction | Single column, large tap targets appropriate for one-handed phone use between sessions |
| Cognitive load under time pressure | Design intent | Tutors fill this in "in the last week" today per §2 — the two-tap flow (mark delivered → attendance + note) is deliberately short precisely because BR-07's 24-hour deadline means this is often done quickly between sessions, not at a desk |

---

## Cross-cutting accessibility notes (apply to all three)

- **Colour is never the only signal** anywhere in these wireframes — the `⚠` cover-search flag, the
  expiry warning `ⓘ`, and any future status colour-coding all pair an icon/text with colour, per WCAG
  2.2 AA's non-text-contrast and use-of-colour requirements.
- **None of these wireframes specify a font, exact colour palette, or component library** — that's
  deliberately left to implementation, consistent with the SRS's own rule that FRs (and by extension
  these wireframes) describe capability and layout intent, not visual design decisions.
- The coordinator screen is the one screen where accessibility and CON-4 (minimal training) pull in the
  same direction — a genuinely accessible, keyboard-and-label-driven UI is also the simplest one for a
  coordinator with no confidence in computers, so there's no real trade-off to negotiate there.
