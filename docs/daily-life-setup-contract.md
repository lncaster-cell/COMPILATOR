# Daily Life setup contract

This is the builder-facing setup contract for Daily Life NPCs and the areas they use. It is intentionally documentation-only: it describes the current expected module markup and does not add runtime validation or change NWScript behavior.

Use this before adding a new Daily Life NPC, changing an NPC schedule destination, or debugging a route/anchor failure. Many recent Daily Life failures were setup-contract problems rather than movement/runtime logic bugs.

## 1. Minimum active area setup

Every area that participates in active Daily Life processing must have the Daily Life area scripts assigned:

| Area event | Required script |
| --- | --- |
| Heartbeat | `dl_a_hb` |
| Enter | `dl_a_enter` |
| Exit | `dl_a_exit` |

These scripts are required for the area worker, player/hot-area state, NPC registration maintenance, and transition handoff/repair paths. If any participating area is missing one of these scripts, the visible symptoms can look like movement or transition bugs even when routes and anchors are correct.

Common symptoms of missing area scripts include:

- worker not ticking;
- NPC registered but not processed;
- transition handoff appearing broken after the NPC changes areas or zones.

## 2. Minimum NPC locals

Daily Life NPCs are configured through local variables on the NPC. Local values that name areas must use the exact area **Tag**, not the display name shown to players or builders.

### Required for a normal resident NPC

| Local | Expected value | Notes |
| --- | --- | --- |
| `dl_profile_id` | profile id string | Drives the schedule/profile family, for example `blacksmith`. |
| `dl_home_area_tag` | exact area Tag | The NPC's home/sleep/chill area. |
| `dl_home_slot` | resident slot number/string | Used to resolve slot-based home, meal, chill, and sleep waypoints. |
| `dl_meal_area_tag` | exact area Tag | The normal meal area. It may be the same as home/work. |

### Usually required

| Local | Expected value | Notes |
| --- | --- | --- |
| `dl_work_area_tag` | exact area Tag | Required when the profile has WORK time. |
| `dl_public_area_tag` | exact area Tag | Required when the profile has PUBLIC time. |
| `dl_social_area_tag` | exact area Tag | Required when the profile has SOCIAL time. |
| `dl_social_slot` | `a` or `b` when paired slots are used | Selects `dl_anchor_social_a` or `dl_anchor_social_b`; falls back to shared social anchor if no slot anchor resolves. |
| `dl_social_partner_tag` | exact NPC Tag | Optional unless the scene depends on explicit pairing. Use when social pairing is intended. |

### Exact technical tag rule

For all `*_area_tag` locals, use the exact area **Tag** field. Do not use:

- area display name;
- localized name;
- conversation/UI label;
- a navigation zone id;
- a waypoint tag.

Example: if the target area Tag is `gotha_interior_kyznica`, the NPC local must be exactly `dl_home_area_tag = gotha_interior_kyznica`.

## 3. Area anchors

Areas expose directive targets through area locals that point to waypoint tags. The waypoint itself should exist in that area and should be reachable.

Expected area locals:

| Area local | Purpose |
| --- | --- |
| `dl_anchor_meal` | Shared/default meal waypoint for the area. |
| `dl_anchor_public` | Public anchor waypoint for PUBLIC directive. |
| `dl_anchor_social` | Shared/default SOCIAL anchor waypoint. |
| `dl_anchor_social_a` | Paired SOCIAL slot A anchor waypoint. |
| `dl_anchor_social_b` | Paired SOCIAL slot B anchor waypoint. |

Fallback waypoint tag patterns used by current setup:

| Fallback waypoint tag | Purpose |
| --- | --- |
| `dl_meal_<home_slot>` | Meal fallback when `dl_anchor_meal` is not set or does not resolve. |
| `dl_chill_seat_<home_slot>` | Home CHILL seat fallback. |
| `dl_sleep_approach_<home_slot>` | Sleep approach fallback. |
| `dl_sleep_bed_<home_slot>` | Sleep bed fallback, if used by the current sleep setup. |

For example, an NPC with `dl_home_slot = 1` can use `dl_meal_1`, `dl_chill_seat_1`, `dl_sleep_approach_1`, and `dl_sleep_bed_1` as fallback waypoint tags.

## 4. Navigation zones

Daily Life navigation routes between zones. A zone may be a whole area, or it may be a pseudo-zone inside one physical area.

Set `dl_nav_zone_id` on:

- the area, when the whole area has one default navigation zone;
- an anchor waypoint, when that anchor belongs to a more specific zone than the area default.

Same-area pseudo-zones are valid. Current examples include:

- `hall`
- `bedroom`
- `far_room`

The same physical area can contain several navigation zones. For example, one home interior area can contain `hall`, `bedroom`, and `far_room`. Routes and transition waypoints must still be defined between these zones even though no physical area change happens.

## 5. Transition waypoints

Transition waypoint tags use this convention:

```text
<from_zone>__<to_zone>
```

The double underscore is part of the contract.

Examples:

- `hall__bedroom`
- `bedroom__hall`
- `hall__far_room`
- `far_room__hall`
- `hall__gotha_cavenue`
- `gotha_cavenue__hall`
- `gotha_cavenue__gotha_tavern`
- `gotha_tavern__gotha_cavenue`

For same-area pseudo-transitions, both waypoints can be inside the same physical area. For cross-area transitions, the entry/exit waypoint pair connects two physical areas.

## 6. Route locals

Routes are target-zone based, not only target-area based.

The route local format is:

```text
route_<current_zone>__<target_zone> = <next_zone>
```

The `target_zone` is the final zone of the resolved destination anchor, not necessarily the destination area's Tag.

Example: if an NPC is in the tavern and the final target is the sleep anchor in the home `bedroom`, the required route chain is:

```text
route_gotha_tavern__bedroom = gotha_cavenue
route_gotha_cavenue__bedroom = hall
route_hall__bedroom = bedroom
```

This is **not** enough:

```text
route_gotha_tavern__gotha_interior_kyznica
```

That route targets an area tag, but the target anchor may resolve to zone `bedroom`. In that case navigation asks for a route to `bedroom`, so the area-level route does not satisfy the current contract.

## 7. Worked example: `blacksmith01`

Current baseline context: `blacksmith01` passed two full Daily Life cycles after the recent stabilization fixes and module setup corrections. Treat this as the reference setup pattern, not as permission to remove diagnostics or rewrite runtime logic.

### NPC locals

Known working NPC locals:

| Local | Value |
| --- | --- |
| `dl_profile_id` | `blacksmith` |
| `dl_home_area_tag` | `gotha_interior_kyznica` |
| `dl_home_slot` | `1` |
| `dl_meal_area_tag` | `gotha_interior_kyznica` |
| `dl_work_area_tag` | `gotha_interior_kyznica` |
| `dl_public_area_tag` | `gotha_tavern` |
| `dl_social_area_tag` | `gotha_cavenue` |
| `dl_social_slot` | `a` |
| `dl_social_partner_tag` | optional/example: set to the current partner NPC Tag when an explicit partner is used. The current partner tag is not documented in this repository baseline. |

### Areas

Participating areas:

- `gotha_interior_kyznica`
- `gotha_cavenue`
- `gotha_tavern`

Each participating area must have the Daily Life heartbeat, enter, and exit scripts assigned.

### Expected route families

Home internal routes:

- `bedroom ↔ hall`
- `far_room ↔ hall`
- `hall ↔ gotha_cavenue`

Street/tavern routes:

- `gotha_cavenue ↔ gotha_tavern`

Routes must exist to final target zones, including:

- from tavern/street to `bedroom`;
- from tavern/street to `far_room`;
- from home zones to `gotha_tavern`;
- from home zones to `gotha_cavenue`.

In practice this means the route locals should guide navigation from each relevant current zone toward the resolved destination anchor zone, not merely toward the destination area tag.

## 8. Common failure signatures

Use these signatures to separate setup problems from runtime regressions.

| Debug/signature | Meaning |
| --- | --- |
| `regular_worker_not_touching_registered_npc` | Likely missing area scripts or a worker/registry issue. First check that all participating areas have `dl_a_hb`, `dl_a_enter`, and `dl_a_exit`. |
| `focus:missing_meal_anchor` | Meal area resolved, but there is no usable `dl_anchor_meal` area local and no `dl_meal_<slot>` waypoint fallback. |
| `route_missing` | Missing `route_<current_zone>__<target_zone>` local for the resolved final target zone. |
| `post_jump_finalizer_area_not_changed` | Should not happen for a valid same-area pseudo-transition after PR #867. If it appears, check pseudo-transition setup first, then suspect a finalizer regression. |
| `target_area_mismatch` | Target is in another area/zone and navigation route setup is needed before the directive can finalize at the anchor. |

## 9. Pre-flight checklist before adding a new NPC

Before adding a new Daily Life NPC:

- [ ] Assign `dl_a_hb`, `dl_a_enter`, and `dl_a_exit` to every active participating area.
- [ ] Set required NPC locals: `dl_profile_id`, `dl_home_area_tag`, `dl_home_slot`, and `dl_meal_area_tag`.
- [ ] Set relevant destination locals: `dl_work_area_tag`, `dl_public_area_tag`, `dl_social_area_tag`, `dl_social_slot`, and `dl_social_partner_tag` when the profile/scene needs them.
- [ ] Confirm every `*_area_tag` local uses the exact area Tag, not display name.
- [ ] Add area anchors or fallback waypoints for meal, public, social, chill, and sleep as needed.
- [ ] Set `dl_nav_zone_id` on areas and on anchor waypoints when a specific anchor belongs to a pseudo-zone.
- [ ] Create transition waypoint pairs using `<from_zone>__<to_zone>`.
- [ ] Create route locals to final target zones using `route_<current_zone>__<target_zone> = <next_zone>`.
- [ ] Start manual tests at key times: `06:00`, `18:00`, and `21:00`.
- [ ] Run one full Daily Life cycle.
- [ ] Then run a second full Daily Life cycle to catch stale state from the previous cycle.

Compilation and in-game validation are user-owned.

## 10. Future validator should check

A future validator/tool should verify at least:

- participating areas have Daily Life heartbeat, enter, and exit scripts assigned;
- NPCs with Daily Life profiles have required locals;
- `*_area_tag` local values resolve to exact area Tags;
- required/recommended destination locals match the profile's schedule directives;
- referenced anchor area locals point to existing waypoint tags in the expected area;
- fallback waypoints such as `dl_meal_<home_slot>`, `dl_chill_seat_<home_slot>`, `dl_sleep_approach_<home_slot>`, and `dl_sleep_bed_<home_slot>` exist when needed;
- social slot setup is coherent: `dl_social_slot`, `dl_anchor_social_a`, `dl_anchor_social_b`, shared `dl_anchor_social`, and optional `dl_social_partner_tag`;
- every participating area/anchor has the expected `dl_nav_zone_id`;
- same-area pseudo-zones have transition waypoint pairs and route locals;
- cross-area transitions have both direction waypoint pairs where schedules require round trips;
- routes are defined to final target zones, not only to area tags;
- known failure signatures can be mapped back to missing scripts, anchors, zones, or route locals;
- validation output clearly distinguishes setup errors from runtime movement/worker regressions.
