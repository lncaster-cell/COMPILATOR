## 2026-05-20 — Transition registry handoff canonical entrypoint restored

**Task/PR/branch:** current branch / handoff entrypoint audit in area worker/resync cycles.
**Files touched:** `daily_life/dl_worker_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** `DL_RunTransitionRegistryHandoffTick` was called from HOT worker, WARM maintenance, and enter-resync ticks, but the function body/signature was missing in `dl_worker_inc.nss` (left as orphaned block), so canonical handoff execution point was not explicit/maintainable.
**Change:** restored `int DL_RunTransitionRegistryHandoffTick(object oArea, int nTickStamp)` as a bounded slot-based handoff processor (`DL_TRANSITION_HANDOFF_SLOT_COUNT`), keeping all existing touch/debug/rebuild behavior and reusing `DL_WorkerTouchNpc` pipeline.
**Reason:** make the canonical handoff entrypoint factual and executable exactly where worker/resync cycles invoke it, without adding scans/polling or new ownership paths.
**Preserve:** canonical handoff entrypoint remains area-owner tick path (`DL_RunAreaWorkerTick`, `DL_RunAreaWarmMaintenanceTick`, `DL_RunAreaEnterResyncTick`); keep bounded slot queue model and existing BSMITH/transition diagnostics.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Social scene solo animation canonicalization (pool logic)

**Task/PR/branch:** current branch / user-requested social scene cleanup.
**Files touched:** `daily_life/dl_social_scene_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** solo social-scene animation selection had two competing mechanisms: unused helper `DL_GetSocialSceneSoloAnim` and active pool-based selection inside `DL_TickSocialScene`.
**Change:** selected pool-based solo animation selection as canonical and removed dead helper `DL_GetSocialSceneSoloAnim`; kept `bSolo` branch behavior and all existing `DL_L_NPC_SOCIAL_SCENE_*` debug locals/contracts unchanged.
**Reason:** preserve current runtime behavior while eliminating duplicate/competing selection path and making canonical ownership explicit in one place (`DL_TickSocialScene`).
**Preserve:** do not rename or alter `DL_L_NPC_SOCIAL_SCENE_*` local-key literals; keep social-scene diagnostics/state locals intact.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — #864 Lane A: remove dead unused diagnostic wrappers

**Task/PR/branch:** current branch / Issue #864 cleanup campaign.
**Files touched:** `daily_life/dl_diag_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** targeted dead/obsolete diagnostic scan in `daily_life/*.nss` after #876/#877 baseline.
**Change:** removed two unused diagnostic wrapper functions: `DL_LogNpcDiagnostic` and `DL_GetNpcDiagnosticSignature`. Core in-use diagnostic path (`DL_MaybeLogNpcDiagnostic` + `DL_LogNpcDiagnosticWithSummary` + `DL_GetNpcDiagnosticSignatureWithSummary`) is unchanged.
**Reason:** both removed wrappers had zero call sites and only forwarded to already-used functions; removing them reduces dead code without touching runtime movement/transition/directive/registry/worker behavior.
**Preserve:** BSMITH trace workflow and `DL_GetNpcProblemSummary` logic are unchanged.
**Validation:** static checks/grep only. Compilation not run; user owns compilation.

## 2026-05-20 — #864 Lane A: remove dead Daily Life chat-debug plumbing

**Task/PR/branch:** current branch / PR #877 refresh on post-#876 baseline.
**Files touched:** `daily_life/dl_res_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** chat-debug infrastructure in resolver remained as dead plumbing (`DL_LogChat` empty, chat-debug event no-op), but still kept unused locals/functions and call sites in active resolver flow.
**Change:** removed dead chat-debug locals/constants (`DL_L_MODULE_CHAT_DEBUG`, `DL_L_MODULE_CHAT_DEBUG_NPC_TAG`, `DL_L_NPC_CHAT_LAST_EVENT_SIG`, `DL_L_NPC_CHAT_STUCK_SIG`, `DL_L_NPC_CHAT_STUCK_SINCE`, `DL_L_NPC_CHAT_STUCK_LAST_LOG`, `DL_CHAT_STUCK_THRESHOLD_MIN`, `DL_CHAT_STUCK_LOG_INTERVAL_MIN`), removed dead functions (`DL_LogChat`, `DL_IsChatDebugEnabledForNpc`, `DL_LogDirectiveChange`, `DL_LogStuckState`), removed no-op branch in `DL_LogMarkupIssueOnce`, and removed resolver call sites to deleted dead functions.
**Reason:** reduce accumulated code/debug debt with net line reduction while preserving movement/transition/directive/registry/worker behavior and existing BSMITH diagnostics.
**Validation:** static grep/diff checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Annotation-only micro-PR: classify critical Daily Life paths (#864)

**Task/PR/branch:** current branch / first cleanup micro-step after audit.
**Files touched:** `daily_life/dl_worker_inc.nss`, `daily_life/dl_res_inc.nss`, `daily_life/dl_focus_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** proceed with safe technical-debt reduction without behavior change; clarify canonical/fallback/emergency ownership near high-risk overlap points.
**Change:** added audit classification comments only (no logic edits) near `DL_NpcNeedsCriticalWorkerTouch`, `DL_EmergencyTouchCriticalStaleReachedNpc`, `DL_EmergencyCloseReachedMoveInvariant`, `DL_EnforceReachedMoveApplyExitInvariant`, and `DL_ProgressFocusAtTarget`.
**Reason:** reduce accidental risky refactors and preserve current stabilization invariants while enabling cleaner follow-up PR planning.
**Validation:** static text review only. Compilation not run; user owns compilation.

## 2026-05-20 — Refine audit tone: analysis-only synthesis (no new blocker framing) (#864)

**Task/PR/branch:** current branch / refine audit according to user feedback.
**Files touched:** `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
**Context:** user requested high-quality Daily Life analysis specifically, without adding new blocker/process-gate framing.
**Change:** replaced the demo-readiness gate framing section with an analysis-only synthesis section that highlights architecture strengths, debt clusters, performance observations, and a quality conclusion without introducing additional blocker language.
**Reason:** keep the audit focused on deep technical analysis rather than governance phrasing, matching user intent.
**Validation:** static documentation review only. Compilation not run; user owns compilation.

## 2026-05-20 — Continue audit: demo-readiness gates and ranked risk register (#864)

**Task/PR/branch:** current branch / quality-hardening audit pass for public-demo readiness framing.
**Files touched:** `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
**Context:** user requested top-quality, production-like readiness mindset and maximal rigor in audit deliverables.
**Change:** added (1) public demo-readiness quality gates (functional, observability, performance/safety), (2) explicit release blocker list, and (3) ranked Top-10 risk register (S/L/D/RPN) mapped to owner files and first mitigation lanes.
**Reason:** convert audit from descriptive coverage into a quality-control framework that is actionable for pre-demo hardening while preserving current baseline constraints.
**Validation:** static documentation review only. Compilation not run; user owns compilation.

## 2026-05-20 — Continue audit: full daily_life script coverage pass (#864)

**Task/PR/branch:** current branch / maximize audit depth with full script pass.
**Files touched:** `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
**Context:** user requested maximal audit depth and full `daily_life/` script review while avoiding compiler/toolchain/stock compiler scripts.
**Change:** added a full inventory section to the audit with coverage totals, role-based file grouping, high-risk/high-mass file list, compile-order include discipline notes, concentrated debt boundaries, and scope guardrails for next PR selection.
**Reason:** provide a complete map of the Daily Life code surface so #864 cleanup can stay incremental and avoid broad regressions.
**Validation:** static documentation review only. Compilation not run; user owns compilation.

## 2026-05-20 — Continue audit: cleanup-readiness matrix and risk lanes (#864)

**Task/PR/branch:** current branch / continued audit iteration.
**Files touched:** `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
**Context:** continued audit requested again; need tighter execution map for selecting first safe cleanup lane after docs-first phase.
**Change:** added file-by-file cleanup readiness matrix, behavior-cleanup risk heatmap lanes (A–E), and an audit continuity checklist for future agents to prevent mixed-scope/risky PRs.
**Reason:** make #864 planning deterministic and reduce chance of broad refactor regressions against working blacksmith baseline.
**Validation:** static documentation review only. Compilation not run; user owns compilation.

## 2026-05-20 — Continue audit: obsolete-candidate gates and evidence template (#864)

**Task/PR/branch:** current branch / continue Daily Life audit depth.
**Files touched:** `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
**Context:** follow-up continuation requested after prior audit refinements; need clearer decision gates before any runtime-path cleanup.
**Change:** added (1) candidate obsolete/dead inventory as documentation hypotheses only, (2) explicit decision gates per candidate, (3) compact evidence package template for follow-up cleanup PRs, and (4) two docs-first micro-PR candidates to continue #864 safely without behavior edits.
**Reason:** convert audit from descriptive map to execution-ready cleanup process while protecting blacksmith01 baseline and current diagnostics.
**Validation:** static documentation review only. Compilation not run; user owns compilation.

## 2026-05-20 — Continue Daily Life stabilization audit depth mapping (#864)

**Task/PR/branch:** current branch / continue audit per review feedback.
**Files touched:** `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
**Context:** prior audit rewrite was accepted as direction but required continued depth for practical triage and phased debt reduction planning.
**Change:** extended the audit with: (1) stage-by-stage failure-signature triage map, (2) unknown/risky backlog with explicit evidence requirements before deletions, (3) audit-driven sequencing plan for #864 follow-up PRs, and (4) explicit definition-of-done for finishing the audit phase without behavior changes.
**Reason:** make #864 actionable for next small cleanup PRs while preserving baseline invariants and avoiding premature runtime path deletion.
**Validation:** static documentation review only. Compilation not run; user owns compilation.

## 2026-05-20 — Daily Life stabilization audit refresh after baseline success (#864)

**Task/PR/branch:** current branch / audit refresh for post-baseline cleanup mapping.
**Files touched:** `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
**Context:** blacksmith01 full-cycle baseline is currently successful, validator is already working, and #861 is closed; #864 remains the debt tracker.
**Change:** rewrote the audit document into a strict pipeline/ownership/debt map with requested classifications (canonical/fallback/emergency/diagnostic/obsolete/unknown-risky), overlap analysis, phased cleanup buckets, a small next cleanup PR recommendation, and manual validation checklist without runtime behavior edits.
**Reason:** provide a practical, low-risk cleanup map so future PRs can reduce Daily Life debt without breaking the working baseline.
**Validation:** static documentation review only. Compilation not run; user owns compilation.

## 2026-05-19 — Compact default output for manual Daily Life setup validator

**Task/PR/branch:** current branch / compact validator output by default.
**Files touched:** `daily_life/dl_dbg_setup.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** manual setup validation output was noisy because every `OK` line was always printed, which flooded chat/log during normal checks.
**Change:** added `DL_SetupPrintOk/Warn/Error` wrappers plus `dl_setup_verbose` toggle (`GetModule()` or `OBJECT_SELF`) so default mode prints `BEGIN`, `WARN/ERROR`, `RESULT`, `END`, while verbose mode preserves full `OK/WARN/ERROR` detail. Also compacted repeated area-script-introspection warnings into a single aggregated warning and switched transition waypoint checks to global waypoint-tag existence first (type=WAYPOINT), with area mismatch warnings only in verbose mode.
**Reason:** improve validator usability without touching runtime Daily Life movement/transition/directive/registry behavior; keep validator read-only and manual.
**Preserve:** no auto-fix behavior, no heartbeat/runtime integration, no `DelayCommand`, no movement/transition worker mutations.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-19 — Add manual Daily Life setup validator debug script

**Task/PR/branch:** current branch / manual setup validator for blacksmith baseline.
**Files touched:** `daily_life/dl_dbg_setup.nss`, `docs/daily-life-setup-contract.md`, `docs/AGENT_WORKLOG.md`.
**Context:** after blacksmith baseline stabilization, setup mistakes (locals/areas/routes/anchors) remain a frequent source of debugging friction and can be mistaken for runtime regressions.
**Change:** added `dl_dbg_setup` as a separate manual OnUsed debug script that validates `blacksmith01` setup with bounded `OK/WARN/ERROR` checklist output (NPC existence, required/optional locals, area-tag resolution, script-introspection reminders, anchors/fallback waypoints, nav zone notes, transition waypoints, and key route locals with area→module fallback). Added a short “Manual setup validator” section to setup-contract docs.
**Reason:** provide a read-only preflight validator that reduces setup pain without changing worker/movement/transition/directive/runtime behavior and without bloating `dl_dbg_time.nss`.
**Preserve:** validator is manual and read-only; no heartbeat integration, no auto-fix, no `DelayCommand`, no per-NPC runtime loop, no worker/registry mutations.
**Validation:** static checks only. Compilation not run; user owns compilation.

# Agent Worklog

## 2026-05-19 — Update manual setup validator to unique Gotha zone IDs

**Task/PR/branch:** current branch / manual validator zone-id migration for blacksmith baseline.
**Files touched:** `daily_life/dl_dbg_setup.nss`, `docs/daily-life-setup-contract.md`, `docs/AGENT_WORKLOG.md`.
**Context:** blacksmith setup migrated from legacy generic nav zones (`hall`, `bedroom`, `far_room`) to unique zone IDs and updated area tags.
**Change:** updated manual validator transition waypoint checks and route-local checks to require `gotha_smith_main`, `gotha_smith_bedroom`, `gotha_smith_backroom`, `gotha_cavenue`, and `gotha_tavern` route families; replaced old hall/bedroom/far_room baseline examples in setup-contract docs with the current unique Gotha baseline and updated home/work/meal area tag examples to `gotha_kyznica`.
**Reason:** keep manual setup validation aligned with the active module setup contract so missing/invalid setup is detected before runtime debugging.
**Preserve:** manual/read-only validator only; no runtime movement/transition/directive/registry behavior changes, no auto-fix paths, no heartbeat/runtime validation integration.
**Validation:** static checks only. Compilation not run; user owns compilation.

### 2026-05-19 — Follow-up: NWScript compiler compatibility fix in dl_dbg_setup

**Task/PR/branch:** current branch / follow-up to unique Gotha validator update.
**Files touched:** `daily_life/dl_dbg_setup.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** CI `check` run reported `NSC1020: Undeclared identifier "OBJECT_TYPE_AREA"` in `dl_dbg_setup.nss`.
**Change:** removed the `OBJECT_TYPE_AREA` gate in `DL_SetupResolveAreaByTag`; resolver now treats a valid `GetObjectByTag` result as acceptable and still returns `OBJECT_INVALID` for unresolved tags.
**Reason:** preserve manual validator behavior while restoring compatibility with this NWScript compiler's available object-type constants.
**Preserve:** manual/read-only validator scope unchanged; no runtime movement/transition/directive/registry behavior touched.
**Validation:** static checks only. Compilation not run; user owns compilation.


## 2026-05-18 - Daily Life stabilization audit map (#864)

- Files touched: `docs/daily-life-stabilization-audit.md`, `docs/AGENT_WORKLOG.md`.
- Change: added an audit-only cleanup/refactor map for the Daily Life subsystem covering the canonical pipeline, ownership boundaries, code-path classification, bugfix debt inventory, setup simplification rules, protected invariants, and manual validation checklist.
- Why: `stable/daily-life-blacksmith-baseline` is now a working baseline after #865/#866/#867 and setup fixes; future cleanup needs a safe staged plan that does not change runtime behavior.
- Compile status: compilation not run; user owns compilation.
- Invariant/warning: this PR is documentation-only. Do not delete or narrow movement, transition, worker, registry, or BSMITH diagnostic code until follow-up PRs have explicit runtime validation evidence.

## 2026-05-18 — Prefer current-area anchor targets after transitions

**Task/PR/branch:** current branch / post-transition PUBLIC anchor finalization bug.
**Files touched:** `daily_life/dl_move_job_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** after PR #865, `blacksmith01` reaches `dl_public_tavern_blacksmith` in `gotha_tavern` but can remain `move_result=running` with `focus_status=moving_to_anchor` and `last_finalize=target_not_reached`.
**Change:** `DL_ResolveMoveJobTarget` now tracks same-tag candidates in the NPC's current area and, for `move_phase=anchor`, prefers the current-area anchor over a stored target-area match/fallback when resolving the canonical move target. Duplicate-target debug now also flags duplicate current-area candidates.
**Reason:** focus-style anchor moves are same-area presentation moves after transition handoff; if `dl_move_target_area` or a cached duplicate points at an old/stale area, the canonical reached/finalizer path must rebind to the current-area anchor so PUBLIC/SOCIAL/MEAL/CHILL can close through the shared reached condition instead of staying running.
**Preserve:** do not change transition transport ownership or radius; keep anchor finalization centralized through `DL_IsMoveJobAtTargetNow`, `DL_TickMoveJob`, and `DL_FinalizeReachedDirectiveMoveJob`; no DelayCommand, polling, area scans, or PUBLIC-only emergency bypass was added.
**Validation:** lightweight static/text checks only. Compilation not run; user owns compilation.

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

## 2026-05-18 — Daily Life setup contract documentation

**Task/PR/branch:** after PR #868 / Document Daily Life setup contract.
**Files touched:** `docs/daily-life-setup-contract.md`, `docs/AGENT_WORKLOG.md`.
**Context:** `blacksmith01` passed two full cycles successfully, and the stabilization audit identified setup complexity as the next source of Daily Life risk.
**Change:** added a builder-facing Daily Life setup contract covering required area scripts, NPC locals, anchors, nav zones, transition waypoint tags, target-zone route locals, the blacksmith01 working baseline, common failure signatures, pre-flight checks, and future validator requirements.
**Reason:** document the setup contract before adding validator code or changing runtime behavior, so future NPC setup errors can be separated from movement/worker regressions.
**Preserve:** documentation-only change; do not treat this as runtime validation, and do not remove existing Daily Life diagnostics based only on this document.
**Validation:** documentation/static checks only. Compilation not run; user owns validation.

## 2026-05-20 — Nav zone inference call-graph pass + 1-tick bounded cache

**Task/PR/branch:** current branch / user request to profile inference call-graph and reduce repeated scans.
**Files touched:** `daily_life/dl_transition_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** in one pipeline pass, `DL_NavPrepareTargetZoneFromAnchor` can invoke both current-zone and target-zone inference paths: `DL_NavSyncCurrentZoneFromArea -> DL_NavResolveCurrentZoneFromPosition -> DL_NavTryResolveZoneFromNearbyAnchors` and then `DL_NavGetAnchorZoneId -> DL_NavTryResolveTargetZoneFromTransitionWaypoints`, causing back-to-back area waypoint scans.
**Change:** added bounded per-subject nav inference cache locals (`dl_nav_infer_cache_*`) keyed by area tag + kind + area worker tick (`dl_worker_tick`) with TTL=1 worker tick; applied cache to `DL_NavTryResolveZoneFromTransitionWaypoints` and `DL_NavTryResolveZoneFromNearbyAnchors` without changing fallback scan logic or caps.
**Reason:** avoid repeated same-tick inference scans in the same owner pipeline while preserving canonical behavior and existing bounded fallback semantics.
**Preserve:** `DL_NAV_AREA_SCAN_CAP` remains unchanged and still bounds fallback loops; no global polling loop/path was introduced.
**Validation:** static checks only. Compilation not run; user owns compilation.
