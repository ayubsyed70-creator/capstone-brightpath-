# Stakeholder Map & RACI — BrightPath Learning

## 1. Stakeholder map

```
                         ┌─────────────────────────┐
                         │  Dr. Yolanda Reyes       │
                         │  Director/Owner (SPONSOR)│
                         └────────────┬─────────────┘
                                      │ signs off scope & budget
              ┌───────────────────────┼───────────────────────┐
              │                       │                       │
     ┌────────▼────────┐   ┌──────────▼─────────┐   ┌─────────▼─────────┐
     │ Marcus Webb      │   │ Sofia Almeida       │   │ Ruth Halloran      │
     │ Coordinator,     │   │ Coordinator, Mesa   │   │ Billing Admin      │
     │ Tempe (pilot)    │   │ (district liaison)  │   │ (part-time)        │
     └────────┬─────────┘   └──────────┬──────────┘   └─────────┬─────────┘
              │                        │                         │
     ┌────────▼─────────┐    ┌─────────▼──────────┐             │
     │ Devon Price       │    │ Mesa Public Schools │             │
     │ Tutor (proxy for  │    │ liaison             │             │
     │ 38 tutors)        │    │ (external, can      │             │
     └───────────────────┘    │  terminate contract)│             │
                               └─────────────────────┘             │
     ┌───────────────────┐                                        │
     │ Guardian (proxy —  │◄───────────────────────────────────────┘
     │ no rep exists yet) │        pays; receives statements
     └────────┬───────────┘
              │ consents for
     ┌────────▼───────────┐
     │ Student (minor,     │
     │ not consulted)      │
     └─────────────────────┘
```

## 2. Getting a parent and a tutor view (§4's gap)

§4 is explicit that tutors "have not been asked yet" and there is "no single [parent] representative."
Both gaps are addressed the same way, not by inventing consent that doesn't exist:

- **Tutor view.** Devon Price is named in §4 and available "20 min, evenings" — that's the entry point.
  He's treated as **Consulted**, not a decision-maker, on anything that touches the tutor-facing schedule
  view or utilisation reporting (R-5). His input is elicited specifically on: whether the mobile schedule
  view is usable without an app install (CON-3), and whether utilisation reporting reads as monitoring.
  This is logged as an open item until the interview actually happens (questions log Q-A1).
- **Parent view.** No representative exists (R-4). Rather than design blind, the team requests the
  director recruit **one guardian volunteer** (any guardian, funded or self-pay) for a single usability
  walkthrough of the portal wireframes before sign-off — logged as Q-A13. Until that happens, the parent
  row in this RACI is marked **Consulted (pending)** and the portal design proceeds on the assumptions
  in the vision & scope doc (A-2), with the gap disclosed, not hidden.

## 3. RACI — by capstone artifact / decision area

**R** = Responsible (does the work) · **A** = Accountable (owns the decision, one per row) ·
**C** = Consulted (two-way input before the decision) · **I** = Informed (told after)

| Decision area | Director (Reyes) | Tempe Coord. (Webb) | Mesa Coord. (Almeida) | Tutor proxy (Price) | Billing Admin (Halloran) | Guardian proxy | Mesa liaison (external) |
|---|---|---|---|---|---|---|---|
| Scope & budget sign-off | **A** | C | C | I | I | — | I |
| Business rules (BR-01–13) | **A** | C | C | C | C | I | I (BR-11 only) |
| Credit ledger design & migration (A-1) | A | C | C | — | **R/A**¹ | I | — |
| Scheduling / cover workflow (E-3) | I | **A**² | C | **C** | — | — | — |
| Parent portal UX | A | C | — | — | — | **C (pending)** | — |
| Tutor schedule view UX | I | C | — | **A/C**³ | — | — | — |
| Mesa CSV export layout & deadline (CON-5) | I | — | **A** | — | C | — | **C (source of truth)** |
| Progress reports / district visibility (BR-11) | A | C | C | I | — | I | I (attendance only) |
| Safeguarding incidents (E-8) | **A** (director-only) | R (reports) | R (reports) | R (reports) | — | — | — |
| AI feature specification (§10) | **A** | C | — | C (bias/fairness input) | — | I | — |
| Go/no-go sign-off (release 1) | **A** | C | C | I | I | — | I |

¹ Ruth is Responsible for the actual reconciliation work but Accountable jointly with the director for
disputed balances she can't resolve alone (A-1).
² Marcus is Accountable for how Tempe's pilot schedule works day to day; the director is only Informed
because CON-2 makes Tempe's pilot outcome a scope decision, not an operational one, once it's evaluated.
³ Devon is Accountable only in the sense that his acceptance is the pilot's usability gate (R-5) — the
actual sign-off authority still sits with the director; this is called out because if it's collapsed into
a plain "C" the surveillance risk (R-5) gets no real check.

## 4. What this RACI does not resolve

- The **student** has no row above. Per CON-6, consent sits with the guardian and the student is
  explicitly "not consulted" in §4 — this is a deliberate design constraint (a minor's tutoring
  arrangement is not theirs to authorize), not an oversight to fix.
- The **Mesa liaison**'s only real authority in this project is external and binary: they can terminate
  the contract (§4). They are not a design stakeholder for anything except the CSV layout and deadline
  itself (CON-5) — everything else routed through Sofia Almeida internally.
