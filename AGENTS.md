# Agent Instructions

This repository contains Neverwinter Nights 2 / NWScript code for the user's module systems. The project is large, actively changing, and developed through multiple AI/Codex sessions. This file is the mandatory shared memory and operating contract for every coding agent.

## Primary rule

Preserve NWScript/NWN2 compatibility, runtime behavior, and project continuity. Do not rely on memory from previous sessions. Always treat the repository, this file, `docs/agent/START_HERE.md`, and `docs/AGENT_WORKLOG.md` as the current source of truth.

This repository is optimized for AI-assisted solo/vibe development: the user drives intent, manual compilation, in-game validation, and final acceptance; agents provide investigation, minimal patches, PRs, and persistent context updates.

## Root-cause rule for bugs

For non-trivial runtime bugs, recurring bugs, Daily Life/NPC bugs, or any issue that has already consumed multiple PRs, agents must follow `docs/agent/ROOT_CAUSE_BUGFIX_PROTOCOL.md`.

Agents must not start with another behavior patch until they can state:

1. observed symptom;
2. expected state;
3. first failing pipeline stage;
4. evidence for that stage;
5. owner subsystem;
6. smallest safe fix or diagnostic step.

If the first failing stage is unknown, prefer a focused diagnostic PR over another broad behavior rewrite.

## Mandatory reading order before editing

Before changing any code, an agent must read:

1. `AGENTS.md`.
2. `docs/agent/START_HERE.md`.
3. `docs/AGENT_WORKLOG.md`, if present.
4. `docs/agent/SUBSYSTEM_INDEX.md` to locate the likely subsystem.
5. `docs/agent/TASK_PROTOCOL.md`.
6. `docs/agent/ROOT_CAUSE_BUGFIX_PROTOCOL.md` for non-trivial, recurring, runtime, or Daily Life/NPC bugs.
7. `docs/agent/DEBUGGING_PROTOCOL.md` when debugging runtime/NPC/Daily Life behavior.
8. `docs/agent/DO_NOT_TOUCH.md` before touching risky areas.
9. The target files and nearby includes.
10. Recent relevant PR descriptions or commit messages when investigating an active bug.
11. Existing helpers, constants, local-key contracts, and diagnostics related to the task.

Never start by rewriting. Start by understanding the current architecture and the last known debugging state.

## Compile ownership rule

Compilation is user-owned.

Agents must not run the NWScript compiler, compiler workflow, or project compile command unless the user explicitly gives a one-off instruction in the current task.

Allowed:

- Read source files.
- Read documentation.
- Read stock/reference scripts shipped with the compiler/toolchain, for compatibility research only.
- Run lightweight static/textual checks only when safe and clearly not invoking the compiler, for example whitespace checks, grep/search, brace-balance scans, or banned-pattern scans.

Forbidden unless explicitly authorized by the user in the current task:

- Running the NWScript compiler.
- Running repository compile workflows.
- Modifying compiler binaries, compiler scripts, compiler configuration, third-party compiler files, or bundled stock/reference scripts.
- Treating static checks as proof of successful compilation.

Final reports must say clearly: `Compilation not run; user owns compilation.`

## Current active development context

The active repository work is bug fixing and behavior debugging, especially around Daily Life/NPC behavior.

Recent active focus:

- `daily_life/` subsystem.
- NPC movement jobs.
- `reached` / `finalize` contradictions.
- stale `move_result == running` states.
- area worker re-entry for registered NPCs.
- canonical move-target/reached checks.
- BSMITH tracing and focused blacksmith diagnostics.

Do not undo recent diagnostic or invariant work unless the task explicitly requires it and the reason is documented.

## Core Daily Life movement invariants

The recent movement/debugging work established these contracts:

1. There should be one canonical reached verdict for a move job.
2. A physically reached NPC must not remain indefinitely in `move_result == running` when there is no active `ACTION_MOVETOPOINT`.
3. Registered critical NPCs with stale reached move state must be routed back through the real worker/directive pipeline, not fixed by unrelated duplicate logic.
4. Existing finalizer and directive pipelines should be reused.
5. Emergency correction paths must be constrained, diagnosable, and not become broad polling systems.
6. Do not remove BSMITH trace fields casually; they are part of the current debugging workflow.

## Before editing code

1. Inspect the current repository state before making changes.
2. Read the relevant files first.
3. Search for existing helpers, constants, contracts, and local-key literals before adding new ones.
4. Prefer minimal targeted patches over broad rewrites.
5. Do not mix architecture rewrites with compile-error fixes or runtime-bug fixes.
6. If the task touches an active bug, record the observed hypothesis and change in `docs/AGENT_WORKLOG.md`.

## Forbidden NWScript-incompatible patterns

Do not introduce:

- reference/output parameters such as `int &x`, `string &x`, `object &x`
- `#define` macro aliases
- local `const` declarations inside functions
- structs, classes, templates, generics, overloaded functions, or unsupported C/C++/C#/TypeScript syntax
- broad include-order hacks
- function bodies in compile-order declaration includes
- default arguments in compile-order declaration includes

## Constants and local-key contracts

Local variable names such as `dl_npc_transition_target`, `dl_area_pass_snapshot_tick`, and `dl_social_reserved_wp` are runtime state contracts.

Rules:

1. Do not rename literal local-key string values unless the task explicitly requires a migration.
2. Before adding any new key, search for both the symbolic name and the literal string value.
3. Do not create duplicate contract constants.
4. Be careful with `const string` globals. This compiler can report `Constant must be initialized before it may be referenced` when const globals are referenced across include-order boundaries.
5. For cross-include local-key names that trigger const-order errors, prefer compiler-safe globals:

```c
string KEY = "same_literal_key";
```

Do not change the literal key value.

## Include-order rules

1. Do not add broad global forward-declaration includes unless absolutely necessary.
2. Prefer local forward declarations inside the specific include that needs them.
3. Keep compile-order helper includes declaration-only:
   - no constants
   - no function bodies
   - no default args
   - no domain implementation
4. Do not place prototypes before large const blocks if it can trigger const-order errors.

## Compatibility patterns

Instead of output/reference parameters:

- return one value directly
- split the logic into helper functions
- store temporary results in module/object locals only when appropriate

Instead of `#define`:

- use `const string` / `const int` only when safe
- use global `string` / `int` for cross-include compatibility when const-order errors occur

Instead of local `const` inside functions:

- use local `string` / `int` variables
- or move true constants to file scope when safe

## Refactor and optimization rules

1. Keep refactors small and focused.
2. Do not mix architecture rewrites with compile-error fixes.
3. Do not rename contracts, local-key literals, or public helper APIs during performance cleanup unless the task explicitly requires it.
4. Reuse existing helpers before adding new ones.
5. Do not create pass-through wrappers unless they are required for compatibility.
6. Do not delete diagnostics that are still part of an active investigation without replacing them with equivalent or better observability.

## Performance rules

1. Do not add repeated area scans in hot paths.
2. Prefer existing registry, cache, snapshot, and index mechanisms.
3. Do not replace dense registries with `GetFirstObjectInArea` loops unless it is a bounded fallback or recovery path.
4. Any fallback scan must have a clear budget/cap.
5. Avoid runtime tag searches in hot paths when cached or indexed lookup is available.
6. Runtime fixes must use early exits and bounded work.

## Agent worklog requirement

Agents must update `docs/AGENT_WORKLOG.md` when they make any non-trivial change, including:

- bug fix
- behavior change
- new diagnostic field or trace
- architectural decision
- runtime contract change
- workaround for NWScript/compiler compatibility
- investigation that discovers an important false lead or invariant

The entry must be short but useful to the next agent. Include:

- date
- task/PR/branch if known
- files touched
- what changed
- why it changed
- compile status: always state whether compilation was not run because the user owns compilation
- any invariant or warning future agents must preserve

Do not use the worklog for tiny formatting-only edits.

## Documentation

If a change modifies architecture, contracts, setup rules, builder-facing workflow, or runtime behavior, update the relevant documentation or `docs/AGENT_WORKLOG.md` in the same PR.

Do not update documentation for pure mechanical compile fixes unless the contract changed.

## Final report requirements

When reporting completion, include:

- changed files
- what was changed
- whether any static checks were run
- `Compilation not run; user owns compilation.`
- remaining risks or next manual validation steps

Do not claim successful compilation unless the user explicitly ran compilation and provided that result in the current task.
