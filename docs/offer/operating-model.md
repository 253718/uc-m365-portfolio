## Operating model

Purpose: define how a Teams Voice migration service operates once it becomes repeatable.

This operating model assumes a public read-only portfolio that supports review, evidence, and handover without claiming to be a full architecture dossier.

### What this enables

- predictable migrations
- fast triage during hypercare
- clean handover to RUN
- explicit operator / tenant / network boundaries

### How the 3-repo model fits

- `uc-m365-ops-feed` -> factual tenant collection
- `uc-m365-portfolio` -> public evidence, DAT snippets, review outputs, and handover artefacts
- `uc-m365-ops-change` -> private controlled changes

