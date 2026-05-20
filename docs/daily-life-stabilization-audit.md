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

---

## 9) Stage-by-stage failure signatures (triage map)

Use this as a quick “first failing stage” locator for #864 follow-up PRs.

| Pipeline stage | Typical failure signature | First files to inspect | Likely classification bucket |
|---|---|---|---|
| schedule slot | registered NPC appears untouched, repeated worker skip/problem summary noise | `dl_worker_inc.nss`, `dl_diag_inc.nss` | canonical vs emergency recovery overlap |
| directive resolver | expected semantic directive not selected (or unexpected social->public fallback) | `dl_res_inc.nss`, `dl_worker_inc.nss` | canonical with fallback |
| directive preemption | directive changed but stale focus/move/transition locals remain | `dl_res_inc.nss` | canonical + emergency recovery |
| target resolver | anchor/zone mismatch, route missing, transition target unresolved | `dl_focus_inc.nss`, `dl_sleep_inc.nss`, `dl_transition_inc.nss` | canonical with fallback |
| movement job start/tick | no move job created, or move job remains running without progress | `dl_move_job_inc.nss`, `dl_res_inc.nss` | canonical + emergency recovery |
| engine action | `ACTION_MOVETOPOINT` absent while move_result remains running | `dl_move_job_inc.nss`, `dl_res_inc.nss`, `dl_worker_inc.nss` | emergency recovery protection |
| reached verdict | physically at target but reached not asserted, or contradictory reached states | `dl_move_job_inc.nss`, `dl_res_inc.nss` | canonical + overlap debt |
| finalizer | reached exists but terminal state not published | `dl_res_inc.nss`, `dl_focus_inc.nss`, `dl_sleep_inc.nss` | canonical + unknown/risky overlap |
| stable terminal state | focus/sleep/work states contradict move/transition closure | `dl_res_inc.nss`, `dl_focus_inc.nss`, `dl_sleep_inc.nss` | unknown/risky + fallback |
| diagnostics/worklog | no useful contradiction lines for failure replay | `dl_diag_inc.nss`, `dl_dbg_time.nss`, BSMITH sections in `dl_res_inc.nss` | diagnostic-only |

---

## 10) Unknown/risky backlog to de-risk before deletions

These are the main “don’t delete yet” audit hotspots that still need evidence from runtime sessions before simplification.

1. **Focus terminalization overlap**
   - Why risky: focus progression can set terminal states while finalizer also owns terminalization.
   - De-risk evidence needed: traces proving only one path closes terminal state per directive cycle.

2. **Critical worker bypass trigger spread**
   - Why risky: multiple trigger sources (problem summary + move/focus/owner mismatch signals).
   - De-risk evidence needed: per-trigger hit counts over stable cycles to find truly redundant triggers.

3. **Transition compatibility wrappers**
   - Why risky: legacy owner wrappers may still be hit in rare zone setups.
   - De-risk evidence needed: bounded instrumentation showing wrapper call frequency and call origin.

4. **Registry catchup fallback scans**
   - Why risky: removal can hide intermittent area registration drifts.
   - De-risk evidence needed: stable multi-cycle runs with zero stale-slot repairs required.

5. **Reached-repair multiplicity**
   - Why risky: several emergency closures prevent stale running state; naive reduction can resurrect #861-style symptoms.
   - De-risk evidence needed: canonical reached/finalize path stability under full cycle with contradiction checks silent.

---

## 11) Audit-driven sequencing for #864 (no behavior changes in first pass)

Recommended sequence for upcoming debt-reduction PRs:

1. **Classification annotation PR** (comments/docs only, no behavior change).
2. **Diagnostic observability normalization PR** (preserve fields, reduce duplicate noise only).
3. **Evidence PR** for unknown/risky branches (bounded counters/traces only if required).
4. **Single-overlap consolidation PR** (choose one overlap family only, e.g., focus/finalizer closure).
5. **Post-consolidation cleanup PR** (remove now-proven obsolete branch fragments).

Guardrails for each step:
- keep blacksmith01 full-cycle baseline green;
- keep validator behavior unchanged;
- keep route model unchanged (`route_<current_zone>__<target_zone>`);
- no broad scans/polling/graph pathfinding additions;
- no deletion-first strategy without runtime evidence.

---

## 12) Definition of done for the audit phase

The audit phase under #864 should be considered complete when all are true:

- Canonical path ownership is documented and agreed (this document + subsystem index updates).
- Each emergency/fallback path has an explicit keep/later/remove decision gate.
- Unknown/risky items have concrete evidence plans (not speculative rewrites).
- Next cleanup PR scope is small (3–5 changes), single-theme, and behavior-safe by design.
- Baseline guarantees remain explicit: blacksmith01 cycle success preserved, validator preserved, #861 remains closed.


---

## 13) Candidate obsolete/dead inventory (documentation hypotheses only)

This section marks **hypotheses**, not deletion approvals. A path may be “obsolete/dead candidate” only if evidence confirms no canonical scenario still depends on it.

| Candidate area | Current hypothesis | Why it might be obsolete | Why it might still be needed | Decision gate |
|---|---|---|---|---|
| transition-owner wrapper calls around `DL_NavTryAdvanceToZoneForOwner` | likely legacy compatibility | Directive-owned transition model is now canonical | Rare callers may still pass legacy owner in uncommon setups | Collect wrapper-hit traces across full stable cycle + failure replay |
| social reached-recovery duplicate branches in focus/social execution | partial duplication with finalizer | Canonical finalizer already closes reached move jobs | Some social-anchor edge cases may still bypass canonical closure | Prove identical closure outcome on SOCIAL slot changes over stable runs |
| repeated reached-running emergency closures in apply/worker | over-defensive overlap | Canonical reached + finalizer invariant should be enough long-term | Edge states from delayed engine action/state drift still possible | Record contradiction counters; only reduce when counters stay silent |
| registry catchup fallback scan path | heavy fallback | Stable setup/scripts may make fallback rarely useful | Protects against intermittent registration drift after transitions | Track stale-slot repair frequency across multiple cycles |

Note: keep classification conservative until data shows true non-use.

---

## 14) Evidence package template for #864 follow-up PRs

To keep cleanup safe, every debt-reduction PR should attach a compact evidence package:

1. **Scope statement**
   - One overlap family only (worker bypass, reached/finalize, transition wrapper, etc.).

2. **First failing stage framing**
   - Observed symptom.
   - Expected state.
   - First failing pipeline stage.

3. **Before/after evidence**
   - BSMITH contradiction/classify summary.
   - Problem summary frequency.
   - Any targeted counters/traces used in the PR.

4. **Invariant checklist**
   - `blacksmith01` full-cycle baseline preserved.
   - Validator behavior unchanged.
   - No route-model changes.
   - No compiler/toolchain touch.

5. **Rollback trigger**
   - Explicit condition that means rollback/revert is safer than more emergency patching.

This template is process-only and does not require runtime behavior changes by itself.

---

## 15) Next two micro-PR candidates (post-audit, docs-first)

### Micro-PR A (documentation alignment)
- Update `docs/agent/SUBSYSTEM_INDEX.md` with canonical/fallback/emergency tags for key Daily Life owner paths.
- Add direct links/names for `DL_ApplyDirectiveSkeleton`, `DL_FinalizeReachedDirectiveMoveJob`, `DL_TickMoveJob`, `DL_NavTryAdvanceToZoneForOwner`, `DL_WorkerTouchNpc`.
- Goal: reduce future owner-confusion without touching runtime files.

### Micro-PR B (annotation-only in code comments)
- Add short classification comments near critical bypass/emergency blocks in:
  - `daily_life/dl_worker_inc.nss`
  - `daily_life/dl_res_inc.nss`
  - `daily_life/dl_focus_inc.nss`
- No behavior edits, no condition rewrites, no local-key changes.
- Goal: prevent accidental deletion or broad rewrites during future bugfix work.

Both micro-PRs remain fully compatible with current constraints: baseline preservation, no route changes, no runtime-heavy additions.


---

## 16) File-by-file cleanup readiness matrix (for #864)

This matrix turns the audit into immediate planning guidance. “Readiness” means **readiness for a small cleanup PR**, not readiness for broad refactor.

| File | Canonical ownership confidence | Cleanup readiness | Allowed now | Blocked until evidence | Notes |
|---|---|---|---|---|---|
| `daily_life/dl_move_job_inc.nss` | high | low | comment-only classification notes | logic simplification of reached/no-progress branches | Canonical movement controller; high blast radius. |
| `daily_life/dl_res_inc.nss` | high | low/medium | comment-only labels around emergency closures | finalizer path consolidation | Contains core apply/finalize and active BSMITH diagnostics. |
| `daily_life/dl_worker_inc.nss` | high | medium | annotate critical bypass intent and invariants | narrowing bypass triggers | Owner is clear, but trigger interactions remain debt-heavy. |
| `daily_life/dl_transition_inc.nss` | medium/high | medium | document wrapper compatibility status | removing wrapper paths | Route model stable; wrapper usage still needs measured evidence. |
| `daily_life/dl_focus_inc.nss` | medium | low | classify legacy recovery blocks | closure-path unification with finalizer | Main overlap hotspot with finalizer terminalization. |
| `daily_life/dl_sleep_inc.nss` | medium | low | no-op docs only | sleep transition/action-flow refactor | Engine-sensitive behavior; avoid speculative changes. |
| `daily_life/dl_registry_inc.nss` | high | medium | docs clarification of ownership/handoff contracts | pruning fallback scan/repair mechanisms | Fallback paths are safety nets; reduction needs runtime proof. |
| `daily_life/dl_diag_inc.nss` | medium/high | medium | deduplicate phrasing/docs around problem summaries | reducing fields used by critical classification | Some diagnostics influence emergency routing decisions. |
| `daily_life/dl_dbg_time.nss` | high | medium/high | output wording/structure cleanup only | removing BSMITH summary lines used during failure triage | Manual bounded tool; low runtime risk if behavior unchanged. |
| `daily_life/dl_move_job_decl_inc.nss` | high | high (declaration hygiene only) | maintain declaration-only discipline | adding bodies/default args/constants | Compile-order contract file; no behavior logic allowed. |

---

## 17) Risk heatmap for first behavior-changing cleanup PRs

When #864 moves from docs-first to behavior cleanup, choose one of these lanes and avoid mixing lanes.

| Lane | Primary target | Expected value | Risk level | Hard constraints |
|---|---|---|---|---|
| Lane A | reduce duplicate diagnostic noise only | cleaner triage, faster issue reading | low/medium | preserve all decision-driving diagnostics |
| Lane B | narrow one critical bypass trigger family | less emergency-path churn | medium/high | never reduce multiple trigger families in one PR |
| Lane C | unify one focus reached-recovery path with canonical finalizer | lower overlap debt | high | only one directive family at a time; keep rollback path explicit |
| Lane D | deprecate one transition wrapper call-site cluster | clearer transition ownership | high | must show wrapper-hit evidence first |
| Lane E | tune registry fallback budgets/entry conditions | lower hot-path maintenance cost | high | only after stable cycles show no stale-slot dependence |

Recommendation for first behavior-changing cleanup under #864:
- prefer **Lane A** first, then re-evaluate counters/contradictions before any Lane B–E change.

---

## 18) Audit continuity checklist for future agents

Before touching Daily Life cleanup code under #864, the agent should explicitly verify:

1. #861 remains closed and non-blocking.
2. `blacksmith01` full-cycle baseline is still the protected reference.
3. Validator behavior remains intact and is not treated as blocker.
4. Route model assumptions remain zone-to-zone (`route_<current_zone>__<target_zone>`).
5. Planned PR scope is one overlap family only.
6. Planned PR states rollback trigger in advance.
7. PR preserves BSMITH contradiction/classify observability unless change is diagnostics-only and proven safe.

If any of the above is unknown, default to evidence/docs PR rather than behavior rewrite.


---

## 19) Full `daily_life/` script inventory audit (read-all pass)

Per current request, a full read pass was executed across all scripts under `daily_life/` (excluding compiler/toolchain and stock compiler scripts).

### 19.1 Coverage summary

- Total files read under `daily_life/`: **49**.
- Includes/docs + runtime scripts were both reviewed.
- Approximate total reviewed lines: **~4988** (textual read pass).

### 19.2 Inventory by role

| Role | Files |
|---|---|
| Area bootstrap/runtime entry points | `dl_a_enter.nss`, `dl_a_exit.nss`, `dl_a_hb.nss`, `dl_userdef.nss`, `dl_spawn.nss`, `dl_load.nss` |
| Core pipeline includes | `dl_res_inc.nss`, `dl_worker_inc.nss`, `dl_move_job_inc.nss`, `dl_transition_inc.nss`, `dl_focus_inc.nss`, `dl_sleep_inc.nss`, `dl_work_inc.nss`, `dl_registry_inc.nss`, `dl_diag_inc.nss`, `dl_sched_inc.nss` |
| Runtime contracts/lifecycle/resync | `dl_runtime_contract_inc.nss`, `dl_lifecycle_inc.nss`, `dl_resync_inc.nss`, `dl_core_inc.nss` |
| Presentation/anchors/movement helpers | `dl_anchor_cache_inc.nss`, `dl_anchor_move_inc.nss`, `dl_presentation_inc.nss`, `dl_activity_archive_anim_inc.nss`, `dl_social_scene_inc.nss` |
| Debug/ops tooling | `dl_dbg_setup.nss`, `dl_dbg_time.nss`, `bsmith_trace_off.nss`, smoke scripts `dl_smk_*.nss`, `dl_smoke_ev.nss` |
| Crime/legal subsystem | `dl_cr_crime_inc.nss`, `dl_city_response_inc.nss`, `dl_legal_inc.nss`, `dl_cr_detain_accept.nss`, `dl_cr_detain_refuse.nss`, `dl_lg_resolve_detain.nss`, `dl_lg_resolve_fine.nss`, `dl_cr_restricted_trg.nss` |
| Event handlers (damage/death/open/etc.) | `dl_damaged.nss`, `dl_death.nss`, `dl_open.nss`, `dl_disturbed.nss`, `dl_perception.nss`, `dl_blocked.nss`, `dl_blocked_inc.nss` |
| Setup docs/contracts | `SOCIAL_SETUP.md` |

### 19.3 High-mass/high-risk files (by size and ownership depth)

These files currently dominate behavior surface and should remain high-caution for any cleanup:

- `dl_res_inc.nss` (~2056 lines, directive/apply/finalize ownership).
- `dl_worker_inc.nss` (~1741 lines, worker scheduling + emergency touch paths).
- `dl_focus_inc.nss` (~1277 lines, focus/anchor progression + overlap debt).
- `dl_registry_inc.nss` (~1144 lines, registration/handoff/fallback repair surface).
- `dl_transition_inc.nss` (~862 lines, route/zone/transition/handoff paths).
- `dl_move_job_inc.nss` (~814 lines, canonical movement lifecycle/reached logic).

### 19.4 Compile-order/safety-critical include discipline

- `dl_move_job_decl_inc.nss` remains declaration-only contract surface.
- Cleanup PRs must preserve “declaration-only” constraints (no bodies/default args/constants).
- This include is safe for hygiene review, unsafe for behavior logic injection.

### 19.5 Cross-subsystem debt concentration

From full inventory review, debt is concentrated at these boundaries:

1. **Directive apply ↔ movement reached/finalize** (`dl_res_inc.nss` + `dl_move_job_inc.nss`).
2. **Worker touch ↔ emergency bypass** (`dl_worker_inc.nss` + `dl_diag_inc.nss`).
3. **Focus progression ↔ terminal closure** (`dl_focus_inc.nss` + `dl_res_inc.nss`).
4. **Transition routing ↔ registry handoff repair** (`dl_transition_inc.nss` + `dl_registry_inc.nss` + worker fallback scans).

This confirms the earlier #864 map: cleanup must stay single-lane and evidence-driven.

### 19.6 “Do not expand scope” guard after full pass

Even with full repository script coverage, the safest next step is still:
- docs/comment classification hardening;
- then targeted evidence PRs;
- only then narrow behavior changes one overlap family at a time.

Broad “all-in-one” simplification across `res/worker/focus/transition/registry` remains high regression risk against the current working baseline.

