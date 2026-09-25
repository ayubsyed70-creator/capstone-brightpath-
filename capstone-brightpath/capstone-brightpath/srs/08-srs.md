# Software Requirements Specification (SRS) — BrightPath Learning

Numbering: `FR-0xx` functional, `NFR-0xx` non-functional (renumbered from the brief's NFR-1..10 to a
zero-padded scheme consistent with the FRs; the brief's original ID is kept in the Source column so
nothing gets lost in translation). Each requirement states a verifiable condition — no requirement here
describes a button, a screen, or a layout (deduction item in §12 of the brief).

## Functional Requirements

### Consent & Records (OBJ-4, CON-6)

| ID | Requirement | Trace | Source |
|---|---|---|---|
| FR-001 | The system shall prevent a session being scheduled for a student with no consent record on file. | OBJ-4, CON-6 | BR-12, US-A1 |
| FR-002 | The system shall flag a student's consent as due for renewal when it is 350 days or older. | OBJ-4 | BR-12, US-A2 |
| FR-003 | The system shall block scheduling for a student whose consent has passed 365 days without renewal. | OBJ-4, CON-6 | BR-12, US-A2 |

### Tutor Qualification, Availability & Matching (OBJ-6, OBJ-1)

| ID | Requirement | Trace | Source |
|---|---|---|---|
| FR-010 | The system shall exclude a tutor from match results for a subject/grade band they hold no qualifying `TutorQualification` for. | OBJ-6 | BR-01, US-B1 |
| FR-011 | The system shall require the certified tier qualification specifically for SAT-prep matches. | OBJ-6 | BR-01, US-B1 |
| FR-012 | The system shall allow a tutor to record recurring weekly availability and one-off date exceptions independently, with exceptions taking precedence over the recurring pattern for that date. | OBJ-1, OBJ-6 | US-B2 |
| FR-013 | The system shall compute weekly tutor utilisation as booked hours ÷ declared available hours, reported by tutor, centre, and subject. | OBJ-6 | US-B3 |

### Scheduling & Cover (OBJ-1, OBJ-2)

| ID | Requirement | Trace | Source |
|---|---|---|---|
| FR-020 | The system shall reject a booking that would double-book a tutor for an overlapping time window. | OBJ-1 | BR-02, US-C1 |
| FR-021 | The system shall reject adding a fifth student to a group session, and shall reject adding a student whose subject or grade band differs from the group's. | OBJ-1 | BR-02, US-C1 |
| FR-022 | The system shall set a new session's status to `Scheduled` and transition it only along the paths `Requested→Scheduled→Confirmed→Delivered→Recorded`, with `Cancelled` reachable from `Requested`, `Scheduled` or `Confirmed`, and `NoShow` reachable only from `Confirmed`. | OBJ-1, OBJ-3 | BR-08 |
| FR-023 | On a tutor reporting inability to cover a `Confirmed` session, the system shall search for qualified, available tutors and start a 24-hour countdown to the session start time. | OBJ-1 | E-3, US-C3 |
| FR-024 | If a qualified tutor accepts a cover request before the 24-hour countdown expires, the system shall reassign the session, keep its status `Confirmed`, and notify the guardian of the tutor change. | OBJ-1 | E-3, US-C3 |
| FR-025 | If no cover is found before the countdown expires, the system shall set the session to `Cancelled`, return the original credit, issue a goodwill credit, and log the event with reason `no cover`. | OBJ-1 | E-3, US-C3 |
| FR-026 | The system shall send a notification to the affected guardian and tutor within 60 seconds of any change to a session's time, tutor, or status. | OBJ-1, OBJ-2 | NFR-8 (orig.), US-C4 |

### Credits & Ledger (OBJ-3, OBJ-5)

| ID | Requirement | Trace | Source |
|---|---|---|---|
| FR-030 | The system shall record every credit-affecting event (bundle purchase, deduction, return, override, expiry, goodwill credit, adjustment) as a new, immutable entry in the credit ledger; no existing entry shall be editable or deletable. | OBJ-3 | BR-09, US-D1 |
| FR-031 | The system shall return the credit for a session cancelled 24 or more hours before its start time. | OBJ-3 | BR-05, US-D2 |
| FR-032 | The system shall consume the credit for a session cancelled less than 24 hours before its start time, or for a student no-show, unless a coordinator records a waiver. | OBJ-3 | BR-05, US-D2 |
| FR-033 | The system shall allow at most one no-show waiver per student per term, rejecting any subsequent waiver attempt that term. | OBJ-3 | BR-05, US-D2 |
| FR-034 | The system shall reject a new booking when the student's current balance is below the session's credit cost, unless a coordinator records an on-account override. | OBJ-3, OBJ-5 | BR-06, US-D3 |
| FR-035 | The system shall reject an on-account override once a student has reached 2 overrides in the current term. | OBJ-3 | BR-06, US-D3 |
| FR-036 | The system shall issue a 30-day advance expiry warning to the guardian for any bundle credits approaching 12 months since purchase, and shall expire those credits with no refund at 12 months. | OBJ-3, OBJ-5 | BR-04, US-D4 |
| FR-037 | The system shall compute a student's current usable credit balance consistently from the ledger, such that the sum of all entries always reconciles to the displayed balance. | OBJ-3 | BR-09, US-D1 |
| FR-038 | The system shall apply Arizona's 8.6% tax to materials line items on an invoice and no tax to tuition line items on the same invoice. | OBJ-3 | BR-10, US-D5 |
| FR-039 | On a district-funded student's funding ending, the system shall route billing for sessions delivered from that date forward to the guardian, leaving previously recorded credit movements unchanged. | OBJ-3 | E-7 |

### Attendance & Progress (OBJ-4)

| ID | Requirement | Trace | Source |
|---|---|---|---|
| FR-040 | The system shall require one attendance record and one progress note per student in a session before deducting that session's credit or setting its status to `Recorded`. | OBJ-4 | BR-07, US-E1 |
| FR-041 | The system shall require a separate progress note for each student in a group session — not one shared note per session. | OBJ-4 | US-E2 |
| FR-042 | The system shall exclude progress-note content from any export or report sent to Mesa Public Schools, including attendance-only reports for district-funded students. | OBJ-4 | BR-11, US-E3 |
| FR-043 | The system shall generate a termly progress report to the guardian at the end of each term for every enrolment with at least one recorded progress note. | OBJ-4 | BR-11 |
| FR-044 | The system shall not count an online session that fails technically as delivered, shall return its credit, and shall record the reason distinctly from a no-show. | OBJ-1, OBJ-4 | E-9 |

### Mesa Public Schools Compliance (OBJ-7)

| ID | Requirement | Trace | Source |
|---|---|---|---|
| FR-050 | The system shall generate a monthly attendance export matching the Mesa Public Schools contracted CSV layout exactly (column order, headers, encoding). | OBJ-7 | CON-5, US-F1 |
| FR-051 | The system shall make the monthly export available within 2 business days of month end. | OBJ-7 | US-F1 |
| FR-052 | For a student whose district funding ended mid-month, the system shall include attendance only up to the funding-end date in that month's export. | OBJ-7 | E-7 |

### Reporting & Access Control (OBJ-3, OBJ-5, OBJ-6, CON-6)

| ID | Requirement | Trace | Source |
|---|---|---|---|
| FR-060 | The system shall report total unused, unexpired credit liability in dollars, computed as the live sum of the credit ledger, on demand. | OBJ-3 | US-G3 |
| FR-061 | The system shall report package renewal rate by centre and subject, counting a renewal only when a new bundle is purchased within 30 days of the prior bundle's exhaustion. | OBJ-5 | US-G4 |
| FR-062 | The system shall report sessions lost with reason `no cover`, by week and centre. | OBJ-1 | §9.5 |
| FR-063 | The system shall report cancellation and no-show rate by centre, tutor, and reason. | OBJ-3 | §9.5 |
| FR-064 | The system shall report demand versus qualified tutor capacity, per subject and grade band. | OBJ-6 | §9.5 |
| FR-065 | The system shall report enrolments with no progress note recorded in the preceding 30 days. | OBJ-4 | §9.5 |
| FR-066 | The system shall report credits expiring within the next 60 days. | OBJ-3 | §9.5 |
| FR-067 | The system shall restrict a tutor's visible records to their own assigned students, a coordinator's visible records to their own centre, and shall permit the director to see all centres and all records. | OBJ-3, CON-6 | BR-13, US-H1 |
| FR-068 | The system shall restrict visibility of a safeguarding or behaviour incident to the director only, overriding the normal centre-level visibility a coordinator would otherwise have. | CON-6 | E-8, US-H2 |
| FR-069 | The system shall log every access to a student record with the accessing user's identity, the record accessed, and a timestamp. | CON-6 | US-H3 |

---

## Non-Functional Requirements

Each NFR restates the brief's original (§8) with the same ID kept for traceability, plus a stated
verification method — a requirement without a way to check it isn't really a requirement.

| ID (orig.) | Requirement | Trace | Verification method |
|---|---|---|---|
| NFR-001 (NFR-1) | The parent portal's schedule and balance view shall load in under 2 seconds at the 95th percentile on a 4G connection. | OBJ-3 | Load testing against a simulated 4G profile; measure p95 over ≥500 requests |
| NFR-002 (NFR-2) | The system shall be available 99.5% of the time Mon–Sat 12:00–21:00 MST, with the 15:00–19:00 window treated as the critical peak. | OBJ-1, OBJ-2 | Uptime monitoring over a rolling 30-day window; MST fixed, no DST adjustment (Arizona) |
| NFR-003 (NFR-3) | The system shall support 120 concurrent users at peak without degrading NFR-001's load time. | OBJ-2, OBJ-3 | Load testing with 120 simulated concurrent sessions mixing tutor and guardian traffic |
| NFR-004 (NFR-4) | The system shall meet WCAG 2.2 AA on every screen, with every form input carrying a programmatic label and contrast ≥4.5:1, and every screen usable on a 5-inch phone. | CON-3 | Automated accessibility scan + manual screen-reader pass; viewport testing at 5-inch dimensions |
| NFR-005 (NFR-5) | Financial records shall be retained 7 years; progress notes 3 years after student exit; safeguarding incidents 25 years, director-only access; session video shall never be stored. | CON-6 | Retention policy configuration review; confirm no video storage path exists in the architecture |
| NFR-006 (NFR-6) | Every access to a student record shall be logged with user, record, and timestamp, consistent with FR-069 and BR-13. | CON-6 | Audit log inspection against a scripted set of test accesses across roles |
| NFR-007 (NFR-7) | A coordinator with 3 hours of training shall be able to schedule a full week for one centre in 20 minutes or less. | OBJ-2 | Usability test with a representative coordinator (not yet trained beyond the 3-hour budget), timed |
| NFR-008 (NFR-8) | A schedule change shall reach the affected tutor and guardian as a notification within 60 seconds. | OBJ-1 | Timestamp comparison between the triggering change and notification delivery, sampled in production |
| NFR-009 (NFR-9) | The Mesa Public Schools export shall match the contracted layout exactly and be produced within 2 business days of month end. | OBJ-7 | Byte-level diff against a reference export; delivery timestamp check each month |
| NFR-010 (NFR-10) | The system shall be usable in English and Spanish. | OBJ-3, OBJ-4 | Full UI string coverage check in both locales; native-Spanish-speaker review pass |

---

## Requirement quality checks applied

- **Verifiable:** every FR and NFR above has an observable pass/fail condition (a rejection, a value, a
  timing bound, a report field) — none says a system "should be easy to use" without a measurable
  standard attached (NFR-007 gives the usability claim a number and a method instead).
- **Unambiguous:** relative terms ("qualified," "available," "current") are anchored to the entities and
  rules already defined in the brief's data dictionary (§9.2) and business rules (§7), not redefined here.
- **Free of design:** no FR specifies a button, a field layout, or a screen name — FR-012, for example,
  requires the *capability* (recurring + exception availability, with exceptions taking precedence) and
  leaves the UI to the wireframes (artifact #10).
- **Traceable:** every row's Trace column points to an OBJ; every row's Source column points to the
  business rule, exception, or backlog story it comes from, so the RTM (artifact #13) can be built by
  reading down this table rather than re-deriving it.
