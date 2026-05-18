# Agent Worklog

## 2026-05-17 — Normalize Daily Life transition transport ownership

**Task/PR/branch:** current branch / Daily Life transition directive-owned transport phase.
**Files touched:** `daily_life/dl_transition_inc.nss`, `daily_life/dl_res_inc.nss`, `daily_life/dl_move_job_inc.nss`, `daily_life/dl_focus_inc.nss`, `daily_life/dl_work_inc.nss`, `daily_life/dl_sleep_inc.nss`, `docs/daily-life-worker-lifecycle.md`, `docs/AGENT_WORKLOG.md`.
**Context:** blacksmith PUBLIC navigation could run as `dir=PUBLIC` while the entry movement was `move_owner=transition`, leaving transition as a competing semantic owner at the Directive/Movement/Transition boundary.
**Change:** added directive-owned transition entry moves using `move_phase=transition_to_area`, routed focus/work/sleep navigation calls through an owner-aware transition helper, kept legacy `move_owner=transition` compatibility explicit, and made transition no-progress reissues use exact location movement like initial transition entry moves.
**Reason:** transition should be a transport service for the active directive, not an alternate directive owner; near-entry no-progress recovery must not fall back to radius-based object movement for transition entries.
**Preserve:** do not globally increase transition radius, move waypoints, or add worker bypasses for this bug class; valid directive-owned transport should not produce `move_owner_directive_mismatch:transition`.
**Validation:** lightweight static/text checks only. Compilation not run; user owns compilation.

## Tavern transition boundary finding

- `blacksmith01` can reach the tavern transition entry with `move_owner=transition`, `move_target=gotha_cavenue__gotha_tavern`, and raw distance hovering around `1.60/1.61` while the action queue is empty.
- The regression was caused by issuing transition entry movement with `ActionMoveToObject`/`DL_QueueMoveToObjectAction` using a range equal to `DL_NAV_ENTRY_RADIUS` (`1.60`). The engine may consider the move complete at the boundary of that range, leaving the canonical transition check just outside `GetDistanceBetween(oNpc, oEntry) <= DL_NAV_ENTRY_RADIUS`.
- Transition entry moves should use exact location movement (`DL_QueueMoveAction(oNpc, GetLocation(oTarget), TRUE)`) so the NPC walks to the waypoint location before `DL_NavTryAdvanceToZone` executes the queued jump/finalizer path.

- preserve context between sessions;
- record why non-trivial changes were made;
- prevent future fixes from undoing active debugging progress;
- keep the next agent oriented without forcing it to reconstruct everything from PR history.

Rules:

1. Read this file before code changes.
2. Add a new entry after every non-trivial bug fix, behavior change, diagnostic change, architecture decision, or compatibility workaround.
3. Keep entries short and factual.
4. Do not use this file for tiny formatting-only edits.
5. Do not claim compilation unless the user explicitly ran it and supplied the result. Compilation is user-owned.

Entry template:

```md
## YYYY-MM-DD — Short title

**Task/PR/branch:** branch or PR number if known.  
**Files touched:** `path/file.nss`, `path/file_inc.nss`.  
**Context:** what bug/problem/decision led to the change.  
**Change:** what was changed.  
**Reason:** why this approach was chosen.  
**Preserve:** invariant, contract, diagnostic, or warning future agents must not break.  
**Validation:** static checks only, or `Compilation not run; user owns compilation.`
```

---

## 2026-05-17 — Establish shared agent memory and compile ownership

**Task/PR/branch:** `codex/update-agent-memory-rules`.  
**Files touched:** `AGENTS.md`, `docs/AGENT_WORKLOG.md`.  
**Context:** the project is large, actively developed through multiple AI/Codex sessions, and session context can be lost. The user also clarified that compilation is manual and must not be run by agents.  
**Change:** strengthened `AGENTS.md` with mandatory reading order, compile ownership rules, current Daily Life debugging context, movement invariants, and the requirement to update this worklog after non-trivial changes. Added this worklog as the canonical mini-history for future agents.  
**Reason:** future agents need persistent context and must not accidentally run or modify the compiler/toolchain while debugging code.  
**Preserve:** compilation remains user-owned; agents may read compiler-stock/reference scripts only for compatibility research and must not run or change the compiler/toolchain unless explicitly authorized in the current task.  
**Validation:** documentation-only change. Compilation not run; user owns compilation.

## 2026-05-17 — Current Daily Life movement debugging context

**Task/PR/branch:** context summarized from recent merged PRs #851-#856.  
**Files touched:** no code in this entry; context concerns `daily_life/dl_move_job_decl_inc.nss`, `daily_life/dl_move_job_inc.nss`, `daily_life/dl_res_inc.nss`, and `daily_life/dl_worker_inc.nss`.  
**Context:** recent debugging focused on NPCs, especially blacksmith behavior, becoming stuck with contradictory movement state: physically/canonically reached target while `move_result` remained `running`, focus stayed `moving_to_anchor`, or the area worker failed to touch the registered NPC.  
**Change:** recent work introduced/used canonical reached checks, reached/finalize invariant enforcement, critical area-worker re-entry, constrained emergency touch/finalize paths, and BSMITH trace diagnostics.  
**Reason:** fixes should route stale reached NPCs back through the existing worker/directive/finalizer pipeline instead of duplicating movement behavior or adding broad polling.  
**Preserve:** one canonical reached verdict; bounded critical handling; no broad area scans in hot paths; no casual removal of BSMITH tracing while this bug class is under investigation.  
**Validation:** context entry only. Compilation not run; user owns compilation.

## 2026-05-17 — Add operational protocol files for agents

**Task/PR/branch:** `codex/add-agent-operational-protocols`.  
**Files touched:** `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/bug_report.yml`, `docs/agent/TASK_PROTOCOL.md`, `docs/agent/DEBUGGING_PROTOCOL.md`, `docs/agent/SUBSYSTEM_INDEX.md`, `docs/agent/DO_NOT_TOUCH.md`, `docs/AGENT_WORKLOG.md`.  
**Context:** after establishing shared agent memory, the repository still needed concrete operating rails so future agents produce consistent PRs, collect consistent bug data, and debug Daily Life/NPC issues in a repeatable order.  
**Change:** added PR and bug-report templates, a general task protocol, a Daily Life debugging protocol, a subsystem index, and do-not-touch guardrails for compiler/toolchain, runtime contracts, diagnostics, include-order contracts, and performance-sensitive paths.  
**Reason:** reduce context loss and prevent agents from solving the same class of problems by broad rewrites, duplicated logic, or unsafe compiler/toolchain interaction.  
**Preserve:** agents must keep using `AGENTS.md` and this worklog first, must not run compilation unless explicitly authorized, and should route Daily Life movement fixes through the existing registry/worker/directive/finalizer contracts.  
**Validation:** documentation/process-only change. Compilation not run; user owns compilation.

## 2026-05-17 — Add Start Here productivity guide

**Task/PR/branch:** `codex/add-agent-start-here`.  
**Files touched:** `AGENTS.md`, `docs/agent/START_HERE.md`, `docs/AGENT_WORKLOG.md`.  
**Context:** the user clarified that the agent files are not meant as ordinary documentation, but as productivity infrastructure for AI-assisted solo/vibe development: faster context loading, safer bug fixing, fewer repeated mistakes, and better continuity between sessions.  
**Change:** added `docs/agent/START_HERE.md` as the high-level entry point explaining the operating model, file map, productivity rules, and expected agent workflow. Updated `AGENTS.md` so agents read it immediately after `AGENTS.md` and before deeper protocols.  
**Reason:** future agents should understand why these files exist and how to use them as a workflow, not treat them as optional docs.  
**Preserve:** user owns intent, manual compilation, runtime validation, and final acceptance; agents own investigation, minimal patches, PRs, and context/worklog updates.  
**Validation:** documentation/process-only change. Compilation not run; user owns compilation.

## 2026-05-17 — Add root-cause bugfix protocol

**Task/PR/branch:** `codex/add-root-cause-bugfix-protocol`.  
**Files touched:** `AGENTS.md`, `docs/agent/ROOT_CAUSE_BUGFIX_PROTOCOL.md`, `docs/AGENT_WORKLOG.md`.  
**Context:** the user identified a process failure: repeated AI fixes were often treating symptoms instead of proving root causes, and the repository was not yet fully managed as an AI-assisted solo-development workflow.  
**Change:** added a mandatory root-cause bugfix protocol for non-trivial, recurring, runtime, and Daily Life/NPC bugs. Updated `AGENTS.md` to require this protocol before behavior patches on such bugs.  
**Reason:** force agents to identify the first failing pipeline stage, gather evidence, choose the correct owner subsystem, and prefer focused diagnostics when the root cause is not proven.  
**Preserve:** issue-driven debugging, evidence before patch, minimal owner-subsystem changes, no symptom-chasing emergency bypasses, and explicit manual validation by the user.  
**Validation:** documentation/process-only change. Compilation not run; user owns compilation.

## 2026-05-17 — Bound manual BSMITH diagnostics

**Task/PR/branch:** current branch.
**Files touched:** `daily_life/dl_dbg_time.nss`, `daily_life/dl_res_inc.nss`, `daily_life/bsmith_trace_off.nss`.
**Context:** the manual Daily Life debug placeable enabled persistent `dl_bsmith_trace` locals, causing blacksmith trace stages to print every worker tick and flood chat during movement debugging.
**Change:** changed the manual debug script to emit only a one-shot status/target/problem snapshot and clear stale trace locals; added `dl_bsmith_trace_budget` enforcement so explicit trace sessions auto-disable after their line budget; added per-stage state-signature throttling with a 5-minute cooldown; added a `BSMITH_TRACE_OFF` script path to clear module/NPC trace locals manually.
**Reason:** preserve the active BSMITH diagnostic infrastructure while making runtime testing readable and preventing accidental persistent spam.
**Preserve:** normal `dl_dbg_time` clicks must not enable persistent `dl_bsmith_trace`; explicit tracing now requires both `dl_bsmith_trace=1` and a positive `dl_bsmith_trace_budget`; do not remove BSMITH trace fields while movement debugging continues.
**Validation:** static/text checks only. Compilation not run; user owns compilation.

## 2026-05-18 — Allow same-area pseudo-transition finalization

**Task/PR/branch:** current branch.
**Files touched:** `daily_life/dl_transition_inc.nss`.
**Context:** after missing area scripts and PR #865 were fixed, `blacksmith01` could enter tavern/PUBLIC correctly but reproducibly failed MEAL at 06:00 when routing `hall -> far_room` inside `gotha_interior_kuznica`; the queued-jump finalizer treated `oCurrentArea == oOldArea` as `post_jump_finalizer_area_not_changed` even for valid same-area pseudo-zone transitions.
**Change:** added a narrow same-area completion path in `DL_FinalizeTransitionAfterQueuedJump` when current/old/expected area match, target zone is pending, and the pending exit or stored jump target is valid. The path clears transition/focus movement state, sets the NPC nav zone to the pending target zone, records `post_jump_finalizer_same_area_complete`, touches the worker, and clears the pending finalizer flag without stale-registry removal or cross-area handoff.
**Reason:** same-area pseudo-transitions are a navigation-system feature, not a MEAL-specific movement problem, and physical area identity must not be treated as failure when the expected route remains within one area.
**Preserve:** cross-area transition finalization, registry repair, stale-reference removal, and registry handoff behavior remain on the existing cross-area path; do not replace this with radii changes, delays, heartbeat loops, or area scans.
**Validation:** static/text checks only. Compilation not run; user owns compilation.
