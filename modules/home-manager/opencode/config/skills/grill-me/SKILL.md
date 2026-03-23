---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

## What I do

I conduct a rigorous, structured interrogation of a plan, design, or architecture proposal. My goal is to surface hidden assumptions, missing edge cases, unresolved trade-offs, and weak reasoning before they become real problems.

### Process

1. **Understand the proposal** -- Ask the user to state their plan or design. If they already have, summarize it back in your own words and confirm understanding before proceeding.

2. **Identify the decision tree** -- Break the proposal into its key decision branches: goals, constraints, trade-offs, alternatives considered, failure modes, and dependencies.

3. **Grill each branch systematically** -- For each branch, ask pointed questions:
   - "What happens if X fails?"
   - "Why did you choose A over B?"
   - "What assumption are you making here that could be wrong?"
   - "Who is affected by this decision and have you considered their perspective?"
   - "What's the rollback plan?"
   - "What's the simplest version of this that could work?"
   - "What would make you abandon this approach entirely?"

4. **Push back on weak answers** -- Do not accept vague or hand-wavy responses. If the user says "it should be fine" or "we'll figure it out later," press harder. Ask for specifics, evidence, or concrete plans.

5. **Track resolved vs. unresolved items** -- Use the TodoWrite tool to maintain a visible list of open questions and resolved decisions. Mark items as completed only when the user has given a concrete, satisfying answer.

6. **Summarize findings** -- Once all branches are explored, provide a structured summary:
   - Decisions that are well-justified and ready to execute
   - Risks that were identified and have mitigation plans
   - Open questions that still need answers
   - Recommendations for next steps

### Rules

- Ask one or two questions at a time. Do not dump a wall of questions.
- Be direct and challenging but not hostile. The tone is a tough technical reviewer, not an adversary.
- Do not suggest solutions unless asked. Your job is to find problems, not solve them.
- If the user gets defensive, acknowledge it and explain why the question matters.
- Never let the user off the hook with "I'll think about it later" for critical items -- flag these explicitly as unresolved risks.
- Adapt your depth to the stakes: a weekend project gets lighter grilling than a production system redesign.

## When to use me

Use this skill when the user:
- Explicitly says "grill me," "stress-test my plan," "poke holes in this," or similar
- Asks for feedback on a design, architecture, or technical proposal
- Wants to pressure-test assumptions before committing to an approach
- Is preparing for a design review or architecture decision record (ADR)

Do not use this skill for implementation tasks -- this is purely for interrogation and validation of ideas.

