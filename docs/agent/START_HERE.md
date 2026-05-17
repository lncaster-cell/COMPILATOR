# Start Here: Agent Productivity Guide

This repository is developed in a vibe-coding workflow: the user drives intent, testing, and compilation, while AI/Codex agents perform code investigation, patching, documentation updates, and PR preparation.

The purpose of the agent files is not documentation for its own sake. They are productivity infrastructure.

They exist to make agents:

- enter the project faster;
- preserve context between sessions;
- avoid repeating solved investigations;
- avoid unsafe rewrites;
- avoid compiler/toolchain mistakes;
- produce consistent PRs;
- leave useful state for the next agent.

## Operating model

The user is the project owner and runtime verifier.

Agents are implementation assistants.

| Owner | Responsibility |
|---|---|
| User | intent, priorities, manual compile, in-game validation, final acceptance |
| Agent | code reading, minimal patches, static checks, PRs, worklog/context updates |

Compilation is user-owned. Agents must not run the compiler unless explicitly authorized in the current task.

## The required path for every coding agent

Before editing code:

1. Read `AGENTS.md`.
2. Read `docs/AGENT_WORKLOG.md`.
3. Read this file.
4. Read `docs/agent/SUBSYSTEM_INDEX.md` to find the likely owner subsystem.
5. Read `docs/agent/TASK_PROTOCOL.md`.
6. If debugging NPC/Daily Life behavior, read `docs/agent/DEBUGGING_PROTOCOL.md`.
7. Read `docs/agent/DO_NOT_TOUCH.md` before changing risky areas.
8. Read the target files and nearby includes.
9. Search for existing helpers/contracts before adding anything.

After non-trivial work:

1. Update `docs/AGENT_WORKLOG.md`.
2. Use `.github/pull_request_template.md`.
3. State manual validation needed from the user.
4. State: `Compilation not run; user owns compilation.`

## File map

| File | Purpose |
|---|---|
| `AGENTS.md` | Hard repository contract for all agents |
| `docs/AGENT_WORKLOG.md` | Persistent mini-history across sessions |
| `docs/agent/START_HERE.md` | High-level operating model and reading path |
| `docs/agent/TASK_PROTOCOL.md` | Default workflow for agent tasks |
| `docs/agent/DEBUGGING_PROTOCOL.md` | Repeatable investigation order for runtime/NPC bugs |
| `docs/agent/SUBSYSTEM_INDEX.md` | Map from problem type to likely files/subsystems |
| `docs/agent/DO_NOT_TOUCH.md` | Guardrails for compiler/toolchain, contracts, diagnostics, and hot paths |
| `.github/pull_request_template.md` | Consistent PR reporting |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | Structured bug input |

## Productivity rules

1. Prefer orientation over guessing.
2. Prefer one minimal patch over a broad rewrite.
3. Prefer existing helpers over new helpers.
4. Prefer existing engine/NWN2 mechanisms over custom simulation loops.
5. Prefer bounded fallback over polling.
6. Prefer preserving diagnostics over deleting them.
7. Prefer worklog entries over relying on session memory.
8. Prefer explicit risk notes over pretending certainty.

## How to handle vague user tasks

When the user gives a broad/vibe-coded task, agents should convert it into a concrete working frame:

```text
Goal:
Likely subsystem:
Files to inspect:
Existing contracts to preserve:
Smallest safe change:
Manual validation needed:
```

Do not ask the user to restate information already available in repository context, recent PRs, traces, or worklog entries.

## How to handle bug fixes

For a bug fix, the agent should:

1. Identify the observed state.
2. Identify the expected state.
3. Find the likely subsystem owner.
4. Read recent related worklog entries and PRs.
5. Reuse the existing pipeline.
6. Add or preserve diagnostics.
7. Make the smallest targeted patch.
8. Record what changed and why.
9. Tell the user exactly what to test manually.

## How to handle Daily Life/NPC bugs

Use `docs/agent/DEBUGGING_PROTOCOL.md`.

Current sensitive area:

- movement jobs;
- canonical reached verdict;
- `move_result == running` stale states;
- worker touch path;
- directive/finalizer closure;
- BSMITH tracing.

Do not replace this with a new polling system or broad area scan.

## What good output looks like

A good agent PR should tell the user:

- what changed;
- why it changed;
- what files changed;
- what runtime contracts were touched;
- whether diagnostics changed;
- what was not touched;
- what static checks were run;
- that compilation was not run;
- what the user should test in game.

## What bad output looks like

Bad agent behavior:

- starts coding before reading context;
- runs compiler despite user ownership;
- rewrites large subsystem for a local bug;
- removes diagnostics because they look noisy;
- changes local-key strings without migration;
- adds duplicate reach/finalizer logic;
- adds hot-path scans or polling;
- leaves no worklog entry;
- claims compile success from static checks.

## Final principle

This repository should be optimized for high-quality AI-assisted solo development.

Every change should make the next fix easier, not just solve the immediate prompt.
