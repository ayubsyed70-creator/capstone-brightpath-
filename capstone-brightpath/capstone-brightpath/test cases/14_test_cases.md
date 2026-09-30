# Artifact 14 — Test cases

Test case IDs match the placeholders reserved in `rtm/13_rtm.md` (TC-01 to TC-15), plus additional
boundary/negative cases (TC-16 onward) not tied to a single story.

**Honesty note on what "executable" means here.** This capstone builds a schema, seed data and SQL
analysis — not a running application. So a test case is only truly executable right now if the rule
it checks is enforced by the database itself (a `CHECK`, `UNIQUE`, or trigger in `erd/schema.sql`).
Those are marked **DB-enforced, executed below** and actually run against the schema, with a real
pass/fail result. Everything else is marked **Application logic — not yet built**: the rule is
correctly specified in the brief and belongs to a layer this capstone doesn't implement. Claiming
those as "tested" would be the "SELECT * as an answer" kind of shortcut the rubric explicitly
penalises, just one level up — so they're listed as specified test cases for whoever builds the
application, not marked as passed.

**TC-06 initially failed.** Running it the first time found that the schema claimed the credit
ledger was append-only (BR-09) but had no actual trigger stopping `UPDATE`/`DELETE` — anyone could
silently edit or delete a ledger row. Fixed in `erd/schema.sql` by adding `trg_ledger_no_update` and
`trg_ledger_no_delete`; re-run confirms both now reject, and a regression check confirms the
existing `INSERT`/audit trigger still fires normally. See DEF-07 in the defect log.

## Results of the DB-enforced test cases (actually run, this session)

| TC | Result | Evidence |
|---|---|---|
| TC-06 | PASS (after fix — see above) | `UPDATE`/`DELETE` on `CreditLedgerEntry` both rejected with `BR-09: ...append-only` |
| TC-08 | PASS | Ben's (student 3) derived balance = 20.0 — no deduction occurred for the session with attendance but no note |
| TC-09 | PASS | Second `INSERT` into `ProgressNote` for the same `session_student_id` rejected: `UNIQUE constraint failed` |
| TC-18 | PASS | Session 3: 4 rows, 1 distinct subject, 1 distinct grade band |
| TC-22 | PASS | Direct `Requested` → `Delivered` update rejected: `BR-08: illegal session status transition` |
| TC-23 | PASS | Online session with non-NULL `centre_id` rejected by the `CHECK` constraint |
| TC-24 | PASS | `Payer` row with both `guardian_id` and `district_contract_id` set rejected by the `CHECK` constraint |

---

## From the RTM (TC-01 to TC-15)

| TC | Traces to | Type | Enforcement | Given / When / Then |
|---|---|---|---|---|
| TC-01 | FR-01 (no double-booking) | Negative | Application logic — not yet built | Given a tutor is booked 4-5pm Tue; When a second booking for 4-5pm Tue is attempted; Then it is rejected |
| TC-02 | FR-02 (substitute suggestion) | Positive | Application logic — not yet built | Given a tutor cancels a session; When the coordinator opens it; Then qualified, available substitutes are listed |
| TC-03 | FR-03 / NFR-8 (60s notification) | Positive | Application logic — not yet built | Given a schedule change is saved; When 60 seconds pass; Then the affected tutor and guardian have been notified |
| TC-04 | FR-04 (weekly view) | Positive | Application logic — not yet built | Given I am a centre coordinator; When I open the weekly view; Then I see every session at my centre, editable in place |
| TC-05 | FR-05 (live conflict flag) | Negative | Application logic — not yet built | Given a room is at capacity; When a 5th student is added; Then the save is blocked immediately |
| TC-06 | FR-06 / NFR-6 (append-only ledger) | Negative | **DB-enforced, executed below** | Given a ledger row exists; When an `UPDATE` or `DELETE` against it is attempted; Then the schema rejects it |
| TC-07 | FR-07 / NFR-1 (multi-child balance) | Positive | Application logic — not yet built (portal UI) | Given a guardian has two children; When they open the portal; Then both balances show on one screen |
| TC-08 | FR-08 (no deduction without note) | Negative | **DB-enforced, executed below** (via derived view) | Given attendance is recorded but no note exists; When the balance is queried; Then no deduction has occurred for that session |
| TC-09 | FR-09 (one note per student per session) | Negative | **DB-enforced, executed below** | Given a progress note exists for a session_student; When a second note for the same session_student is inserted; Then it is rejected |
| TC-10 | FR-10 (district report excludes notes) | Negative | Application logic — not yet built (export job); partially DB-supported | Given a district-funded student has notes; When the district CSV is generated; Then no note text appears in it |
| TC-11 | FR-11 (renewal reminder) | Positive | Application logic — not yet built | Given a bundle expires in 25 days; When the daily check runs; Then a reminder is sent |
| TC-12 | FR-12 (utilisation report) | Positive | **SQL-verified in artifact 12** | Given delivered sessions exist; When query 1 (artifact 12) runs; Then per-tutor utilisation is returned correctly |
| TC-13 | FR-13 (demand vs. capacity) | Positive | **SQL-verified in artifact 12** | Given enrolments and qualifications exist; When query 7 runs; Then the enrolled:qualified ratio is returned correctly |
| TC-14 | FR-14 / NFR-9 (district CSV timing) | Positive | Application logic — not yet built (scheduled job) | Given a month ends; When 2 business days pass; Then the CSV has been generated |
| TC-15 | FR-15 (CSV excludes other data) | Negative | Application logic — not yet built (export job) | Given a district student has incidents and notes; When the CSV is generated; Then neither appears in it |

## Boundary and negative cases (not tied to a single story)

| TC | Rule | Type | Enforcement | Given / When / Then |
|---|---|---|---|---|
| TC-16 | BR-05 — cancellation exactly at 24h | Boundary | Application logic — not yet built | Given a guardian cancels at exactly 24h00m before the session; When the cancellation is processed; Then the credit is returned (≥24h returns it) |
| TC-17 | BR-05 — cancellation at 23h59m | Boundary/Negative | Application logic — not yet built | Given a guardian cancels at 23h59m before the session; When processed; Then the credit is consumed |
| TC-18 | BR-02 — group session at exactly 4 students | Boundary | **DB-verified against seed, executed below** | Given a group session has 4 enrolled students, one subject, one grade band; When checked; Then it is valid |
| TC-19 | BR-02 — a 5th student in the same group session | Boundary/Negative | Application logic — not yet built | Given a group session already has 4 students; When a 5th is added; Then it is rejected regardless of room capacity |
| TC-20 | BR-06 — on-account override, 2nd use in a term | Boundary | Application logic — not yet built | Given a student has used 1 on-account override this term; When a 2nd is recorded; Then it is allowed (at most 2) |
| TC-21 | BR-06 — on-account override, 3rd use in a term | Boundary/Negative | Application logic — not yet built | Given a student has used 2 on-account overrides this term; When a 3rd is attempted; Then it is rejected |
| TC-22 | BR-08 — illegal status transition | Negative | **DB-enforced, executed below** | Given a session is `Requested`; When it is updated directly to `Delivered`; Then the trigger rejects it |
| TC-23 | §9.3 trap 2 — online session with a centre | Negative | **DB-enforced, executed below** | Given a session has `mode='online'`; When `centre_id` is set to a non-NULL value; Then the CHECK constraint rejects it |
| TC-24 | §9.3 trap 4 — Payer with both guardian and district set | Negative | **DB-enforced, executed below** | Given a Payer row; When both `guardian_id` and `district_contract_id` are non-NULL; Then the CHECK constraint rejects it |
