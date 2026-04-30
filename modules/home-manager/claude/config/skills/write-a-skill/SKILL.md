---
name: write-a-skill
description: Create new Claude Code agent skills with proper structure, progressive disclosure, and bundled resources. Use when the user wants to create, write, or build a new skill.
---

# Write a Skill

Create Claude Code agent skills that enable specialized workflows for specific domains or tasks.

## Quick Start

Skills are directories with:
- **SKILL.md** - Main instructions and workflows
- **Optional files** - REFERENCE.md, EXAMPLES.md, scripts/

To create a skill:

1. Understand the task/domain the skill will cover
2. Draft SKILL.md with quick start + workflows
3. Add scripts or reference files if content exceeds ~100 lines
4. Place skill folder at `~/.claude/skills/<skill-name>/`

Claude Code loads skills automatically when their trigger conditions match the user's request.

## Skill Anatomy

**SKILL.md structure** (50-100 lines typical):

```markdown
---
name: skill-name
description: One sentence what it does. Use when [specific triggers].
---

# Skill Name

## Quick start
[Minimal example to get started fast]

## Workflows
[Step-by-step processes with decision points]

## Advanced features
[Link to REFERENCE.md for deep dives]
```

**Description** - The agent sees ONLY this to decide if it should load your skill. Make it specific:
- First sentence: what the skill enables
- Second sentence: "Use when [keywords or contexts]"
- Max 1024 characters
- Example: "Extract text and tables from PDF files, fill forms, merge documents. Use when user mentions PDFs, forms, or document extraction."

## Workflows

Define workflows for complex multi-step tasks. Structure as:

1. **Gather information** - what questions to ask the user
2. **Plan the work** - track steps with a todo tool if available
3. **Execute systematically** - complete tasks in priority order
4. **Verify completion** - confirm all requirements met

Use checklists and decision trees to guide complex processes.

## When to Use Scripts

Add utility scripts to `scripts/` directory when:

- Operation is deterministic (validation, formatting, parsing)
- Same code would be generated repeatedly
- Error handling needs explicit control
- Speed/token usage matters

Scripts save agent tokens and improve reliability.

## When to Split Content

Move content to separate files when:

- SKILL.md exceeds ~100 lines
- Content has distinct domains (e.g., finance vs sales)
- Advanced features are rarely needed for typical use

File organization:
- `REFERENCE.md` - detailed specs, comprehensive guides
- `EXAMPLES.md` - concrete usage examples
- `scripts/` - helper utilities

## Review Checklist

Before finishing a skill:

- [ ] Description clearly states trigger conditions ("Use when...")
- [ ] SKILL.md stays under 100 lines (or split if longer)
- [ ] No time-sensitive or machine-specific paths
- [ ] Consistent terminology throughout
- [ ] Concrete examples in quick start
- [ ] Workflows reference only SKILL.md/REFERENCE.md (one level deep)
