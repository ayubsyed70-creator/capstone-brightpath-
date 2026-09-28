# Artifact 11 — Entity-Relationship Diagram

BrightPath Learning · release 1 data model

## Design decisions on the four §9.3 traps

1. **Multi-student session, per-student progress note.** `Session` holds shared facts (tutor, time,
   mode, centre). `SessionStudent` links each enrolled student to the session and carries their own
   attendance outcome. `ProgressNote` is 1:1 with `SessionStudent`, not with `Session` — a 4-student
   group session can have up to 4 notes; BR-07 (attendance + note before the credit is deducted)
   applies per student.
2. **Nullable centre.** `Session.centre_id` is nullable for `mode = 'online'`. Reports grouped by
   centre (§9.5) bucket NULL as a synthetic "Online" group in the query layer, not as a fake centre row.
3. **Credit balance: derived, not stored.** `CreditLedgerEntry` is append-only (BR-09); balance is
   `SUM(amount)` per student, materializable later if read performance demands it (view `v_credit_balance`
   below). No column is ever overwritten — a correction is a new signed entry.
4. **Invoice payer, two kinds.** `Payer` is a supertype with `payer_type` and exactly one of
   `guardian_id` / `district_contract_id` populated (enforced by CHECK). `Invoice.payer_id → Payer`.
   E-7 (funding ends mid-bundle) creates a new `Payer` row and future invoices point to it; past
   ledger entries are untouched.

## Diagram

```mermaid
erDiagram
    GUARDIAN ||--o{ STUDENT : "guardian of"
    STUDENT ||--o{ CONSENT : "has"
    STUDENT ||--o{ ENROLMENT : "enrolled in"
    STUDENT ||--o{ BUNDLE : "purchases"
    STUDENT ||--o{ CREDIT_LEDGER_ENTRY : "owns balance"
    STUDENT ||--o{ SESSION_STUDENT : "attends"
    STUDENT ||--o{ INCIDENT : "involved in"

    TUTOR ||--o{ TUTOR_QUALIFICATION : "holds"
    TUTOR ||--o{ TUTOR_AVAILABILITY : "declares"
    TUTOR ||--o{ SESSION : "teaches"

    CENTRE ||--o{ SESSION : "hosts (nullable)"

    ENROLMENT ||--o{ SESSION_STUDENT : "tracked in"

    SESSION ||--o{ SESSION_STUDENT : "has"
    SESSION_STUDENT ||--o| PROGRESS_NOTE : "one note"
    SESSION_STUDENT ||--o| CREDIT_LEDGER_ENTRY : "may trigger"

    BUNDLE ||--o{ CREDIT_LEDGER_ENTRY : "funds"

    PAYER ||--o{ INVOICE : "billed"
    GUARDIAN ||--o| PAYER : "may be"
    DISTRICT_CONTRACT ||--o| PAYER : "may be"
    DISTRICT_CONTRACT ||--o{ STUDENT : "funds (via enrolment)"
    INVOICE ||--o{ PAYMENT : "settled by"

    GUARDIAN {
        int id PK
        string name
        string phone
        string email
        string preferred_language
    }
    STUDENT {
        int id PK
        int guardian_id FK
        date dob
        string school
        string grade
    }
    CONSENT {
        int id PK
        int student_id FK
        date given_date
        string scope
        date reconfirmed_date
    }
    ENROLMENT {
        int id PK
        int student_id FK
        string subject
        string grade_band
        string goal
        string term
        string status
    }
    TUTOR {
        int id PK
        string name
        string employment_type
        string tier
        int home_centre_id FK
        bool teaches_online
    }
    TUTOR_QUALIFICATION {
        int id PK
        int tutor_id FK
        string subject
        string grade_band
        string tier
    }
    TUTOR_AVAILABILITY {
        int id PK
        int tutor_id FK
        int day_of_week
        time start_time
        time end_time
        bool is_recurring
        date exception_date
    }
    CENTRE {
        int id PK
        string name
        string address
        int rooms
    }
    SESSION {
        int id PK
        int tutor_id FK
        date session_date
        time start_time
        string mode
        int centre_id FK "nullable — online sessions"
        string status
        string cancellation_reason
    }
    SESSION_STUDENT {
        int id PK
        int session_id FK
        int student_id FK
        int enrolment_id FK
        string attendance_outcome
    }
    PROGRESS_NOTE {
        int id PK
        int session_student_id FK "unique — 1:1"
        string note_text
        datetime created_at
    }
    BUNDLE {
        int id PK
        int student_id FK
        int credits_purchased
        decimal price_paid
        date purchase_date
        date expiry_date
    }
    CREDIT_LEDGER_ENTRY {
        int id PK
        int student_id FK
        int bundle_id FK "nullable"
        int session_student_id FK "nullable"
        decimal amount "signed, append-only"
        string reason
        string created_by
        datetime created_at
    }
    PAYER {
        int id PK
        string payer_type "guardian | district"
        int guardian_id FK "nullable"
        int district_contract_id FK "nullable"
    }
    DISTRICT_CONTRACT {
        int id PK
        string name
        int contracted_students
        decimal rate
        string report_layout
        int deadline_day
    }
    INVOICE {
        int id PK
        int payer_id FK
        date invoice_date
        decimal tuition_amount
        decimal materials_amount
        decimal tax_amount
        decimal total_amount
        string status
    }
    PAYMENT {
        int id PK
        int invoice_id FK
        decimal amount
        date payment_date
        string method
    }
    INCIDENT {
        int id PK
        int student_id FK
        int session_id FK "nullable"
        string description
        string reported_by
        datetime reported_at
        bool visibility_restricted
    }
    AUDIT_LOG {
        int id PK
        string entity_type
        int entity_id
        string action
        string user_id
        datetime timestamp
        string detail
    }
```

`AuditLog` and `TutorAvailability`'s recurring/exception split aren't drawn with relationship lines
above (they reference many tables generically / one table respectively) — see the DDL for their
actual foreign keys and the trigger that populates `AuditLog` automatically on ledger writes.
