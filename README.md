# WorldSimulator Skeleton

This repository now includes a minimal C#/.NET/WPF solution skeleton for the external world simulator.

## Solution layout

- `WorldSimulator.sln`
- `src/WorldSimulator.App` — WPF desktop app (UI shell only)
- `src/WorldSimulator.Core` — future simulation logic (placeholder only)
- `src/WorldSimulator.Persistence` — future save/load layer (placeholder only)

## Open in IDE

1. Open `WorldSimulator.sln` in Visual Studio 2022+ or JetBrains Rider.
2. Set `WorldSimulator.App` as startup project if needed.

## Build

```bash
dotnet build WorldSimulator.sln
```

## Run

```bash
dotnet run --project src/WorldSimulator.App/WorldSimulator.App.csproj
```

Current behavior: starts a WPF window with placeholder text. No simulation logic, no save/load implementation.
