## 2026-05-21 — BSMITH TARGET_IDENTITY_CHANGED guard against legitimate lifecycle re-resolve

**Task/PR/branch:** current branch / `dl_res_inc.nss` contradiction-triage refinement.
**Files touched:** `daily_life/dl_res_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** `TARGET_IDENTITY_CHANGED` contradiction could trigger in stable tag/area/distance context during legitimate transition/handoff lifecycle windows where move target object can be re-resolved intentionally.
**Change:** kept the existing stable-context base check (`tag`, `area`, `distance`) and added lifecycle guard suppression for known re-resolve windows (`dl_transition_pending_finalizer_expected`, `dl_transition_registry_handoff`, `dl_transition_registry_problem`). Kept the same contradiction field and made evidence more specific by adding `reason=stable_context_identity_swap`.
**Reason:** reduce false-positive contradiction noise while preserving useful triage signal and existing local-key literal contracts.
**Preserve:** no local-key literal value changes; no diagnostic field removals; no movement/directive/finalizer pipeline rewrites.
**Validation:** static checks only. Compilation not run; user owns compilation.


## 2026-05-21 — Daily Life invariant hardening: stale-critical filter + emergency-close context guard

**Task/PR/branch:** current branch / Daily Life bugfix pass (logical conflicts in movement invariant path).
**Files touched:** `daily_life/dl_worker_critical_inc.nss`, `daily_life/dl_res_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** static analysis found two contradiction risks in active movement-debug paths: (1) stale-reached critical classifier could escalate while `ACTION_MOVETOPOINT` was still active; (2) apply-exit emergency close could run after context changed (ticket/owner/target drift) between finalize attempt and fallback close.
**Change:** tightened `DL_IsStaleReachedMoveJobCritical` to only classify stale critical when move is canonically reached/running and current action is **not** `ACTION_MOVETOPOINT`; removed the additional moving-to-anchor branch that forced `TRUE` under active move action. Added guard snapshots (`move_ticket`, `move_owner`, `move_target_tag`) in `DL_DetectApplyMoveRegression` and `DL_EnforceReachedMoveApplyExitInvariant`; `DL_EmergencyCloseReachedMoveInvariant` now runs only when context is unchanged, otherwise emits `INVARIANT` trace `invariant_skip_context_changed`.
**Reason:** preserve canonical worker/finalizer pipeline and BSMITH observability while preventing false critical escalation and late fallback closure on stale context.
**Preserve:** no local-key literal renames; no broad scans/polling; no transition/directive architecture rewrite; no diagnostic field removals.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-21 — Extract worker critical/emergency recovery helpers into dedicated include

**Task/PR/branch:** refactor/worker-critical-include / extract critical worker helpers from `dl_worker_inc.nss`.
**Files touched:** `daily_life/dl_worker_inc.nss`, `daily_life/dl_worker_critical_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** `dl_worker_inc.nss` contained critical/emergency recovery helper implementations intermixed with core worker pass/runtime code, increasing file size and reducing maintainability.
**Change:** moved only these implementations to new include `daily_life/dl_worker_critical_inc.nss`: `DL_IsRegisteredCurrentAreaStaleReachedMoveCritical`, `DL_EmergencyTouchCriticalStaleReachedNpc`, `DL_IsStaleReachedMoveJobCritical`, `DL_NpcNeedsCriticalWorkerTouch`, `DL_GetAreaWorkerCursorNpc`, `DL_ProcessCriticalAreaCursorNpc`; inserted `#include "dl_worker_critical_inc"` inside `dl_worker_inc.nss` after worker constants/declarations, `dl_worker_debug_inc`, and `dl_worker_handoff_inc`.
**Reason:** reduce `dl_worker_inc.nss` size while preserving exact runtime behavior and existing include ownership contracts.
**Preserve:** no logic rewrites; no debug string/critical reason/local-key changes; no scheduling/transition-handoff/worker-debug/registry-recovery edits.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Fix anchor move reissue helper ownership

**Task/PR/branch:** current branch / emergency compile recovery for Daily Life main.
**Files touched:** `daily_life/dl_anchor_move_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** `dl_anchor_move_inc.nss` called sleep-specific `DL_ShouldReissueSleepMoveAction` defined in `dl_sleep_inc.nss`, creating shared->sleep include ownership dependency and cascading undeclared identifier compile failures.
**Change:** moved generic move-action reissue decision into anchor helper via `DL_GetAnchorMoveActionStamp` and `DL_ShouldReissueAnchorMoveAction`, and switched `DL_ShouldIssueAnchorMoveAction` to use the generic helper with a 6-second interval.
**Reason:** restore compile-order ownership (shared anchor helper no longer depends on sleep include internals) while preserving current reissue timing behavior.
**Preserve:** no movement/transition/directive/registry/worker behavior redesign; no contract literal changes.
**Validation:** compilation/check attempted per task; see current task report.

## 2026-05-20 — Fix remaining Daily Life compile-order wrappers

**Task/PR/branch:** current branch / follow-up emergency compile recovery after prior stack fix.
**Files touched:** `daily_life/dl_transition_inc.nss`, `daily_life/dl_res_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** reduced compile set still failed on three roots: undeclared `sOwner` in post-jump helper diagnostic text, compatibility wrappers calling non-existent transition helpers, and sleep include failing to see anchor-move helpers.
**Change:** removed invalid `owner=` fragment from `DL_ApplyPostJumpCompletionSuccess` diagnostic string (no new state added); rewired `DL_HasTransitionExecutionState` to existing transition locals (`DL_L_NPC_TRANSITION_STATUS`/`DL_L_NPC_TRANSITION_TARGET`) and `DL_ClearTransitionExecutionStateWithReason` to `DL_ClearTransitionExecutionState` plus optional diagnostic reason writeback; reordered includes so `dl_anchor_move_inc` is parsed before `dl_sleep_inc` while keeping `dl_move_job_decl_inc` available first.
**Reason:** restore compile-compatible existing contracts with minimal behavior impact and no subsystem redesign.
**Preserve:** no movement/transition/directive/registry/worker/nav behavior redesign; no local-key literal changes.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Emergency Daily Life compile recovery after refactor stack

**Task/PR/branch:** current branch / emergency compile recovery for Daily Life main.
**Files touched:** `daily_life/dl_res_inc.nss`, `daily_life/dl_transition_inc.nss`, `daily_life/dl_work_inc.nss`, `daily_life/dl_social_scene_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** recent helper-cleanup/refactor stack introduced include-order and symbol-contract regressions (missing wrappers/prototypes, removed compatibility hook, and one bad social-scene call signature), causing widespread compile failures across transition/work/sleep/focus/res includes.
**Change:** restored compile-compatibility surface with minimal behavior impact: added no-op `DL_LogChatDebugEvent` shim; restored transition execution compatibility wrappers (`DL_HasTransitionExecutionState`, `DL_ClearTransitionExecutionStateWithReason`) by delegating to current transition-state helpers; added narrow forward declarations in transition/work includes for later-defined helpers; fixed broken fallback argument names in work anchor fallback call; replaced invalid `DL_WORK_KIND_WORK` artifact with existing `DL_WORK_KIND_FORGE` kind; fixed solo social-scene call to pass required `oNpc` and `nStep` args.
**Reason:** recover main compilability by restoring pre-refactor symbol contracts and call signatures instead of introducing new runtime behavior.
**Preserve:** no movement/transition/directive/registry redesign; no local-key literal migrations; wrappers intentionally preserve existing owner pipeline.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Work kind helper unification for primary/secondary/fetch

**Task/PR/branch:** current branch / user request to centralize work target resolution by kind in `dl_work_inc.nss`.
**Files touched:** `daily_life/dl_work_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** work waypoint resolvers in blacksmith/domestic branches duplicated anchor-by-role selection logic (`primary`/`secondary`/`fetch`) and split fallback policy inline per function.
**Change:** introduced shared `DL_ResolveWorkAnchorByKind` (kind-set `{work/craft/fetch}` mapping to anchor key+cache) and profile-specific wrappers that only choose area/fallback policy (`DL_ResolveBlacksmithWorkAnchorByKind`, `DL_ResolveDomesticWorkAnchorByKind`); blacksmith and domestic primary/secondary/fetch resolvers now reuse this helper.
**Reason:** remove duplicated role-switch logic while preserving literal anchor keys, cache-key contracts, and profile-specific fallback behavior (including fetch->craft fallback for blacksmith and no-fallback domestic behavior).
**Preserve:** profile wrappers remain responsible only for profile policy (area + fallback), while shared helper owns kind-to-anchor mapping.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Work waypoint resolver profile helper unification (work roles)

**Task/PR/branch:** current branch / unify repeated work waypoint resolvers in `dl_work_inc.nss`.
**Files touched:** `daily_life/dl_work_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** blacksmith/gate/trader/domestic role resolvers duplicated the same “anchor first, optional fallback by tag profile” pattern with only profile literals changed.
**Change:** added shared helper `DL_ResolveWorkWaypointByRoleParams` with explicit profile parameters (anchor key + anchor cache key + fallback cache key/prefix/suffix/tag), migrated blacksmith forge/craft/fetch, gate post, trader, and domestic primary/secondary/fetch resolvers to call it, and preserved domestic behavior by passing home area plus empty fallback profile so no fallback lookup runs.
**Reason:** reduce duplicate resolver logic while preserving existing runtime contracts, role-specific cache keys, and domestic home-area/no-fallback behavior.
**Preserve:** literal local-key values and fallback literal tags are unchanged; domestic path remains home-area anchored and may validly return `OBJECT_INVALID` without fallback.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Social scene IDs now drive real scene cadence/pools

**Task/PR/branch:** current branch / explicit invalidation for `dl_nav_infer_cache_*`.
**Files touched:** `daily_life/dl_transition_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** bounded nav infer cache (tick+area+kind) reduced repeated scans, but invalidation moments were implicit, making rare transition edge cases harder to diagnose.
**Change:** added `DL_NavInvalidateInferZoneCache` helper that clears all `DL_L_NAV_INFER_CACHE_*` locals and writes a nav-debug reason `infer_cache_invalidated:<reason>`; invoked it on transition execution-state clear, transition finalize success paths (`post_jump_finalizer_same_area_complete`, `post_jump_finalizer_complete`, completed-transition finalize), and when stored nav-zone area contract no longer matches NPC area (`zone_area_changed`) during sync.
**Reason:** keep current bounded-cache behavior while explicitly documenting/enforcing when cached inference is stale across area/transition lifecycle edges.
**Preserve:** cache key model remains `tick + area + kind`; no new scans/polling; existing scan caps/inference fallbacks unchanged.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Transition registry problem codes: remove raw string literals

**Task/PR/branch:** current branch / literal-to-constant cleanup for transition registry problem codes.
**Files touched:** `daily_life/dl_transition_inc.nss`, `daily_life/dl_worker_inc.nss`, `daily_life/dl_registry_inc.nss`, `daily_life/dl_diag_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** transition registry problem code comparisons/assignments used repeated raw string literals, increasing drift risk in active Daily Life diagnostics/handoff paths.
**Change:** declared shared compiler-safe global string constants for all used `dl_transition_registry_problem` codes in `dl_transition_inc.nss` and replaced raw literal comparisons/assignments in transition/worker paths; also replaced remaining comparisons in Daily Life registry/diagnostic includes and verified static search has no old literal comparisons in `daily_life/*.nss`.
**Reason:** preserve runtime literal contract values while centralizing code usage and reducing typo/divergence risk across owner and observer paths.
**Preserve:** literal code values are unchanged; only symbolic usage in code paths was updated.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Nav stale-zone guard in current-zone sync

**Task/PR/branch:** current branch / stale current-zone resync guard for transition navigation.
**Files touched:** `daily_life/dl_transition_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** `DL_NavSyncCurrentZoneFromArea` preserved existing same-area nav zone to protect pseudo-zones, but could also preserve stale `dl_nav_zone_current` when position evidence no longer matched nearby nav anchors/transitions.
**Change:** added a narrow stale-zone guard in `DL_NavSyncCurrentZoneFromArea`: before preserving existing zone, confirm it via nearby anchor-zone inference and (if anchor evidence is absent) nearby transition-waypoint inference; if contradicted by nearby evidence, emit nav debug reason `sync_stale_zone_guard` and allow canonical resync through `DL_NavResolveCurrentZoneFromPosition`; if no nearby evidence exists, preserve existing zone as before.
**Reason:** keep same-area pseudo-zone stability while allowing bounded, evidence-based recovery from stale current-zone state without adding new global scans or changing local-key literal contracts.
**Preserve:** no changes to local-key literal values; reuse existing inference helpers and existing area-scan caps only.
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

## 2026-05-20 — Transition finalizer problem-code constants + cleanup whitelist alignment

**Task/PR/branch:** current branch / user-requested literal-code normalization in transition finalizer.
**Files touched:** `daily_life/dl_transition_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** several `dl_transition_registry_problem` post-jump finalizer codes were still used as raw string literals in comparisons/assignments, and safe-clear whitelist did not include the full post-jump code set now used by finalizer paths.
**Change:** added compiler-safe shared string constants for remaining post-jump registry-problem literals (`post_jump_finalizer_not_expected`, `post_jump_finalizer_unexpected_area`), replaced literal assignments/comparisons with constants, and expanded clear-on-success whitelist checks to cover all relevant post-jump finalizer problem codes.
**Reason:** preserve runtime literal contracts while reducing drift/typo risk and keeping registry-problem cleanup behavior explicit and complete.
**Preserve:** literal string values were not changed.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Unified status constants for directive/focus finalize paths

**Task/PR/branch:** current branch / status literal deduplication request.
**Files touched:** `daily_life/dl_focus_inc.nss`, `daily_life/dl_res_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** finalize/recovery/apply paths still mixed raw status literals with constants in `SetLocalString(...STATUS, ...)` and status comparisons.
**Change:** added a focused `DL_FOCUS_STATUS_*` constants block in `dl_focus_inc.nss`; replaced raw status literals in `dl_res_inc.nss` with owner/status constants for focus/work/sleep (`moving_to_anchor`, `on_public_anchor`, `on_social_anchor`, `on_anchor`, `on_bed`) including SetLocalString status writes and compatible status checks; documented the explicit stable-stage mapping (`PUBLIC/SOCIAL/MEAL/CHILL/WORK/SLEEP -> owner-specific status`) inline in `DL_IsDirectiveStableAfterReachedFinalize`.
**Reason:** preserve literal runtime values while deduplicating access paths and reducing drift/typo risk across finalize and invariant code.
**Preserve:** literal string values were not changed; this is a symbolic-constant normalization only.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-20 — Restore missing Daily Life helper bodies

**Task/PR/branch:** current branch / continue Daily Life compile recovery.
**Files touched:** `daily_life/dl_transition_inc.nss`, `daily_life/dl_work_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** repeated compile blockers in multiple Daily Life scripts reported missing function bodies for `DL_FinalizePostJumpTransitionResult` and `DL_ResolveWorkWaypointByRoleParams`.
**Change:** restored both helper bodies with minimal contract-preserving logic. `DL_ResolveWorkWaypointByRoleParams` was restored from prior history (`cfb6ef9`) pattern (area anchor first, then fallback resolver when fallback contract fields are present). `DL_FinalizePostJumpTransitionResult` was reconstructed to match existing call contract (validity guard, set `dl_post_jump_result`, set `dl_post_jump_worker_touch_called`, optional transition finalizer BSMITH trace, clear pending finalizer expected flag).
**Reason:** recent helper refactors left forward declarations without bodies, producing unresolved body errors during compile; this restores compile-time symbol completeness without redesigning transition/work behavior.
**Preserve:** no movement/directive/worker/registry/nav behavior redesign; literal local-key contracts unchanged.
**Validation:** compilation/check attempted per task; see current task report.

## 2026-05-21 — Extract worker debug/helper implementations into dedicated include (PR #942 continuation)

**Task/PR/branch:** continue PR #942 / `refactor-worker-debug-helpers`.
**Files touched:** `daily_life/dl_worker_debug_inc.nss`, `daily_life/dl_worker_inc.nss`, `daily_life/dl_core_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Change:** moved implementations for the worker debug/helper functions from `dl_worker_inc.nss` into `dl_worker_debug_inc.nss`: `DL_GetAreaWorkerPassModeDebugLabel`, `DL_GetAreaTierDebugLabel`, `DL_SetAreaHotnessDebug`, `DL_CopyAreaHotnessDebugToNpc`, `DL_ClearCriticalWorkerDebug`, `DL_SetCriticalWorkerDebug`, `DL_SetCriticalProcessFailedDebug`, `DL_ClearCriticalProcessFailedDebug`, `DL_SetAreaWorkerPassDebug`, `DL_SetNpcRegularWorkerDebug`, `DL_TraceAreaWorkerTickForRegisteredNpc`; wired include order so `dl_worker_debug_inc.nss` is included before `dl_worker_inc.nss` via `dl_core_inc.nss`; retained forward declaration in `dl_worker_inc.nss` for `DL_SetNpcRegularWorkerDebug` because it is referenced by early code paths in the same include.
**Reason:** separate worker debug/helper implementations from main worker flow without touching runtime scheduling/worker logic.
**Preserve:** no changes to critical worker processing pipeline functions listed as out-of-scope in task; no new scans/tag lookups/DB/delay usage.
**Validation:** static text checks only. Compilation not run; user owns compilation.

## 2026-05-21 — PR #942 follow-up: restore exact worker debug/helper bodies after extraction

**Task/PR/branch:** continue PR #942 / `refactor-worker-debug-helpers` follow-up.
**Files touched:** `daily_life/dl_worker_debug_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** prior extraction changed implementation details in the new debug include (literal keys/compact rewrites/numeric pass-mode checks), which violated the strict no-behavior-change and no-debug-contract-change constraints.
**Change:** restored the moved worker debug/helper implementations in `dl_worker_debug_inc.nss` to match the original bodies exactly (same constants, same local-key identifiers, same control flow/format), while keeping them extracted out of `dl_worker_inc.nss`.
**Reason:** preserve runtime behavior and debugging contracts exactly while retaining the refactor split requested in PR #942.
**Preserve:** include order remains `dl_worker_debug_inc` before `dl_worker_inc`; retained necessary forward declaration in `dl_worker_inc.nss` for early callsites.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-21 — PR #944 include-order fix for extracted worker debug include

**Task/PR/branch:** continue PR #944 / `work` branch head.
**Files touched:** `daily_life/dl_core_inc.nss`, `daily_life/dl_worker_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** compiler pipeline failed because `dl_worker_debug_inc.nss` was included from `dl_core_inc.nss` before worker constants/prototypes from `dl_worker_inc.nss` were parsed.
**Change:** removed `#include "dl_worker_debug_inc"` from `dl_core_inc.nss`; added `#include "dl_worker_debug_inc"` inside `dl_worker_inc.nss` after worker constants and after required forward declarations (`DL_SetNpcRegularWorkerDebug`, `DL_RemoveStaleNpcReferenceFromAreaRegistrySlot`, `DL_IsNpcRegistryOwnerForArea`).
**Reason:** preserve extracted debug-helper structure while fixing compile order dependency without changing runtime behavior.
**Preserve:** no worker runtime logic edits; no additional function moves.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-21 — Worker transition handoff helper extraction into dedicated include

**Task/PR/branch:** `refactor/worker-handoff-helpers` / current task.
**Files touched:** `daily_life/dl_worker_inc.nss`, `daily_life/dl_worker_handoff_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** `dl_worker_inc.nss` contained transition registry handoff helper implementations interleaved with worker flow; task required isolating only handoff helpers without runtime behavior change.
**Change:** moved these functions verbatim into new include `dl_worker_handoff_inc.nss`: `DL_GetAreaTransitionHandoffSlotKey`, `DL_SetTransitionRegistryHandoffDebug`, `DL_QueueTransitionRegistryHandoff`, `DL_RequestTransitionRegistryHandoff`, `DL_RunTransitionRegistryHandoffTick`; added `#include "dl_worker_handoff_inc"` inside `dl_worker_inc.nss` in place of removed helper bodies after worker constants/prototypes are available.
**Reason:** reduce `dl_worker_inc.nss` size and keep transition handoff code isolated while preserving existing handoff logic/contracts and include ownership.
**Preserve:** worker runtime scheduling, area registry fallback/recovery, and critical stale-reached recovery paths were not changed.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-21 — PR #945 compile-order follow-up: forward declaration for handoff helper call

**Task/PR/branch:** continue PR #945 / `refactor/worker-handoff-helpers`.
**Files touched:** `daily_life/dl_worker_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** compiler pipeline failed with undeclared identifier `DL_ClearStaleTransitionHandoffProblemIfOwned` inside moved `DL_RunTransitionRegistryHandoffTick` body in `dl_worker_handoff_inc.nss` because declaration appeared later in parse order.
**Change:** added minimal forward declaration `void DL_ClearStaleTransitionHandoffProblemIfOwned(object oNpc);` immediately before `#include "dl_worker_handoff_inc"` in `dl_worker_inc.nss`.
**Reason:** fix include-order symbol visibility only; preserve exact runtime behavior and moved helper bodies.
**Preserve:** no registry recovery, critical recovery, or worker runtime scheduling changes.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-21 — Worker registry recovery helper extraction into dedicated include

**Task/PR/branch:** `refactor/worker-registry-recovery` / current task.
**Files touched:** `daily_life/dl_worker_inc.nss`, `daily_life/dl_worker_registry_recovery_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** `dl_worker_inc.nss` still contained area registry recovery/helper implementations interleaved with worker flow; task required extracting only the registry recovery helper implementations without behavior changes.
**Change:** moved these functions verbatim into new include `dl_worker_registry_recovery_inc.nss`: `DL_RemoveStaleNpcReferenceFromAreaRegistrySlot`, `DL_IsNpcRegistryOwnerForArea`, `DL_ClearStaleTransitionHandoffProblemIfOwned`, `DL_RunAreaRegistryFallbackIntegrityRepair`, `DL_RunAreaRegistryFallbackCatchupScan`, `DL_RunAreaRegistryFallbackRecovery`; added `#include "dl_worker_registry_recovery_inc"` inside `dl_worker_inc.nss` at the former implementation location.
**Reason:** reduce `dl_worker_inc.nss` size while preserving compile-order visibility and exact runtime behavior.
**Preserve:** worker runtime scheduling, transition handoff pipeline, worker debug helper ownership, and critical stale-reached recovery paths were not changed.
**Validation:** static checks only. Compilation not run; user owns compilation.

## 2026-05-21 — Worker contract extraction include (`dl_worker_contract_inc`)

**Task/PR/branch:** current task / new worker contract include extraction.
**Files touched:** `daily_life/dl_worker_inc.nss`, `daily_life/dl_worker_contract_inc.nss`, `docs/AGENT_WORKLOG.md`.
**Context:** worker constants and forward declarations were still embedded at the top of `dl_worker_inc.nss`, making include dependencies implicit and fragile.
**Change:** moved only the top worker contract section (worker/local/debug constants, pass/budget constants, and worker forward declarations including `DL_ClearStaleTransitionHandoffProblemIfOwned`) into new include `daily_life/dl_worker_contract_inc.nss`; replaced that top block in `dl_worker_inc.nss` with `#include "dl_worker_contract_inc"` and kept implementation bodies in place.
**Reason:** make worker include dependencies explicit and reduce include-order fragility without behavior changes.
**Preserve:** no function implementations moved in this step; no constant renames/value changes; no runtime scheduling, registry recovery, critical recovery, transition handoff, or debug helper logic changes.
**Validation:** static checks only. Compilation not run; user owns compilation.
