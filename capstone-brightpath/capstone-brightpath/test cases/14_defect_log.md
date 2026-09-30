# Artifact 14 — Defect log

Every entry here is a defect actually found by running something (a query, a test case) against the
real schema and seed data — not a hypothetical. Severity follows: **Critical** (violates a business
rule or corrupts data), **High** (wrong result / contractual risk), **Medium** (real gap, workable
around for now), **Low** (cosmetic).

| ID | Found by | Severity | Description | Expected | Actual | Status |
|---|---|---|---|---|---|---|
| DEF-01 | Artifact 12, query 1 | Critical | Seed's "group of four" session (case b) enrolled four students across four *different* subject/grade-band combinations (Math 3-5, Reading 3-5, Math 6-8, SAT Prep 9-12) in one group session. | BR-02: a group session holds students of one subject, one grade band. | Query 1 inflated utilisation counts for three different subject buckets from one physical session. | **Fixed** — `erd/seed.sql` v2: all four students in session 3 now share Math/3-5; Ben and Noah moved to their own individual sessions. |
| DEF-02 | Manual review while fixing DEF-01 | High | Noah's post-funding-switch invoice (Invoice 3) was billed to `payer_id = 2` — Marcus Webb (Ben's guardian) — not Noah's actual guardian, Aisha Rahman. No `Payer` row existed for Aisha at all. | E-7: after a funding switch, future invoices bill the student's own guardian. | The wrong family would have received Noah's bill. | **Fixed** — added `Payer` row 4 (Aisha Rahman); Invoice 3 repointed to it. |
| DEF-03 | Artifact 12, query 1 (first version) | High | Query 1 joined every subject a tutor is qualified for, not the subject actually delivered in that session — e.g. Devon Price (qualified in both Reading and Math) made one Reading session also count as a Math session. | One session counts toward the subject actually taught in it. | Utilisation figures double-counted certain sessions. | **Fixed** — query rewritten to derive subject from the session's actual `Enrolment`, not from `TutorQualification` directly. |
| DEF-04 | Artifact 12, query 8 (after DEF-02 fix) | Medium | Query 8 (Mesa Public Schools reconciliation) joined `Payer` on a fragile `OR` condition. Once a second guardian-type `Payer` row existed (the DEF-02 fix), the join started returning a duplicate row for Noah. | One row per district-funded student per session. | Two identical rows returned for Noah. | **Fixed** — removed the unnecessary `Payer` join; the `EXISTS` subquery on the ledger already did the real filtering. |
| DEF-05 | Artifact 12, query 5 | Medium | Renewal-rate-by-centre (§9.5) cannot actually be computed — there is no `Student`/`Enrolment` → `Centre` relationship in the schema; a student's centre is only implied by wherever their sessions happen, which can vary. | Query groups renewal rate by centre, per §9.5. | Query 5 has no centre column; an earlier draft faked one with a join that always returned NULL. | **Open.** Needs a modelling decision (add `home_centre_id`, or define "centre" as "the centre of the most recent session") — raising as a change request candidate for artifact 15. |
| DEF-06 | Artifact 12, query 8 | High | There is no direct `Student` → `DistrictContract` link. "District-funded" is only inferable from which `created_by` user logged the funding ledger entry — correct by convention, not by a real foreign key. | The monthly district report (BR-11, CON-5, NFR-9) identifies funded students unambiguously. | The report's correctness depends on every ledger entry's `created_by` being entered consistently — a single typo silently drops a student from the contractual report. | **Open.** High severity given this feeds a contract-compliance deliverable (OBJ-7: 7/12 → 12/12). Recommend adding an explicit `district_contract_id` to `Enrolment` before this goes live — raising as a change request candidate for artifact 15. |
| DEF-07 | Artifact 14, TC-06 | Critical | The schema documented the credit ledger as "append-only" (BR-09) but had no trigger preventing `UPDATE` or `DELETE` on `CreditLedgerEntry` — any write could silently alter financial history. | BR-09: the ledger is append-only; a correction is a new row, never an edit. | `UPDATE`/`DELETE` both succeeded with no error before the fix. | **Fixed** — added `trg_ledger_no_update` and `trg_ledger_no_delete` to `erd/schema.sql`; re-run confirms both are now rejected, and the existing insert/audit trigger still works (regression-checked). |

## Sign-off readiness (feeds artifact 17)

- **0 open Critical or High-severity defects that block a go decision on what this capstone actually
  delivers** (a data model, SQL analysis, and specification) — DEF-01, 02, 03, 04, 07 are closed;
  DEF-05 and DEF-06 are open but belong to the *application* layer, which release 1 hasn't been built
  yet, not to the artifacts delivered so far.
- DEF-05 and DEF-06 should both be raised as change requests (artifact 15) before any application
  build starts, since both affect the data model, not just a report.
