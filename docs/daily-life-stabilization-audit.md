# Daily Life stabilization audit map

Issue: #864 — Daily Life stabilization audit: reduce accumulated bugfix debt.

Baseline to protect: `stable/daily-life-blacksmith-baseline`.

Status of this PR: **documentation/audit only**. It does not change runtime NWScript behavior, delete NWScript code, refactor logic, add movement logic, or alter diagnostics. Compilation was not run; user owns compilation and in-game validation.

## 0. Audit scope and assumptions

Audited files:

- `daily_life/dl_res_inc.nss`
- `daily_life/dl_worker_inc.nss`
- `daily_life/dl_move_job_inc.nss`
- `daily_life/dl_move_job_decl_inc.nss`
- `daily_life/dl_transition_inc.nss`
- `daily_life/dl_focus_inc.nss`
- `daily_life/dl_sleep_inc.nss`
- `daily_life/dl_registry_inc.nss`
- `daily_life/dl_diag_inc.nss`
- `daily_life/dl_dbg_time.nss`

Important baseline context captured from the task:

- `blacksmith01` passed two full Daily Life cycles after PRs #865, #866, and #867 plus module setup fixes.
- Transition is now treated as a directive-owned transport phase, not as a semantic directive owner.
- Same-area pseudo-transitions are valid and can complete without a physical area change.
- Several observed failures were setup-contract failures: missing area scripts, missing NPC locals, and missing target-zone routes.

## 1. Current canonical Daily Life pipeline

The intended stable pipeline is:

```text
schedule slot
→ directive resolver
→ directive preemption
→ target resolver
→ transition/navigation if target is in another zone/area
→ movement job start/tick
→ engine action queue
→ reached verdict
→ directive finalizer
→ stable terminal directive state
→ diagnostics/debug state
```

### 1.1 Schedule slot → directive resolver

- The area worker touches registered NPCs and calls the normal NPC worker path.
- The worker resolves the current schedule directive with `DL_ResolveNpcDirective` and then routes through `DL_ApplyDirectiveSkeleton`.
- `DL_ResolveEffectiveDirective` may transform SOCIAL into PUBLIC when the social anchor is unavailable.

Canonical owner: **directive resolver / worker**.

### 1.2 Directive preemption

- `DL_ApplyDirectiveSkeleton` compares the previously stored directive with the newly resolved effective directive.
- If the directive changes, `DL_PreemptOldDirectiveState` clears stale move/focus/transition/presentation state according to the previous and next directive.
- Same-directive passes use compatibility checks instead of clearing everything.

Canonical owner: **directive application**.

### 1.3 Target resolver

- Directive-specific executors resolve anchors:
  - SLEEP: sleep approach/bed helpers in `dl_sleep_inc.nss`.
  - WORK: work helpers in nearby work includes.
  - MEAL/SOCIAL/PUBLIC/CHILL: focus/waypoint helpers in `dl_focus_inc.nss`.
- `DL_ResolveDirectiveAnchorForMoveBridge` provides the common bridge from semantic directive to physical target.

Canonical owner: **directive-specific resolver**.

### 1.4 Transition/navigation when target is in another zone/area

- `DL_NavPrepareTargetZoneFromAnchor` records the destination zone from the target anchor.
- `DL_NavTryAdvanceToZoneForOwner` routes toward the next zone using `route_<current_zone>__<target_zone>` locals and transition waypoint tags.
- Movement to transition entries should use the semantic directive move owner when possible, with phase `transition_to_area`.
- `DL_FinalizeTransitionAfterQueuedJump` finalizes queued jumps and performs registry handoff/repair for real area changes.
- `DL_NavTryFinalizeCompletedTransition` finalizes completed transition state from the directive/focus path after the NPC reaches the target area/zone.

Canonical owner: **transition/navigation service**, called by directive execution. Transition is not the semantic owner.

### 1.5 Movement job start/tick

- `DL_BeginMoveJobToObject` and `DL_BeginMoveJob` start canonical movement jobs.
- `DL_TickMoveJob` owns target resolution, same-area checks, action reissue, no-progress handling, result state, and failure state.
- `DL_IsMoveJobAtTargetNow` is the canonical reached check for movement jobs.

Canonical owner: **Movement Job Controller**.

### 1.6 Engine action queue

- Movement jobs ultimately issue engine actions through existing action helpers such as `DL_QueueMoveAction`.
- Sleep still has sleep-specific action helpers, but physical movement should not be reimplemented independently unless the sleep presentation/bed flow requires it.

Canonical owner: **Movement Job Controller plus directive-specific presentation action where appropriate**.

### 1.7 Reached verdict

- The canonical physical reached verdict is `DL_IsMoveJobAtTargetNow`.
- `DL_TickMoveJob` marks `move_result=reached` when the canonical check succeeds.
- `DL_ForceReachMoveJobIfAlreadyAtTarget` is a compatibility/recovery path for already-at-target running jobs.

Canonical owner: **Movement Job Controller**.

### 1.8 Directive finalizer

- `DL_FinalizeReachedDirectiveMoveJob` is the intended semantic finalizer after a physical move is reached.
- It clears the movement job and calls or sets the directive-specific terminal state:
  - PUBLIC → `on_public_anchor` plus presentation.
  - SOCIAL → `DL_ExecuteSocialDirective`.
  - MEAL → `DL_ExecuteMealDirective`.
  - CHILL → `DL_ExecuteChillDirective`.
  - WORK → `DL_ExecuteWorkDirective`.
  - SLEEP → `DL_ExecuteSleepDirective`.

Canonical owner: **directive application/finalizer**.

### 1.9 Stable terminal directive state

Stable terminal states include:

- SLEEP: `dl_npc_sleep_status=on_bed` and sleep target set.
- WORK: `dl_npc_work_status=on_anchor` and work target set.
- MEAL: focus status begins with `on_meal_anchor` and focus target set.
- SOCIAL: `dl_npc_focus_status=on_social_anchor` and focus target set.
- PUBLIC: `dl_npc_focus_status=on_public_anchor` and focus target set.
- CHILL: `dl_npc_focus_status=on_chill_anchor` and focus target set.

`DL_IsDirectiveStableAfterReachedFinalize` encodes this expected closure check.

Canonical owner: **directive-specific executor/finalizer**.

### 1.10 Diagnostics/debug state

- `DL_LogStuckState`, `DL_GetNpcProblemSummary`, BSMITH traces, reached/finalize debug locals, worker debug locals, nav debug locals, and manual `dl_dbg_time.nss` snapshots provide observability.
- Current BSMITH instrumentation is part of the active stabilization workflow and must not be removed casually.

Canonical owner: **diagnostic layer**, read-only with respect to behavior except where current emergency paths explicitly store debug locals.

## 2. Ownership model

### Directive = semantic owner

The semantic directive owns meaning and presentation:

- SLEEP
- WORK
- MEAL
- SOCIAL
- PUBLIC
- CHILL

Directive code decides *what* the NPC should be doing and what stable terminal state means. It should not grow independent physical movement controllers.

### Movement Job = physical movement executor

The movement job owns:

- move owner/phase/target/radius/result locals;
- target identity resolution;
- same-area movement checks;
- engine movement action issuance/reissue;
- canonical reached verdict;
- no-progress failure diagnostics.

Future cleanup should keep physical movement lifecycle centralized here.

### Transition = transport phase/service, not semantic directive owner

Transition code owns:

- zone IDs;
- route keys;
- transition entry/exit lookup;
- queued jump finalization;
- registry handoff after physical area changes;
- same-area pseudo-zone completion.

Transition should be invoked by directive-owned movement, not replace the directive owner with `transition` except for legacy compatibility paths that still exist.

### Area worker = scheduler/tick owner

The area worker owns:

- area tick advancement;
- hot/warm/frozen area lifecycle;
- registered NPC round-robin processing;
- budgeted worker touches;
- deterministic critical bypasses for known stale states.

It should not become a broad polling movement controller.

### Registry = area ownership tracking

Registry code owns:

- area slot storage;
- NPC registration/unregistration;
- reconciliation between physical area and registered area;
- bounded repair of stale slots.

Registry code should not own semantic directive decisions or movement finalization.

### Focus state = presentation/anchor state, not movement truth

Focus owns:

- anchor selection for MEAL/SOCIAL/PUBLIC/CHILL;
- presentation state such as `moving_to_anchor` or `on_public_anchor`;
- social scene startup;
- waypoint animation/sitting presentation.

Focus state can trigger movement jobs, but physical truth must come from the movement job reached verdict and the engine action state.

## 3. Code path classification

Legend:

- **CANONICAL**: main intended path; must preserve.
- **FALLBACK**: valid fallback; allowed only under documented conditions.
- **EMERGENCY**: recovery path added during bugfixing; candidate for later narrowing/removal.
- **DIAGNOSTIC**: debug/logging only; candidate for simplification after baseline validation.
- **OBSOLETE_CANDIDATE**: likely replaced by newer movement-job/transition model; do not delete yet.
- **UNKNOWN_RISKY**: do not touch without runtime evidence.

### 3.1 `dl_res_inc.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| `DL_ResolveEffectiveDirective` | CANONICAL | Social-to-public semantic resolution. Preserve fallback behavior until social setup is fully validated. |
| `DL_ShouldUseDirectiveFastPath` | CANONICAL | Stable same-directive no-op/refresh gate. High risk if broadened. |
| `DL_ApplyDirectiveSkeleton` | CANONICAL | Central directive apply pipeline: preempt, process transition move, bridge, tick, finalize, execute directive, materialize, log. Do not refactor broadly in one PR. |
| `DL_PreemptOldDirectiveState` | CANONICAL | Owns old-state cleanup on directive changes. Must preserve local-key contracts. |
| `DL_ProcessTransitionMoveInApply` | CANONICAL with compatibility | Current directive-owned transition phase bridge. Contains compatibility with legacy transition-owned jobs. |
| `DL_IsTransitionMoveJobCompatibleWithDirective` | FALLBACK/compatibility | Allows legacy `transition` owner only through explicit checks. Candidate for later narrowing after validation. |
| `DL_BridgeLegacyDirectiveAnchorMoveJob` | FALLBACK/OBSOLETE_CANDIDATE | Bridges older focus anchor movement into movement jobs. Preserve until all focus movement paths are proven movement-job-owned. |
| `DL_FinalizeReachedDirectiveMoveJob` | CANONICAL | Main reached-to-stable semantic finalizer. Consolidation target, not deletion target. |
| `DL_IsDirectiveStableAfterReachedFinalize` / `DL_VerifyReachedFinalizeClosure` | DIAGNOSTIC/invariant | Valid invariant reporting. Could become a validator-style helper later. |
| `DL_EnforceReachedMoveApplyExitInvariant` | EMERGENCY | Runtime repair when reached state remains running/moving. Candidate for narrowing after duplicate paths are consolidated. |
| `DL_EmergencyCloseReachedMoveInvariant` | EMERGENCY | Hard closure for PUBLIC/SOCIAL stale reached states. Do not remove before runtime proof. |
| `DL_DetectApplyMoveRegression` | DIAGNOSTIC/EMERGENCY | Detects and repairs same-tick regression from reached/cleared back to running. Good later candidate for diagnostic-only mode if root cause is eliminated. |
| `DL_RecoverReachedFocusAnchorMoveState` | FALLBACK/EMERGENCY | Recovers legacy focus `moving_to_anchor` when already at anchor. Candidate to merge into canonical finalizer once safe. |
| BSMITH helpers (`DL_BsmithTraceStage`, `DL_BsmithDetectContradictions`, classifiers) | DIAGNOSTIC | Active blacksmith diagnostics. Reduce only after baseline and user confirmation. |

### 3.2 `dl_move_job_inc.nss` and `dl_move_job_decl_inc.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| `dl_move_job_decl_inc.nss` declarations | CANONICAL | Declaration-only include. Keep body-free and constant-free. |
| `DL_BeginMoveJobToObject` / `DL_BeginMoveJob` | CANONICAL | Canonical movement job entry points. |
| `DL_TickMoveJob` | CANONICAL | Canonical movement job tick; owns action reissue and no-progress handling. |
| `DL_IsMoveJobAtTargetNow` | CANONICAL | Canonical reached verdict. Avoid duplicating reach math elsewhere. |
| `DL_MarkMoveJobReachedNow` | CANONICAL | Reached state marker and debug capture. |
| `DL_ResolveMoveJobTarget` | CANONICAL with diagnostic debt | Handles cached target object, target tag, same-area duplicate target detection. Candidate for future simplification only with validation. |
| `DL_ForceReachMoveJobIfAlreadyAtTarget` | FALLBACK/EMERGENCY | Useful compatibility repair for running-but-reached jobs. Should become rare after controller/finalizer consolidation. |
| No-progress/reissue helpers | FALLBACK | Valid movement robustness path. Preserve budgets and caps. |
| Duplicate target debug helpers | DIAGNOSTIC | Likely useful until setup validator reduces duplicate/missing anchor confusion. |

### 3.3 `dl_transition_inc.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| Route/key helpers (`DL_NavMakeRouteKey`, `DL_NavGetNextZone`) | CANONICAL | Target-zone route model. Preserve route contract. |
| Zone inference helpers | FALLBACK | Valid when explicit zone locals are absent. Bounded scans/caps must remain. |
| `DL_NavPrepareTargetZoneFromAnchor` | CANONICAL | Establishes target zone from semantic anchor. |
| `DL_NavTryAdvanceToZoneForOwner` | CANONICAL | Main route/transition movement service. Preserve directive-owned owner parameter. |
| `DL_SetPendingTransitionAfterJump` / `DL_FinalizeTransitionAfterQueuedJump` | CANONICAL with emergency repair | Canonical queued jump finalizer; also contains registry repair and same-area pseudo-transition logic. Future cleanup should split documentation/diagnostics first, not behavior. |
| Same-area branch in `DL_FinalizeTransitionAfterQueuedJump` | CANONICAL | Same-area pseudo-zones are valid. Must not regress to `area_not_changed` failure. |
| Cross-area registry repair in finalizer | FALLBACK/EMERGENCY | Needed for handoff robustness. Candidate for later narrowing after area scripts/setup validator are reliable. |
| `DL_NavTryFinalizeCompletedTransition` | CANONICAL/FALLBACK | Finalizes transition state from directive/focus path when areas align. Must preserve same-area pseudo-zone compatibility. |
| `DL_TryUseNavigationRouteToTarget` / `DL_TryExecuteTransitionAtWaypoint` | OBSOLETE_CANDIDATE | Thin compatibility wrappers using current move owner local. Do not delete until call sites and runtime traces prove unused/safe. |
| Nav debug setters | DIAGNOSTIC | Keep until setup validator exists and route failures are rarer. |

### 3.4 `dl_focus_inc.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| `DL_IssueFocusMoveAction` | CANONICAL bridge | Focus presentation starts physical movement through Movement Job Controller. Good current model. |
| `DL_ProgressFocusAtTarget` | CANONICAL with legacy debt | Main focus target progression for PUBLIC/SOCIAL-like anchors. It finalizes transition, routes, starts movement, and sets stable focus state. Contains overlapping finalizer behavior with `DL_FinalizeReachedDirectiveMoveJob`. |
| `DL_ApplyFocusWaypointAnimation` | CANONICAL presentation | Presentation only after anchor reached. |
| MEAL/CHILL legacy chair helpers | FALLBACK | Valid only for hand-verified chair ActionSit setups; waypoint animation is default. |
| `DL_ShouldFallbackSocialToPublic` | FALLBACK | Semantic fallback when social anchor missing. Later setup validator should make this a builder-facing warning rather than runtime surprise. |
| `DL_TryStartSocialSceneAtReachedAnchor` | CANONICAL | Social stable-state gate before ticking social scene. |
| Reached social recovery block in `DL_ExecuteSocialDirective` | EMERGENCY/OBSOLETE_CANDIDATE | Duplicates reached/finalize logic for social focus state. Candidate to consolidate into canonical finalizer after validation. |
| Social probe locals/logging | DIAGNOSTIC | Useful during current social stabilization; candidate for noise reduction after multi-NPC validation. |

### 3.5 `dl_sleep_inc.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| Sleep target resolvers | CANONICAL | Own sleep-specific home slot/approach/bed target resolution. |
| Sleep action reissue stamp helpers | FALLBACK | Sleep-specific anti-spam/reissue control. Preserve until sleep is moved more fully under movement jobs, if ever. |
| `DL_TryExitSleepToApproach` and delayed exit jump | UNKNOWN_RISKY | Presentation/placement behavior likely depends on NWN2 engine quirks. Do not refactor without runtime evidence. |
| `DL_ExecuteSleepDirective` | CANONICAL | Sleep semantic executor. Movement overlap should be audited separately before changes. |

### 3.6 `dl_worker_inc.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| `DL_RunAreaWorkerTick` | CANONICAL | Main area scheduler/tick owner. Must preserve no per-NPC heartbeat model. |
| `DL_RunAreaNpcRoundRobinPass` / `DL_ProcessAreaNpcByPassMode` / `DL_TouchNpcFromAreaWorker` | CANONICAL | Registered NPC processing pipeline. |
| `DL_WorkerTouchNpc` | CANONICAL | Real worker touch path; emergency routes should call this rather than duplicate directive logic. |
| Hot/warm/frozen tier management | CANONICAL | Area lifecycle and budgets. Avoid mixing with movement cleanup. |
| Transition handoff queue/tick | FALLBACK | Valid cross-area handoff recovery/continuity mechanism. Candidate for narrowing only after area scripts are guaranteed. |
| `DL_RunAreaRegistryFallbackIntegrityRepair` | FALLBACK/EMERGENCY | Bounded repair for stale registry slots. Keep caps. |
| `DL_RunAreaRegistryFallbackCatchupScan` | EMERGENCY | Bounded scan fallback. Candidate for later reduction after setup validator and handoff stability. |
| `DL_NpcNeedsCriticalWorkerTouch` | EMERGENCY/FALLBACK | Deterministic critical bypass for directive changes, owner mismatches, stale reached jobs, stale transitions, and worker-not-touching diagnostics. Candidate for staged narrowing. |
| `DL_ProcessCriticalAreaCursorNpc` | EMERGENCY | Scans registered slots for critical stale reached cases. Preserve until stale reached invariant is clean over multiple cycles. |
| `DL_EmergencyTouchCriticalStaleReachedNpc` | EMERGENCY | Last-resort call back into real worker path for stale reached registered NPC. Candidate for removal only after runtime evidence. |
| `DL_TraceAreaWorkerTickForRegisteredNpc` | DIAGNOSTIC | Blacksmith-specific worker tick tracing. Candidate for debug flagging/removal after stabilization. |

### 3.7 `dl_registry_inc.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| Dense registry slot helpers | CANONICAL | Area ownership tracking. |
| Area player count/tier helpers | CANONICAL | Area lifecycle support. |
| Freeze/thaw runtime helpers | CANONICAL/UNKNOWN_RISKY | Runtime lifecycle behavior; avoid changing during Daily Life movement cleanup. |
| `DL_OnAreaEnterBootstrap` / `DL_OnAreaExitBootstrap` | CANONICAL | Required area script entry points for setup contract. |
| `DL_EnsureNpcRegisteredInCurrentArea` / `DL_ReconcileNpcAreaRegistration` / `DL_RegisterNpc` / `DL_UnregisterNpc` | CANONICAL | Registration ownership and physical-area reconciliation. |
| Stale slot removal helpers | FALLBACK | Valid repair paths; keep bounded behavior. |

### 3.8 `dl_diag_inc.nss` and `dl_dbg_time.nss`

| Function/block | Classification | Notes |
| --- | --- | --- |
| `DL_GetNpcProblemSummary` | DIAGNOSTIC with scheduler impact | Diagnostic summary also triggers critical worker paths. Treat as behavior-sensitive. |
| `DL_MaybeLogNpcDiagnostic` | DIAGNOSTIC | Noise reduction candidate after validation. |
| `dl_dbg_time.nss` BSMITH snapshots | DIAGNOSTIC | Manual blacksmith-only snapshot script. Useful until baseline is accepted as durable. |

## 4. Bugfix debt inventory

### 4.1 Duplicate reached/finalize logic

Observed duplication/risk areas:

- `DL_TickMoveJob` marks reached from the canonical movement job tick.
- `DL_FinalizeReachedDirectiveMoveJob` rechecks `DL_IsMoveJobAtTargetNow`, then marks reached and converts to directive terminal state.
- `DL_ProgressFocusAtTarget` directly clears move/transition state and sets focus terminal state if distance is within radius.
- `DL_ExecuteSocialDirective` has an explicit reached focus recovery block for `moving_to_anchor` social anchors.
- `DL_RecoverReachedFocusAnchorMoveState`, `DL_EnforceReachedMoveApplyExitInvariant`, and `DL_EmergencyCloseReachedMoveInvariant` also repair reached-but-not-finalized states.

Future PR candidate: consolidate reached terminalization so focus/directive-specific code delegates to one finalizer path where possible.

### 4.2 Legacy focus movement vs Movement Job Controller

Current model is mostly good because `DL_IssueFocusMoveAction` starts `DL_BeginMoveJobToObject`. Debt remains in focus paths that directly inspect distance, clear move jobs, or set terminal state without routing through the canonical finalizer.

Future PR candidate: preserve focus as presentation/anchor owner while moving final physical reached closure to `DL_FinalizeReachedDirectiveMoveJob`.

### 4.3 Transition-owner compatibility paths

Recent baseline normalized transition as directive-owned transport phase, but compatibility remains:

- `DL_IsTransitionMoveJobCompatibleWithDirective` still accepts legacy `DL_MOVE_OWNER_TRANSITION` through explicit checks.
- `DL_NavTryAdvanceToZone` still calls `DL_NavTryAdvanceToZoneForOwner` with owner `transition`.
- Thin wrappers read `dl_move_owner` and default to `transition`.

Future PR candidate: instrument usage first; narrow legacy `transition` owner only after traces prove directive-owned paths cover baseline scenarios.

### 4.4 Stale registry repair / handoff paths

Current repair/handoff mechanisms include:

- transition pending old/new area locals;
- same-area pseudo-transition finalization;
- cross-area registry repair in `DL_FinalizeTransitionAfterQueuedJump`;
- transition registry handoff queue in worker code;
- registry fallback integrity repair and catchup scan.

These were necessary during stabilization but are spread across transition, worker, and registry layers. Future cleanup should clarify which path owns normal handoff versus recovery after missing scripts/setup.

### 4.5 Emergency worker touch paths

Emergency/critical paths currently ensure registered NPCs with stale reached move state are routed through the real worker/directive pipeline. This protects the baseline, but it is debt because the area worker now contains movement-state-specific critical bypass logic.

Future PR candidate: first rename/document these as invariant-repair paths; later remove only after two-cycle and multi-NPC validation proves canonical worker passes always touch stale reached NPCs promptly.

### 4.6 BSMITH debug spam or stale diagnostics

Active diagnostic debt:

- BSMITH trace stages throughout directive apply, movement, transition, and worker tick.
- Social probe locals and verbose before/after strings.
- Post-jump transition registry locals.
- Reached finalize/invariant debug locals.
- `dl_dbg_time.nss` manual status snapshots.

Do not remove now. Later, reduce noise by gating or pruning obsolete fields after the setup validator and multi-NPC validation exist.

### 4.7 Repeated “running but already at target” repair logic

This invariant is protected in multiple places:

- `DL_ForceReachMoveJobIfAlreadyAtTarget`.
- `DL_IsStaleReachedMoveJobCritical` and `DL_IsRegisteredCurrentAreaStaleReachedMoveCritical`.
- critical worker bypass/emergency touch.
- `DL_FinalizeReachedDirectiveMoveJob`.
- `DL_EnforceReachedMoveApplyExitInvariant`.
- BSMITH/debug-time classifiers.

This is useful for stabilization but should eventually become one canonical finalizer plus diagnostic-only assertions.

### 4.8 Route/anchor/setup diagnostics should become validator logic

Many observed failures were setup-contract issues, not movement logic bugs:

- missing area heartbeat/enter/exit scripts;
- missing NPC area/slot locals;
- missing target-zone routes;
- target-area routes defined without target-zone routes;
- same-area pseudo-zones misread as failed physical transitions.

Future PR candidate: create an offline/setup validator that reports these before runtime, reducing runtime confusion and emergency repair pressure.

## 5. Cleanup roadmap

### PR 1: documentation/setup contract only

- Purpose: turn this audit into builder-facing setup rules and stabilize language around directive/movement/transition ownership.
- Files touched: `docs/daily-life-stabilization-audit.md`, possibly a shorter builder setup doc under `docs/`.
- Risk level: Low.
- Validation required: Documentation review only.
- Behavior changes: No.

### PR 2: reduce stale/noisy diagnostics only

- Purpose: remove or gate clearly obsolete BSMITH/social/post-jump noise after the user confirms the baseline remains stable.
- Files touched: likely `daily_life/dl_res_inc.nss`, `daily_life/dl_worker_inc.nss`, `daily_life/dl_focus_inc.nss`, `daily_life/dl_transition_inc.nss`, `daily_life/dl_dbg_time.nss`.
- Risk level: Medium because some diagnostics currently influence critical worker classification through problem summaries.
- Validation required: one blacksmith two-cycle run before and after; confirm required absence list remains absent.
- Behavior changes: Intended no behavior change, but diagnostic gating must be reviewed for side effects.

### PR 3: narrow or rename emergency paths, no behavior change

- Purpose: rename/document emergency stale reached and critical worker paths so future agents do not treat them as canonical architecture.
- Files touched: likely `daily_life/dl_worker_inc.nss`, `daily_life/dl_res_inc.nss`, `docs/AGENT_WORKLOG.md`.
- Risk level: Medium if function names change across include boundaries; prefer comments/local diagnostic labels first.
- Validation required: static textual check for call sites; one blacksmith cycle if names/comments affect any diagnostic locals.
- Behavior changes: No intended behavior change.

### PR 4: consolidate duplicate finalizer helpers, with validation

- Purpose: reduce repeated reached/finalize logic by routing focus/social recovery through `DL_FinalizeReachedDirectiveMoveJob` or a small shared helper.
- Files touched: likely `daily_life/dl_res_inc.nss`, `daily_life/dl_focus_inc.nss`, possibly `daily_life/dl_move_job_inc.nss`.
- Risk level: High.
- Validation required: blacksmith two-cycle baseline; explicit PUBLIC/SOCIAL/MEAL/CHILL/WORK/SLEEP terminal-state verification; capture BSMITH traces on failure.
- Behavior changes: Yes, even if intended equivalent. Must be a runtime-validated behavior PR.

### PR 5: remove obsolete code only after runtime validation

- Purpose: remove legacy transition-owner compatibility wrappers or obsolete recovery branches proven unused by traces.
- Files touched: likely `daily_life/dl_transition_inc.nss`, `daily_life/dl_res_inc.nss`, `daily_life/dl_focus_inc.nss`, `daily_life/dl_worker_inc.nss`.
- Risk level: High.
- Validation required: two-cycle blacksmith baseline plus at least one same-area pseudo-zone transition and one real cross-area transition.
- Behavior changes: Yes. Do not do until trace evidence proves the paths are obsolete.

### PR 6: add setup validator

- Purpose: move route/anchor/local/script mistakes out of runtime debugging and into an explicit validator/checklist.
- Files touched: new docs and/or tooling outside compiler/toolchain; possibly a non-compiler static script if approved.
- Risk level: Low if documentation/static-only; Medium if runtime validator locals are added.
- Validation required: run validator against known blacksmith setup; confirm it catches missing area scripts, missing NPC locals, missing target-zone routes, and same-area pseudo-zone requirements.
- Behavior changes: No if static/documentation-only; yes if runtime validator logic is added.

## 6. Setup simplification recommendations

Many recent failures were setup-contract issues, not movement logic bugs. Future cleanup should make this explicit for builders.

### 6.1 Required area scripts

Active Daily Life areas require:

- heartbeat script;
- enter script;
- exit script.

Without these, the area worker, registration, and transition handoff pipeline can appear broken even when movement logic is correct.

### 6.2 Required NPC locals

NPCs should have explicit locals where relevant:

- `dl_home_area_tag`
- `dl_meal_area_tag`
- `dl_home_slot`
- `dl_work_area_tag` when needed
- `dl_public_area_tag` when needed
- `dl_social_area_tag` when needed

Future validator should distinguish missing setup from movement runtime failures.

### 6.3 Target-zone routes, not only target-area routes

Navigation routes are target-zone based, not only target-area based.

Example: if the target anchor is in `bedroom`, routes must exist toward `bedroom`:

- `route_gotha_tavern__bedroom`
- `route_gotha_cavenue__bedroom`
- `route_hall__bedroom`

It is not sufficient to define only area-level routes such as:

- `route_gotha_tavern__gotha_interior_kyznica`

### 6.4 Same-area pseudo-zones are valid

Same-area pseudo-zones are valid and expected, for example:

- `hall → bedroom`
- `hall → far_room`

Same-area pseudo-transitions must update the navigation zone and continue to the target anchor. They must not be treated as physical-area transition failures merely because `GetArea(oNpc)` did not change.

## 7. Protected invariants

Cleanup must preserve all of these:

1. No per-NPC heartbeat.
2. No `DelayCommand` pseudo-heartbeat.
3. No unbounded area scans in hot paths.
4. Movement lifecycle remains centralized through Movement Job Controller.
5. Transition remains directive-owned transport phase.
6. Worker touch remains deterministic.
7. Stable directive state must clear stale movement/transition state.
8. Reached target must not remain `move_result=running` forever.
9. Registry area must match physical area after cross-area transition.
10. Same-area pseudo-transition must update nav zone without cross-area registry handoff.
11. BSMITH trace fields remain protected until the user confirms diagnostic cleanup is safe.
12. Declaration-only includes remain body-free and constant-free.
13. Local-key literal contracts must not be renamed without migration.
14. Fallback scans/repairs must remain bounded and diagnosable.

## 8. Validation checklist

Compilation is user-owned. Agents should not run the NWScript compiler unless the user explicitly requests it in the current task.

### 8.1 Single NPC baseline validation

Use the current successful baseline as the manual reference:

1. Start at 06:00.
2. Observe one NPC (`blacksmith01`) through:
   - MEAL
   - WORK
   - CHILL
   - SOCIAL
   - PUBLIC
   - MEAL/SLEEP
3. Repeat for two full Daily Life cycles.

### 8.2 Required absence list

During validation, the following should be absent:

- `route_missing`
- `missing_meal_anchor`
- `post_jump_finalizer_area_not_changed`
- `regular_worker_not_touching_registered_npc`
- `move_status:running` when already at target
- `target_area_mismatch` after a valid route exists

### 8.3 Specific transition checks

- Same-area pseudo-transition completes without physical area-change failure.
- Cross-area transition updates registry area to match physical area.
- After transition finalization, stale transition/move locals do not keep the directive out of terminal state.

### 8.4 Future multi-NPC validation

Add a second NPC only after the cleanup map/setup contract exists and the single-NPC baseline remains stable.

Recommended staged multi-NPC checks:

1. Add one additional NPC in the same active area.
2. Confirm both NPCs are registered in the correct area slots.
3. Confirm the worker round-robin touches both deterministically.
4. Confirm no social/public anchor collision is hidden by blacksmith-only diagnostics.
5. Run at least one full schedule cycle before enabling more NPCs.

## 9. Future PR candidates found during audit; do not fix in this PR

- Convert setup-contract failures into a setup validator or builder checklist.
- Consolidate duplicate reached/finalize logic only after the baseline is revalidated.
- Instrument legacy transition-owner usage before removing compatibility paths.
- Narrow emergency worker touch and catchup scans after multi-cycle evidence proves the canonical worker path is sufficient.
- Reduce BSMITH/social/post-jump diagnostic noise only after the user confirms the traces are no longer needed for active debugging.
