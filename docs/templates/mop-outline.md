### Method of Procedure (MOP) — Outline

Concise structure to document a Method of Procedure for Teams Phone delivery activities.

#### Purpose

Provide a controlled execution structure for planned changes without exposing tenant-changing procedures in the public repository.

This public template describes the expected shape of a MOP. Customer-specific commands, credentials, tenant identifiers and operational escalation paths must remain private.

#### Core sections

- Change summary
- Scope
- Preconditions
- Roles and responsibilities
- Risk and mitigation
- Implementation steps
- Validation steps
- Evidence capture
- Rollback triggers
- Rollback steps
- Communications
- Post-change actions
- Handover notes

#### Preconditions

- change window approved
- impacted users and services identified
- rollback owner confirmed
- validation owner confirmed
- evidence location confirmed
- support and operator boundaries understood

#### Execution principles

- every step has an owner
- every validation has an expected result
- rollback triggers are defined before execution
- evidence capture is part of the procedure, not an afterthought
- public versions stay generic and read-only

#### Evidence expectations

- timestamped execution log
- validation results
- screenshots or exports where appropriate
- incident or deviation notes
- rollback decision if applicable
- final go/no-go result

#### Acceptance criteria

- the MOP can be reviewed before the change window
- execution and validation steps are separated
- rollback triggers are explicit
- evidence capture is included
- private tenant-changing details are not published
