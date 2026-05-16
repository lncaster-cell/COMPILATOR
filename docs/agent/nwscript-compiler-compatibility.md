# NWScript / NWN2 Compiler Compatibility Instructions for Codex

This document is repository-wide compiler and agent guidance. It is not a Daily Life subsystem specification, and it must not be treated as a request to edit `daily_life/` scripts unless the task explicitly targets them.

## Operating model

1. The release source of truth is the NWN2 EE stock toolset compiler used by this repository.
2. External compilers are secondary validation layers, not the canonical definition of NWN2 compatibility.
3. Prefer this gate order when available:
   - `stock toolset compiler` as the blocking release gate;
   - `Skywing / Advanced Script Compiler for NWN2` as a Windows/NWN2 diagnostic gate;
   - `nwnsc >= 1.1.5` as a CI/lint/regression gate, especially for Linux case-sensitivity and include-only checks;
   - legacy `nwnnsscomp` only as optional, non-blocking historical comparison in a 32-bit environment.
4. Never introduce code that only works because a newer external compiler accepts it if the stock NWN2 toolset compiler may reject it.

## Before changing code

1. Inspect the current repository state first. Do not rely on prior memory of files, branches, or helpers.
2. Read the exact script/include files involved in the task before editing.
3. Search for existing helpers, constants, local-key literals, and narrow includes before adding new symbols.
4. Keep the change scoped. Do not mix compiler compatibility work with unrelated gameplay, behavior, or Daily Life changes.
5. If adding a new include, justify why an existing narrow include or local helper is not enough.

## Safe NWScript subset

Keep generated code inside a conservative NWN2-compatible subset:

- file names should be lowercase;
- `#include` names must exactly match filesystem case;
- avoid duplicate include basenames across resource layers;
- use small one-purpose include files instead of broad umbrella includes;
- keep include dependencies one-directional and acyclic;
- use explicit prototypes for functions called before their implementation;
- include parameter names in prototypes;
- ensure every prototyped custom function has an implementation in the final include-expanded translation unit;
- keep true `const` declarations at file/global scope only;
- avoid compiler-specific extensions.

## Forbidden patterns

Do not introduce:

- local `const` declarations inside functions;
- parameter shadowing, especially declaring a local variable with the same name as a function parameter;
- `nwnsc`-only `#pragma` directives or script extensions;
- reference/output parameters such as `int &x`, `string &x`, or `object &x`;
- C/C++/C#/TypeScript constructs such as structs, classes, templates, generics, overloads, lambdas, namespaces, or inline functions;
- broad include-order hacks;
- mega includes that pull unrelated subsystems into every entry script;
- duplicate generic exported names such as `GetState`, `Init`, `Debug`, `Apply`, or `Process` without a project/subsystem prefix;
- large static data tables embedded in includes when a 2DA/data table or bounded lookup function is more appropriate.

## Parameter shadowing rule

Never reuse a parameter name for a local variable.

Bad:

```c
int MOD_GetAdjustedSkill(int nSkill, object oPC)
{
    int nSkill = GetSkillRank(nSkill, oPC);
    return nSkill;
}
```

Good:

```c
int MOD_GetAdjustedSkill(int nSkill, object oPC)
{
    int nResolvedSkill = GetSkillRank(nSkill, oPC);
    return nResolvedSkill;
}
```

This is a compatibility and codegen safety rule, not just style.

## Include rules

Treat NWScript compilation as one large translation unit after include expansion.

Recommended roles:

- `*_s_*.nss` — executable entry scripts with `void main()` or `int StartingConditional()`;
- `*_i_*.nss` — narrow implementation includes for one subsystem or responsibility;
- `*_c_*.nss` — tiny configuration includes only when configuration cannot live in data.

Rules:

1. Do not add an umbrella include merely for convenience.
2. Do not create include cycles.
3. Do not rely on include order to hide missing declarations.
4. Do not keep two different files with the same basename in different resource layers.
5. Be especially careful with config `const string` values because different compilers or resource search orders may select different include copies.

## Function declaration rules

NWScript compiles top-down. If a function is called before its implementation, add a prototype above the call.

Good:

```c
int MOD_CanRun(object oPC);

void main()
{
    object oPC = OBJECT_SELF;
    if (!MOD_CanRun(oPC))
    {
        return;
    }
}

int MOD_CanRun(object oPC)
{
    return GetIsObjectValid(oPC);
}
```

For mutual recursion, prototype both functions before either implementation.

Do not use prototypes as `extern` declarations. There is no separate linker step for custom NWScript functions; the implementation must exist in the final expanded script.

## Constants and configuration

1. Do not use local `const` inside functions.
2. Use global `const` only for stable, shared values that are safe for the target compiler/include order.
3. For cross-include local-key contracts that trigger const-order issues, prefer a compiler-safe global variable while preserving the literal value.
4. Never rename local-key literal strings unless the task explicitly requires a migration.
5. If an environment-specific string differs between module/temp/hak/override/builder setup, do not hide that difference behind the same include basename.

Preferred local constant substitute:

```c
const string MOD_S_TAG_CHEST_01 = "chest_01";

void main()
{
    string sTag = MOD_S_TAG_CHEST_01;
}
```

If `const` ordering breaks across includes, preserve the literal and use a plain global of the same type only where needed for compiler compatibility.

## Naming rules

1. Use subsystem/project prefixes for exported symbols.
2. Avoid generic names that can collide across includes.
3. Search before adding a new public helper.
4. Prefer names that reveal the owning subsystem and responsibility.

Examples:

- good: `MOD_CountItemsByTag`, `DL_RuntimeCanMove`, `NPC_FindCachedRecord`;
- bad: `GetState`, `Init`, `Debug`, `Apply`, `Run`.

## Large include and symbol-pressure rules

The stock-style compiler has practical identifier limits. To reduce false and cascading errors:

1. Do not place large data tables in `.nss` includes unless there is no better option.
2. Split unrelated helpers into narrow include files.
3. Avoid transitively including whole subsystems from small entry scripts.
4. Prefer 2DA/data files or bounded lookup functions for large tables.
5. Fix the first root include/symbol error before chasing repeated downstream diagnostics.

## CI and compile workflow

Every code PR must compile.

Expected workflow after a code change:

1. Run the repository's current compile/check command or workflow.
2. If the failure is compiler-related, identify the first root cause before editing many files.
3. Fix compatibility errors in the same branch.
4. Do not delete behavior merely to silence compiler output.
5. Report the compiler/toolchain used and whether the check passed.

When a multi-compiler matrix exists, prefer:

- stock compiler as blocking for release;
- Skywing/ASC as diagnostic/blocking after project validation;
- `nwnsc >= 1.1.5` for Linux, Docker, include-only, and cross-platform regression checks.

## Codex behavior requirements

1. Keep edits minimal and localized.
2. Reuse existing helpers before creating new ones.
3. Do not introduce a new include without explaining the need.
4. Do not mix unrelated refactors into a compiler fix.
5. Do not move or rewrite Daily Life files while applying these general compiler instructions unless the task explicitly requires Daily Life changes.
6. When reporting completion, list changed files, compile/check command, result, and any remaining first root error.
7. Do not claim success unless the relevant compile/check workflow passes or clearly state that it was not run.
