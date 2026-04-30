# PROJECT_ANALYSIS.md template

Use this template when writing `PROJECT_ANALYSIS.md` in the project's working directory. Omit any
section that doesn't apply. Replace bracketed placeholders with real content; never leave them in.

~~~md
# Project Analysis

## Executive Summary

[2-3 sentences: what this project does and why it matters from a domain perspective.]

## Core Domain Concepts

### [Concept Name]

**Domain definition:** [What this concept means in the business/domain context.]

**Implementation:** [Where and how it's implemented in code; `file:line` references.]

**Relationships:** [How it relates to other core concepts.]

**Example:** [Concrete example of how this concept is used.]

## Key Workflows

### [Workflow Name]

**Purpose:** [Why this workflow exists and what problem it solves.]

**Steps:**
1. [Step description]
2. [Step description]
3. [Step description]

**Responsible components:** [Key files/modules involved; `file:line` references.]

**Data flow:** [How data moves through this workflow.]

## Architecture

### Layering & Boundaries

[Describe the high-level structure: layered, microservices, monolithic? Major divisions?]

**Key subsystems:**
- **[Subsystem]** -- [Purpose and responsibility]
- **[Subsystem]** -- [Purpose and responsibility]

### Critical Dependencies

- [Dependency with rationale]
- [Dependency with rationale]

### Integration Points

[How parts of the system communicate. External integrations? APIs? Message queues?]

## Data Models

### [Entity/Aggregate]

**Purpose:** [What this represents.]

**Key properties:** [Main fields and their meaning.]

**Lifecycle:** [How this entity is created, modified, deleted.]

**Location:** [Where defined in code; `file:line`.]

## Technical Decisions

| Decision   | Rationale               | Trade-offs         |
| ---------- | ----------------------- | ------------------ |
| [Decision] | [Why this was chosen]   | [What was given up]|
| [Decision] | [Why this was chosen]   | [What was given up]|

## Open Questions & Ambiguities

- [Question that needs clarification]
- [Assumption that should be verified]
- [Unclear responsibility boundary]

## How to Navigate This Project

[Brief guidance for new developers: where to start, main entry point, most important files.]
~~~
