# Artifact 18 — Reflection (DRAFT — rewrite this in your own words before submitting)

This is a starting point, built only from what actually happened while working through this
capstone. It is not a substitute for your own reflection — add what you remember that isn't captured
here (how long things took, what actually frustrated you, anything I don't have visibility into), and
cut anything that doesn't match your real experience.

## What I got wrong, and when I found out

The biggest one: my first pass at the group-session seed data (artifact 11, case b — "a group session
of four") put four students from four *different* subjects and grade bands into one session. I didn't
catch this by re-reading it — I caught it by running artifact 12's utilisation query against it and
noticing the numbers didn't add up. That's the pattern worth naming: BR-02 says a group session is one
subject, one grade band, and the rule sat right there in §7 the whole time. Writing the seed data by
hand, matching it against the rule text, I still got it wrong. Running something against it is what
actually caught it.

The same thing happened twice more, smaller: the invoice for the district-funded student's post-
funding-switch bill pointed at the wrong guardian's payer record (caught while fixing the first bug,
not independently), and the credit ledger was documented as "append-only" per BR-09 but had no actual
database trigger stopping an edit or delete — that one wasn't caught until I wrote a test case
specifically to check it (TC-06) and it failed. Three different bugs, three different ways of finding
them: one from running a report, one from manually reviewing adjacent data, one from a dedicated test.
That's probably the real lesson — different kinds of checking catch different kinds of mistakes, and
"I read it carefully" didn't catch any of the three.

## Where the brief misled me, or where I misled myself

The brief doesn't actually mislead on the business rules — BR-02's wording is clear. Where I went
wrong was trusting that writing data which *satisfied one part* of a rule ("four students") meant it
satisfied the *whole* rule, without checking the other clause ("same subject, same band"). That's on
me, not on the brief.

Where the brief genuinely has a gap, not just a hard problem: §9.2 lists entity attributes but never
gives `Student` or `Enrolment` a link to `Centre` or to `DistrictContract`, even though §5 and §9.5
both assume you can report by centre and reconcile district funding. I didn't notice this by reading
the brief twice — I noticed it by trying to write the actual SQL query §9.5 asks for and discovering
there was nothing to join against. Artifact 15 (the change request) exists because of that gap, and
it's the kind of thing you only find by trying to build the thing, not by reviewing the spec.

## Where I used AI in this work, what I kept, what I rejected, and how I checked it

I used Claude for most of the actual construction — schema design, seed data, the SQL analysis
queries, the RTM, the test cases, this reflection draft itself. The useful discipline wasn't "trust it"
or "don't trust it" — it was **make it prove the claim**. Every time something was described as
working ("the ledger is append-only," "the group session is valid," "the queries return correct
numbers"), the check was to actually run it against the schema and look at the real output, not to
read the explanation and accept it. That's how all three bugs above got caught — not by catching them
in the write-up, but by refusing to accept a written claim without a matching execution result next to
it.

What I kept: the schema design decisions (derived credit balance via an append-only ledger, a `Payer`
supertype for the two billing paths, nullable centre for online sessions) — these held up under
testing and matched the brief's own traps in §9.3.

What I rejected or made Claude redo: the first version of the "group of four" seed case (BR-02
violation), the first version of the tutor-utilisation query (it joined on every subject a tutor was
qualified for instead of the subject actually taught in that session, inflating some numbers), and a
query that developed a duplicate-row bug of its own once an earlier fix changed the data underneath it
— a reminder that fixing one thing can quietly break another, which is why I re-ran the full query set
after every schema change rather than assuming the fix was isolated.

What I'd still want to check, and haven't: the AI feature specification (artifact 16) is written to a
defensible standard, but nothing in it has been tested against real BrightPath data, because none
exists yet — its metrics (precision, recall, the switch-off threshold) are proposed, not measured. I'm
treating that honestly as unverified rather than claiming confidence I don't have.
