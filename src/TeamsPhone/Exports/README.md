# Teams Phone / Exports

This folder contains feed-driven output generation for Teams Phone audit and DAT snippet artefacts.

It produces technical annex content and review artefacts rather than a full architecture dossier.

## Main entry point

```powershell
./src/TeamsPhone/Exports/Invoke-TeamsPhoneDatExport.ps1 -FeedPath ./tests/Fixtures/feed-sample -RunId demo001
```

## Output

The command writes a run under `./out/audit/teamsphone-<RunId>/` and generates `DAT-snippets.md` as technical annex content plus supporting artefacts.
