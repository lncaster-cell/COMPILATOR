# Daily Life Movement Job Controller

Movement-based directives use a single NPC-local movement job instead of each directive owning its own action-queue lifecycle.

## NPC-local state

The canonical movement job locals are:

- `dl_move_owner` — directive/controller that owns the move (`sleep`, `work`, `meal`, `social`, `public`, `chill`, or `transition`).
- `dl_move_phase` — owner phase such as `anchor`, `approach`, or the transition target zone.
- `dl_move_target_tag` — waypoint/object tag to resolve.
- `dl_move_target_area` — resolved target area tag.
- `dl_move_radius` — completion radius.
- `dl_move_ticket` — last move issue stamp.
- `dl_move_result` — `running`, `reached`, or `failed`.
- `dl_move_diagnostic` — failure or wait reason.

Existing directive locals such as focus, work, sleep, and transition status remain as presentation/owner state only. They are not the generic source of movement truth.

## Runtime flow

1. A directive resolves its domain-specific target using the existing cache/anchor/transition helpers.
2. If the NPC must move, the directive sets its presentation state and calls `DL_BeginMoveJob`.
3. The worker ticks `DL_TickMoveJob` before directive fast-path logic.
4. While the job is `running`, fast-path is blocked and the worker does not advance owner presentation.
5. When the job returns `reached`, the owner directive advances to its stable phase and clears the move job.
6. When the target cannot be resolved, the job returns `failed` and records `dl_move_diagnostic`.

`DL_TickMoveJob` is the generic place that resolves the target, checks distance, issues or reissues movement when the action queue is empty, finalizes reached movement, and clears stale transition state when the NPC is already at the final target.
