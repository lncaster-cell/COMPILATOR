# Daily Life stabilization audit after baseline success

Issue tracker context:
- Debt/audit tracker: **#864** (active).
- Resolved blocker: **#861** (closed, no longer blocker).
- Related stabilization history: **#860** (worker lifecycle simplification), **#862** (root-cause process hardening), plus #865/#866/#867 baseline fixes.

Status of this PR: **audit-only documentation**; no runtime NWScript behavior changes.

---

## 1) Current known status

Confirmed baseline inputs for this audit:

- `blacksmith01` now completes a full Daily Life cycle successfully.
- Manual validator/debug tool already exists and works.
- Route solving is already based on preconfigured `route_<current_zone>__<target_zone>` locals.
- Unique zone id approach is already accepted.
- #861 tavern/social/public -> sleep/home stuck scenario is resolved and closed.
- #864 remains the active debt/audit umbrella.

Implication: this audit is **post-stabilization mapping**, not a blocker-fix PR.

---

## 2) Intended Daily Life pipeline (canonical target model)

```text
schedule slot
→ directive resolver
→ directive preemption
→ target resolver
→ movement job start/tick
→ engine action
→ reached verdict
→ finalizer
→ stable terminal state
→ diagnostics/worklog
```

This pipeline is the reference used below to classify code paths.

---

## 3) Owner subsystem table

| Pipeline stage | Owning file/function area | Canonical helper/function (current best fit) | Important locals/state keys | Invariants to preserve |
|---|---|---|---|---|
| schedule slot | `daily_life/dl_worker_inc.nss` | `DL_RunAreaWorkerTick`, `DL_WorkerTouchNpc` | area worker tick/budget locals; area tier locals | No heartbeat-per-NPC replacement; bounded pass budgets; registered NPC must be touchable. |
| directive resolver | `daily_life/dl_worker_inc.nss`, `daily_life/dl_res_inc.nss` | `DL_ResolveNpcDirective`, `DL_ResolveEffectiveDirective` | directive locals, focus status, problem summary diagnostics | Resolver must stay semantic (SLEEP/WORK/MEAL/SOCIAL/PUBLIC/CHILL), not movement-emulation logic. |
| directive preemption | `daily_life/dl_res_inc.nss` | `DL_PreemptOldDirectiveState`, `DL_ShouldUseDirectiveFastPath` | `dl_npc_focus_status`, move/transition state locals | On directive change, stale state must be cleared predictably; no contract-key renames. |
| target resolver | `daily_life/dl_focus_inc.nss`, `daily_life/dl_sleep_inc.nss`, `daily_life/dl_transition_inc.nss` | `DL_ResolveDirectiveAnchorForMoveBridge`, directive-specific anchor/zone resolution | anchor tags, zone ids, `dl_npc_transition_target` | Must resolve explicit target anchor/zone before movement; fallback must remain bounded. |
| movement job start/tick | `daily_life/dl_move_job_inc.nss` | `DL_BeginMoveJob`, `DL_BeginMoveJobToObject`, `DL_TickMoveJob` | `dl_move_owner`, `dl_move_phase`, `dl_move_result`, target/radius locals | One canonical movement lifecycle; no duplicate parallel move controllers. |
| engine action | `daily_life/dl_move_job_inc.nss` (+ directive wrappers) | queue/reissue inside `DL_TickMoveJob` and helpers | action-state locals, no-progress counters | Engine action queue should remain primary actuator; no broad polling loop replacement. |
| reached verdict | `daily_life/dl_move_job_inc.nss` | `DL_IsMoveJobAtTargetNow`, `DL_MarkMoveJobReachedNow` | move result + target identity locals | Canonical reached verdict should be singular and reused everywhere. |
| finalizer | `daily_life/dl_res_inc.nss` | `DL_FinalizeReachedDirectiveMoveJob` | reached/finalize debug locals, focus/sleep/work terminal locals | Physically reached NPC must not remain indefinite `move_result=running` with no move action. |
| stable terminal state | `daily_life/dl_res_inc.nss`, `daily_life/dl_focus_inc.nss`, `daily_life/dl_sleep_inc.nss` | `DL_IsDirectiveStableAfterReachedFinalize` + directive executors | `dl_npc_focus_status`, sleep/work status locals | Terminal directive state must be coherent and move/transition stale state cleared. |
| diagnostics/worklog | `daily_life/dl_diag_inc.nss`, `daily_life/dl_dbg_time.nss`, `docs/AGENT_WORKLOG.md` | `DL_GetNpcProblemSummary`, BSMITH trace helpers | BSMITH lines, contradiction/classify locals | Do not remove active BSMITH diagnostics casually; preserve observability for regressions. |

---

## 4) Path classification table

| file | function/block | pipeline stage | classification | keep/delete/later | risk | evidence/reason |
|---|---|---|---|---|---|---|
| `daily_life/dl_worker_inc.nss` | `DL_RunAreaWorkerTick` | schedule slot | canonical | keep | high | Core scheduler/tick owner for registered NPC processing. |
| `daily_life/dl_worker_inc.nss` | `DL_WorkerTouchNpc` | schedule slot → directive resolver | canonical | keep | high | Canonical entry to resolver/apply path; emergency paths route back here. |
| `daily_life/dl_res_inc.nss` | `DL_ResolveNpcDirective` + `DL_ResolveEffectiveDirective` calls | directive resolver | canonical | keep | high | Semantic directive computation and social->public fallback logic. |
| `daily_life/dl_res_inc.nss` | `DL_PreemptOldDirectiveState` | directive preemption | canonical | keep | high | Clears previous directive state; protects transition/move/focus coherence. |
| `daily_life/dl_res_inc.nss` | `DL_ApplyDirectiveSkeleton` | resolver/preemption/target/move/finalize spine | canonical | keep | high | Main apply pipeline; broad edits here are high regression risk. |
| `daily_life/dl_transition_inc.nss` | `DL_NavPrepareTargetZoneFromAnchor` | target resolver | canonical | keep | medium | Zone-target prep for route-based transition/move flow. |
| `daily_life/dl_transition_inc.nss` | `DL_NavTryAdvanceToZoneForOwner` | target resolver → movement job start | canonical | keep | high | Canonical route-driven advancement via `route_<from>__<to>`. |
| `daily_life/dl_transition_inc.nss` | thin wrappers defaulting to transition owner | target resolver | fallback | later | medium | Compatibility wrappers around owner argument appear legacy-protective. |
| `daily_life/dl_move_job_inc.nss` | `DL_BeginMoveJob*` | movement job start | canonical | keep | high | Standard movement-job creation path. |
| `daily_life/dl_move_job_inc.nss` | `DL_TickMoveJob` | movement job tick / engine action | canonical | keep | high | Owns move progress/reissue/no-progress logic. |
| `daily_life/dl_move_job_inc.nss` | `DL_IsMoveJobAtTargetNow` | reached verdict | canonical | keep | high | Declared canonical reached helper in current contracts. |
| `daily_life/dl_move_job_inc.nss` | `DL_ForceReachMoveJobIfAlreadyAtTarget` | reached repair | emergency recovery | later | medium | Protects stale `running` while already-at-target edge case. |
| `daily_life/dl_res_inc.nss` | `DL_FinalizeReachedDirectiveMoveJob` | finalizer | canonical | keep | high | Canonical reached->terminal semantic closure point. |
| `daily_life/dl_res_inc.nss` | `DL_EnforceReachedMoveApplyExitInvariant` | finalizer repair | emergency recovery | later | medium | Added to suppress reached/finalize contradictions when state regresses. |
| `daily_life/dl_res_inc.nss` | `DL_EmergencyCloseReachedMoveInvariant` | finalizer repair | emergency recovery | later | medium | Hard closure for stale reached states; keep until redundant by proof. |
| `daily_life/dl_focus_inc.nss` | `DL_ProgressFocusAtTarget` | target/move/finalize overlap | unknown/risky | later | high | Blends routing/move/focus-terminalization; overlap with canonical finalizer. |
| `daily_life/dl_focus_inc.nss` | reached recovery blocks in social path | reached/finalize overlap | fallback | later | medium | Legacy guard paths likely still covering edge anchors. |
| `daily_life/dl_transition_inc.nss` | `DL_FinalizeTransitionAfterQueuedJump` | handoff/finalize | canonical + emergency recovery | keep (narrow later) | high | Handles real area handoff + same-area pseudo-transition completion. |
| `daily_life/dl_worker_inc.nss` | `DL_NpcNeedsCriticalWorkerTouch` and critical cursor path | worker touch repair | emergency recovery | later | high | Current safeguard for stale reached/owner mismatch not touched by regular passes. |
| `daily_life/dl_worker_inc.nss` | `DL_EmergencyTouchCriticalStaleReachedNpc` | worker emergency | emergency recovery | later | high | Explicit invariant repair to re-enter real worker pipeline. |
| `daily_life/dl_worker_inc.nss` | `DL_RunAreaRegistryFallbackIntegrityRepair` | stale registry repair | fallback | keep (narrow later) | medium | Bounded slot repair; protects registry consistency. |
| `daily_life/dl_worker_inc.nss` | `DL_RunAreaRegistryFallbackCatchupScan` | stale registry repair | emergency recovery | later | medium | Bounded scan fallback; potentially redundant after long stable runs. |
| `daily_life/dl_diag_inc.nss` | `DL_GetNpcProblemSummary` | diagnostics | diagnostic-only | keep | medium | Used for observability and some critical-path classification. |
| `daily_life/dl_res_inc.nss` + `daily_life/dl_dbg_time.nss` | BSMITH trace/contradiction/classify blocks | diagnostics | diagnostic-only | keep | high | Active investigation interface; explicitly protected by current process docs. |
| `daily_life/dl_move_job_decl_inc.nss` | declaration-only prototypes | compile-order support | canonical | keep | medium | Must remain declaration-only; structural compatibility constraint. |
| `daily_life/dl_registry_inc.nss` | register/reconcile/bootstrap area entry points | ownership/handoff | canonical | keep | high | Registry ownership contract for worker + transitions. |

---

## 5) Overlap / debt analysis

### A) Worker touch paths
- Canonical: `DL_RunAreaWorkerTick` → `DL_WorkerTouchNpc`.
- Debt: critical bypass/emergency touch paths duplicate “ensure touch” semantics.
- Risk: removing bypass too early can reintroduce stale `running` stuck states.

### B) Critical bypass paths
- Canonical intent: bypass should only route NPC back into canonical worker path.
- Debt: criteria spread across problem summary, move-result checks, focus status checks.
- Risk: hard to reason about when a path is real behavior vs protective shim.

### C) Handoff paths
- Canonical: transition finalizer + registry reconcile.
- Debt: queue-based handoff and fallback integrity/catchup paths are layered and partly redundant.
- Risk: simplification without runtime proof can break cross-area recovery.

### D) Transition repair paths
- Canonical: `DL_FinalizeTransitionAfterQueuedJump` / `DL_NavTryFinalizeCompletedTransition`.
- Debt: compatibility wrappers and extra completion branches keep legacy model alive.
- Risk: unknown call-site dependence under uncommon zone setups.

### E) Reached/finalize repair paths
- Canonical: `DL_IsMoveJobAtTargetNow` + `DL_FinalizeReachedDirectiveMoveJob`.
- Debt: additional repairs in apply/focus/worker produce overlapping closure logic.
- Risk: contradictory local states when one path finalizes and another still sees running.

### F) Focus bridge / legacy focus-anchor paths
- Canonical direction: focus should choose anchors/presentation, move job should own physical closure.
- Debt: focus still contains direct at-target/terminalization behavior in some branches.
- Risk: dual ownership between focus and finalizer can regress anchor states.

### G) Stale registry repair
- Canonical: register/reconcile during normal area enter/exit + transitions.
- Debt: fallback scans remain needed as safety net.
- Risk: likely safe only after repeated stable multi-NPC runs.

### H) BSMITH tracing and contradiction diagnostics
- Canonical use: active debugging + regression triage.
- Debt: noisy and scattered fields from multiple stabilization PRs.
- Risk: removing fields now degrades failure triage velocity.

---

## 6) Cleanup candidates

### A. Safe after static review only
1. Align comments/docstrings to explicitly label canonical vs fallback vs emergency paths.
2. Normalize audit/debug naming in docs for the same path (no code behavior change).
3. Consolidate duplicated documentation notes about route-zone vs route-area expectations.

### B. Safe only after runtime validation
1. Narrow trigger conditions for critical worker bypass once stable runs prove fewer false positives.
2. Reduce fallback registry catchup scan frequency/caps only after proving no missed registrations.
3. Route remaining focus reached-recovery branches through canonical finalizer helper (equivalent behavior expected but runtime-sensitive).

### C. Do not touch yet
1. `DL_TickMoveJob` / canonical reached helper path.
2. `DL_FinalizeReachedDirectiveMoveJob` and current invariant-repair helpers.
3. Transition finalizer path handling same-area pseudo-zone and cross-area handoff.
4. BSMITH trace/contradiction diagnostics currently used in stabilization workflows.

---

## 7) Recommended first cleanup PR (post-audit)

**Recommended scope: documentation/classification hardening only (3–5 changes, no runtime behavior change).**

Proposed small PR:
1. Add inline classification comments in `dl_worker_inc.nss` for critical bypass blocks.
2. Add inline classification comments in `dl_res_inc.nss` for reached/finalize emergency helpers.
3. Add inline classification comments in `dl_focus_inc.nss` around legacy reached-recovery paths.
4. Update `docs/agent/SUBSYSTEM_INDEX.md` with explicit “canonical vs emergency” mapping pointers.

Why this first:
- keeps blacksmith01 full-cycle baseline untouched;
- preserves validator behavior;
- reduces future accidental rewrites by clarifying ownership before code pruning.

---

## 8) Manual validation plan (user)

1. Compile manually.
2. Run `blacksmith01` through a full Daily Life cycle.
3. Run the validator/debug setup tool.
4. Confirm no new stuck state appears.
5. Confirm no regression in route/finalizer/worker behavior.
6. Capture BSMITH/debug output **only if failure returns**.

Expected outcome for this audit PR:
- no runtime behavior changes;
- same successful baseline as before this PR;
- clearer debt map for safe incremental cleanup under #864.

---

Compilation not run; user owns compilation.
