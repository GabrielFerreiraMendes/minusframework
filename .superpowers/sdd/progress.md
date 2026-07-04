Task 1: complete (commits bd8edd7..0bd0235, review clean after fix)
Task 2: complete (commit a6914d0, build passes, brand CSS applied)
---
Phase 1A: Security (.gitignore + key regeneration) — complete
Phase 1B: Compilation blockers investigation — complete (circular dep fixed in Task 1, search paths OK, 2 {$R *.res} added)
Phase 1C: Docs fixes (duplicates, [Campo]→[Coluna]) — complete
Phase 1D: Config fixes (Docusaurus warning, .gitignore) — complete
Task 1: Circular dependency fix — complete (callback pattern)
Task 2: .dproj search paths — complete (no changes needed, paths already correct)
Task 3: {$R *.res} — complete (added to MinusTelemetry_Runtime.dpk and MinusMessaging_Design.dpk)
Task 4: release.ps1 — complete (created)
Task 5: .gitignore standardization — complete (all 9 submodules)
Task 6: CI/CD pipeline — complete (release-prep.yml created)
Task 7: Docs review — complete (clean, one typo fixed)
Task 8: Installer validation — complete (well-structured, OK)
Task 9: Security audit — complete (PASS, no secrets found)
Task 10: CLI readiness — complete (10 discrepancies found, all fixed: [Campo]→[Coluna] in source, docs aligned, non-existent flags removed)
