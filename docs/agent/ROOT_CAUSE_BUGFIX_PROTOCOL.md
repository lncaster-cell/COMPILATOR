# Root-Cause Bugfix Protocol

This protocol is mandatory for non-trivial runtime bugs, recurring bugs, Daily Life/NPC bugs, and any issue that has already consumed multiple PRs.

The goal is to stop symptom-chasing. Agents must prove the failing layer before changing behavior.

## Core rule

Do not start with a patch.

Start with a failure map:

```text
Observed state
→ expected state
→ pipeline stage where expected state first diverges
→ evidence for that divergence
→ smallest owner subsystem
→ minimal patch or diagnostic needed
```

If the failing layer is not proven, the next PR should usually be diagnostic/investigation-focused, not another broad behavior fix.

## Required bugfix phases

### 1. Stabilize the bug narrative

Before editing code, identify or create a GitHub issue.

The issue must contain:

- observed behavior;
- expected behavior;
- affected NPC/tag/area if known;
- latest trace/debug locals if available;
- recent related PRs;
- acceptance criteria;
- manual validation scenario.

For recurring bugs, do not scatter the narrative across chat messages and PR descriptions. Keep the GitHub issue as the source of truth.

### 2. Build the pipeline map

For Daily Life/NPC bugs, map the expected path explicitly.

Example:

```text
schedule slot changes
→ directive resolves
→ old directive state is preempted
→ target anchor resolves
→ move job starts
→ engine action moves NPC
→ reached verdict becomes true
→ finalizer closes move
→ stable focus/sleep/work/social state is published
```

Then identify the first stage that fails.

Do not patch later stages until the first failing stage is known.

### 3. Separate symptoms from root cause

A symptom is what we see:

- NPC stands still.
- `move_result` stays `running`.
- focus remains `moving_to_anchor`.
- worker skip reason appears.
- NPC does not go home.

A root cause is the first incorrect state transition:

- directive did not change;
- old focus state blocked new directive;
- target did not resolve;
- movement job was never created;
- registry owner differed from physical area;
- worker did not touch the NPC;
- finalizer returned `target_not_reached` despite canonical reached;
- sleep state was published before actual arrival.

Agents must state which one they are fixing.

### 4. Evidence before modification

Before any behavior-changing patch, the agent must record at least one of:

- trace line proving the failing state;
- local variable combination proving the failing state;
- code-path proof showing an impossible/incorrect transition;
- reproduction note from the issue;
- comparison with a recent PR that introduced/changed the failing path.

If none exists, add focused diagnostics first.

### 5. Choose the owner subsystem

Patch the smallest owner subsystem.

Examples:

| Root cause | Likely owner |
|---|---|
| schedule chooses wrong directive | schedule/directive resolver |
| directive changes but old state blocks it | `dl_res_inc.nss` / directive preemption |
| target anchor is missing | setup/cache/anchor resolver |
| movement job not created | move bridge / directive executor |
| movement reaches but not finalized | move job/finalizer pipeline |
| NPC in wrong registry | registry/transition handoff |
| worker never touches NPC | worker lifecycle |
| sleep state published too early | sleep executor / terminal state gate |

Do not fix an owner mismatch by adding emergency logic elsewhere.

### 6. Prefer diagnostic PRs when uncertain

If there have already been multiple failed fixes, the next PR should usually:

- narrow the trace;
- capture the exact first divergence;
- reduce noise;
- add an invariant assertion/debug local;
- avoid behavior changes unless the root cause is proven.

### 7. Minimal patch rule

Once the root cause is proven:

- change the smallest necessary code path;
- reuse existing helpers;
- preserve existing runtime contracts;
- do not add duplicate pipelines;
- do not add broad scans or polling;
- do not delete active diagnostics unless replacing them with better targeted diagnostics.

### 8. Regression awareness

For bugs touched by many recent PRs, inspect the recent sequence before editing.

The PR body must answer:

- Which recent PRs are relevant?
- Which invariant did they add or change?
- Is the current patch preserving or replacing that invariant?
- Could this fix reintroduce a bug those PRs were preventing?

### 9. Manual validation plan

Every runtime bug PR must include a manual validation script for the user.

Example:

```text
1. Compile branch manually.
2. Load area X.
3. Enable BSMITH trace if needed.
4. Observe NPC tag Y from schedule slot A to slot B.
5. Confirm exact expected state transition.
6. If failure remains, paste these trace keys into issue #NNN.
```

### 10. Worklog and issue update

After non-trivial bug work:

- update `docs/AGENT_WORKLOG.md`;
- comment on the related issue with the current hypothesis/result;
- link the PR to the issue;
- state whether root cause was proven or only narrowed.

## Required PR sections for root-cause bugfixes

For non-trivial bugs, the PR body must include:

```md
## Root-cause analysis

Observed symptom:
First failing pipeline stage:
Evidence:
Why this is root cause, not symptom:

## Fix shape

Owner subsystem:
Why this subsystem owns the fix:
What was intentionally not changed:

## Regression protection

Relevant recent PRs:
Invariants preserved:
Diagnostics preserved/added:

## Manual validation

Steps:
Expected result:
Failure data to capture:
```

## Red flags

Stop and reassess if the proposed fix:

- adds another emergency bypass to make progress happen;
- patches the final visible symptom without proving why the earlier state failed;
- modifies several unrelated subsystems at once;
- removes diagnostics during an active bug;
- adds a broad scan/polling loop to hide missed ownership;
- claims success without user runtime validation;
- describes the change as “simplify” but removes a path whose replacement has not been validated;
- fixes HOT area behavior by breaking WARM/FROZEN/transition behavior.

## Assistant behavior rule

When the user reports a bug, the assistant should behave like a repository maintainer, not just a code generator:

1. Identify or create the tracking issue.
2. Check related open PRs.
3. Decide whether the current PR is a candidate fix, diagnostic PR, or risky rewrite.
4. Give the user a concrete compile/test path.
5. Preserve findings in issue/worklog/PR comments.
6. Only then ask an agent to patch code.

## Current priority for this repository

Daily Life bugs must be treated as pipeline bugs unless proven otherwise.

The default investigation question is:

```text
At which exact pipeline stage did the NPC stop transitioning from expected state to next expected state?
```

Not:

```text
How do we force the NPC to move again?
```
