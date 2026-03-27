---
name: project-analysis
description: Analyze the entire project and create a domain-focused overview document that bridges domain logic and code structure. Flags ambiguities and asks clarifying questions. Use when user wants a project overview, domain documentation, architecture summary, or mentions "analyze project", "project overview", or "domain documentation".
---

# Project Analysis

Analyze the full project to create a comprehensive overview document that captures domain concepts, architecture, and code structure in an integrated way. This bridges the gap between business logic and implementation.

## Process

1. **Explore the entire project** -- Use the Task tool with the `explore` agent (thorough level) to gather:
   - Directory structure and module organization
   - Key domain concepts and workflows
   - Major subsystems and components
   - Data models and entities
   - Integration points and dependencies
   - Configuration and deployment patterns

2. **Identify domain and architecture** -- From the exploration, determine:
   - **Core domain concepts** (main entities, aggregates, bounded contexts)
   - **Key workflows** (how the system operates, user journeys, business processes)
   - **Architectural patterns** (layering, service boundaries, responsibility boundaries)
   - **Critical relationships** (dependencies, data flow, communication patterns)
   - **Technical constraints and decisions** (why things are designed this way)

3. **Ask clarifying questions** -- If anything is ambiguous or unclear:
   - Ask the user to explain unclear domain concepts
   - Clarify the purpose of subsystems if not evident
   - Confirm assumptions about workflows and relationships
   - Request examples if domain logic is complex
   - Never guess or assume -- ask instead

4. **Write `PROJECT_ANALYSIS.md`** -- Create in working directory using format below. Balance code references with domain-level clarity.

5. **Review with user** -- Present the analysis and ask for feedback before finalizing.

## Output Format

Write `PROJECT_ANALYSIS.md` with this structure:

```md
# Project Analysis

## Executive Summary

[2-3 sentences: What this project does and why it matters from a domain perspective]

## Core Domain Concepts

### [Concept Name]

**Domain definition:** [What this concept means in the business/domain context]

**Implementation:** [Where and how it's implemented in code; file:line references]

**Relationships:** [How it relates to other core concepts]

**Example:** [Concrete example of how this concept is used]

## Key Workflows

### [Workflow Name]

**Purpose:** [Why this workflow exists and what problem it solves]

**Steps:**
1. [Step description]
2. [Step description]
3. [Step description]

**Responsible components:** [Key files/modules involved; file:line references]

**Data flow:** [How data moves through this workflow]

## Architecture

### Layering & Boundaries

[Describe the high-level structure: is it layered, microservices, monolithic? What are the major divisions?]

**Key subsystems:**
- **[Subsystem]** -- [Purpose and responsibility]
- **[Subsystem]** -- [Purpose and responsibility]

### Critical Dependencies

- [Dependency description with rationale]
- [Dependency description with rationale]

### Integration Points

[Describe how parts of the system communicate. External integrations? APIs? Message queues?]

## Data Models

### [Entity/Aggregate]

**Purpose:** [What this represents]

**Key properties:** [Main fields and their meaning]

**Lifecycle:** [How this entity is created, modified, deleted]

**Location:** [Where defined in code; file:line]

## Technical Decisions

| Decision | Rationale | Trade-offs |
|----------|-----------|-----------|
| [Decision] | [Why this was chosen] | [What was given up] |
| [Decision] | [Why this was chosen] | [What was given up] |

## Open Questions & Ambiguities

- [Question that needs clarification]
- [Assumption that should be verified]
- [Unclear responsibility boundary]

## How to Navigate This Project

[Brief guidance for new developers: where to start, what's the main entry point, which files are most important]

```

## Rules

- **Ask, don't assume.** If domain intent or architectural purpose is unclear, ask the user instead of guessing.
- **Bridge domain and code.** Explain domain concepts in business terms, then reference where they live in code (use `file:line` format).
- **Be specific.** Use concrete examples and actual code references, not generic descriptions.
- **Flag uncertainty.** In the "Open Questions" section, list anything that felt unclear during analysis.
- **No implementation details.** Skip low-level code mechanics unless they directly explain a domain decision.
- **One entity per section.** Don't compress multiple concepts into one block.
- **Show relationships.** Explain how concepts depend on or relate to each other.

## Workflow During Analysis

1. **Initial exploration** -- Run the explore agent to get the full picture
2. **Domain mapping** -- Extract domain concepts from code and documentation
3. **Ask for clarification** -- Present preliminary findings and ask the user:
   - "Is [concept] the primary entity in [subsystem]?"
   - "Does [workflow] match how you think about [process]?"
   - "What's the purpose of [module] -- is it for [purpose A] or [purpose B]?"
   - "Are these two concepts distinct or the same?"
4. **Refine understanding** -- Incorporate user feedback into analysis
5. **Write the analysis** -- Create comprehensive document with user-validated understanding
6. **Final review** -- Present to user and offer to adjust sections

## Re-running

When invoked again in the same project:

1. Read the existing `PROJECT_ANALYSIS.md`
2. Re-explore the project to identify changes
3. Ask the user:
   - "What's changed since we last analyzed?"
   - "Are there new workflows or domain concepts?"
   - "Should I update specific sections?"
4. Update only the sections that have changed, marking them with "(updated)"
5. Add new concepts to appropriate sections with "(new)"
6. Re-validate assumptions with the user

## Post-output instruction

After writing and validating the file, state:

> I've created `PROJECT_ANALYSIS.md` with a domain-and-code-integrated overview of this project. This analysis is based on [specific confirmations from the user]. If the domain model changes or new key workflows emerge, I can update this document to keep it current.
