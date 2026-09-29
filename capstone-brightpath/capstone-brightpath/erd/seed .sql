-- Artifact 11 — seed data (v2, corrected)
-- Awkward cases included, each flagged in a comment:
--   (a) online session with no centre        -> Session id 5
--   (b) group session of four students        -> Session id 3 (BR-02 compliant: all four
--                                                  share subject=Math, grade_band=3-5)
--   (c) funding switches mid-bundle (E-7)      -> Student 4 (Noah): Invoice 2 (district, Payer 3,
--                                                  before switch) vs. Invoice 3 (guardian, Payer 4, after)
--   (d) expired bundle                         -> Bundle id 4
--   (e) delivered session with no progress note-> SessionStudent id 7 (Session 4 / Ben)
--   (f) tutor with zero bookings                -> Tutor id 4 (Priya Nair)
--
-- v2 fixes two defects found by actually running artifact 12's SQL analysis against v1:
--   1. BR-02 violation: v1's group session mixed four different subject/grade-band
--      enrolments (Math 3-5, Reading 3-5, Math 6-8, SAT Prep 9-12) in one group session,
--      which BR-02 forbids ("at most 4 students, all in the same subject and within one
--      grade band"). Fixed by adding three new same-subject-band students (Ravi, Emma,
--      Liam) to fill the group properly, and giving Ben and Noah their own individual
--      sessions instead (still same tutors/dates/cases, just no longer forced together).
--   2. Invoice 3 (Noah's post-funding-switch bill) pointed at payer_id 2 (Marcus Webb —
--      Ben's guardian, not Noah's). There was no Payer row for Noah's actual guardian
--      (Aisha Rahman) at all. Added Payer 4 and corrected Invoice 3 to use it.

PRAGMA foreign_keys = ON;

INSERT INTO Centre (id, name, address, rooms) VALUES
 (1, 'Tempe',    '123 Mill Ave, Tempe AZ',    6),
 (2, 'Chandler', '45 Boston St, Chandler AZ', 4);

INSERT INTO Guardian (id, name, phone, email, preferred_language) VALUES
 (1, 'Elena Cruz',    '480-555-0101', 'elena.cruz@example.com',   'es'),
 (2, 'Marcus Webb',   '480-555-0102', 'marcus.webb@example.com',  'en'),
 (3, 'Aisha Rahman',  '480-555-0103', 'aisha.rahman@example.com', 'en'),
 (4, 'Priya Shah',    '480-555-0104', 'priya.shah@example.com',   'en');

INSERT INTO DistrictContract (id, name, contracted_students, rate, report_layout, deadline_day) VALUES
 (1, 'Mesa Public Schools', 45, 38.00, 'MESA_CSV_v3', 2);

INSERT INTO Payer (id, payer_type, guardian_id, district_contract_id) VALUES
 (1, 'guardian', 1, NULL),
 (2, 'guardian', 2, NULL),
 (3, 'district', NULL, 1),
 (4, 'guardian', 3, NULL);

INSERT INTO Student (id, guardian_id, first_name, last_name, dob, school, grade) VALUES
 (1, 1, 'Maya',  'Cruz',    '2014-03-02', 'Tempe Elementary', '5'),
 (2, 1, 'Leo',   'Cruz',    '2016-08-19', 'Tempe Elementary', '3'),
 (3, 2, 'Ben',   'Webb',    '2011-01-11', 'Mesa Middle',      '8'),
 (4, 3, 'Noah',  'Rahman',  '2010-06-30', 'Mesa Middle',      '9'),
 (5, 4, 'Ravi',  'Patel',   '2015-04-10', 'Tempe Elementary', '4'),
 (6, 4, 'Emma',  'Liu',     '2015-07-22', 'Tempe Elementary', '4'),
 (7, 4, 'Liam',  'OBrien',  '2015-09-30', 'Tempe Elementary', '4');

INSERT INTO Consent (id, student_id, given_date, scope, reconfirmed_date) VALUES
 (1, 1, '2026-01-05', 'tutoring', '2026-01-05'),
 (2, 2, '2026-01-05', 'tutoring', '2026-01-05'),
 (3, 3, '2025-09-01', 'tutoring', '2026-09-01'),
 (4, 4, '2025-09-01', 'tutoring', '2026-09-01'),
 (5, 5, '2026-01-10', 'tutoring', '2026-01-10'),
 (6, 6, '2026-01-10', 'tutoring', '2026-01-10'),
 (7, 7, '2026-01-10', 'tutoring', '2026-01-10');

INSERT INTO Enrolment (id, student_id, subject, grade_band, goal, term, status) VALUES
 (1, 1, 'Math',    '3-5', 'Fluent with fractions by term end',   'Fall2026', 'active'),
 (2, 2, 'Reading', '3-5', 'Read at grade level',                  'Fall2026', 'active'),
 (3, 3, 'Math',    '6-8', 'Pass Algebra I',                       'Fall2026', 'active'),
 (4, 4, 'SAT Prep','9-12','Score 1300+',                          'Fall2026', 'active'),
 (5, 5, 'Math',    '3-5', 'Build confidence with multiplication', 'Fall2026', 'active'),
 (6, 6, 'Math',    '3-5', 'Master multi-step word problems',      'Fall2026', 'active'),
 (7, 7, 'Math',    '3-5', 'Keep pace with the group',             'Fall2026', 'active');

INSERT INTO Tutor (id, name, employment_type, tier, home_centre_id, teaches_online) VALUES
 (1, 'Jordan Lee',      'part_time_student', 'standard',  1, 1),
 (2, 'Devon Price',     'part_time_student', 'standard',  1, 1),
 (3, 'Ruth Halloran_T', 'retired_teacher',   'certified', 2, 0),
 (4, 'Priya Nair',      'retired_teacher',   'certified', 2, 1);

INSERT INTO TutorQualification (id, tutor_id, subject, grade_band, tier) VALUES
 (1, 1, 'Math',    '3-5', 'standard'),
 (2, 2, 'Reading', '3-5', 'standard'),
 (3, 2, 'Math',    '6-8', 'standard'),
 (4, 3, 'Math',    '6-8', 'certified'),
 (5, 3, 'SAT Prep','9-12','certified'),
 (6, 4, 'SAT Prep','9-12','certified');

INSERT INTO TutorAvailability (id, tutor_id, day_of_week, start_time, end_time, is_recurring, exception_date) VALUES
 (1, 1, 2, '16:00', '19:00', 1, NULL),
 (2, 2, 4, '15:00', '18:00', 1, NULL),
 (3, 3, 1, '16:00', '19:00', 1, NULL),
 (4, 4, 3, '16:00', '19:00', 1, NULL);

-- Session 3 is now taught by Jordan Lee (qualified Math 3-5) at Tempe, not Ruth at
-- Chandler — the group's subject/grade band has to match a real qualification.
INSERT INTO Session (id, tutor_id, session_date, start_time, mode, centre_id, status, cancellation_reason) VALUES
 (1, 1, '2026-10-01', '16:00', 'in_centre', 1, 'Recorded',  NULL),
 (2, 2, '2026-10-01', '15:00', 'in_centre', 1, 'Recorded',  NULL),
 (3, 1, '2026-10-02', '16:00', 'in_centre', 1, 'Recorded',  NULL),
 (4, 3, '2026-10-05', '16:00', 'in_centre', 2, 'Delivered', NULL),
 (5, 2, '2026-10-03', '17:00', 'online',    NULL, 'Recorded', NULL),
 (6, 3, '2026-10-07', '16:00', 'in_centre', 2, 'Recorded',  NULL);

-- SessionStudent — session 3 is now one subject (Math), one grade band (3-5), 4 students: BR-02 compliant
INSERT INTO SessionStudent (id, session_id, student_id, enrolment_id, attendance_outcome) VALUES
 (1, 1, 1, 1, 'attended'),
 (2, 2, 2, 2, 'attended'),
 (3, 3, 1, 1, 'attended'),
 (4, 3, 5, 5, 'attended'),
 (5, 3, 6, 6, 'no_show'),
 (6, 3, 7, 7, 'attended'),
 (7, 4, 3, 3, 'attended'),
 (8, 5, 2, 2, 'attended'),
 (9, 6, 4, 4, 'attended');

INSERT INTO ProgressNote (id, session_student_id, note_text, created_at) VALUES
 (1, 1, 'Maya now confident adding unlike fractions.',                         '2026-10-01 18:10'),
 (2, 2, 'Leo read two chapters aloud with fewer errors.',                      '2026-10-01 18:20'),
 (3, 3, 'Maya paired well with the group on multiplication drills.',           '2026-10-02 18:05'),
 (4, 4, 'Ravi built confidence with two-digit multiplication today.',          '2026-10-02 18:06'),
 (5, 5, 'Emma did not attend; called guardian to confirm reason.',             '2026-10-02 18:07'),
 (6, 6, 'Liam kept pace with the group on word problems.',                     '2026-10-02 18:08'),
 (8, 8, 'Leo handled the online session well despite a brief connection drop.','2026-10-03 18:00'),
 (9, 9, 'Noah worked through timed SAT math sections; on track for goal.',     '2026-10-07 18:10');

INSERT INTO Bundle (id, student_id, credits_purchased, price_paid, purchase_date, expiry_date) VALUES
 (1, 1, 20, 840.00, '2026-08-01', '2027-08-01'),
 (2, 2, 10, 450.00, '2026-08-01', '2027-08-01'),
 (3, 3, 20, 840.00, '2026-08-15', '2027-08-15'),
 (4, 1, 10, 450.00, '2025-01-10', '2026-01-10'),
 (5, 4, 20, 0.00,   '2026-08-15', '2027-08-15'),
 (6, 5, 10, 450.00, '2026-08-05', '2027-08-05'),
 (7, 6, 10, 450.00, '2026-08-05', '2027-08-05'),
 (8, 7, 10, 450.00, '2026-08-05', '2027-08-05');

INSERT INTO CreditLedgerEntry (id, student_id, bundle_id, session_student_id, amount, reason, created_by, created_at) VALUES
 (1, 1, 1, NULL, 20,   'purchase',          'ruth.halloran', '2026-08-01 09:00'),
 (2, 2, 2, NULL, 10,   'purchase',          'ruth.halloran', '2026-08-01 09:05'),
 (3, 3, 3, NULL, 20,   'purchase',          'ruth.halloran', '2026-08-15 10:00'),
 (4, 4, 5, NULL, 20,   'purchase',          'sofia.almeida', '2026-08-15 10:05'),
 (5, 5, 6, NULL, 10,   'purchase',          'ruth.halloran', '2026-08-05 09:00'),
 (6, 6, 7, NULL, 10,   'purchase',          'ruth.halloran', '2026-08-05 09:05'),
 (7, 7, 8, NULL, 10,   'purchase',          'ruth.halloran', '2026-08-05 09:10'),
 (8, 1, NULL, 1, -1,   'session_delivered', 'system',        '2026-10-01 18:10'),
 (9, 2, NULL, 2, -1,   'session_delivered', 'system',        '2026-10-01 18:20'),
 (10, 1, NULL, 3, -0.5,'session_delivered', 'system',        '2026-10-02 18:05'),
 (11, 5, NULL, 4, -0.5,'session_delivered', 'system',        '2026-10-02 18:06'),
 (12, 6, NULL, 5, -0.5,'no_show_consumed',  'system',        '2026-10-02 18:07'),
 (13, 7, NULL, 6, -0.5,'session_delivered', 'system',        '2026-10-02 18:08'),
 (14, 2, NULL, 8, -1,  'session_delivered', 'system',        '2026-10-03 18:00'),
 (15, 4, NULL, 9, -1,  'session_delivered', 'system',        '2026-10-07 18:10'),
 (16, 1, 4, NULL, -10, 'expiry',            'system',        '2026-01-10 00:00');

INSERT INTO Invoice (id, payer_id, invoice_date, tuition_amount, materials_amount, tax_amount, total_amount, status) VALUES
 (1, 1, '2026-10-01', 450.00, 25.00, 2.15, 477.15, 'open'),
 (2, 3, '2026-09-30', 840.00, 0.00,  0.00, 840.00, 'paid'),
 (3, 4, '2026-10-10', 38.00,  0.00,  0.00, 38.00,  'open');

INSERT INTO Payment (id, invoice_id, amount, payment_date, method) VALUES
 (1, 2, 840.00, '2026-09-30', 'district_transfer');

INSERT INTO Incident (id, student_id, session_id, description, reported_by, reported_at, visibility_restricted) VALUES
 (1, 3, 4, 'Minor disagreement between two students during a session, resolved on the spot.', 'ruth.halloran', '2026-10-05 17:05', 1);
