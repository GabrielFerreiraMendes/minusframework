# Task 1: Circular Dependency Core ↔ FeatureFlags — Fix Report

## Status: DONE

## Summary

Resolved circular dependency where `Core\MF.Licensing.pas` directly referenced `FeatureFlags\MF.FeatureFlags.Licensing.pas`, violating the intended dependency direction (FeatureFlags → Core).

## Changes Made

### 1. `Core\Source\Core\MF.Licensing.pas`

- **Interface section** (lines 51-57): Added callback type declaration `TSincronizarTierCallback`, global variable `FSincronizarTierCallback`, and forward declaration of `RegistrarSincronizacaoTier`.
- **Implementation uses** (line 62): Removed `MF.FeatureFlags.Licensing` from the uses clause (now only `MF.LicenseManager`).
- **Implementation** (lines 64-67): Added full implementation of `RegistrarSincronizacaoTier` that stores the callback.
- **`SincronizarFeatureFlags` method** (lines 250-251): Replaced `MF.FeatureFlags.Licensing.SincronizarTierLicenca(LTier)` with `if Assigned(FSincronizarTierCallback) then FSincronizarTierCallback(LTier)`.

### 2. `FeatureFlags\Source\FeatureFlags\MF.FeatureFlags.Licensing.pas`

- Replaced entire file. Removed `SincronizarTierLicenca` procedure.
- Uses `MF.Licensing` and `MF.FeatureFlags`.
- Registers `TFeatureFlags.DefinirTier` as the callback via `RegistrarSincronizacaoTier` in the `initialization` section.

## Verification

Both files are syntactically valid Pascal:

- **`MF.Licensing.pas`**: 358 lines. Units: uses `MF.FeatureFlags.Types` in interface (for `TTierLicenca`), `MF.LicenseManager` in implementation. No reference to FeatureFlags licensing unit. The callback pattern is type-safe — `TSincronizarTierCallback` matches the signature of `TFeatureFlags.DefinirTier`.

- **`MF.FeatureFlags.Licensing.pas`**: 14 lines. Uses `MF.Licensing` (for callback registration) and `MF.FeatureFlags` (for `TFeatureFlags`). The initialization section wires the callback before any licensing code runs.

## Concerns

- **Ordering**: `initialization` sections run in unit dependency order. Since `MF.Licensing` does not depend on `MF.FeatureFlags.Licensing`, Delphi will run `RegistrarSincronizacaoTier` (FeatureFlags init) before `TLicenciamento.Verificar` (Core) is first called. This is correct — the callback is registered before it's needed.
- **Thread safety**: If licensing is verified from multiple threads concurrently, `FSincronizarTierCallback` is only written once during initialization (single-threaded), so reads via `Assigned` + call are safe. No change from original behavior.
