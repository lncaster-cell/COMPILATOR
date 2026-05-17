# Subsystem Index

This index helps agents locate the likely owner of a task before editing code.

It is intentionally compact. Update it when a new subsystem becomes active or when ownership changes.

## Global agent/process files

- `AGENTS.md` — mandatory repository-level instructions and constraints.
- `docs/AGENT_WORKLOG.md` — short shared memory for non-trivial changes.
- `docs/agent/TASK_PROTOCOL.md` — default task workflow.
- `docs/agent/DEBUGGING_PROTOCOL.md` — runtime/NPC debugging protocol.
- `.github/pull_request_template.md` — PR report structure.
- `.github/ISSUE_TEMPLATE/bug_report.yml` — structured bug-report intake.

## Daily Life / NPC behavior

Purpose:

- NPC schedules;
- directives;
- movement jobs;
- area worker processing;
- transitions;
- diagnostics for runtime behavior.

Likely files:

- `daily_life/dl_worker_inc.nss`
- `daily_life/dl_move_job_inc.nss`
- `daily_life/dl_move_job_decl_inc.nss`
- `daily_life/dl_res_inc.nss`
- `daily_life/dl_transition_inc.nss`
- `daily_life/dl_diag_inc.nss`
- `daily_life/dl_dbg_time.nss`

Critical contracts:

- area-level dense registry;
- move job state;
- directive pipeline;
- reached/finalize invariant;
- BSMITH tracing;
- local-key string stability;
- include-order compatibility.

Default protocol:

- read `docs/agent/DEBUGGING_PROTOCOL.md` before touching movement/worker/finalizer code;
- preserve canonical reached checks;
- keep critical worker fallback bounded;
- do not introduce broad scans or duplicate finalizer logic.

## Movement jobs

Likely owner:

- `daily_life/dl_move_job_inc.nss`
- `daily_life/dl_move_job_decl_inc.nss`

Use when task involves:

- move target resolution;
- move result transitions;
- radius/distance/reached checks;
- move ticket/version;
- canonical reached verdict.

Preserve:

- one canonical reached verdict;
- no duplicate distance logic unless documented;
- no reference/output params;
- declaration includes remain declaration-only.

## Directive/apply/finalizer pipeline

Likely owner:

- `daily_life/dl_res_inc.nss`

Use when task involves:

- applying directives;
- finalizing reached movement;
- same-directive fast path;
- focus state closure;
- movement regression after apply.

Preserve:

- existing finalizer path;
- diagnostic breadcrumbs around apply/finalize;
- bounded emergency corrections.

## Area worker / scheduler touch path

Likely owner:

- `daily_life/dl_worker_inc.nss`

Use when task involves:

- registered NPC not being touched;
- warm/budget/round-robin skipping;
- critical stale-reached handling;
- area maintenance tick;
- worker entry/exit traces.

Preserve:

- dense registry ownership;
- no unbounded area scans in hot path;
- critical bypass must route through real worker/directive pipeline when possible.

## Transitions

Likely owner:

- `daily_life/dl_transition_inc.nss`

Use when task involves:

- NPC cross-area transition;
- transition target;
- transition execution/finalization;
- stale transition state.

Preserve:

- local-key transition contracts;
- no runtime tag-search replacement for cached transition state unless bounded fallback.

## Diagnostics

Likely owner:

- `daily_life/dl_diag_inc.nss`
- `daily_life/dl_res_inc.nss`
- `daily_life/dl_dbg_time.nss`

Use when task involves:

- BSMITH_TRACE;
- contradiction/classify output;
- debug local summaries;
- targeted screen/log diagnostics.

Preserve:

- focused diagnostics over broad noisy dumps;
- trace fields used by current debugging workflow;
- explicit skip/failure reasons.

## Compiler/toolchain area

Agents must not modify or run compiler/toolchain files unless explicitly authorized in the current task.

Allowed:

- read stock/reference scripts shipped with the compiler/toolchain for compatibility research;
- read docs or previous PRs;
- run text-only/static checks that do not invoke the compiler.

Forbidden by default:

- NWScript compiler run;
- compile workflow run;
- compiler binary/config/script edits;
- claims of compile success from static checks.

## When unsure

1. Do not broaden the patch.
2. Search for existing helper/contract names.
3. Read recent PRs touching the same file.
4. Add a worklog note if the investigation discovered a durable invariant.
5. Report the uncertainty in the PR risk notes.
