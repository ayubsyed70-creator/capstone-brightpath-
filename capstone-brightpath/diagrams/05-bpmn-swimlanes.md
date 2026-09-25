# Process Model (BPMN-style, swimlanes) — BrightPath Learning

Two diagrams. The first is the full lifecycle happy path with the exception branches that hang directly
off it. The second pulls out the tutor-cover flow (E-3) on its own, because it has the most gateways and
the only nested timer, and cramming it into the main diagram makes both unreadable.

Lanes used throughout: **Guardian**, **Coordinator**, **Tutor**, **System**, **Mesa Public Schools**
(external, main diagram only).

## 1. Main lifecycle: enquiry → renewal/exit

```plantuml
@startuml
|Guardian|
start
:Enquiry (call or walk-in);
|Coordinator|
:Log enquiry;
:Book free assessment
(when a tutor is free);
:Conduct assessment;
if (Proceed to enrolment?) then (yes)
  :Create enrolment with
  goal, subject, grade band;
  |Guardian|
  :Choose bundle
  (10/20/40 credits);
  :Pay (desk/transfer only —
  no online card, §5);
  |System|
  :Create bundle purchase;
  :Post BR-04 ledger entry
  (append-only, BR-09);
  :Start 12-month expiry timer
  (E-5);

  |Coordinator|
  repeat
    :Match tutor
    (must satisfy BR-01
    qualification gate);
    :Schedule session
    (BR-02: no double-book,
    group ≤ 4, one grade band);
  repeat while (More sessions
  to schedule this term?) is (yes)
  ->no;

  |System|
  :Session status = Scheduled
  (BR-08);
  :Notify tutor + guardian
  (≤ 60s, NFR-8);

  |Tutor|
  if (Tutor confirms
  availability?) then (yes)
    :Session status = Confirmed;
  else (no — cannot make it)
    -[#red]-> See "Tutor Cover Flow" (E-3);
    stop
  endif

  |Guardian|
  if (Guardian cancels
  before session?) then (≥24h ahead — E-1)
    |System|
    :Session status = Cancelled;
    :Return credit to ledger;
    :Release slot to waiting list;
    stop
  elseif (<24h ahead — E-2) then (yes)
    |System|
    :Session status = Cancelled;
    :Consume credit (BR-05);
    :Pay tutor half (informational,
    payroll out of scope);
    stop
  else (no cancellation)
  endif

  |Tutor|
  :Deliver session;

  if (Online session?) then (yes)
    if (Technical failure? — E-9) then (yes)
      |System|
      :Not counted as delivered;
      :Return credit;
      :Record reason
      (explicitly NOT a no-show);
      stop
    else (delivered fine)
    endif
  else (in-centre)
  endif

  if (Student no-show? — E-2) then (yes)
    |System|
    :Consume credit (BR-05);
    note right: one no-show/student/term\nmay be waived by coordinator\nwith recorded reason
    stop
  else (attended)
  endif

  |Tutor|
  :Record attendance +
  progress note per student
  (within 24h, BR-07);

  |System|
  if (Both attendance AND
  progress note recorded
  within 24h?) then (yes)
    :Deduct credit from ledger
    (BR-09 append-only);
    :Session status = Recorded
    (BR-08 terminal state);
  else (no — 24h timer expires)
    :Credit stays undeducted;
    :Session does not count
    as delivered;
    note right: Flag to coordinator —\nincomplete record after 24h
  endif

  :Generate guardian statement /
  Mesa attendance record;

  if (District-funded student?) then (yes)
    |Mesa Public Schools|
    :Receive attendance only
    (BR-11 — never progress notes);
  else (self-pay)
    |Guardian|
    :Receive statement
    (tuition untaxed, materials
    taxed 8.6%, BR-10);
  endif

  |System|
  if (Term ends?) then (yes)
    :Generate termly progress report
    → guardian (BR-11);
  endif

  if (Credits exhausted
  mid-term? — E-4) then (yes)
    if (Coordinator records
    on-account override?
    (max 2/student/term, BR-06)) then (yes)
      :Booking allowed on account;
    else (no override)
      :No further booking
      until renewal;
    endif
  endif

  if (Bundle exhausted?) then (yes)
    |Guardian|
    if (Renews within 30 days?) then (yes)
      :Purchase new bundle;
      -[#blue]-> back to bundle purchase;
    else (no)
      :Exit;
      stop
    endif
  endif

else (no — does not enrol)
  stop
endif
@enduml
```

### Exceptions handled elsewhere in this diagram (not separately drawn)
- **E-6** (student changes subject/outgrows tutor) and **E-7** (district funding ends mid-bundle) are
  *state changes* to an existing enrolment/session, not branches in the session lifecycle above — they're
  better shown on the class/state model (artifact #9) and are noted here so they aren't lost: E-6 closes
  the old goal and opens a new enrolment; E-7 flips the invoice's payer link (§9.3) from that date forward
  without touching the credit ledger.
- **E-8** (safeguarding incident) is deliberately **not** shown as a gateway in the main flow, because it
  can interrupt the process at literally any point (during assessment, mid-session, at pickup) — it's
  modelled as an interrupting event, documented in the SRS and the incident use case, not as a diamond
  here.
- **E-10** (group session drops to one student) doesn't change this diagram's shape at all — it's a
  pricing rule (still billed at group rate), enforced at the credit-deduction step, not a process branch.

## 2. Sub-flow: Tutor Cover (E-3)

Pulled out because this is the one place the brief implies a real timer-driven gateway chain, and it's
also the exception the whole OBJ-1 target (26/wk → <8/wk) hangs on.

```plantuml
@startuml
|Tutor|
start
:Tutor reports cannot
make scheduled session;

|System|
:Search qualified, available
tutors (BR-01 gate applied);
:Start 24h-to-session timer;

|Coordinator|
if (Qualified tutor
found and accepts?) then (yes)
  |System|
  :Reassign session to
  covering tutor;
  :Notify guardian of
  tutor change (≤60s, NFR-8);
  :Session status stays
  Confirmed (BR-08);
  stop
else (no)
  if (More than 24h
  remains before session?) then (yes)
    :Keep searching /
    re-broadcast to
    qualified tutors;
    -[#blue]-> back to search;
  else (24h timer expires,
  no cover found)
    |System|
    :Session status = Cancelled;
    :Return credit;
    :Issue goodwill credit
    (E-3, on top of the
    returned credit);
    :Log as "lost — no cover"
    (counts against OBJ-1
    weekly measure);
    |Guardian|
    :Receive cancellation
    notice;
    stop
  endif
endif
@enduml
```

## Notes for the reviewer

- Timers are explicit in two places only: the 12-month credit expiry (E-5, main diagram) and the 24-hour
  cancellation/cover-decision window (E-2 and E-3). Every other "within 24h" reference (BR-07 attendance
  and progress note) is a data-completeness deadline, not a process timer — it doesn't block or redirect
  the flow, it just leaves the session in an incomplete state, which is why it's modelled as a
  system-side flag rather than a gateway.
- BR-08's legal state transitions (`Requested → Scheduled → Confirmed → Delivered → Recorded`, with
  `Cancelled` and `NoShow` as the only side exits) are annotated at each point they change state above —
  cross-check this diagram against the state machine in artifact #9 for consistency; they should describe
  the same automaton from two angles.
