# Product Backlog — BrightPath Learning

## Prioritisation method

**MoSCoW**, tie-broken by two questions in order: (1) does this story block the Tempe pilot going live
before fall 2027 (CON-2)? If yes, it can't be lower than Should. (2) which §2 baseline measure does it
move, and how far is that measure from target? A story that only helps a measure already close to target
is ranked below one that helps a measure far from target, budget being fixed (CON-1). Every story below
carries its OBJ/BR/NFR trace so the ranking can be checked, not just asserted.

**Must** = release 1 doesn't ship without it. **Should** = ships in release 1 unless CON-1/CON-2 forces a
cut, in which case it's the first thing cut. **Could** = valuable, explicitly droppable without breaking
the golden thread. Nothing here is **Won't** — anything truly out of scope is in the Vision & Scope
document's out-of-scope list instead, not a backlog item marked won't.

---

## Epic A — Consent, Guardian & Student Records (OBJ-4, CON-6, BR-12)

### A1. Record guardian consent before first session
**Priority:** Must
As a **coordinator**, I want to record a guardian's consent before a student's first session, so that no
student is ever booked without authorization.

```gherkin
Scenario: Booking blocked without consent
  Given a student has no consent record on file
  When a coordinator attempts to schedule that student's first session
  Then the system rejects the booking
  And the system prompts the coordinator to record consent first

Scenario: Booking allowed once consent is recorded
  Given a student has a current, valid consent record
  When a coordinator schedules a session for that student
  Then the booking succeeds
```

### A2. Annual consent re-confirmation reminder
**Priority:** Should
As a **coordinator**, I want to be warned when a student's consent is due for annual re-confirmation, so
that I re-confirm it before it lapses.

```gherkin
Scenario: Consent nearing expiry
  Given a student's consent was given 350 days ago
  When the coordinator opens that student's record
  Then the system displays a "consent renewal due" warning

Scenario: Consent expired
  Given a student's consent is more than 365 days old and not renewed
  When a coordinator attempts to schedule a new session
  Then the system blocks the booking until consent is re-confirmed
```

---

## Epic B — Tutor Qualification, Availability & Matching (OBJ-6, BR-01, R-2, A-4)

### B1. Restrict tutor matching to qualified tutors
**Priority:** Must
As a **coordinator**, I want the system to only suggest tutors qualified for a subject and grade band, so
that I never book an unqualified tutor.

```gherkin
Scenario: SAT prep requires certified tier
  Given a tutor has no SAT-certification qualification
  When a coordinator searches for tutors for an SAT-prep enrolment
  Then that tutor does not appear in the results

Scenario: Qualified tutor appears
  Given a tutor is qualified for grade-8 math
  And that tutor is available at the requested time
  When a coordinator searches for a grade-8 math tutor
  Then that tutor appears in the results
```

### B2. Tutor sets recurring availability from a phone
**Priority:** Must
As a **tutor**, I want to set my weekly availability from my phone's browser without installing an app, so
that coordinators can see when I'm free.

```gherkin
Scenario: Set recurring weekly availability
  Given a tutor is logged into the mobile web view
  When they mark themselves available Tue/Thu 3–6pm
  Then that recurring pattern is saved
  And it appears in tutor-matching searches for future Tue/Thu 3–6pm slots

Scenario: One-off exception overrides the recurring pattern
  Given a tutor has a recurring Tuesday 3–6pm availability
  When they mark next Tuesday as unavailable
  Then next Tuesday's slot does not appear as available
  And all other Tuesdays remain unaffected
```

### B3. Weekly tutor utilisation report
**Priority:** Must
As the **director**, I want to see tutor utilisation (booked ÷ offered hours) weekly by centre and subject,
so that I can see capacity and demand instead of guessing.

```gherkin
Scenario: Utilisation report reflects bookings and declared availability
  Given a tutor declared 10 available hours this week
  And 6 of those hours were booked into delivered or scheduled sessions
  When the director views the weekly utilisation report
  Then that tutor's utilisation shows 60% for the week
```

---

## Epic C — Scheduling & Cover (OBJ-1, OBJ-2, BR-02, BR-08, E-3, NFR-7, NFR-8)

### C1. Schedule a session with double-booking and group-size checks
**Priority:** Must
As a **coordinator**, I want the system to block a booking that would double-book a tutor or exceed a
group's size/subject/grade rules, so that BR-02 can't be violated by mistake.

```gherkin
Scenario: Double-booking rejected
  Given a tutor is already booked 3:00–3:55pm
  When a coordinator tries to book the same tutor 3:30–4:25pm
  Then the system rejects the booking with a conflict message

Scenario: Group session exceeds capacity
  Given a group session already has 4 students
  When a coordinator tries to add a 5th student
  Then the system rejects the addition
```

### C2. Full week scheduled in under 20 minutes
**Priority:** Must
As a **coordinator with 3 hours of training**, I want to schedule a full week for my centre in 20 minutes
or less, so that I get my week back (OBJ-2).

```gherkin
Scenario: Coordinator completes a week's schedule within the time budget
  Given a coordinator with baseline (3-hour) training
  And a centre with its usual weekly session volume
  When they schedule the full week using only the scheduling screen
  Then the task is completable in 20 minutes or less
  # Verified via usability testing with a representative coordinator, not a code assertion
```

### C3. Automatic cover search when a tutor drops out
**Priority:** Must
As a **coordinator**, I want the system to automatically search qualified, available tutors when an
assigned tutor reports unavailable, so that sessions aren't lost for lack of a manual search (OBJ-1).

```gherkin
Scenario: Cover found before the 24-hour cutoff
  Given a tutor reports unavailable for a session 30 hours away
  When the system searches qualified, available tutors
  And a qualified tutor accepts the cover
  Then the session is reassigned and stays Confirmed
  And the guardian is notified of the tutor change within 60 seconds

Scenario: No cover found by the 24-hour cutoff
  Given a tutor reports unavailable for a session
  And no qualified tutor accepts by 24 hours before the session
  Then the session is cancelled
  And the credit is returned plus a goodwill credit
  And the event is logged as "lost — no cover"
```

### C4. Schedule-change notifications within 60 seconds
**Priority:** Must
As a **guardian and a tutor**, I want to be notified within 60 seconds of any change to a session I'm
involved in, so that I'm never caught out by a stale schedule.

```gherkin
Scenario: Notification latency
  Given a scheduled session is cancelled by a coordinator
  When the cancellation is saved
  Then the affected guardian and tutor each receive a notification within 60 seconds
```

---

## Epic D — Credits & Billing (OBJ-3, OBJ-5, BR-04–BR-06, BR-09, BR-10, E-1/E-2/E-4/E-5)

### D1. Single, trustworthy credit balance
**Priority:** Must
As a **guardian**, I want to see one accurate credit balance, so that I stop having to phone the centre to
ask (OBJ-3).

```gherkin
Scenario: Balance reflects all ledger movements
  Given a student has a bundle purchase of 10 credits
  And 3 credits have since been deducted for delivered sessions
  When the guardian views their balance
  Then it shows 7 credits
```

### D2. Cancellation credit rule (≥24h vs. <24h)
**Priority:** Must
As the **system**, I need to return a credit for a ≥24-hour cancellation and consume it for a <24-hour
cancellation or no-show, so that BR-05 is applied consistently rather than left to memory.

```gherkin
Scenario: Cancellation 24+ hours ahead
  Given a session is scheduled for 3:00pm tomorrow
  When the guardian cancels at 2:00pm today (25 hours ahead)
  Then the credit is returned to the ledger
  And the slot is released to the waiting list

Scenario: Cancellation less than 24 hours ahead
  Given a session is scheduled for 3:00pm today
  When the guardian cancels at 8:00pm the previous day (19 hours ahead)
  Then the credit is consumed, not returned

Scenario: One no-show per term may be waived
  Given a student has had zero waived no-shows this term
  When a coordinator marks a no-show as waived with a reason
  Then the credit is returned despite the no-show
  And a second waiver attempt this term is rejected
```

### D3. On-account override at booking, capped per term
**Priority:** Should
As a **coordinator**, I want to book a session on account when a student's balance is insufficient, up to
2 times per student per term, so that a family isn't turned away over a temporary shortfall (but the
liability stays bounded).

```gherkin
Scenario: Override allowed within cap
  Given a student has used 1 on-account override this term
  And their balance is below the session cost
  When a coordinator records an on-account override to book the session
  Then the booking succeeds
  And the override count for that student this term becomes 2

Scenario: Override rejected beyond cap
  Given a student has used 2 on-account overrides this term
  When a coordinator attempts a third override
  Then the system rejects it
```

### D4. Credit expiry at 12 months
**Priority:** Should
As the **system**, I need to warn a guardian 30 days before unused credits expire and then expire them
with no refund, so that BR-04/E-5 is enforced and the ~$80k liability stops growing invisibly.

```gherkin
Scenario: 30-day expiry warning
  Given a bundle was purchased 335 days ago and has unused credits
  When the daily expiry check runs
  Then the guardian receives an expiry warning notification

Scenario: Credits expire at 12 months
  Given a bundle's unused credits reach 365 days old
  When the daily expiry check runs
  Then those credits are removed from the usable balance with no refund
  And the ledger records the expiry as its own entry
```

### D5. Combined tuition + materials invoice with correct tax
**Priority:** Should
As the **billing administrator**, I want an invoice to apply 8.6% tax to materials but not tuition, so
that BR-10 is followed without a manual calculation every time.

```gherkin
Scenario: Mixed invoice tax calculation
  Given an invoice includes $100 of tuition and $50 of materials
  When the invoice is generated
  Then the materials line shows $4.30 of tax (8.6% of $50)
  And the tuition line shows no tax
  And the invoice total is $154.30
```

---

## Epic E — Attendance, Progress & Reporting to Families (OBJ-4, BR-07, BR-11)

### E1. Attendance and progress note required before credit deduction
**Priority:** Must
As the **system**, I need to withhold credit deduction until both attendance and a progress note exist for
a session, so that BR-07 can't be silently skipped.

```gherkin
Scenario: Credit not deducted without a progress note
  Given a session was delivered and attendance was recorded
  But no progress note has been added within 24 hours
  Then the credit remains undeducted
  And the session does not count as Recorded

Scenario: Credit deducted once both records exist
  Given a session was delivered
  When attendance and a progress note are both recorded within 24 hours
  Then the credit is deducted
  And the session status becomes Recorded
```

### E2. Progress note is per student, not per session
**Priority:** Must
As a **tutor**, I want to write one progress note per student in a group session, so that each family gets
individual feedback rather than a shared note.

```gherkin
Scenario: Group session requires one note per student
  Given a group session has 3 students
  When the tutor completes attendance and progress notes
  Then the system requires exactly 3 progress notes, one per student
  And will not mark the session Recorded with fewer than 3
```

### E3. District students receive attendance only, never progress notes
**Priority:** Must
As the **system**, I need to exclude progress notes from anything sent to Mesa Public Schools, so that
BR-11 can't be violated by an export that pulls the wrong fields.

```gherkin
Scenario: Mesa export excludes progress notes
  Given a district-funded student has attendance and progress notes on file
  When the Mesa monthly export is generated
  Then it contains attendance records only
  And contains no progress-note text or reference to one
```

---

## Epic F — Mesa Public Schools Compliance (OBJ-7, CON-5, NFR-9)

### F1. Monthly CSV export in the contracted layout
**Priority:** Must
As the **Mesa coordinator**, I want a monthly attendance CSV in the exact contracted layout, generated
within 2 business days of month end, so that BrightPath stops missing the deadline (7/12 → 12/12, OBJ-7).

```gherkin
Scenario: Export matches contracted layout
  Given the reporting month has ended
  When the Mesa export is generated
  Then the file matches the contracted column order, headers and format exactly

Scenario: Export delivered on time
  Given the reporting month ended on the 1st
  When the export process runs
  Then the file is available for submission by end of day on the 3rd (2 business days)
```

---

## Epic G — Portal & Operational Visibility (OBJ-3, OBJ-5, OBJ-6, NFR-1, NFR-3, NFR-4, NFR-10)

### G1. Guardian portal loads balance and schedule in under 2 seconds
**Priority:** Should
As a **guardian**, I want the portal to load my schedule and balance quickly on my phone, so that checking
it is actually easier than calling the centre.

```gherkin
Scenario: Portal load time
  Given a guardian opens the portal on a 4G connection
  When the schedule and balance view loads
  Then it renders within 2 seconds at the 95th percentile
```

### G2. Portal available in English and Spanish
**Priority:** Should
As a **guardian who prefers Spanish**, I want the portal in Spanish, so that I can actually use it
(NFR-10 — ~30% of guardians).

```gherkin
Scenario: Language preference respected
  Given a guardian's preferred language is set to Spanish
  When they open the portal
  Then all portal text displays in Spanish
```

### G3. Outstanding credit liability report, to the dollar
**Priority:** Must
As the **director**, I want to see total unused, unexpired credit liability at any time, so that the
~$80,000 unknown becomes a known, trusted number (the anchor fact of the whole brief).

```gherkin
Scenario: Liability figure is exact
  Given the sum of all unexpired, unused credits across all students
  When the director opens the credit liability report
  Then the figure shown equals that sum exactly, in dollars
```

### G4. Renewal rate by centre and subject
**Priority:** Should
As the **director**, I want to see renewal rate by centre and subject, so that I can see where OBJ-5's
58%→75% target is or isn't being met.

```gherkin
Scenario: Renewal counted correctly
  Given a student's bundle was exhausted on day 0
  And they purchased a new bundle on day 20
  When the renewal report is generated
  Then that student counts as renewed (within the 30-day window)

Scenario: Late renewal not counted
  Given a student's bundle was exhausted on day 0
  And they purchase a new bundle on day 45
  Then that student does not count as renewed at bundle exhaustion
```

---

## Epic H — Safeguarding & Access Control (CON-6, BR-13, NFR-5, NFR-6, E-8)

### H1. Restrict record visibility by role
**Priority:** Must
As a **tutor**, I should only see students assigned to me; as a **coordinator**, only my own centre; only
the **director** sees everything — so BR-13 holds regardless of who's logged in.

```gherkin
Scenario: Tutor cannot see another tutor's student
  Given a student is assigned only to Tutor A
  When Tutor B searches for that student
  Then the student does not appear in Tutor B's results

Scenario: Coordinator limited to their own centre
  Given a coordinator is assigned to the Tempe centre
  When they view the student list
  Then only Tempe students appear
```

### H2. Safeguarding incident restricted to director only
**Priority:** Must
As the **director**, I want safeguarding incidents visible only to me, so that CON-6/NFR-5's stricter
access rule holds even for coordinators who can otherwise see their centre's records.

```gherkin
Scenario: Incident hidden from coordinator
  Given a safeguarding incident is logged for a student at a coordinator's own centre
  When that coordinator views the student's record
  Then the incident is not visible to them
  And is visible only to the director
```

### H3. Every record access logged
**Priority:** Must
As the **director**, I want every access to a student record logged with user, record and timestamp, so
that NFR-6 is auditable, not just asserted.

```gherkin
Scenario: Access is logged
  Given any user views a student record
  Then an audit log entry is created with that user's ID, the record ID, and the timestamp
```

---

## Backlog summary by priority

| Priority | Count | Stories |
|---|---|---|
| Must | 18 | A1, B1, B2, B3, C1, C2, C3, C4, D1, D2, E1, E2, E3, F1, G3, H1, H2, H3 |
| Should | 7 | A2, D3, D4, D5, G1, G2, G4 |
| Could | 0 (release-1 items only; deferred items live in Vision & Scope §3, not here) | — |

25 stories total. Recount independently before carrying these into the RTM (artifact #13) — the two
documents must agree exactly, and this is the kind of arithmetic slip the RTM cross-check exists to catch.
