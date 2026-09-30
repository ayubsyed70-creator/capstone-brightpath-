# Artifact 15 — Change Request CR-01

**Status: proposed, not yet implemented.** Per §4, scope changes are signed off by Dr. Yolanda Reyes
(director/sponsor). This document is the proposal and impact analysis for that decision — building it
would be a follow-on task once approved, not something to do unilaterally mid-capstone.

## Raised from the brief's own tension

§5 puts district reporting squarely **in scope** — the Mesa Public Schools monthly CSV (BR-11,
CON-5, NFR-9) is one of only seven business objectives (OBJ-7), and it's explicitly one of the four
things that "cannot be changed or negotiated" (CON-5). §5's in-scope renewal analysis (§9.5, feeding
OBJ-5) is equally explicit. But §9.2's given entity list — the attributes the brief hands you — has no
field connecting a `Student` or `Enrolment` to the `Centre` they attend or to the `DistrictContract`
that funds them. The brief specifies the *deliverable* (a contractually-required monthly report, a
renewal-by-centre figure) without specifying the *data* needed to produce either reliably. That's the
tension: two objectives the brief insists are load-bearing, resting on a data model the brief itself
never quite finishes.

This surfaced concretely as two logged defects, not as a hypothetical:

- **DEF-06** (artifact 14): there is no `Enrolment`/`Student` → `DistrictContract` link. "District-
  funded" is only inferable from which `created_by` user logged a ledger entry — correct today only
  because the seed data is consistent by convention, not by a real foreign key. A single data-entry
  typo would silently drop a student from a contractually-required report.
- **DEF-05** (artifact 14): there is no `Student`/`Enrolment` → home `Centre` link, so §9.5's
  "renewal rate by centre" cannot be computed at all — artifact 12's query 5 has no centre column
  because there's nothing to put in it.

## Proposed change

Add two things to the data model:

1. **`Enrolment.home_centre_id`** (nullable FK → `Centre`) — nullable because an online-only
   enrolment has no home centre, same reasoning as `Session.centre_id`.
2. **A new `StudentFunding` table**: `(id, student_id, district_contract_id, start_date, end_date
   NULLABLE)` — an *effective-dated* record of funding periods, not a single mutable column on
   `Student`. This is deliberately more than the minimum fix, and the trade-off is worth stating
   explicitly:
   - **Minimum fix** (rejected): add `Student.district_contract_id` directly. Simpler, but E-7
     ("funding ends mid-bundle... billing switches to the guardian from that date") becomes a
     silent overwrite — the moment it happens, you lose the ability to say *when* a student was
     district-funded, which is exactly the kind of thing a contract audit asks for.
   - **Recommended fix**: `StudentFunding` with start/end dates preserves that history and makes
     E-7 a new row, not an edit — consistent with how BR-09 already treats the credit ledger.
   - Recommending the more thorough fix, but flagging that the minimum fix is a legitimate fallback
     if the director weighs CON-1/CON-2 (fixed budget, fixed fall-2027 deadline) against the added
     table and decides the simpler version is worth the lost history for release 1.

## Impact analysis — every artifact this touches

| Artifact | Impact | What changes |
|---|---|---|
| 8. SRS | Direct | FR-16 (new): record an enrolment's home centre. FR-17 (new): record a student's district-funding periods with start/end dates. Both trace to existing objectives (OBJ-5, OBJ-7) — no new objective needed. |
| 11. ERD + schema + seed | Direct | `erd/erd.md`: add the `Enrolment → Centre` relationship and the new `StudentFunding` entity. `erd/schema.sql`: `ALTER TABLE Enrolment ADD COLUMN home_centre_id`; `CREATE TABLE StudentFunding`. `erd/seed.sql`: populate `home_centre_id` for all 7 enrolments; replace the inferred Noah funding (currently read off `CreditLedgerEntry.created_by`) with two explicit `StudentFunding` rows (district period, then guardian period from the switch date). |
| 12. SQL analysis | Direct | Query 5 (renewal by centre) rewritten to join `Enrolment.home_centre_id` instead of omitting centre entirely. Query 8 (Mesa reconciliation) rewritten to join `StudentFunding` instead of the fragile `created_by` inference — this also removes the "fragile even now" caveat recorded against DEF-06. |
| 13. RTM | Direct | Add rows for FR-16/FR-17 with new stories (US-16, US-17) and new test-case IDs (TC-25, TC-26), following the existing no-orphans pattern. |
| 14. Test cases & defect log | Direct | New test cases for `StudentFunding` (e.g., a student's funding periods must not overlap — a boundary case worth adding). DEF-05 and DEF-06 move from Open to "Addressed by CR-01, pending approval" rather than silently closing before the fix actually exists. |
| 6. Use cases | Indirect | The enrolment use case should mention selecting a home centre at enrolment time; the E-7 funding-switch exception path should reference creating a new `StudentFunding` row rather than "billing switches." |
| 10. Wireframes | Indirect | The enrolment/intake screen needs a centre-selection field. Not redrawn here — flagging it so whoever owns the wireframes artifact doesn't discover the gap after the fact. |
| 5. BPMN | Indirect | E-7's swimlane step changes from an implicit billing change to an explicit "close funding period / open new funding period" action. |
| 1–4, 7, 9, 16–18 | None | Vision/scope, stakeholders, context diagram, backlog structure (beyond the two new stories), AI feature spec, sign-off template, and reflection aren't affected by a schema addition of this size. |

## Effort and risk

Small in isolation — two columns' worth of schema change plus one small table — but CON-1 ($120,000,
no contingency) and CON-2 (fixed fall-2027 term date) mean *any* added scope should be named
explicitly rather than absorbed silently, per R-3 ("the fall-term date and the fixed budget cannot
both survive scope growth"). This CR is small enough that it likely doesn't trip R-3 on its own, but
it's the kind of change that accumulates — recommend batching it with any other release-1 schema
change found before implementation starts, rather than doing one-off migrations per defect.

## Recommendation

Approve the `StudentFunding` table version. It directly fixes a defect that affects a contractually
required, audited deliverable (OBJ-7), and the audit-style benefit (knowing exactly when a student's
funding source changed) is the same reasoning BR-09 already applies to the credit ledger — so it's
consistent with a pattern the brief already trusts, not a new one.
