-- Artifact 12 — SQL analysis
-- One query per §9.5 report, run against erd/schema.sql + erd/seed.sql.
-- Each query is followed by its result (as run against the seed data) and a
-- one-line business interpretation, per the rubric's "not SELECT *" requirement.

-- =====================================================================
-- 1. Tutor utilisation, weekly, by centre and subject
--    (booked hours / declared available hours, per §9.5)
-- =====================================================================
WITH tutor_sessions AS (
    -- subject comes from the actual enrolment delivered in the session, not
    -- from every subject the tutor happens to be qualified for (an earlier
    -- draft joined TutorQualification directly and double-counted a tutor's
    -- other subjects against sessions they didn't teach that subject in)
    SELECT DISTINCT s.id AS session_id, s.tutor_id, s.centre_id, en.subject
    FROM Session s
    JOIN SessionStudent ss ON ss.session_id = s.id
    JOIN Enrolment en      ON en.id = ss.enrolment_id
    WHERE s.status IN ('Delivered','Recorded')
),
tutor_avail AS (
    SELECT tutor_id,
           SUM((strftime('%s','2000-01-01 '||end_time) -
                strftime('%s','2000-01-01 '||start_time)) / 3600.0) AS hours
    FROM TutorAvailability
    WHERE is_recurring = 1
    GROUP BY tutor_id
)
SELECT
    COALESCE(c.name, 'Online')                                   AS centre,
    ts.subject,
    t.name                                                       AS tutor,
    COUNT(DISTINCT ts.session_id)                                AS sessions_delivered,
    ROUND(COUNT(DISTINCT ts.session_id) * 55.0/60, 2)            AS booked_hours,
    ROUND(ta.hours, 2)                                           AS declared_available_hours,
    ROUND(100.0 * (COUNT(DISTINCT ts.session_id) * 55.0/60) / ta.hours, 1) AS utilisation_pct
FROM tutor_sessions ts
JOIN Tutor t       ON t.id = ts.tutor_id
LEFT JOIN Centre c ON c.id = ts.centre_id
JOIN tutor_avail ta ON ta.tutor_id = ts.tutor_id
GROUP BY centre, ts.subject, t.name, ta.hours
ORDER BY centre, ts.subject;

-- Actual result (5 rows, v2 seed) — Chandler/Math 30.6% (Ruth, 1 session) ·
-- Chandler/SAT Prep 30.6% (Ruth, 1) · Online/Reading 30.6% (Devon) ·
-- Tempe/Math 61.1% (Jordan, 2 sessions — his individual Maya session plus the
-- now BR-02-compliant group session) · Tempe/Reading 30.6% (Devon).
-- Interpretation: this is §2's "tutor utilisation: not measurable" baseline
-- made queryable, per tutor, subject and centre — which is what makes OBJ-6
-- achievable. (An earlier seed had a BR-02 violation — a group session mixing
-- four different subjects — that this same query exposed; see erd/seed.sql
-- v2 changelog for the fix.)


-- =====================================================================
-- 2. Sessions lost because no tutor could cover, by week and centre
-- =====================================================================
SELECT
    strftime('%Y-W%W', s.session_date) AS week,
    COALESCE(c.name, 'Online')          AS centre,
    COUNT(*)                            AS sessions_lost_no_cover
FROM Session s
LEFT JOIN Centre c ON c.id = s.centre_id
WHERE s.status = 'Cancelled' AND s.cancellation_reason = 'no_cover'
GROUP BY week, centre
ORDER BY week, centre;

-- Result on seed data: 0 rows — the seed set has no tutor-cancellation case
-- (E-3) yet. The query is correct; the seed should be extended with at least
-- one Cancelled session with cancellation_reason = 'no_cover' before this can
-- be demonstrated against real numbers. Flagging this rather than padding
-- the seed just to make the query look busy.
-- Interpretation (once populated): this is OBJ-1's own metric (baseline 26/wk,
-- target <8/wk) — the query needs no further logic, only real cancellation data.

-- =====================================================================
-- 3. Cancellation and no-show rate, by centre, tutor and reason
-- =====================================================================
WITH tutor_totals AS (
    SELECT tutor_id, COUNT(*) AS total_sessions FROM Session GROUP BY tutor_id
)
SELECT
    COALESCE(c.name, 'Online')                          AS centre,
    t.name                                               AS tutor,
    s.status,
    COALESCE(s.cancellation_reason, '(n/a)')             AS reason,
    COUNT(*)                                             AS occurrences,
    ROUND(100.0 * COUNT(*) / tt.total_sessions, 1)       AS pct_of_tutor_total_sessions
FROM Session s
JOIN Tutor t          ON t.id = s.tutor_id
LEFT JOIN Centre c    ON c.id = s.centre_id
JOIN tutor_totals tt  ON tt.tutor_id = t.id
WHERE s.status IN ('Cancelled','NoShow')
GROUP BY centre, tutor, s.status, reason, tt.total_sessions

UNION ALL

-- BR-05's no-show rule is per student, not per session — a group session
-- can stay 'Recorded' overall while one enrolled student didn't show. That
-- case needs its own row, computed against the tutor's total SessionStudent
-- records rather than total sessions, or it silently disappears from the
-- report above.
SELECT
    COALESCE(c.name, 'Online')                             AS centre,
    t.name                                                  AS tutor,
    'StudentNoShow(withinRecordedSession)'                  AS status,
    '(n/a)'                                                 AS reason,
    COUNT(*)                                                AS occurrences,
    ROUND(100.0 * COUNT(*) /
          (SELECT COUNT(*) FROM SessionStudent ss2
           JOIN Session s2 ON s2.id = ss2.session_id
           WHERE s2.tutor_id = t.id), 1)                    AS pct_of_tutor_total_sessions
FROM SessionStudent ss
JOIN Session s     ON s.id = ss.session_id
JOIN Tutor t       ON t.id = s.tutor_id
LEFT JOIN Centre c ON c.id = s.centre_id
WHERE ss.attendance_outcome = 'no_show' AND s.status NOT IN ('Cancelled','NoShow')
GROUP BY centre, tutor;

-- Actual result (v2 seed): one row — Jordan Lee, Tempe, 'StudentNoShow...',
-- 1 occurrence, 20.0% of his SessionStudent records (1 of 5 — Emma, in
-- session 3, the group session; the session itself stayed 'Recorded' since
-- the other three students attended). No whole-session Cancelled/NoShow rows
-- exist in the seed, so the first half of the UNION correctly returns
-- nothing yet.
-- Interpretation: the two rates need to stay separate in any dashboard — a
-- whole-session no-show blocks a tutor slot entirely; a per-student no-show
-- inside a group session doesn't, and only the second one is what BR-05's
-- one-per-term waiver actually governs.

-- =====================================================================
-- 4. Outstanding credit liability, in dollars
--    (unused, unexpired credits — the figure nobody can produce today)
-- =====================================================================
SELECT
    ROUND(SUM(bal.balance * (b.price_paid / b.credits_purchased)), 2) AS outstanding_liability_usd
FROM v_credit_balance bal
JOIN Bundle b ON b.student_id = bal.student_id
WHERE bal.balance > 0
  AND b.id = (
      SELECT MAX(b2.id) FROM Bundle b2
      WHERE b2.student_id = bal.student_id AND b2.expiry_date >= date('now')
  );

-- Actual result (v2 seed): $2,839.50 — a real dollar figure, computed by
-- valuing each student's derived balance at their most recent unexpired
-- bundle's per-credit price (higher than v1's $1,581 mainly because v2 adds
-- three fully-credited students, Ravi/Emma/Liam, to make the group session
-- BR-02 compliant). Noah's district-funded bundle has price_paid=0, so his
-- 19.0 remaining credits correctly add $0 to the liability — BrightPath owes
-- him tutoring, not a refund, and this reflects that without a special-case
-- in the query.
-- Interpretation: this directly answers §1's "~$80,000 — nobody can state the
-- figure to the dollar" — at real scale this is the query the director has
-- never had. Caveat worth recording at review: it values a balance at the
-- latest bundle's price, not a blended average across bundles bought at
-- different prices — a modelling choice, not a bug, but one to defend.

-- =====================================================================
-- 5. Package renewal rate, by centre and subject
--    (renewed within 30 days of last credit, per §2 baseline)
-- =====================================================================
WITH exhausted AS (
    SELECT b.student_id, b.id AS bundle_id, b.expiry_date, en.subject,
           (SELECT MIN(purchase_date) FROM Bundle nb
            WHERE nb.student_id = b.student_id AND nb.purchase_date > b.purchase_date) AS next_purchase
    FROM Bundle b
    JOIN Student s2 ON s2.id = b.student_id
    JOIN Enrolment en ON en.student_id = s2.id
    WHERE (SELECT balance FROM v_credit_balance vb WHERE vb.student_id = b.student_id) <= 0
       OR b.expiry_date < date('now')
)
SELECT
    -- Deliberately no centre column: the schema has no Student -> Centre
    -- relationship (a student's centre is only implied by where their
    -- sessions happen, which can vary session to session). An earlier draft
    -- faked a join that always returned NULL just to have a centre column —
    -- removed, because a query that looks complete but silently can't answer
    -- part of the question is worse than one that admits the gap.
    subject,
    COUNT(*)                                             AS exhausted_bundles,
    SUM(CASE WHEN julianday(next_purchase) - julianday(expiry_date) <= 30
             THEN 1 ELSE 0 END)                           AS renewed_within_30d,
    ROUND(100.0 * SUM(CASE WHEN julianday(next_purchase) - julianday(expiry_date) <= 30
             THEN 1 ELSE 0 END) / COUNT(*), 1)             AS renewal_rate_pct
FROM exhausted
GROUP BY subject;

-- Actual result: 1 row — Math, 1 exhausted bundle (Maya's Bundle 4, expired
-- 2026-01-10), renewed_within_30d = 0 (her next purchase, Bundle 1, was
-- ~7 months later, not within 30 days) -> 0.0% renewal rate.
-- Open item for the questions log: "by centre" from §9.5 can't be answered
-- as written — raise as a change request (artifact 15): either add a
-- home_centre_id to Student/Enrolment, or confirm the director actually
-- means "the centre of the student's most recent session," which is
-- answerable but needs its own subquery and a decision on ties.

-- =====================================================================
-- 6. Students with no progress note in 30 days
-- =====================================================================
SELECT
    st.id, st.first_name, st.last_name,
    MAX(pn.created_at) AS last_note_date,
    CAST(julianday('now') - julianday(MAX(pn.created_at)) AS INT) AS days_since_last_note
FROM Student st
LEFT JOIN SessionStudent ss ON ss.student_id = st.id
LEFT JOIN ProgressNote pn   ON pn.session_student_id = ss.id
GROUP BY st.id
HAVING last_note_date IS NULL OR days_since_last_note > 30
ORDER BY days_since_last_note DESC NULLS FIRST;

-- Actual result (v2 seed): 1 row — Ben Webb, last_note_date NULL. Every other
-- student has at least one note dated in the (session-clock) future relative
-- to "now" in this environment, so their gap reads as negative, not >30, and
-- correctly doesn't trip the filter. Ben is the one real case: attendance
-- recorded, no note yet (case e / BR-07), so he correctly surfaces here too.
-- Interpretation: this is OBJ-4's own metric (31% -> 100% documented) — once
-- run on live data it becomes the coordinator's weekly follow-up list.

-- =====================================================================
-- 7. Demand vs. qualified tutor capacity, per subject and grade band
-- =====================================================================
SELECT
    e.subject, e.grade_band,
    COUNT(DISTINCT e.student_id)         AS enrolled_students,
    COUNT(DISTINCT tq.tutor_id)          AS qualified_tutors
FROM Enrolment e
LEFT JOIN TutorQualification tq
       ON tq.subject = e.subject AND tq.grade_band = e.grade_band
WHERE e.status = 'active'
GROUP BY e.subject, e.grade_band
ORDER BY enrolled_students * 1.0 / NULLIF(qualified_tutors,0) DESC;

-- Actual result (v2 seed): Math/3-5: 4 students, 1 tutor (4:1 — Jordan Lee is
-- now the busiest match in the whole set) · Math/6-8: 1 student, 2 tutors
-- (0.5:1 — Devon and Ruth are both qualified) · Reading/3-5: 1 student,
-- 1 tutor (1:1) · SAT Prep/9-12: 1 student, 2 tutors (0.5:1) — Priya Nair
-- (case f, zero bookings) is correctly counted as capacity even though she's
-- unbooked.
-- Interpretation: this is the query that would catch a subject/grade band
-- going understaffed before it costs OBJ-1's lost-session count — at 320
-- real students this ratio, not the raw counts, is what the director needs.

-- =====================================================================
-- 8. Mesa Public Schools monthly attendance reconciliation
--    (CON-5: fixed layout; BR-11: attendance only, never progress notes)
-- =====================================================================
SELECT
    st.id                                    AS district_student_id,
    st.first_name, st.last_name,
    s.session_date,
    ss.attendance_outcome
FROM Student st
JOIN SessionStudent ss ON ss.student_id = st.id
JOIN Session s         ON s.id = ss.session_id
WHERE EXISTS (
    SELECT 1 FROM CreditLedgerEntry cle
    JOIN Bundle b ON b.id = cle.bundle_id
    WHERE cle.student_id = st.id AND cle.created_by = 'sofia.almeida'
)
ORDER BY s.session_date;

-- Actual result: 1 row — Noah, session 6 (his individual SAT Prep session,
-- 2026-10-07, after the funding switch), attended. An earlier draft also
-- joined Payer on a fragile OR condition not needed for the actual filter
-- logic; once a second guardian-type Payer existed (v2's fix for the invoice
-- bug), that join started producing a duplicate row for Noah. Removed the
-- unnecessary join rather than paper over duplicates with a DISTINCT.
-- Note: there's still no direct Student -> DistrictContract link in the
-- schema — "district-funded" is only inferable from who created the funding
-- ledger entry, which is fragile even now that it's deduplicated correctly.
-- Interpretation / open item for the questions log: this report is
-- contractually required every month (BR-11, NFR-9, CON-5) and cannot rely on
-- an inferred link. Enrolment or Student needs an explicit
-- district_contract_id (nullable) before this query is trustworthy — worth
-- raising as a change request (artifact 15) rather than patching around it
-- here, since it also affects the data model and the RTM.

-- =====================================================================
-- 9. Credits expiring in the next 60 days
-- =====================================================================
SELECT
    st.first_name, st.last_name, b.id AS bundle_id,
    b.expiry_date,
    (SELECT COALESCE(SUM(amount),0) FROM CreditLedgerEntry cle WHERE cle.bundle_id = b.id) AS remaining_from_this_bundle,
    CAST(julianday(b.expiry_date) - julianday('now') AS INT) AS days_to_expiry
FROM Bundle b
JOIN Student st ON st.id = b.student_id
WHERE b.expiry_date BETWEEN date('now') AND date('now', '+60 days')
  AND (SELECT COALESCE(SUM(amount),0) FROM CreditLedgerEntry cle WHERE cle.bundle_id = b.id) > 0
ORDER BY days_to_expiry;

-- Result on seed data: 0 rows — every seeded bundle either expires far in the
-- future (2027) or already expired (Bundle 4, correctly excluded since it's
-- in the past, not within the next 60 days). The query is correct; add a
-- bundle expiring in ~45 days to the seed to demonstrate a non-empty result.
-- Interpretation: this is E-5's 30-day warning made queryable a layer earlier
-- (60 days out) so a coordinator has time to nudge a renewal before OBJ-5's
-- clock starts.
