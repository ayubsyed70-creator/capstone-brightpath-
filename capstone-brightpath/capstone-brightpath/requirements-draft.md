# Requirements (draft, for RTM traceability)

**Reconcile against your existing `srs/` artifact before treating this as final** — if requirement
IDs already exist there, use those IDs and this file's OBJ-tracing instead.

Every requirement traces to one of §3's seven objectives (OBJ-1 to OBJ-7).

## Functional requirements

| ID | Requirement | Traces to |
|---|---|---|
| FR-01 | The system shall prevent a tutor from being booked into two overlapping sessions (BR-02). | OBJ-1 |
| FR-02 | When a tutor cancels a session, the system shall suggest qualified, available substitute tutors, ranked by fit (E-3). | OBJ-1 |
| FR-03 | The system shall notify the affected tutor and guardian of a schedule change within 60 seconds (NFR-8). | OBJ-1 |
| FR-04 | A coordinator shall be able to view and edit a full week's schedule for one centre from a single screen. | OBJ-2 |
| FR-05 | The system shall flag a scheduling conflict (double-booking, room capacity, qualification mismatch) at the moment it is entered, not after. | OBJ-2 |
| FR-06 | The system shall derive each student's credit balance from an append-only ledger; no balance field shall be directly editable (BR-09). | OBJ-3 |
| FR-07 | A guardian shall be able to view real-time credit balances for every one of their children from a single screen. | OBJ-3 |
| FR-08 | The system shall not deduct a credit for a session until both attendance and a progress note exist for that student (BR-07). | OBJ-3, OBJ-4 |
| FR-09 | A tutor shall be able to submit one progress note per student per session from their phone, without installing an app (CON-3). | OBJ-4 |
| FR-10 | The system shall compile a termly progress report per student; a district-funded student's report to the district shall contain attendance only, never progress notes (BR-11). | OBJ-4 |
| FR-11 | The system shall send a renewal reminder to a guardian when a student's credit balance falls to zero or a bundle is within 30 days of expiry (E-5). | OBJ-5 |
| FR-12 | The system shall report weekly tutor utilisation (booked hours ÷ declared available hours) by tutor, subject and centre. | OBJ-6 |
| FR-13 | The system shall report enrolled-student demand against qualified-tutor capacity, by subject and grade band. | OBJ-6 |
| FR-14 | The system shall generate the Mesa Public Schools monthly attendance report in the contracted CSV layout within 2 business days of month end (CON-5, NFR-9). | OBJ-7 |
| FR-15 | The district CSV export shall contain attendance records only; it shall never include progress notes, incident records, or any other student data (BR-11). | OBJ-7 |

## Non-functional requirements (from brief §8, carried forward for traceability)

| ID | Requirement | Traces to |
|---|---|---|
| NFR-1 | Parent portal schedule/balance view loads in <2s at p95 on 4G. | OBJ-3 |
| NFR-4 | WCAG 2.2 AA; every screen usable on a 5-inch phone. | OBJ-2, OBJ-4 |
| NFR-6 | Every access to a student record is logged, per BR-13's role visibility. | OBJ-3 |
| NFR-8 | A schedule change reaches the affected tutor and guardian within 60 seconds. | OBJ-1 |
| NFR-9 | The Mesa Public Schools export matches the contracted layout exactly, within 2 business days of month end. | OBJ-7 |
