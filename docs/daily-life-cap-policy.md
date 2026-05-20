# Daily Life cap policy (`daily_life/`)

This document consolidates scan/lookup/budget caps and defines a shared criticality policy:

- **HOT** — executed in worker/directive hot loops; must stay very tight and cheap.
- **WARM** — regular navigation/resync/repair paths; bounded moderate caps.
- **COLD** — event-driven paths (e.g., crime reactions); can be moderate but still bounded.

## Policy groups

1. **worker-hotpath**: caps that can execute inside `DL_WorkerTouchNpc`-driven flows. Prioritize predictable per-tick CPU.
2. **nav-resolution**: caps used by zone/route/transition resolution and bounded registry/nav fallbacks.
3. **crime-reactions**: caps used in event-triggered crime witness/guard discovery.

## Cap inventory and classification

| Constant | Value | Path criticality | Policy group | Rationale |
|---|---:|---|---|---|
| `DL_MOVE_TARGET_SEARCH_CAP` | 64 | HOT | worker-hotpath | Binds nth-tag target lookup in move job resolution; avoids unbounded tag probing while preserving duplicate-target diagnostics. |
| `DL_WAYPOINT_TAG_SEARCH_CAP` | 64 | HOT | worker-hotpath | Shared waypoint nth-tag lookup bound reused by focus/move helpers in active NPC ticks. |
| `DL_SOCIAL_PARTNER_TAG_SEARCH_CAP` | 32 | HOT | worker-hotpath | Bounds social partner lookup during focus execution. |
| `DL_MEAL_NEAR_CHAIR_SCAN_CAP` | 12 | HOT | worker-hotpath | Small local scan budget for meal seat polish in focus tick paths. |
| `DL_WORKER_BUDGET_WARM` | 2 | HOT | worker-hotpath | Per-area touch budget for warm areas. |
| `DL_WORKER_BUDGET_HOT` | 4 | HOT | worker-hotpath | Per-area touch budget for hot areas. |
| `DL_WORKER_BUDGET_MAX` | 12 | HOT | worker-hotpath | Absolute safety ceiling for per-area worker processing per tick. |
| `DL_MODULE_WORKER_PRESSURE_CAP` | 3 | HOT | worker-hotpath | Pressure-mode clamp protecting global throughput under load. |
| `DL_NAV_TRANSITION_TAG_SEARCH_CAP` | 64 | WARM | nav-resolution | Bounds transition waypoint tag probing. |
| `DL_NAV_AREA_SCAN_CAP` | 128 | WARM | nav-resolution | Bounded area sweep for nearby zone inference. |
| `DL_AREA_NAV_ROUTE_CAP` | 32 | WARM | nav-resolution | Max route hops when resolving next nav zone. |
| `DL_RESYNC_BUDGET_WARM` | 1 | WARM | nav-resolution | Warm-area resync budget. |
| `DL_RESYNC_BUDGET_HOT` | 2 | WARM | nav-resolution | Hot-area resync budget. |
| `DL_RESYNC_BUDGET_MAX` | 6 | WARM | nav-resolution | Absolute resync budget ceiling. |
| `DL_STALE_REGISTRY_REPAIR_SCAN_CAP` | 8 | WARM | nav-resolution | Bounded fallback scan for stale registry repair. |
| `DL_MODULE_RESYNC_PRESSURE_CAP` | 1 | WARM | nav-resolution | Pressure-mode clamp for resync work. |
| `DL_CR_WITNESS_SCAN_CAP` | 24 | COLD | crime-reactions | Event-driven witness discovery bound for crime signals. |
| `DL_CR_GUARD_SCAN_CAP` | 24 | COLD | crime-reactions | Event-driven guard discovery bound for crime signals. |
| `DL_CR_GUARD_RESPONDERS_MAX_CAP` | 2 | COLD | crime-reactions | Hard cap for concurrent guard responders to prevent fan-out. |

## Guardrails for future changes

- Any HOT cap increase requires explicit CPU-risk rationale and should prefer cache/index reuse over loop growth.
- WARM caps may be tuned only with a concrete failure signature (e.g., unresolved nav in large area) and bounded fallback reasoning.
- COLD caps should protect gameplay plausibility first (no overreaction swarms), then CPU cost.
- Keep literals and local-key contracts unchanged when adjusting cap usage.
