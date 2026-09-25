# UML as Code — BrightPath Learning

Three diagrams, each earning its place rather than restating the BPMN: the **class diagram** resolves the
four data-model traps §9.3 explicitly calls out; the **sequence diagram** shows the tutor-cover flow at
the message level (the BPMN in artifact #5 shows it as a business process, this shows who calls whom); the
**activity diagram** shows the credit-deduction algorithm's internal logic, which the BPMN deliberately
left as a black box (see artifact #5's closing note).

## 1. Class diagram — resolving the four §9.3 traps

```plantuml
@startuml
hide circle
skinparam classAttributeIconSize 0

class Guardian {
  +guardian_id
  +name
  +contact_info
  +preferred_language
}

class Student {
  +student_id
  +date_of_birth
  +school
  +grade
}

class Consent {
  +consent_id
  +date_given
  +scope
  +annual_confirm_date
}

class Enrolment {
  +enrolment_id
  +subject
  +grade_band
  +goal
  +term
  +status
}

class Tutor {
  +tutor_id
  +employment_type
  +tier
  +teaches_online
}

class TutorQualification {
  +subject
  +grade_band
  +tier
}

class TutorAvailability {
  +availability_id
  +day_of_week (nullable)
  +specific_date (nullable)
  +start_time
  +end_time
  +is_exception
}

class Centre {
  +centre_id
  +location
  +rooms
  +opening_hours
}

class Session {
  +session_id
  +date_time
  +mode  ' in-centre | online
  +status  ' BR-08 state machine
  +cancellation_reason
}

class SessionStudent {
  +attendance_outcome
}

class ProgressNote {
  +note_id
  +text
  +written_by
  +written_at
}

class Bundle {
  +bundle_id
  +credits_purchased
  +price_paid
  +purchase_date
  +expiry_date
}

class CreditLedgerEntry {
  +entry_id
  +signed_amount
  +reason
  +recorded_by
  +recorded_at
}

abstract class Payer {
  +payer_id
}
class DistrictContract {
  +contract_id
  +rate
  +report_layout
  +deadline_rule
}

class Invoice {
  +invoice_id
  +tuition_amount
  +materials_amount
  +tax_amount
  +issued_date
}
class Payment {
  +payment_id
  +amount
  +method
  +paid_date
}

class Incident {
  +incident_id
  +description
  +severity
  +recorded_at
  ' visibility restricted to director — enforced in application layer, not schema
}

class AuditLog {
  +log_id
  +user_id
  +record_type
  +record_id
  +accessed_at
}

' --- Trap 1: a session has many students, but a progress note is per student ---
' SessionStudent is the join entity; ProgressNote attaches to the JOIN, not to Session directly.
' This makes "one note per student per session" a natural key (session_id, student_id) rather than
' an application-level rule with nothing to enforce it.
Session "1" -- "0..*" SessionStudent
Student "1" -- "0..*" SessionStudent
SessionStudent "1" -- "0..1" ProgressNote : must reach 1 within 24h (BR-07)

' --- Trap 2: nullable centre for online sessions ---
' Session.centre_id is nullable. Any report grouped by centre (§9.5 utilisation-by-centre) must
' explicitly bucket NULL as "Online" rather than dropping those rows — called out in the SQL (artifact #12).
Centre "0..1" -- "0..*" Session : nullable — null means online

' --- Trap 3: stored balance vs. derived from the ledger ---
' DECISION: balance is DERIVED (SUM of CreditLedgerEntry.signed_amount for the enrolment), not stored.
' Argued in favour of: BR-09 requires the ledger to be the single source of truth and append-only;
' a stored balance is a second source of truth that can drift from it (exactly R-1's failure mode).
' NFR-1's 2-second portal load is met with a materialized/cached view refreshed on ledger write,
' not a denormalized column on Student — the cache can be rebuilt from the ledger if it's ever wrong,
' which a stored column cannot guarantee.
Enrolment "1" -- "0..*" CreditLedgerEntry
Bundle "1" -- "0..*" CreditLedgerEntry : originates

' --- Trap 4: an invoice's payer is one of two kinds of thing ---
' Payer is abstract; Guardian and DistrictContract both realize it. An Invoice always points to
' exactly one Payer, regardless of which concrete type. E-7 (funding ends mid-bundle) is modelled as
' a NEW invoice pointing to Guardian from that date, not a mutation of the existing DistrictContract-payer
' invoice — consistent with BR-09's "never edit, always a new entry" philosophy applied to billing too.
Guardian --|> Payer
DistrictContract --|> Payer
Payer "1" -- "0..*" Invoice
Invoice "0..*" -- "0..*" Payment : may be part-paid

Guardian "1" -- "0..*" Student
Student "1" -- "0..*" Consent
Student "1" -- "0..*" Enrolment
Enrolment "1" -- "0..*" Session : sessions scheduled against it via SessionStudent
Tutor "1" -- "0..*" TutorQualification
Tutor "1" -- "0..*" TutorAvailability
Tutor "1" -- "0..*" Session
Centre "1" -- "0..*" TutorAvailability : home centre context (in-centre only)

Session "0..*" -- "0..1" Incident
Enrolment "1" -- "0..1" DistrictContract : if district-funded (nullable — most are guardian-paid)

AuditLog ..> Student : logs access to
AuditLog ..> Enrolment : logs access to
@enduml
```

## 2. Sequence diagram — Tutor Cover Flow (E-3 / UC-8)

Message-level view of the same flow the BPMN sub-flow (artifact #5 §2) shows as a business process.

```plantuml
@startuml
actor Tutor as T
participant "Scheduling\nService" as SS
participant "Tutor\nRepository" as TR
participant "Notification\nService" as NS
participant "Credit\nLedger" as CL
actor Guardian as G

T -> SS: reportUnavailable(session_id)
activate SS
SS -> SS: session.status == Confirmed?
SS -> TR: findQualifiedAvailable(subject, grade_band, time_slot)
activate TR
TR --> SS: candidate tutor list
deactivate TR
SS -> SS: startCountdown(24h before session.start)
SS -> NS: notifyCandidates(candidate list, session_id)
NS -> T: cover request (to each candidate)

alt a qualified tutor accepts before countdown expires
  T -> SS: acceptCover(session_id)
  SS -> SS: reassignTutor(session_id, new_tutor)
  note right: status stays Confirmed (BR-08)
  SS -> NS: notifyGuardian(session_id, tutor_change)
  NS -> G: notification (within 60s, NFR-8)
else countdown expires, no acceptance
  SS -> SS: session.status = Cancelled
  SS -> CL: postEntry(session_id, +original_credit, reason="cover not found")
  SS -> CL: postEntry(session_id, +goodwill_credit, reason="E-3 goodwill")
  activate CL
  CL --> SS: entries recorded (append-only, BR-09)
  deactivate CL
  SS -> SS: log(reason="lost — no cover")
  note right: feeds OBJ-1 weekly measure directly
  SS -> NS: notifyGuardian(session_id, cancellation)
  NS -> G: notification
end
deactivate SS
@enduml
```

## 3. Activity diagram — Credit Deduction Algorithm (UC-10 internals)

The BPMN treated `UC-10 Deduct Credit` as a single opaque step (artifact #5's closing note says exactly
this). Here's what's actually inside it.

```plantuml
@startuml
start
:Receive trigger event
(session Recorded, late-cancel,
no-show, override, expiry, ...);

switch (event type?)
case (session Recorded)
  if (attendance AND progress note
  both present for this student?) then (yes)
    :amount = -1 × session_cost
    (1 credit 1:1, 0.5 group, BR-03);
  else (no)
    :do not proceed —
    UC-9 should not have
    triggered this event yet;
    stop
  endif
case (late cancel / no-show)
  if (waiver recorded AND
  waiver count this term < 1?) then (yes)
    :amount = 0
    (credit not consumed);
  else (no waiver)
    :amount = -1 × session_cost;
  endif
case (≥24h cancellation)
  :amount = +1 × session_cost
  (full return);
case (on-account override)
  if (override count this term < 2?) then (yes)
    :amount = 0
    (booking proceeds without
    a balance requirement);
  else (no)
    :reject — override not applied;
    stop
  endif
case (12-month expiry)
  :amount = -1 × remaining_unused_credits
  (no refund, BR-04);
case (E-3 goodwill)
  :amount = +1 × goodwill_credit_value;
endswitch

:Append new CreditLedgerEntry
(enrolment_id, amount, reason,
recorded_by, timestamp);
note right: NEVER update or delete\nan existing entry (BR-09)

:Recompute cached balance view
for this enrolment
(source of truth remains
the ledger sum, per Trap 3);

if (session-triggered event?) then (yes)
  :Set session status = Recorded
  (terminal state, BR-08);
endif

stop
@enduml
```

## Cross-checks for the reviewer

- The class diagram's `SessionStudent`→`ProgressNote` cardinality (`0..1`, "must reach 1 within 24h")
  should match FR-040/FR-041 in the SRS and the BPMN's BR-07 timer — three artifacts describing one rule
  from three angles; if any of them disagree, one of them is wrong.
- The sequence diagram's `alt` branches map directly to Gherkin scenarios D2/C3 in the backlog (artifact
  #7) — same two outcomes, same trigger, different notation.
- The activity diagram's `switch` cases are exactly the reason codes the SQL (artifact #12) will need to
  `GROUP BY` when answering "outstanding credit liability" and "credits expiring in 60 days" — worth
  confirming the reason strings used here match what ends up in the actual schema (artifact #11).
