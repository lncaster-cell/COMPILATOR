# Agent Instructions

This repository contains Neverwinter Nights 2 / NWScript code. Compile compatibility is mandatory.

## Primary rule

Keep the code compiling with the existing NWScript compiler. Performance improvements, cleanup, and refactors are allowed only when they preserve compile compatibility and runtime behavior.

## Before editing

1. Inspect the current repository state before making changes.
2. Read the relevant files first.
3. Search for existing helpers, constants, contracts, and local-key literals before adding new ones.
4. Do not rely on memory from previous tasks. The repository may have changed.

## Forbidden NWScript-incompatible patterns

Do not introduce:

- reference/output parameters such as `int &x`, `string &x`, `object &x`
- `#define` macro aliases
- local `const` declarations inside functions
- structs, classes, templates, generics, overloaded functions, or unsupported C/C++/C#/TypeScript syntax
- broad include-order hacks
- function bodies in compile-order declaration includes
- default arguments in compile-order declaration includes

## Constants and local-key contracts

Local variable names such as `dl_npc_transition_target`, `dl_area_pass_snapshot_tick`, and `dl_social_reserved_wp` are runtime state contracts.

Rules:

1. Do not rename literal local-key string values unless the task explicitly requires a migration.
2. Before adding any new key, search for both the symbolic name and the literal string value.
3. Do not create duplicate contract constants.
4. Be careful with `const string` globals. This compiler can report `Constant must be initialized before it may be referenced` when const globals are referenced across include-order boundaries.
5. For cross-include local-key names that trigger const-order errors, prefer compiler-safe globals:

```c
string KEY = "same_literal_key";
```

Do not change the literal key value.

## Include-order rules

1. Do not add broad global forward-declaration includes unless absolutely necessary.
2. Prefer local forward declarations inside the specific include that needs them.
3. Keep compile-order helper includes declaration-only:
   - no constants
   - no function bodies
   - no default args
   - no domain implementation
4. Do not place prototypes before large const blocks if it can trigger const-order errors.

## Compatibility patterns

Instead of output/reference parameters:

- return one value directly
- split the logic into helper functions
- store temporary results in module/object locals only when appropriate

Instead of `#define`:

- use `const string` / `const int` only when safe
- use global `string` / `int` for cross-include compatibility when const-order errors occur

Instead of local `const` inside functions:

- use local `string` / `int` variables
- or move true constants to file scope when safe

## Refactor and optimization rules

1. Keep refactors small and focused.
2. Do not mix architecture rewrites with compile-error fixes.
3. Do not rename contracts, local-key literals, or public helper APIs during performance cleanup unless the task explicitly requires it.
4. Reuse existing helpers before adding new ones.
5. Do not create pass-through wrappers unless they are required for compatibility.

## Performance rules

1. Do not add repeated area scans in hot paths.
2. Prefer existing registry, cache, snapshot, and index mechanisms.
3. Do not replace dense registries with `GetFirstObjectInArea` loops unless it is a bounded fallback or recovery path.
4. Any fallback scan must have a clear budget/cap.
5. Avoid runtime tag searches in hot paths when cached or indexed lookup is available.

## Compile workflow

Every PR must compile.

After any code change:

1. Run the repository's existing compile/check workflow.
2. If compilation fails, fix the compile errors in the same branch.
3. Fix the first root cause first, not every repeated downstream error.
4. Prefer minimal compatibility patches.
5. Do not silence errors by deleting behavior.

## Documentation

If a change modifies architecture, contracts, setup rules, builder-facing workflow, or runtime behavior, update the relevant documentation in the same PR.

Do not update documentation for pure mechanical compile fixes unless the contract changed.

## Final report requirements

When reporting completion, include:

- changed files
- whether compilation/check was run
- compile result
- remaining first root errors, if any

Do not claim success unless the compile/check workflow passes.
