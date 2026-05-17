# Debugging Protocol

This protocol is for behavior bugs, especially Daily Life/NPC movement issues.

## General rule

Debug from the existing pipeline outward. Do not start by adding new global systems, broad scans, or duplicate finalizer logic.

## Required first pass

For any runtime behavior bug, identify:

1. affected subsystem;
2. actor/object tag;
3. area/location;
4. expected state;
5. observed state;
6. latest relevant trace/log/local variables;
7. recent PRs or worklog entries touching the same path.

## Daily Life movement investigation order

For NPC movement or schedule bugs, inspect in this order:

1. **Area ownership / registry**
   - Is the NPC registered in the current area?
   - Does the area-level dense registry still point to the same NPC?
   - Avoid broad area scans unless it is a bounded recovery path.

2. **Directive state**
   - Current directive type.
   - Whether the directive should be PUBLIC, SOCIAL, WORK, SLEEP, transition, or idle.
   - Whether same-directive fast path is valid.

3. **Move job state**
   - move owner;
   - move result;
   - move target;
   - move ticket/version;
   - move radius;
   - whether the canonical target resolves.

4. **Reach verdict**
   - Use the canonical reached helper/path when available.
   - Do not duplicate distance/reach checks without a clear reason.
   - Check raw distance and normalized radius.

5. **Engine action state**
   - `GetCurrentAction`;
   - whether the NPC still has `ACTION_MOVETOPOINT`;
   - whether engine action state conflicts with canonical reached state.

6. **Focus state**
   - focus status;
   - focus target;
   - whether focus is still `moving_to_anchor` after the NPC reached the target.

7. **Finalizer path**
   - whether `DL_FinalizeReachedDirectiveMoveJob` or equivalent path ran;
   - whether it returned/recorded `target_not_reached` despite canonical reached state;
   - whether a regression changed `reached` back to `running`.

8. **Worker touch path**
   - whether the area worker saw the NPC;
   - whether warm/budget/round-robin throttles skipped it;
   - whether critical stale-reached bypass is expected;
   - whether the real `DL_WorkerTouchNpc -> directive/apply/finalizer` pipeline was used.

9. **Diagnostics**
   - BSMITH trace stage;
   - contradiction/classify lines;
   - explicit skip reasons;
   - invariant debug locals.

## Current Daily Life movement invariants

Preserve these unless the task explicitly replaces them with a documented better invariant:

1. One canonical reached verdict for move jobs.
2. A physically/canonically reached NPC should not stay indefinitely in `move_result == running` without `ACTION_MOVETOPOINT`.
3. Stale reached registered NPCs should be routed back through the real worker/directive/finalizer pipeline.
4. Emergency correction paths must be bounded and diagnosable.
5. No broad polling loop should replace the engine action queue.
6. BSMITH trace fields are active debugging infrastructure and must not be removed casually.

## Good fix shape

A good Daily Life bug fix usually:

- touches one narrow owner file or a small set of directly related includes;
- reuses an existing helper;
- records a clear trace/debug reason;
- preserves local-key literal contracts;
- updates `docs/AGENT_WORKLOG.md`;
- gives the user one manual runtime validation scenario.

## Bad fix shape

Avoid fixes that:

- add heartbeat/polling behavior per NPC;
- add unbounded area scans in hot paths;
- bypass the canonical directive/finalizer path;
- duplicate movement reach logic in a new location;
- delete diagnostics because they look noisy;
- rename local-key strings without a migration plan;
- change include order broadly to silence one local error.

## Manual validation prompt for the user

When reporting a Daily Life movement fix, ask the user to validate with a concrete scenario, for example:

```text
Manual validation needed:
1. Load the affected area.
2. Observe NPC `<tag>` until it receives the target directive.
3. Confirm it reaches the anchor and exits `move_result=running`.
4. Capture BSMITH_TRACE lines if it remains stuck.
```
