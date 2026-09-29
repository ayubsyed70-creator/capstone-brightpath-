# Product backlog (draft, for RTM traceability)

**Reconcile against your existing `backlog/` artifact before treating this as final** — if story IDs
already exist there, use those and re-point the RTM at them instead of these.

Each story maps to exactly one requirement above. INVEST-style, Gherkin acceptance criteria.

---

**US-01** — As a coordinator, I want the system to block a double-booked tutor, so that I never
discover the conflict on the whiteboard at 4pm. *(FR-01)*
```gherkin
Given Jordan Lee is already booked for a session at 4:00pm Tuesday
When a coordinator tries to book Jordan Lee for a different session at 4:00pm Tuesday
Then the booking is rejected with a conflict message
```

**US-02** — As a coordinator, I want qualified substitute suggestions when a tutor cancels, so that
I don't have to phone every tutor I can think of. *(FR-02)*
```gherkin
Given Ruth Halloran cancels her SAT Prep session at 4:00pm Thursday
When the coordinator opens the cancelled session
Then the system lists tutors qualified for SAT Prep 9-12 who are available at that time
```

**US-03** — As a tutor, I want to be notified immediately when my schedule changes, so that I don't
find out from a group chat. *(FR-03)*
```gherkin
Given a coordinator reassigns one of Devon Price's sessions to another tutor
When the change is saved
Then Devon Price receives a notification within 60 seconds
```

**US-04** — As a coordinator, I want to see and edit my centre's whole week on one screen, so that I
get my evenings back. *(FR-04)*
```gherkin
Given I am the Tempe coordinator
When I open the weekly schedule view
Then I see every session at Tempe for the week, editable without leaving the screen
```

**US-05** — As a coordinator, I want conflicts flagged as I type, so that I catch a mistake before I
commit to it. *(FR-05)*
```gherkin
Given a room at Chandler is booked to its 4-student capacity
When I try to add a 5th student to that group session
Then the system flags the capacity conflict immediately and prevents the save
```

**US-06** — As the director, I want the credit balance to come from an unchangeable ledger, so that
a "correction" can never quietly erase what happened. *(FR-06)*
```gherkin
Given a billing administrator needs to correct a credit entry
When she enters the correction
Then a new ledger row is appended and the original row is never edited or deleted
```

**US-07** — As a guardian with more than one child, I want to see both balances at once, so that I
stop calling the centre to ask. *(FR-07)*
```gherkin
Given Elena Cruz is the guardian of Maya and Leo
When she opens the parent portal
Then she sees Maya's and Leo's current credit balances on one screen
```

**US-08** — As the billing administrator, I want a credit only deducted once attendance and a note
both exist, so that a half-finished record never silently bills a family. *(FR-08)*
```gherkin
Given a session is marked Delivered with attendance recorded but no progress note
When the nightly billing job runs
Then no credit is deducted for that student until the note is added
```

**US-09** — As a tutor, I want to log a progress note from my phone right after a session, so that
I don't have to remember to write it up later. *(FR-09)*
```gherkin
Given I just finished a session with one student
When I open the session on my phone and add a note
Then the note is saved and linked to that student and that session only
```

**US-10** — As a guardian, I want a termly progress report, so that I know tutoring is actually
working. *(FR-10)*
```gherkin
Given a term has ended for an enrolled student
When the termly report job runs
Then the guardian receives a report with every note from the term,
 and — if the student is district-funded — the district receives only the attendance record
```

**US-11** — As a guardian, I want a reminder before my child's credits run out, so that tutoring
doesn't just stop without warning. *(FR-11)*
```gherkin
Given a student's bundle will expire in 25 days with unused credits
When the daily expiry check runs
Then the guardian receives a renewal reminder
```

**US-12** — As the director, I want weekly tutor utilisation by subject and centre, so that I can
see who's overloaded and who has room. *(FR-12)*
```gherkin
Given a week of delivered sessions has been recorded
When the director opens the utilisation report
Then she sees, per tutor, subject and centre, booked hours against declared available hours
```

**US-13** — As the director, I want demand vs. qualified capacity by subject and grade band, so
that I can hire or requalify before we turn families away. *(FR-13)*
```gherkin
Given enrolled students and qualified tutors both exist for Math grade band 3-5
When the director opens the capacity report
Then she sees the ratio of enrolled students to qualified tutors for that subject and band
```

**US-14** — As the Mesa coordinator, I want the district CSV generated automatically, so that I
stop assembling it by hand every month. *(FR-14)*
```gherkin
Given a calendar month has ended
When the district export job runs
Then a CSV in the contracted layout is produced within 2 business days
```

**US-15** — As the director, I want the district export to contain only attendance, so that we
never breach BR-11 by accident. *(FR-15)*
```gherkin
Given a district-funded student has both attendance records and progress notes
When the monthly district CSV is generated
Then it contains the attendance records only — no progress note field exists in the output
```
