# Agent Workflow Rules: NixOS, Graphify, & NixOS MCP Context

## Environment & Tooling
- This repository is indexed via **Graphify**. 
- You have access to Graphify MCP tools (like `graph_query` or `query_codebase_graph`).
- You have access to the **NixOS MCP Server**, which provides direct execution hooks into the active Nix environment (e.g., evaluating expressions, querying options, tracking current configurations).
- The Nix Language Server (`nil`) has been injected into the graph pipeline for precise Nix attribute resolution.

## Dual-Engine Orchestration: Which Tool to Trigger?
You must combine Graphify and the NixOS MCP strategically instead of blindly running expensive `grep`, `find`, or text-reading commands.

### 1. Trigger Graphify For:
- **Structural Audits:** Mapping how modules, host configurations (e.g., laptop vs. server), or Home Manager profiles are structurally linked.
- **Impact Analysis ("Blast Radius"):** Before editing or refactoring code, querying downstream dependencies or module chains to see what files rely on that node.
- **Trace Inquiries:** Mapping out file layout topologies and tracing where custom option definitions physically live across the repository layout.

### 2. Trigger NixOS MCP For:
- **Option Introspection:** Validating whether an option exists, checking its default values, or reading its official documentation description.
- **Expression Evaluation:** Evaluating Nix expressions or tracing dynamic variable derivations directly against the Nix evaluator rather than guessing the outcome.
- **System Generation state:** Investigating current host generation details, system profile history, or checking build capabilities.

## Tool Execution Flow
- **Step 1:** Determine if your problem is **structural** (Use Graphify) or **functional/evaluative** (Use NixOS MCP).
- **Step 2:** Formulate your question into a precise tool call to the respective server. 
- **Step 3:** Use Graphify first to locate the *exact, relevant files* to keep your token budget small. Use the NixOS MCP next to *verify your logic* before suggesting a build or commit.

## Nix-Specific Guardrails
- Nix maps functions and modules as complex functional sets, not traditional linear calls. Trust Graphify's entity relationships (`IMPORTS`, `DEPENDS_ON`, `DECLARES`) over standard text matches.
- If Graphify indicates a file is a highly connected "god-node" (e.g., your core `flake.nix` or `modules/core/default.nix`), exercise extreme caution before editing it. Verify changes using the NixOS MCP evaluation tools first.
