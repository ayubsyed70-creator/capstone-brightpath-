-- Artifact 11 — seed data
-- Awkward cases included, each flagged in a comment:
--   (a) online session with no centre        -> Session id 5
--   (b) group session of four students        -> Session id 3
--   (c) funding switches mid-bundle (E-7)      -> Student 4 (Noah), Payer 3 -> Payer 1
--   (d) expired bundle                         -> Bundle id 4
--   (e) delivered session with no progress note-> SessionStudent id 7 (Session 4 / Ben)
--   (f) tutor with zero bookings                -> Tutor id 4 (Priya Nair)

PRAGMA foreign_keys = ON;

INSERT INTO Centre (id, name, address, rooms) VALUES
 (1, 'Tempe',    '123 Mill Ave, Tempe AZ',    6),
 (2, 'Chandler', '45 Boston St, Chandler AZ', 4);

INSERT INTO Guardian (id, name, phone, email, preferred_language) VALUES
 (1, 'Elena Cruz',   '480-555-0101', 'elena.cruz@example.com',   'es'),
 (2, 'Marcus Webb',  '480-555-0102', 'marcus.webb@example.com',  'en'),
 (3, 'Aisha Rahman',  '480-555-0103', 'aisha.rahman@example.com', 'en');

INSERT INTO DistrictContract (id, name, contracted_students, rate, report_layout, deadline_day) VALUES
 (1, 'Mesa Public Schools', 45, 38.00, 'MESA_CSV_v3', 2);

-- Payer supertype rows (trap #4)
INSERT INTO Payer (id, payer_type, guardian_id, district_contract_id) VALUES
 (1, 'guardian', 1, NULL),
 (2, 'guardian', 2, NULL),
 (3, 'district', NULL, 1);

INSERT INTO Student (id, guardian_id, first_name, last_name, dob, school, grade) VALUES
 (1, 1, 'Maya',  'Cruz',    '2014-03-02', 'Tempe Elementary', '5'),
 (2, 1, 'Leo',   'Cruz',    '2016-08-19', 'Tempe Elementary', '3'),
 (3, 2, 'Ben',   'Webb',    '2011-01-11', 'Mesa Middle',      '8'),
 (4, 3, 'Noah',  'Rahman',  '2010-06-30', 'Mesa Middle',      '9');  -- (c) district-funded, funding ends mid-bundle

INSERT INTO Consent (id, student_id, given_date, scope, reconfirmed_date) VALUES
 (1, 1, '2026-01-05', 'tutoring', '2026-01-05'),
 (2, 2, '2026-01-05', 'tutoring', '2026-01-05'),
 (3, 3, '2025-09-01', 'tutoring', '2026-09-01'),
 (4, 4, '2025-09-01', 'tutoring', '2026-09-01');

INSERT INTO Enrolment (id, student_id, subject, grade_band, goal, term, status) VALUES
 (1, 1, 'Math',    '3-5', 'Fluent with fractions by term end', 'Fall2026', 'active'),
 (2, 2, 'Reading', '3-5', 'Read at grade level',                'Fall2026', 'active'),
 (3, 3, 'Math',    '6-8', 'Pass Algebra I',                     'Fall2026', 'active'),
 (4, 4, 'SAT Prep','9-12','Score 1300+',                        'Fall2026', 'active');

INSERT INTO Tutor (id, name, employment_type, tier, home_centre_id, teaches_online) VALUES
 (1, 'Jordan Lee',   'part_time_student', 'standard',  1, 1),
 (2, 'Devon Price',  'part_time_student', 'standard',  1, 1),
 (3, 'Ruth Halloran_T', 'retired_teacher', 'certified', 2, 0),
 (4, 'Priya Nair',   'retired_teacher',   'certified', 2, 1);  -- (f) zero bookings — newly qualified, not yet scheduled

INSERT INTO TutorQualification (id, tutor_id, subject, grade_band, tier) VALUES
 (1, 1, 'Math',    '3-5', 'standard'),
 (2, 2, 'Reading', '3-5', 'standard'),
 (3, 2, 'Math',    '6-8', 'standard'),
 (4, 3, 'Math',    '6-8', 'certified'),
 (5, 3, 'SAT Prep','9-12','certified'),
 (6, 4, 'SAT Prep','9-12','certified');  -- Priya is qualified but unbooked

INSERT INTO TutorAvailability (id, tutor_id, day_of_week, start_time, end_time, is_recurring, exception_date) VALUES
 (1, 1, 2, '16:00', '19:00', 1, NULL),
 (2, 2, 4, '15:00', '18:00', 1, NULL),
 (3, 3, 1, '16:00', '19:00', 1, NULL),
 (4, 4, 3, '16:00', '19:00', 1, NULL);

-- Sessions
INSERT INTO Session (id, tutor_id, session_date, start_time, mode, centre_id, status, cancellation_reason) VALUES
 (1, 1, '2026-10-01', '16:00', 'in_centre', 1, 'Recorded',  NULL),
 (2, 2, '2026-10-01', '15:00', 'in_centre', 1, 'Recorded',  NULL),
 (3, 3, '2026-10-02', '16:00', 'in_centre', 2, 'Recorded',  NULL),  -- (b) group of four, below
 (4, 3, '2026-10-05', '16:00', 'in_centre', 2, 'Delivered', NULL),  -- (e) delivered, no note yet
 (5, 2, '2026-10-03', '17:00', 'online',    NULL, 'Recorded', NULL); -- (a) online, no centre

-- SessionStudent
INSERT INTO SessionStudent (id, session_id, student_id, enrolment_id, attendance_outcome) VALUES
 (1, 1, 1, 1, 'attended'),                -- Maya, math, Session 1
 (2, 2, 2, 2, 'attended'),                -- Leo, reading, Session 2
 (3, 3, 3, 3, 'attended'),                -- (b) group session, 4 students same subject/grade band
 (4, 3, 4, 4, 'attended'),
 (5, 3, 1, 1, 'attended'),
 (6, 3, 2, 2, 'no_show'),
 (7, 4, 3, 3, 'attended'),                -- (e) delivered, attendance recorded, note missing
 (8, 5, 2, 2, 'attended');                -- (a) online session

INSERT INTO ProgressNote (id, session_student_id, note_text, created_at) VALUES
 (1, 1, 'Maya now confident adding unlike fractions.', '2026-10-01 18:10'),
 (2, 2, 'Leo read two chapters aloud with fewer errors.', '2026-10-01 18:20'),
 (3, 3, 'Ben engaged well in group discussion of linear equations.', '2026-10-02 18:05'),
 (4, 4, 'Noah kept pace with the group; needs more practice on word problems.', '2026-10-02 18:07'),
 (5, 5, 'Maya paired well with Ben on the harder problems.', '2026-10-02 18:08'),
 (6, 6, 'Leo did not attend; called guardian to confirm reason.', '2026-10-02 18:09'),
 (7, 8, 'Leo handled the online session well despite a brief connection drop.', '2026-10-03 18:00');
 -- (e) intentionally no row for session_student_id = 7 (Session 4 / Ben) — delivered, note outstanding

-- Bundles
INSERT INTO Bundle (id, student_id, credits_purchased, price_paid, purchase_date, expiry_date) VALUES
 (1, 1, 20, 840.00, '2026-08-01', '2027-08-01'),
 (2, 2, 10, 450.00, '2026-08-01', '2027-08-01'),
 (3, 3, 20, 840.00, '2026-08-15', '2027-08-15'),
 (4, 1, 10, 450.00, '2025-01-10', '2026-01-10'),  -- (d) expired bundle, unused remainder
 (5, 4, 20, 0.00,   '2026-08-15', '2027-08-15');  -- Noah: entitlement funded by the district contract, not a cash sale (price_paid=0; district is billed separately via Invoice/Payer 3)

-- Credit ledger (append-only; balance is derived via v_credit_balance)
INSERT INTO CreditLedgerEntry (id, student_id, bundle_id, session_student_id, amount, reason, created_by, created_at) VALUES
 (1, 1, 1, NULL, 20,   'purchase',          'ruth.halloran', '2026-08-01 09:00'),
 (2, 2, 2, NULL, 10,   'purchase',          'ruth.halloran', '2026-08-01 09:05'),
 (3, 3, 3, NULL, 20,   'purchase',          'ruth.halloran', '2026-08-15 10:00'),
 (10, 4, 5, NULL, 20,  'purchase',          'sofia.almeida', '2026-08-15 10:05'),  -- Noah's district-funded entitlement
 (4, 1, NULL, 1, -1,   'session_delivered', 'system',        '2026-10-01 18:10'),
 (5, 2, NULL, 2, -1,   'session_delivered', 'system',        '2026-10-01 18:20'),
 (6, 3, NULL, 3, -0.5, 'session_delivered', 'system',        '2026-10-02 18:05'),
 (7, 4, NULL, 4, -0.5, 'session_delivered', 'system',        '2026-10-02 18:07'),
 (8, 1, NULL, 5, -0.5, 'session_delivered', 'system',        '2026-10-02 18:08'),
 (9, 1, 4, NULL, -10,  'expiry',            'system',        '2026-01-10 00:00');  -- (d) expired, no refund (BR-04)

-- (c) Noah's district funding ends mid-bundle: existing ledger entries stay on Payer 3 (district);
-- the invoice for services from 2026-10-06 onward switches to Guardian payer (Payer 2), per E-7.
INSERT INTO Invoice (id, payer_id, invoice_date, tuition_amount, materials_amount, tax_amount, total_amount, status) VALUES
 (1, 1, '2026-10-01', 450.00, 25.00, 2.15, 477.15, 'open'),
 (2, 3, '2026-09-30', 840.00, 0.00,  0.00, 840.00, 'paid'),   -- Noah's district-billed invoice before funding ended
 (3, 2, '2026-10-10', 0.00,   0.00,  0.00, 0.00,   'open');   -- (c) Noah's first guardian-billed invoice, funding ended 2026-10-06

INSERT INTO Payment (id, invoice_id, amount, payment_date, method) VALUES
 (1, 2, 840.00, '2026-09-30', 'district_transfer');

-- Incident example (E-8), restricted visibility
INSERT INTO Incident (id, student_id, session_id, description, reported_by, reported_at, visibility_restricted) VALUES
 (1, 3, 4, 'Minor disagreement between two students during group session, resolved on the spot.', 'jordan.lee', '2026-10-05 17:05', 1);
