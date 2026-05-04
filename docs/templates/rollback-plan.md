### Rollback Plan

Rollback strategy to safely revert a Teams Phone cutover or migration if critical issues are encountered.

#### Purpose

Define before the change window what conditions justify rollback, who decides, what scope is reverted and how the service is validated afterward.

#### Trigger examples

- widespread inbound or outbound call failures
- call routing instability impacting business operations
- emergency calling validation failure
- service-entry points unreachable
- unacceptable caller ID behavior
- unresolved operator / SBC issue within the agreed window
- support unable to triage the failure within the cutover window

#### Rollback boundaries

Rollback must be defined per migration wave or service scope.

A rollback plan should identify:

- impacted users
- impacted service numbers
- impacted Auto Attendants and Call Queues
- PSTN routing dependency
- operator involvement, if any
- validation tests after rollback

#### Decision process

1. Identify the critical symptom.
2. Confirm whether it matches a rollback trigger.
3. Validate whether mitigation is available within the change window.
4. Obtain decision from the rollback owner.
5. Execute the private rollback procedure.
6. Validate restored service behavior.
7. Capture evidence and communicate outcome.

#### Evidence expectations

- rollback trigger invoked
- decision owner
- rollback start and end time
- scope reverted
- validation results after rollback
- residual issues
- follow-up actions

#### Acceptance criteria

- rollback triggers are known before cutover
- rollback ownership is explicit
- restored service paths are validated
- evidence is captured
- follow-up actions are documented for the next attempt
