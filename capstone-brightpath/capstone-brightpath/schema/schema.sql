-- Artifact 11 — BrightPath Learning schema (SQLite)
-- Run with: sqlite3 brightpath.db < 11_schema.sql

PRAGMA foreign_keys = ON;

CREATE TABLE Guardian (
    id                  INTEGER PRIMARY KEY,
    name                TEXT NOT NULL,
    phone               TEXT,
    email               TEXT,
    preferred_language  TEXT NOT NULL DEFAULT 'en' CHECK (preferred_language IN ('en','es'))
);

CREATE TABLE Centre (
    id      INTEGER PRIMARY KEY,
    name    TEXT NOT NULL,
    address TEXT,
    rooms   INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE Student (
    id          INTEGER PRIMARY KEY,
    guardian_id INTEGER NOT NULL REFERENCES Guardian(id),
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    dob         DATE NOT NULL,
    school      TEXT,
    grade       TEXT
);

-- BR-12: guardian consent required before first session, re-confirmed annually
CREATE TABLE Consent (
    id                INTEGER PRIMARY KEY,
    student_id        INTEGER NOT NULL REFERENCES Student(id),
    given_date        DATE NOT NULL,
    scope             TEXT NOT NULL,
    reconfirmed_date  DATE
);

CREATE TABLE Enrolment (
    id          INTEGER PRIMARY KEY,
    student_id  INTEGER NOT NULL REFERENCES Student(id),
    subject     TEXT NOT NULL,
    grade_band  TEXT NOT NULL,
    goal        TEXT NOT NULL,
    term        TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','closed'))
);

CREATE TABLE Tutor (
    id              INTEGER PRIMARY KEY,
    name            TEXT NOT NULL,
    employment_type TEXT NOT NULL CHECK (employment_type IN ('part_time_student','retired_teacher','other')),
    tier            TEXT NOT NULL CHECK (tier IN ('standard','certified')),
    home_centre_id  INTEGER REFERENCES Centre(id),
    teaches_online  INTEGER NOT NULL DEFAULT 0 CHECK (teaches_online IN (0,1))
);

-- BR-01: subject/grade-band qualification gate; SAT prep requires a certified tutor
CREATE TABLE TutorQualification (
    id          INTEGER PRIMARY KEY,
    tutor_id    INTEGER NOT NULL REFERENCES Tutor(id),
    subject     TEXT NOT NULL,
    grade_band  TEXT NOT NULL,
    tier        TEXT NOT NULL CHECK (tier IN ('standard','certified')),
    UNIQUE (tutor_id, subject, grade_band)
);

CREATE TABLE TutorAvailability (
    id              INTEGER PRIMARY KEY,
    tutor_id        INTEGER NOT NULL REFERENCES Tutor(id),
    day_of_week     INTEGER CHECK (day_of_week BETWEEN 0 AND 6),  -- NULL when is_recurring = 0
    start_time      TEXT NOT NULL,   -- 'HH:MM', MST
    end_time        TEXT NOT NULL,
    is_recurring    INTEGER NOT NULL CHECK (is_recurring IN (0,1)),
    exception_date  DATE             -- populated only when is_recurring = 0
);

CREATE TABLE Session (
    id                  INTEGER PRIMARY KEY,
    tutor_id            INTEGER NOT NULL REFERENCES Tutor(id),
    session_date        DATE NOT NULL,
    start_time          TEXT NOT NULL,  -- 55-minute duration per BR-03, not stored redundantly
    mode                TEXT NOT NULL CHECK (mode IN ('in_centre','online')),
    centre_id           INTEGER REFERENCES Centre(id),  -- nullable: online sessions have no centre
    status              TEXT NOT NULL DEFAULT 'Requested'
                        CHECK (status IN ('Requested','Scheduled','Confirmed','Delivered','Recorded','Cancelled','NoShow')),
    cancellation_reason TEXT,
    CHECK ( (mode = 'online' AND centre_id IS NULL) OR (mode = 'in_centre' AND centre_id IS NOT NULL) )
);

-- BR-08: enforce the only legal status transitions at the database layer
CREATE TRIGGER trg_session_status_transition
BEFORE UPDATE OF status ON Session
FOR EACH ROW
WHEN NOT (
    (OLD.status = 'Requested' AND NEW.status IN ('Scheduled','Cancelled'))
 OR (OLD.status = 'Scheduled' AND NEW.status IN ('Confirmed','Cancelled'))
 OR (OLD.status = 'Confirmed' AND NEW.status IN ('Delivered','Cancelled','NoShow'))
 OR (OLD.status = 'Delivered' AND NEW.status = 'Recorded')
)
BEGIN
    SELECT RAISE(ABORT, 'BR-08: illegal session status transition');
END;

-- BR-02: at most 4 students in a group session, same subject, one grade band — enforced in application
-- layer / a view (see 11_seed.sql comments) since SQLite CHECK cannot count sibling rows across sessions.
CREATE TABLE SessionStudent (
    id                  INTEGER PRIMARY KEY,
    session_id          INTEGER NOT NULL REFERENCES Session(id),
    student_id          INTEGER NOT NULL REFERENCES Student(id),
    enrolment_id        INTEGER NOT NULL REFERENCES Enrolment(id),
    attendance_outcome  TEXT CHECK (attendance_outcome IN ('attended','no_show') OR attendance_outcome IS NULL),
    UNIQUE (session_id, student_id)
);

-- BR-07: one note per student per session, not one per session
CREATE TABLE ProgressNote (
    id                  INTEGER PRIMARY KEY,
    session_student_id INTEGER NOT NULL UNIQUE REFERENCES SessionStudent(id),
    note_text           TEXT NOT NULL,
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- BR-04: bundle purchase; credits expire 12 months after purchase, non-refundable once delivery starts
CREATE TABLE Bundle (
    id                INTEGER PRIMARY KEY,
    student_id        INTEGER NOT NULL REFERENCES Student(id),
    credits_purchased REAL NOT NULL CHECK (credits_purchased IN (10,20,40)),
    price_paid        REAL NOT NULL,
    purchase_date     DATE NOT NULL,
    expiry_date       DATE NOT NULL
);

-- BR-09: append-only credit ledger; balance is derived (SUM), never overwritten
CREATE TABLE CreditLedgerEntry (
    id                  INTEGER PRIMARY KEY,
    student_id          INTEGER NOT NULL REFERENCES Student(id),
    bundle_id           INTEGER REFERENCES Bundle(id),           -- populated for a purchase entry
    session_student_id  INTEGER REFERENCES SessionStudent(id),   -- populated for a deduction/refund entry
    amount              REAL NOT NULL,   -- positive = credit added, negative = credit consumed
    reason              TEXT NOT NULL,   -- 'purchase' | 'session_delivered' | 'refund_ge_24h' | 'goodwill' | 'expiry' | 'on_account_override' | ...
    created_by          TEXT NOT NULL,
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- derived balance, materialized as a view (no stored balance column — trap #3)
CREATE VIEW v_credit_balance AS
SELECT student_id, SUM(amount) AS balance
FROM CreditLedgerEntry
GROUP BY student_id;

CREATE TABLE DistrictContract (
    id                  INTEGER PRIMARY KEY,
    name                TEXT NOT NULL,
    contracted_students INTEGER NOT NULL,
    rate                REAL NOT NULL,
    report_layout       TEXT NOT NULL,
    deadline_day        INTEGER NOT NULL  -- business days after month end, CON-5/NFR-9
);

-- Payer supertype: exactly one of guardian_id / district_contract_id is populated (trap #4)
CREATE TABLE Payer (
    id                    INTEGER PRIMARY KEY,
    payer_type            TEXT NOT NULL CHECK (payer_type IN ('guardian','district')),
    guardian_id           INTEGER REFERENCES Guardian(id),
    district_contract_id  INTEGER REFERENCES DistrictContract(id),
    CHECK (
        (payer_type = 'guardian'  AND guardian_id IS NOT NULL AND district_contract_id IS NULL)
     OR (payer_type = 'district' AND district_contract_id IS NOT NULL AND guardian_id IS NULL)
    )
);

-- BR-10: tuition untaxed, materials taxed at 8.6% — both may appear on one invoice
CREATE TABLE Invoice (
    id               INTEGER PRIMARY KEY,
    payer_id         INTEGER NOT NULL REFERENCES Payer(id),
    invoice_date     DATE NOT NULL,
    tuition_amount   REAL NOT NULL DEFAULT 0,
    materials_amount REAL NOT NULL DEFAULT 0,
    tax_amount       REAL NOT NULL DEFAULT 0,  -- = materials_amount * 0.086
    total_amount     REAL NOT NULL,
    status           TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','part_paid','paid'))
);

CREATE TABLE Payment (
    id            INTEGER PRIMARY KEY,
    invoice_id    INTEGER NOT NULL REFERENCES Invoice(id),
    amount        REAL NOT NULL,
    payment_date  DATE NOT NULL,
    method        TEXT NOT NULL
);

-- E-8 / NFR-5 / NFR-6: restricted visibility, 25-year retention, director only
CREATE TABLE Incident (
    id                     INTEGER PRIMARY KEY,
    student_id             INTEGER NOT NULL REFERENCES Student(id),
    session_id             INTEGER REFERENCES Session(id),
    description            TEXT NOT NULL,
    reported_by            TEXT NOT NULL,
    reported_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    visibility_restricted  INTEGER NOT NULL DEFAULT 1 CHECK (visibility_restricted IN (0,1))
);

-- BR-09 / NFR-6: every schedule change, credit movement and record access is logged
CREATE TABLE AuditLog (
    id           INTEGER PRIMARY KEY,
    entity_type  TEXT NOT NULL,
    entity_id    INTEGER NOT NULL,
    action       TEXT NOT NULL,
    user_id      TEXT NOT NULL,
    timestamp    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detail       TEXT
);

-- Auto-log every ledger write (BR-09) so the audit trail can't be bypassed by forgetting to log it
CREATE TRIGGER trg_audit_ledger_insert
AFTER INSERT ON CreditLedgerEntry
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (entity_type, entity_id, action, user_id, detail)
    VALUES ('CreditLedgerEntry', NEW.id, 'insert', NEW.created_by,
            'amount=' || NEW.amount || ' reason=' || NEW.reason);
END;
