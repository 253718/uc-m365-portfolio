# Evidence Packs

This folder packages a feed-driven run into an evidence bundle.

## Main entry point

```powershell
./src/Compliance/EvidencePacks/Invoke-TeamsPhoneEvidencePack.ps1 -FeedPath ./tests/Fixtures/feed-sample -RunId demo001
```

## Output

The command writes:

- `./out/evidence/teamsphone-evidence-<RunId>/`
- `./out/evidence/teamsphone-evidence-<RunId>.zip`

Start with `SUMMARY.md` and the evidence ZIP.
