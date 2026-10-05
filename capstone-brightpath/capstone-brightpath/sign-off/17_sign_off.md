# Artifact 17 — Sign-off Recommendation

## What this sign-off covers, and what it doesn't

This capstone delivered an **analysis and design package** — requirements, a data model, SQL
analysis, test cases, a change request, and an AI feature specification. It did not build a running
application. So this is a sign-off on **readiness to hand these artifacts to the director for scope
approval and to a development team for build**, not a go-live decision on production software — that
distinction matters for how "go/no-go" should be read below.

## RTM coverage (artifact 13)

- 15/15 functional requirements (FR-01 to FR-15) map to exactly one story and one reserved test case
  ID, verified programmatically with no orphans in either direction.
- All 7 business objectives (OBJ-1 to OBJ-7) have at least one requirement.
- 5 of the brief's 10 NFRs are folded into an FR they constrain; 5 (NFR-2, 3, 5, 7, 10) are not
  currently traced to any FR in this set — recorded as a known RTM gap, not silently dropped (see
  artifact 13's coverage-check section).
- Change request CR-01 (artifact 15) proposes 2 more requirements (FR-16, FR-17) to close DEF-05 and
  DEF-06. These are **not yet in the baseline RTM** — they're pending director approval, per CR-01's
  own status.

## Defects by severity (artifact 14)

| Severity | Open | Closed |
|---|---|---|
| Critical | 0 | 2 (DEF-01, DEF-07) |
| High | 1 (DEF-06) | 2 (DEF-02, DEF-03) |
| Medium | 1 (DEF-05) | 1 (DEF-04) |
| Low | 0 | 0 |

**Zero open Critical defects.** The two open defects (DEF-05, DEF-06) are both schema gaps that block
specific reports (renewal-by-centre, district reconciliation) rather than corrupting data or violating
a business rule already in production — and both already have a proposed fix sitting in CR-01, not an
unaddressed unknown.

## Recommendation: CONDITIONAL GO

**Go**, on these conditions:

1. **CR-01 is decided before development starts** — not after. DEF-06 in particular sits under a
   contractual deliverable (OBJ-7, CON-5); shipping release 1 without resolving it means building the
   district-reporting feature on an inference ("whoever logged the ledger entry") instead of a real
   foreign key, which the defect log already flags as fragile. Approving CR-01's `StudentFunding`
   design (or its minimal fallback) before the data layer is built is far cheaper than migrating it
   afterward.
2. **The 5 untraced NFRs get resolved in the SRS**, either by writing requirements for them or by
   explicitly documenting them as architectural constraints the whole system must meet (per artifact
   13's own recommendation) — "untraced because nobody wrote them down" is different from "deliberately
   out of RTM scope," and right now it reads as the former.
3. **The AI feature (artifact 16) does not ship in release 1's critical path.** It's specified to a
   defensible standard, but §1 of that spec is honest that a cheap rule-based flag should ship first and
   the model's value over it is still unmeasured. Treat the model as a post-release-1 experiment, not a
   release-1 dependency — nothing in OBJ-5 requires it specifically; FR-11's rule-based reminder does
   the baseline job.

**Not recommending unconditional go**, because signing off on a data model with two known, open gaps
under a contractually binding reporting obligation — without a stated commitment to resolve them
first — is exactly the kind of sign-off the rubric calls out as a deduction, even when the open items
aren't Critical.

## What would move this to GO (no conditions)

Director approval of CR-01, and either (a) implementation of FR-16/FR-17 against that approval, or
(b) an explicit, documented decision to defer them with a stated date — not just silence.
