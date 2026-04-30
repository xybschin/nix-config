---
name: project-analysis
description: Analyze the entire project and create a domain-focused overview document that bridges domain logic and code structure. Flags ambiguities and asks clarifying questions. Use when user wants a project overview, domain documentation, architecture summary, or mentions "analyze project", "project overview", or "domain documentation".
---

# Project Analysis

Analyze the full project to create a comprehensive overview document that captures domain concepts, architecture, and code structure in an integrated way. This bridges the gap between business logic and implementation.

## Process

1. **Explore the entire project** -- Use available exploration tools (prefer an `explore` subagent if configured; otherwise use grep/glob/view) to gather:
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

3. **Ask clarifying questions** -- If anything is ambiguous, ask the user. Never guess:
   - Unclear domain concepts
   - Purpose of subsystems if not evident
   - Assumptions about workflows and relationships
   - Examples for complex domain logic

4. **Write `PROJECT_ANALYSIS.md`** -- Create in the working directory using the template in `REFERENCE.md`. Balance code references with domain-level clarity.

5. **Review with user** -- Present the analysis and ask for feedback before finalizing.

## Rules

- **Ask, don't assume.** If domain intent or architectural purpose is unclear, ask the user instead of guessing.
- **Bridge domain and code.** Explain domain concepts in business terms, then reference where they live in code (use `file:line` format).
- **Be specific.** Use concrete examples and actual code references, not generic descriptions.
- **Flag uncertainty.** In the "Open Questions" section, list anything that felt unclear during analysis.
- **No implementation details.** Skip low-level code mechanics unless they directly explain a domain decision.
- **One entity per section.** Don't compress multiple concepts into one block.
- **Show relationships.** Explain how concepts depend on or relate to each other.

## Workflow

1. **Initial exploration** -- get the full picture
2. **Domain mapping** -- extract domain concepts from code and documentation
3. **Ask for clarification** -- present preliminary findings; example questions:
   - "Is [concept] the primary entity in [subsystem]?"
   - "Does [workflow] match how you think about [process]?"
   - "What's the purpose of [module] -- is it for [purpose A] or [purpose B]?"
4. **Refine understanding** -- incorporate user feedback
5. **Write the analysis** -- using the template in `REFERENCE.md`
6. **Final review** -- present and offer adjustments

## Re-running

When invoked again in the same project:

1. Read the existing `PROJECT_ANALYSIS.md`
2. Re-explore the project to identify changes
3. Ask the user what's changed and which sections to update
4. Update only changed sections, marking them with "(updated)"
5. Add new concepts with "(new)"
6. Re-validate assumptions with the user

## Post-output

After writing and validating, briefly tell the user the file was created, mention the user-confirmed assumptions it relies on, and offer to update it as the domain evolves.

## Output template

See `REFERENCE.md` in this skill directory for the full `PROJECT_ANALYSIS.md` template.
