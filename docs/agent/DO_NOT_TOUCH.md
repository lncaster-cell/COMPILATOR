# Do Not Touch Without Explicit Current-Task Authorization

This file lists repository areas and contracts that agents must not change unless the user explicitly asks for that in the current task.

## Compiler/toolchain

Do not run, modify, rename, move, or reconfigure:

- NWScript compiler binaries;
- compiler wrapper scripts;
- compiler workflow/config files;
- third-party compiler files;
- bundled stock/reference scripts;
- generated compiler output directories.

Agents may read stock/reference scripts shipped with the compiler/toolchain only for compatibility research.

## Runtime contracts

Do not rename or casually change:

- literal local-key string values;
- persistent DB key names;
- area registry key names;
- movement job local names;
- transition state local names;
- diagnostic local names used in active debugging;
- public helper APIs used across includes.

If a contract must change, document the migration plan in the PR and update `docs/AGENT_WORKLOG.md`.

## Include-order contracts

Do not casually change:

- declaration-only include files;
- compile-order helper includes;
- public prototypes used by multiple includes;
- large include ordering just to silence a local error.

Prefer narrow local forward declarations only when necessary and compatible with the repository rules.

## Active diagnostics

Do not remove active diagnostics unless the task is explicitly diagnostic cleanup.

Currently sensitive diagnostics include:

- BSMITH_TRACE stages;
- movement reached/finalize debug locals;
- worker skip/failure reasons;
- critical stale-reached handling traces;
- contradiction/classify lines used for blacksmith/Daily Life debugging.

If diagnostics are too noisy, narrow them instead of deleting them.

## Performance-sensitive paths

Do not add by default:

- per-NPC heartbeat logic;
- unbounded `GetFirstObjectInArea` loops in hot paths;
- repeated runtime tag searches;
- broad polling as a replacement for the engine action queue;
- DB calls as runtime cache lookups;
- large global resyncs from a local behavior bug.

Any fallback scan must be bounded, have an explicit reason, and be recorded in the worklog if non-trivial.

## Documentation/process files

Do not delete or bypass:

- `AGENTS.md`;
- `docs/AGENT_WORKLOG.md`;
- `docs/agent/TASK_PROTOCOL.md`;
- `docs/agent/DEBUGGING_PROTOCOL.md`;
- `docs/agent/SUBSYSTEM_INDEX.md`;
- `.github/pull_request_template.md`.

These files exist to preserve project continuity across agent sessions.
