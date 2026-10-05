# BrightPath Learning — Capstone

BrightPath Learning is a 4-centre after-school tutoring network (Tempe, Chandler, Mesa, Gilbert) plus
online sessions, running on whiteboards, spreadsheets, and a WhatsApp group. This capstone analyses,
specifies, designs, and validates a Tutoring Scheduling & Attendance System to replace that — before
any of it gets built.

The story, in the order it actually happened:

1. **[Questions log](./questions-log/)** — what was asked, what came back, and what's still open.
2. **[Vision & scope](./vision-scope/)** — the problem, the seven objectives (OBJ-1 to OBJ-7), what's
   in and out of release 1, constraints, assumptions, risks.
3. **[Stakeholder map & RACI](./stakeholders/)** — including how the parent and tutor perspectives
   were sourced, given neither was directly available (§4).
4. **[Context diagram](./context-diagram/)** — the system boundary, external actors, and the Mesa
   Public Schools interface.
5. **[BPMN](./diagrams/)** — the happy path and the ten exception paths (E-1 to E-10) that are the
   actual business, not an afterthought to it.
6. **[Use cases](./use-cases/)** — primary flows with alternates and exceptions.
7. **[Product backlog](./backlog/)** — INVEST stories with Gherkin acceptance criteria.
8. **[SRS](./srs/)** — numbered functional and non-functional requirements, each traced to an
   objective.
9. **[UML as code](./uml/)** — activity, sequence and class diagrams, committed as text.
10. **[Wireframes](./wireframes/)** — parent portal, coordinator schedule view, tutor phone view.
11. **[ERD + schema + seed data](./erd/)** — the data model, resolved against the four §9.3 traps
    (per-student progress notes in a group session, nullable centre for online sessions, a derived
    not-stored credit balance, and a two-kind invoice payer). Verified runnable in SQLite. Caught and
    fixed three real defects while building it — see artifact 14.
12. **[SQL analysis](./sql-analysis/)** — one query per §9.5 director report, each actually run
    against the schema above with a real result and a one-line business interpretation, not a
    plausible-looking guess.
13. **[RTM](./rtm/)** — objective → requirement → story → test case, programmatically verified to
    have zero orphan rows in either direction.
14. **[Test cases & defect log](./test-cases/)** — 24 test cases (7 actually executed against the
    schema with real pass/fail results, the rest honestly marked as application-layer behaviour not
    yet built); 7 logged defects, 5 closed with what was fixed, 2 open and carried into artifact 15.
15. **[Change request](./change-request/)** — CR-01, raised from a real tension between §5's in-scope
    reporting commitments and §9.2's data model, which never links a student to a centre or a
    district contract. Full impact analysis across every other artifact. Proposed, not yet approved
    or implemented.
16. **[AI feature specification](./ai-spec/)** — the at-risk flag, chosen over tutor matching because
    it extends OBJ-5 work already in the SRS. Specifies metrics, human-in-the-loop overrides, failure
    behaviour, named bias proxies, and a governance position: the model may never, by itself, affect a
    student's access to tutoring.
17. **[Sign-off recommendation](./sign-off/)** — conditional go, not unconditional. Zero open
    Critical defects, but DEF-05 and DEF-06 (both open, both feeding CR-01) sit under a contractually
    binding reporting obligation — the condition is CR-01 gets decided before development starts, not
    after.
18. **[Reflection](./reflection/)** — a draft, explicitly meant to be rewritten in the student's own
    words. Grounded only in what actually happened: three real bugs, each caught a different way, and
    a real gap in the brief's own data model found by trying to build the thing, not by re-reading the
    spec.

## A defect, traced all the way through, as one example of the golden thread

DEF-06 (a missing `Student → DistrictContract` link, found while running artifact 12's query 8) is the
same defect that motivated artifact 15's change request, which proposes new requirements FR-16/FR-17
(not yet in the artifact 13 baseline, pending approval), which artifact 17's sign-off makes a condition
of going ahead. One finding, traced from a query result through five further artifacts — that
continuity is the point of doing it this way rather than writing each artifact in isolation.
