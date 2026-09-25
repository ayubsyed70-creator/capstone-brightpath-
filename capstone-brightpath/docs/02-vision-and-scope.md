# Vision & Scope — BrightPath Learning

## 1. Problem statement

BrightPath Learning runs ~600 tutoring sessions a week across four centres and an online channel, but
every operational fact that matters — who's available, what a family has paid for, whether a student is
progressing, whether the district contract is being met — lives in a coordinator's head, a whiteboard
photo, a WhatsApp thread, or one of four spreadsheets that don't agree with each other. The business has
grown past the point where informal coordination works: sessions are lost to uncovered tutors, coordinators
spend a third of their week on manual scheduling, ~$80,000 in credit liability can't be stated to the
dollar, and a compliance report to a funder (Mesa Public Schools) has missed its deadline five times this
year.

This project replaces that informal coordination with a single system of record for enrolments,
scheduling, credits and progress — without changing what BrightPath actually does (tutoring), only how it
tracks and schedules the work.

## 2. Objectives, traced to baseline measures

Every objective below is numbered to match §3 of the brief and traced to the §2 measure it targets. A
requirement that doesn't trace to one of these rows is either a missing objective or scope creep (brief's
own instruction) — flag it in the RTM rather than let it float.

| Obj | Objective | Baseline measure (§2) | Baseline → Target | By |
|---|---|---|---|---|
| OBJ-1 | Stop losing sessions to unavailable tutors | Sessions lost, no cover | 26/wk → <8/wk | Fall 2027 |
| OBJ-2 | Give coordinators their week back | Coordinator scheduling time | 11 hrs/wk → <3 hrs/wk | Fall 2027 |
| OBJ-3 | One credit balance everyone can see and trust | Credit-balance disputes | ~18/mo → <3/mo | Spring 2027 |
| OBJ-4 | Make progress visible to parents | Students with goal + progress record | 31% → 100% | Fall 2027 |
| OBJ-5 | Keep more families past the first bundle | Renewal rate at bundle exhaustion | 58% → 75% | 2028 |
| OBJ-6 | Make tutor capacity and demand visible | Tutor utilisation | not measurable → reported weekly | Fall 2027 |
| OBJ-7 | Meet the Mesa Public Schools reporting obligation | On-time monthly report | 7/12 → 12/12 | Spring 2027 |

Two baseline measures in §2 are **not** directly owned by a single OBJ and are worth watching separately:
cancel/no-show rate (14% → <7%) is a shared effect of OBJ-1 and OBJ-3 together (better cover *and* an
enforced credit rule), and days-to-first-session (9 → 2) is a shared effect of OBJ-2 and OBJ-6 (faster
scheduling only works if capacity is visible). Both get their own SRS requirements even without a
one-to-one OBJ.

## 3. Scope

### In scope — release 1
Guardian/student records with consent (BR-12) · enrolments with a stated goal per subject · tutor
profiles, qualifications (BR-01) and declared availability (recurring + exceptions) · session scheduling,
one-to-one and group, in-centre and online · cancellation/no-show/cover handling (E-1–E-3, E-9, E-10) ·
credit bundles and a single append-only ledger (BR-04, BR-09) · invoicing/statements for guardian and
district payers (BR-10, E-7) · attendance and per-student progress notes (BR-07) · termly progress reports
(BR-11) · parent portal (schedule, balance, reschedule request) · tutor schedule view · Mesa Public
Schools monthly CSV export (CON-5, NFR-9) · operational reports (§9.5).

### Out of scope — release 1
Payroll and tutor payments · native mobile app · the video platform itself (links only) · online card
payment (desk/transfer payment recorded, not processed) · curriculum/homework/content library · tutor
recruitment/onboarding · marketing campaigns · SSO with school district accounts · writing back to
QuickBooks (CON-7, export only).

### Deferred, not rejected
AI tutor matching and the at-risk flag (one is specified in §16, neither is built) · automatic
re-scheduling when a tutor drops out · referral/sibling discount scheme.

## 4. Constraints

| ID | Constraint | Design implication |
|---|---|---|
| CON-1 | Budget fixed at $120,000, no contingency | No gold-plating; every deferred item stays deferred |
| CON-2 | Live before fall term 2027; Tempe pilots first | ~6-month build; phased rollout, not big-bang |
| CON-3 | Tutors use personal phones; no required app install | Tutor-facing views must work as mobile web, not a native app |
| CON-4 | Coordinators get 3 hours training total; 2 of 4 not confident with computers | Scheduling UI must clear NFR-7 (full week ≤ 20 min) with minimal training |
| CON-5 | Mesa CSV layout fixed by contract | Export format is a hard external constraint, not negotiable in design |
| CON-6 | Students are minors; consent required before booking; no student sees another's data | Drives BR-12 and BR-13 as non-negotiable gates, not just business rules |
| CON-7 | QuickBooks cannot be modified; CSV export only | No live accounting integration; invoicing lives in-system, exports out |
| CON-8 | One shared desktop per centre + public Wi-Fi | Coordinator UI is single-session, kiosk-like; can't assume a private, fast connection |

## 5. Assumptions

Each assumption needs an owner (who confirms it) and a confirm-by date. Owners below are proposed based
on who in §4 has the relevant authority or knowledge — confirm them with the client and log the answer in
the questions log (Q-A5, Q-A6, Q-A13).

| ID | Assumption | Risk if wrong | Owner (proposed) | Confirm by |
|---|---|---|---|---|
| A-1 | The four centre spreadsheets can be cleansed and merged into one ledger | R-1 — disputes get worse, not better | Billing administrator (Ruth Halloran), with director sign-off on disputed balances | Before data migration begins |
| A-2 | Parents will use a portal instead of phoning the centre | Adoption failure undermines OBJ-3/OBJ-5 | Director (Dr. Reyes) — no parent rep exists yet (Q-A13) | Before portal UI is finalised |
| A-3 | All four centres apply the same cancellation rule | Mesa may forgive no-shows differently (BR-05 exception needed) | Sofia Almeida (Mesa coordinator) + director | Before BR-05 is finalised in the SRS |
| A-4 | Tutors will keep availability current without being chased | R-2 — schedule in system goes stale, WhatsApp persists | Centre coordinators, tutor buy-in via pilot | During Tempe pilot |
| A-5 | Wi-Fi in tutoring rooms is sufficient for online sessions | Online session delivery/no-show misclassification (E-9) | Centre coordinators (facilities check) | Before online scheduling goes live |

## 6. Risks

| ID | Risk | Likelihood/Impact | Mitigation direction |
|---|---|---|---|
| R-1 | Imported credit balances from disagreeing spreadsheets make disputes worse | High/High | Manual reconciliation pass per centre before cutover; publish a single "as-of" balance and freeze old spreadsheets |
| R-2 | Tutors keep using WhatsApp; in-system schedule goes stale | High/High | Pilot at Tempe first (CON-2); make the in-system schedule strictly easier than WhatsApp before wider rollout |
| R-3 | Fixed fall-2027 date and fixed $120k budget can't both survive scope growth | Medium/High | Any scope addition must go through the change-request process (artifact #15) with an explicit budget/date trade-off, not silent absorption |
| R-4 | No parent representative — portal designed on assumption | Medium/Medium | Recruit a proxy guardian for usability review before build sign-off; log as open in questions log |
| R-5 | Tutors read utilisation/scheduling features as surveillance | Medium/High | Frame utilisation reporting as capacity planning, not individual monitoring; involve a tutor (Devon Price) in review |
| R-6 | Mesa contract renewal during build changes the CSV layout or deadline | Low/High | Confirm renewal timeline with Sofia Almeida/district liaison early (Q-A16); design export as a mapping layer, not hard-coded |

## 7. Success criteria for release 1

Release 1 is ready to recommend for go-live (artifact #17) when: every §2 baseline measure has a
corresponding, testable requirement in the SRS; the RTM (artifact #13) has no orphan rows in either
direction; all Critical-severity defects are closed; and the Mesa CSV export has been validated against
the actual contracted layout, not an assumed one.
