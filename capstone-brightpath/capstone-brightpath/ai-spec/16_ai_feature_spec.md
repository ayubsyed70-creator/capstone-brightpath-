# Artifact 16 — AI Feature Specification: At-Risk Flag

Chosen over tutor matching because it attacks OBJ-5 directly (58% → 75% renewal) and connects to
work already specified in this capstone — FR-11 (renewal reminder) is a blunt, rule-based version of
the same goal; this spec asks whether a model earns its place on top of that rule.

## 1. Value and alternative

**What the user does differently.** Today a coordinator finds out a family is drifting only when the
bundle hits zero and nobody rebooks (§2: renewal rate 58%, "nobody can answer... which students
stopped coming and why"). The at-risk flag surfaces a warning 2–3 weeks earlier, while there's still
a credit balance and a reason to call — letting a coordinator phone the guardian proactively instead
of reactively.

**The alternative, honestly assessed.** A rule could already catch some of this cheaply: "flag any
student whose attendance dropped below 70% over the last 4 sessions" or "flag a student with no
progress note in 30 days" (the latter is already query 6 from artifact 12). Those rules would catch
the obvious cases — a student stopped showing up — essentially for free, with no model, no training
data pipeline, and no bias review. **A rule-based flag should ship first, regardless of whether the
model is built**, because it's nearly costless and already mostly specified. The case for the model is
narrower than it first looks: it's for the *non-obvious* pattern — a student still attending, still
getting good notes, who nonetheless won't renew (e.g., a family that renews every August regardless of
how the student is doing, then suddenly doesn't). If the model's lift over the simple rule turns out to
be small once measured (§3 below), that's a valid finding, and the honest recommendation would be to
ship the rule and shelve the model.

## 2. Data

Three years of history: ~46,000 session records, attendance, free-text progress notes (no controlled
vocabulary, written by 38 different tutors), and renewal outcomes.

- **Consent.** Guardian consent (BR-12, CON-6) covers *tutoring*, not *model training*. Using session
  and attendance history to train a renewal-prediction model is a new processing purpose and needs its
  own consent line, not a silent extension of the existing one. Recommend: an opt-in, separate from
  tutoring consent, explained in plain terms ("we use attendance patterns to help coordinators reach
  out before a renewal is missed") — and a path to decline that doesn't affect the tutoring service
  itself.
- **Free-text notes are the hardest input.** No controlled vocabulary, 38 different authors, 3 years
  of drift in what a "good" note looks like. Any feature derived from note text (sentiment, keyword
  flags) needs its own bias check — a tutor who writes terse notes isn't a worse tutor, and a student
  described in short notes shouldn't be flagged more just because their tutor writes less.

## 3. Metrics, not "shall"

The output is probabilistic — it has no "shall" and should never be specified with one.

- **Primary metric**: precision and recall at a chosen threshold, measured against actual non-renewal
  within 60 days of a flag being raised.
- **Secondary metric**: top-3 acceptance — when a coordinator calls a flagged family, did they agree
  something was off, logged as a simple yes/no after the call (this doubles as the human-in-the-loop
  record in §4).
- **Measurement window**: rolling 90 days, re-evaluated monthly, with at least one full renewal cycle
  (a term) before the first real read.
- **Switch-off threshold**: if precision falls below 40% (worse than a coin flip weighted toward the
  58% baseline renewal rate) for two consecutive monthly windows, the feature is switched off and
  reverts to the rule-based flag from §1, pending retraining.

## 4. Human in the loop

- **Who decides**: the centre coordinator, not the model and not the director directly.
- **What they see**: the flag, the handful of underlying signals that drove it (e.g., "attendance down
  20% vs. this student's own 90-day average," "renewal 45 days overdue vs. typical pattern" — pattern-
  level reasons, not a raw feature dump), and a single button to call or message the guardian.
- **What's recorded on override**: if a coordinator dismisses a flag, they pick a reason from a short
  list ("already renewed," "known reason, not a concern," "disagree with flag") rather than a free-text
  box — this becomes the labeled data that both measures precision (§3) and feeds retraining.

## 5. Failure behaviour

- **Low confidence**: below the operating threshold, nothing is shown. A flag with a hedge ("maybe at
  risk, 55% confidence") is worse than no flag — it trains coordinators to ignore the feature.
- **What must never be shown**: a numeric probability score presented as a fact about the student or
  family ("73% likely to leave"). It invites treating a probabilistic guess as a diagnosis of a child
  or a judgment of a family's commitment — show the underlying pattern instead, never the score itself.

## 6. Bias and fairness

These are children, and the flag concerns a family's money and a child's continued access to tutoring.

- **Fields the model may not use**: race, ethnicity, immigration status, family structure, any field
  from BR-12's consent record, and the guardian's preferred language (NFR-10) as a direct input.
- **Proxies that would smuggle them back in, named explicitly**: centre (Mesa's centre serves the
  district-funded population disproportionately — a centre-level feature is a funding-status proxy
  and, loosely, a socioeconomic one); school; postcode/zip if ever collected; language preference used
  indirectly via note-writing patterns; tutor-assigned tier (standard vs. certified) as a proxy for
  subject difficulty rather than student risk.
- **Subgroup testing**: precision and recall (§3) must be reported separately by centre and by
  guardian-vs-district funding status, not only in aggregate. A model that's accurate overall but
  systematically over-flags district-funded families would be flagging poverty, not risk, and needs to
  be caught before it reaches a coordinator's screen, not after a complaint.

## 7. Who may see the output

- **Not the student** — consistent with BR-13 and the general principle that a profiling output about
  a minor isn't shown to the minor.
- **The guardian**: no. Showing a family "our system thinks you might leave" before they've said
  anything is adversarial, not supportive, and risks the family feeling surveilled rather than helped.
  The *consequence* of the flag (a coordinator calling to check in) reaches the guardian; the flag
  itself does not.
- **The coordinator**: yes, for their own centre's students only (BR-13).
- **The director**: yes, aggregated (e.g., "12% of active enrolments flagged this month, 40% precision
  this quarter") — not a per-student list unless investigating a specific complaint.

## 8. Governance

Profiling a minor's continued engagement with an educational service, where the output can prompt an
outreach call that affects whether a family stays enrolled, is **not low-risk by default**. Position:
treat this as a **limited-risk, human-reviewed decision-support tool**, not an automated decision — the
model never books, cancels, or withholds a session on its own; it only directs a coordinator's
attention. **The output must never, by itself, affect a student's access to tutoring** — no automated
hold on booking, no automated change to a credit balance, no automated change in which tutor a student
is offered. If a future version is ever proposed to do any of those things automatically, that crosses
into a different, higher risk tier and needs its own governance review, not an extension of this one.
