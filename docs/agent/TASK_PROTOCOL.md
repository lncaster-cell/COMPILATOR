# Agent Task Protocol

This protocol is the default workflow for AI/Codex agents working in this repository.

## Goal

Reduce context loss, prevent broad rewrites, and keep every task traceable.

## Start of task

1. Read `AGENTS.md`.
2. Read `docs/AGENT_WORKLOG.md`.
3. Read any relevant file in `docs/agent/`.
4. Inspect recent relevant PRs or commits if the task is a bug fix.
5. Identify the smallest subsystem that can own the change.
6. Read the target files and nearby includes before editing.

Do not start by rewriting code.

## Investigation phase

Before editing, write down mentally or in the PR body:

- observed problem;
- expected behavior;
- likely subsystem;
- existing helper/function/contract that should be reused;
- risk of touching runtime state, include order, local-key strings, or diagnostics.

Search before adding anything new:

- function name;
- symbolic constant;
- literal local-key value;
- debug/trace field;
- similar fix in recent PRs.

## Patch phase

Default patch rules:

1. Make the smallest targeted change that can fix the current issue.
2. Reuse existing helpers before adding new helpers.
3. Keep behavior inside the existing pipeline whenever possible.
4. Do not introduce duplicate movement/finalizer/directive logic.
5. Preserve diagnostics that are part of an active investigation.
6. Add new diagnostics only if they explain a concrete state transition or invariant.
7. Avoid broad scans, polling loops, and tag lookups in hot paths.
8. Do not touch compiler/toolchain files.

## Validation phase

Compilation is user-owned.

Allowed agent-side validation:

- whitespace/diff check;
- grep/search consistency check;
- brace/string/comment balance scan;
- banned NWScript pattern scan;
- targeted review of touched includes and prototypes.

Forbidden without explicit current-task authorization:

- NWScript compiler run;
- repository compile workflow run;
- modifying compiler binaries/config/scripts;
- claiming static checks prove successful compilation.

## Worklog phase

Update `docs/AGENT_WORKLOG.md` for any non-trivial task.

A worklog entry is required for:

- bug fix;
- behavior change;
- new diagnostic/tracing field;
- runtime contract change;
- architecture decision;
- compatibility workaround;
- investigation finding that future agents must preserve.

No worklog entry is needed for pure formatting or typo-only edits.

## PR phase

Use `.github/pull_request_template.md`.

The PR must state:

- files changed;
- behavior/runtime contracts touched;
- diagnostics added/removed;
- static checks run, if any;
- `Compilation not run; user owns compilation.`;
- manual validation needed from the user.

## Stop conditions

Stop and report risk instead of guessing when:

- the fix requires changing compiler/toolchain files;
- the root cause depends on unavailable in-game runtime state;
- the change would require broad architecture rewrite;
- multiple subsystems conflict and there is no clear minimal owner;
- preserving compile compatibility would require changing public include order broadly.
