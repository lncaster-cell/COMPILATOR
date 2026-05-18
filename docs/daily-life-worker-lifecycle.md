# Daily Life worker / move lifecycle

## HOT area worker contract

A HOT area is an area that currently has at least one runtime player. In a HOT area, the area worker is authoritative for active Daily Life NPC progression:

1. Registered active NPCs owned by the current area are visited by the area registry round-robin.
2. The normal HOT path calls `DL_WorkerTouchNpc` through the round-robin touch path.
3. HOT progression does not rely on critical or emergency bypass paths, transition handoff touches, last-touch gating, warm gating, shared module budget exhaustion, or stale diagnostic state.
4. Registry fallback scans remain bounded recovery mechanisms only, used when registry state is missing or stale.

## Worker touch authority

`DL_WorkerTouchNpc` is the normal lifecycle entry point for resolving and applying directives. Movement job ticks, reached-move finalization, directive changes, and directive executor calls must remain inside the worker touch/apply pipeline instead of being reintroduced as separate HOT-area bypasses.

## Transition move lifecycle

Transition entry movement is a transport phase of the active directive inside the canonical worker/apply pipeline. When a directive resolves to an anchor in another area, new route-to-entry jobs keep the directive owner (`public`, `social`, `work`, `sleep`, `meal`, or `chill`) and use `move_phase=transition_to_area`; legacy `move_owner=transition` jobs remain accepted only through explicit compatibility checks. A transition move is compatible only while its transition target zone matches the directive destination zone and its move target is the current route's transition waypoint. The HOT worker must not use a separate transition handoff bypass to advance this movement; it must flow through `DL_WorkerTouchNpc`, `DL_ApplyDirectiveSkeleton`, the move-job tick, and the existing transition execution/finalizer path.

## Reached movement invariant

When a move job reports that it is already at its target via `DL_IsMoveJobAtTargetNow`, the apply pipeline must close the reached move through `DL_FinalizeReachedDirectiveMoveJob`. A reached move must not remain in `move_result=running`, and anchor focus must not remain in `focus_status=moving_to_anchor` after the invariant enforcement path runs.
