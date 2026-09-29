# Artifact 13 — Requirements Traceability Matrix

Traces every business objective (§3) through to a requirement, a backlog story, and a test case ID.
Test case IDs (TC-xx) are placeholders for artifact 14 — build artifact 14's Gherkin scenarios using
these exact IDs so the chain doesn't break at the last link.

**No orphans, either direction:** every OBJ has at least one FR; every FR has exactly one US; every
US has exactly one TC; every TC traces back up to an OBJ. If you add a requirement later that doesn't
fit this table, that's a signal per §2's own instruction — decide whether it's a missing objective or
scope creep, and say so in the questions log.

| Objective | Requirement | Story | Test case |
|---|---|---|---|
| OBJ-1 — Stop losing sessions to unavailable tutors (26→<8/wk) | FR-01 | US-01 | TC-01 |
| OBJ-1 | FR-02 | US-02 | TC-02 |
| OBJ-1 | FR-03 / NFR-8 | US-03 | TC-03 |
| OBJ-2 — Give coordinators their week back (11→<3 hrs/wk) | FR-04 / NFR-4 | US-04 | TC-04 |
| OBJ-2 | FR-05 | US-05 | TC-05 |
| OBJ-3 — One trusted credit balance (~18→<3 disputes/mo) | FR-06 / NFR-6 | US-06 | TC-06 |
| OBJ-3 | FR-07 / NFR-1 | US-07 | TC-07 |
| OBJ-3, OBJ-4 | FR-08 | US-08 | TC-08 |
| OBJ-4 — Make progress visible (31%→100% documented) | FR-09 | US-09 | TC-09 |
| OBJ-4 | FR-10 | US-10 | TC-10 |
| OBJ-5 — Keep families past first bundle (58%→75% renewal) | FR-11 | US-11 | TC-11 |
| OBJ-6 — Make tutor capacity/demand visible | FR-12 | US-12 | TC-12 |
| OBJ-6 | FR-13 | US-13 | TC-13 |
| OBJ-7 — Meet the Mesa Public Schools obligation (7/12→12/12) | FR-14 / NFR-9 | US-14 | TC-14 |
| OBJ-7 | FR-15 | US-15 | TC-15 |

## Coverage check

- 7/7 objectives have at least one requirement (OBJ-1: 3 · OBJ-2: 2 · OBJ-3: 3, incl. one shared with
  OBJ-4 · OBJ-4: 2 · OBJ-5: 1 · OBJ-6: 2 · OBJ-7: 2).
- 15/15 functional requirements have exactly one story.
- 15/15 stories have exactly one test case ID reserved.
- 5 NFRs (NFR-1, NFR-4, NFR-6, NFR-8, NFR-9) are folded into the FR row they constrain, rather than
  given separate rows with no story of their own — an NFR describes a *quality* of an existing FR's
  behaviour, not a new behaviour, so giving it its own orphan story would be traceability theatre.
  NFR-2, NFR-3, NFR-5, NFR-7, NFR-10 from the brief's §8 aren't traced here because no FR-01..15
  currently depends on them (NFR-5's retention schedule, for instance, isn't exercised by any of
  these 15 requirements) — flagging as a gap, not silently dropping them: they need either a
  requirement of their own or an explicit note in the SRS that they're architectural constraints
  the whole system must meet, not features to trace individually.
