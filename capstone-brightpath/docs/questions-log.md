# Questions Log — BrightPath Learning Capstone

Format: each row is one question raised with the client (instructor), the answer given, who gave it,
and the date. Anything without an answer yet sits in the **Open Questions** table at the bottom —
a capstone with an empty open-questions table at submission time hasn't been analysed either; it just
means you closed every loop before the deadline, which is fine, but the working log should show it
happened over time, not all on one day.

## Answered

| # | Question | Asked of | Answer | Date | Given by |
|---|---|---|---|---|---|
| Q1 | *(template — replace with your actual exchange)* Is the ~$80,000 unused-credit figure from the four spreadsheets, or an estimate? | Director (Dr. Reyes) | | | |
| Q2 | | | | | |

> Delete the template row once you have real entries. Everything below is a *starting list* of what's
> worth asking — pick from it, add your own, and log the actual answers you get.

## Open — worth raising with the client

Grouped by where the brief is genuinely silent, contradictory, or resting on an unverified assumption.

### Scheduling & tutors (OBJ-1, OBJ-2, OBJ-6)
- Q-A1 §4 says tutors haven't been asked anything yet. Who actually represents tutor interests at
  reviews — do we get access to Devon Price, or a coordinator speaking for tutors?
- Q-A2 A-4 assumes tutors will keep availability current without being chased. What happens to the
  matching/scheduling feature if that assumption fails — is a reminder/nudge in scope, or do we accept
  stale availability as a known risk (R-2)?
- Q-A3 E-3: cover must come from "qualified, available tutors." If no one qualified is available, does
  the system notify the coordinator immediately, or only at the 24-hour cancellation trigger?
- Q-A4 E-3 says a tutor who isn't covered is "still paid half" — is that half a session's pay or half a
  credit's worth, and is payroll (out of scope, §5) meant to consume this record, or is it purely
  informational for release 1?

### Credits & billing (OBJ-3, OBJ-5, BR-04–06, BR-10)
- Q-A5 A-1: the four spreadsheets currently disagree. Who has authority to resolve a discrepancy during
  migration — the billing administrator, the director, or per-centre coordinators for their own centre?
- Q-A6 A-3: Mesa is *said* to forgive every no-show — is that confirmed policy or hearsay? If confirmed,
  does BR-05 (no-show consumes credit) simply not apply to district-funded students, and does that need
  its own business rule?
- Q-A7 BR-04 sibling credit transfer — does a transfer require guardian request, or can a coordinator
  move credits unilaterally? Is a transfer a ledger event (BR-09) like anything else?
- Q-A8 BR-06 on-account override, max 2 per student per term — does "term" reset the count, and who can
  see the count so a coordinator doesn't exceed it by accident?
- Q-A9 BR-10: an invoice can contain taxed materials and untaxed tuition — does §5 "no online card
  payment" mean invoices are always settled by a payment taken at the desk, even for the materials
  portion, or could materials be handled differently?

### Data model (§9.3)
- Q-A10 Stored balance vs. derived from the append-only ledger (BR-09) — does the client have a
  preference (e.g. for NFR-1's 2-second portal load), or is this purely our engineering call to justify?
- Q-A11 E-10: a group session that drops to one student stays at group price — does that rule apply
  retroactively if the drop happens mid-term, or only to sessions scheduled after the drop?
- Q-A12 Online sessions have no centre (§9.1). For §9.5's "utilisation by centre" report, are online
  sessions excluded entirely, rolled into a virtual "Online" bucket, or attributed to the tutor's home
  centre?

### Parents, consent & minors (CON-6, BR-11, BR-12, NFR-10)
- Q-A13 §4 flags no parent representative exists yet. Is the team expected to recruit one (e.g. via the
  director), or design the portal on stated assumptions and flag it as risk R-4 without resolving it?
- Q-A14 BR-12 consent is "re-confirmed annually" — what happens to already-scheduled sessions if a
  guardian's annual consent lapses before it's renewed? Auto-hold, or does existing bookings proceed?
- Q-A15 §10 AI feature: consent (BR-12/CON-6) covers tutoring, not model training. Is a *second*
  consent for model training/use of progress notes in scope for the team to design, or is that a gap we
  flag rather than solve?

### Mesa Public Schools contract (OBJ-7, CON-5, E-7)
- Q-A16 R-6 flags the contract is up for renewal during the build. Is there a known renewal date, and
  should the team build any flexibility into the export beyond CON-5's "fixed, cannot be negotiated"?
- Q-A17 E-7: when a district-funded student's funding ends mid-bundle, billing switches to the guardian
  "from that date." Does the guardian need to be notified/opt in before sessions continue, or does
  billing just switch silently and the guardian finds out on the next statement?

### Scope & governance
- Q-A18 §10 AI feature governance: does the director (or the institution) have an existing AI/data
  policy for minors that constrains the risk-tier decision, or is the team setting the position from
  scratch based on the brief alone?
- Q-A19 CON-2's fall-2027 date and CON-1's fixed $120k budget are both hard. If the team's own risk
  analysis (R-3) shows they can't both hold given the scope in §5, who breaks the tie — does budget win,
  or does scope shrink first?

## How to use this file
1. Before a review/session, pick 3–5 of the open questions most likely to reshape your requirements.
2. Ask the instructor (playing the client) directly; record the literal answer, not a paraphrase, in
   the Answered table.
3. Move the question out of Open once answered. If an assumption (§5) turns out to be wrong, update
   that assumption's owner/confirm-by date too and note the cascade (e.g. Q-A6 answered → BR-05 gets an
   exception clause → SRS and Gherkin criteria change → RTM updated).
4. Anything still open at submission stays in Open — that's honest, not a defect, as long as you've
   shown it was tracked and you made a reasoned assumption to keep moving (§5 "Assumptions" table).
