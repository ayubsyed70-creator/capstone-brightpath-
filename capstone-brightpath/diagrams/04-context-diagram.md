# Context Diagram — BrightPath Learning System

Level-0 (system context): the system as one box, every external actor that sends or receives something
across its boundary, and what crosses in each direction.

```mermaid
graph TB
    subgraph EXT["External Actors"]
        Guardian["Guardian<br/>(payer, consent-giver)"]
        Student["Student<br/>(minor, no direct access)"]
        Tutor["Tutor<br/>(personal phone, no app install)"]
        Coordinator["Centre Coordinator<br/>(4 centres)"]
        Director["Director<br/>(Dr. Reyes)"]
        Billing["Billing Administrator<br/>(part-time, Mon/Wed)"]
        Mesa["Mesa Public Schools<br/>(district funder, external contract)"]
        QuickBooks["QuickBooks<br/>(accounting package)"]
        VideoTool["District-approved video tool<br/>(online session platform)"]
    end

    SYS(("BrightPath Learning<br/>System"))

    Guardian -->|"enquiry, consent, bundle purchase, reschedule request"| SYS
    SYS -->|"balance, schedule, statement, progress report"| Guardian

    Student -.->|"no direct system access (CON-6)"| SYS

    Tutor -->|"availability, cover response, attendance + progress note"| SYS
    SYS -->|"schedule, notification (≤60s, NFR-8)"| Tutor

    Coordinator -->|"enrolment, scheduling decisions, overrides, incident record"| SYS
    SYS -->|"day/week schedule view, dispute data, utilisation view"| Coordinator

    Director -->|"scope/objective priorities"| SYS
    SYS -->|"weekly utilisation, renewal rate, credit liability, KPI reports"| Director

    Billing -->|"reconciliation actions, invoice adjustments"| SYS
    SYS -->|"ledger, invoice, statement data"| Billing

    SYS -->|"monthly attendance CSV<br/>(fixed layout, CON-5, NFR-9)"| Mesa
    Mesa -->|"contract terms, funded-student list, deadline"| SYS

    SYS -->|"invoice/payment CSV export<br/>(CON-7, export-only)"| QuickBooks

    SYS -->|"session link pasted in"| VideoTool
    VideoTool -.->|"no data returned to system<br/>(video itself out of scope, §5)"| SYS
```

## Notes on the boundary

- **Student** has a dotted line: they exist in the data model (as the subject of sessions and progress
  notes) but have no login and send/receive nothing directly, per CON-6 and §4 ("not consulted").
- **QuickBooks** and the **video tool** are one-way at the system boundary by design (CON-7: export only,
  no write-back; §5: video platform itself is out of scope) — the diagram shows no return arrow from
  either, which is the point, not an omission.
- **Mesa Public Schools** is the only external actor whose interface shape is a hard, unnegotiable
  constraint (CON-5) rather than something the team designs — worth calling out explicitly in the SRS
  when this diagram is referenced.
- This is intentionally system-level (Level-0). Which internal component talks to Mesa or QuickBooks
  (a scheduled job vs. an on-demand export button) is a design decision for the sequence diagrams
  (artifact #9), not this diagram.
