### Cutover Runbook

Operational steps required to execute a Teams Phone cutover in a controlled and reversible manner.

#### Purpose

Coordinate the cutover window so that routing, users, call flows, evidence capture and support readiness are handled as one controlled event.

#### Preconditions

- migration plan approved
- MOP reviewed
- rollback plan available
- impacted users and services identified
- monitoring and escalation contacts confirmed
- exports and evidence baseline completed
- business validation owner available
- RUN support notified

#### Cutover sequence

1. Confirm go/no-go decision.
2. Freeze non-essential changes on the impacted scope.
3. Execute the private implementation MOP.
4. Validate user calling scenarios.
5. Validate inbound and outbound PSTN paths.
6. Validate Auto Attendants and Call Queues.
7. Validate priority numbers and service-entry points.
8. Capture evidence and deviations.
9. Confirm business validation.
10. Decide go-live, rollback or extended monitoring.

#### Validation examples

- outbound national call
- outbound international call, if in scope
- inbound call to user number
- inbound call to service number
- Auto Attendant routing
- Call Queue ringing and answer behavior
- emergency calling validation where applicable and approved
- caller ID presentation

#### Evidence expectations

- cutover timestamp
- executed scope
- validation matrix
- evidence pack reference
- incidents or deviations
- rollback decision record
- final go/no-go result

#### Acceptance criteria

- critical call paths are validated
- known issues are documented
- rollback decision is explicit
- support receives the cutover result and evidence location
- the service can enter hypercare with a known baseline
