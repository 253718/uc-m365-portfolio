#### DEX Template — Teams Phone RUN operations

Purpose: provide a reusable, anonymized operational reference for maintaining a delivered Teams Phone service after handover.

This document complements the as-built DAT. The DAT explains what was delivered. The DEX explains how to operate it safely over time.

It is not a public tenant-changing runbook. Customer-specific commands, object IDs, escalation contacts and operational evidence must remain private.

##### Public anonymization note

Before publishing or reusing publicly, remove or replace:

- client names
- tenant IDs
- real phone numbers
- SIP trunk identifiers
- real UPNs
- names of people
- object IDs and schedule IDs
- screenshots containing tenant data
- internal escalation paths
- command output from production tenants

Use placeholders such as:

- `MODELE`
- `<TenantId>`
- `<ScheduleId>`
- `agent.principal@modele.example`
- `phone_aa_accueil@modele.example`
- `+XX999999999`

##### Objectives

This DEX describes how to operate a Teams Phone configuration over time.

It should provide:

- roles and responsibilities
- operational inventory
- routine checks
- safe change guidance
- validation steps after change
- incident triage guidance
- rollback principles
- periodic maintenance expectations
- RUN checklist

##### Roles and responsibilities

Define who owns each operational activity.

Minimum roles:

- Teams Phone operator or administrator
- project or service owner
- customer business validator
- operator / SBC provider
- support team

Make the boundary explicit:

- tenant configuration
- operator-managed SBCaaS or Operator Connect boundary
- customer network and endpoints
- recording vendor if applicable

##### Operational inventory

Maintain an inventory that support can read quickly.

Minimum fields:

- service name
- service number
- Auto Attendant
- Call Queue
- Resource Account
- agent or target group
- overflow target
- schedule
- holiday calendar
- Shared Calling policy where applicable

This inventory should match the as-built DAT.

##### Operating principles

Recommended principles:

- control the existing state before changing it
- export or capture relevant objects before structural changes
- do not mix unrelated changes in the same operation
- separate message changes, schedule changes, queue membership changes and routing changes
- document every change in a ticket or change log
- validate the call path after change
- keep the operator boundary explicit during incident triage

##### Connection and baseline checks

The private operational version may contain tenant-specific commands.

The public version should describe the checks generically:

- connect to the approved administration surface
- confirm tenant identity
- confirm PSTN gateway or operator status where visible
- confirm voice routing policies
- confirm dial plans
- confirm service numbers and Resource Accounts
- confirm Auto Attendants and Call Queues

Do not publish credentials, tenant IDs or production command output.

##### Routine checks

Recommended routine checks:

- service numbers are assigned and active
- Resource Accounts exist and are licensed where required
- Auto Attendants exist and point to the expected Call Queues
- Call Queues contain the expected agents or groups
- timeout and overflow targets match the documented design
- schedules and holidays are still valid
- Shared Calling policies are still assigned correctly
- dial plan normalization still matches the expected examples

##### Managing greetings and messages

Message changes should be treated as standard changes when the destination and routing logic do not change.

Recommended process:

- capture current message
- validate new wording with the business owner
- update the message through the approved administration path
- test during the relevant schedule condition
- record the change in the ticket

Avoid changing Call Queue routing when the request only concerns an Auto Attendant greeting.

##### Managing opening hours

Schedule changes must be business-approved before implementation.

Recommended process:

- confirm requested hours and timezone
- check whether holidays or exceptions are affected
- update the schedule through the approved administration path
- validate open-hours and closed-hours behavior
- document the result

##### Managing holidays

Holiday schedules require ownership.

Recommended process:

- identify the business calendar rule
- create or update the annual schedule
- confirm association with the relevant Auto Attendants
- validate holiday behavior through a controlled test
- record the schedule name and owner

For France / Monaco contexts, document whether the rule is an intersection, union or customer-specific calendar.

##### Managing Call Queues

Standard queue changes include:

- adding an agent
- replacing an agent
- changing timeout value
- changing overflow destination
- validating routing method

Recommended validation:

- queue membership visible
- inbound test reaches the expected agent or group
- timeout routes to the expected target
- no loop is introduced

##### Managing Shared Calling

When Shared Calling is used, support must understand the model.

Recommended checks:

- user is voice-enabled
- user has the expected dial plan
- user has the Shared Calling policy
- user has the voice routing policy with no direct PSTN usages where required by design
- Resource Account has the service number
- emergency location requirement is satisfied
- outbound caller ID matches the expected service number

Do not assign personal LineURI to Shared Calling users unless the design is intentionally changed.

##### Managing dial plans

Dial plan changes affect user behavior and should be validated with examples.

Recommended examples:

- local Monaco number normalization
- French national number normalization
- E.164 number handling
- international prefix handling if in scope

Document expected input and normalized output.

##### Backup or evidence capture before change

Before structural changes, capture enough information to support rollback or diagnosis.

Recommended captures:

- Auto Attendant configuration summary
- Call Queue configuration summary
- Resource Account mapping
- policy assignments
- dial plan rules
- affected service numbers
- ticket or change reference

Public templates should not include production exports.

##### Tests after change

Every change should end with a concise validation set.

Recommended tests:

- inbound open-hours call
- inbound closed-hours call if schedule changed
- holiday behavior if calendar changed
- queue membership and ringing
- timeout and overflow
- outbound calling if Shared Calling or routing changed
- caller ID validation if outbound behavior changed
- dial plan normalization if normalization changed

##### Incident triage

Use symptom localization before escalation.

Suggested first-line questions:

- Is the issue inbound, outbound, internal Teams-to-Teams, or device-specific?
- Is one service number affected or all PSTN calls?
- Is the issue linked to a schedule or holiday condition?
- Is the affected object an Auto Attendant, Call Queue, Resource Account, user, device, policy or operator boundary?
- Does Teams-to-Teams calling work?
- Does the issue require operator / SBC escalation?

##### Known incident patterns

Document recurring symptoms and likely boundaries.

Examples:

- message change not audible immediately: propagation delay
- queue agents not ringing: membership, presence routing or device state
- outbound caller ID wrong: Shared Calling policy or operator treatment
- inbound PSTN failure: operator / SBC / number assignment boundary
- dialed number not normalized: dial plan assignment or rule issue

##### Rollback principles

Rollback depends on the change type.

Examples:

- message change: restore previous text or audio
- schedule change: restore previous schedule values
- queue membership change: restore previous agent list
- overflow change: restore previous target
- policy assignment change: reapply previous policy

Rollback triggers should be defined before the change window for risky changes.

##### Periodic maintenance

Recommended maintenance rhythm:

- monthly: verify critical service numbers, AA/CQ objects, agents and overflow
- after business change: verify messages, hours and call handling
- annually: refresh holiday schedules
- after user additions: verify license, voice enablement, policies and dial plan
- after incident: review evidence and update known issue notes if needed

##### RUN checklist

A minimal checklist should confirm:

- correct tenant context
- service numbers active
- Auto Attendants present
- Call Queues present
- Resource Accounts mapped
- agents or groups assigned
- timeout and overflow documented
- messages present
- schedules present
- holiday calendar present
- Shared Calling policy assigned where applicable
- dial plan normalization validated
- operator boundary known
- tests documented

##### Acceptance criteria

This DEX is complete when:

- support can identify delivered service objects
- routine checks are repeatable
- standard changes are described safely
- validation after change is explicit
- incident triage starts with boundary localization
- rollback principles are documented
- periodic maintenance ownership is visible
- the build engineer is no longer required for basic operations
