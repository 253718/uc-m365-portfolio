#### DAT Template — Teams Phone as-built

Purpose: provide a reusable, anonymized structure for documenting a delivered Microsoft Teams Phone configuration.

This template is intended for a small to medium Teams Phone scope using Direct Routing, operator-managed SBCaaS, Auto Attendants, Call Queues, Resource Accounts, dial plans and Shared Calling.

It is not a tenant-changing procedure. It is an architecture and delivery handover artefact.

##### Public anonymization note

This template must remain safe to publish or reuse publicly.

Replace or remove:

- client names
- real phone numbers
- tenant domains
- real UPNs
- names of people
- tenant IDs and object IDs
- operator circuit identifiers
- screenshots containing tenant data
- customer-specific command outputs
- private escalation paths

Use placeholders such as:

- `MODELE`
- `<TenantId>`
- `<ScheduleId>`
- `modele.example`
- `agent.principal@modele.example`
- `+XX999999999`

##### Objectives

This document describes the architecture implemented for a Teams Phone service.
It captures the delivered as-built state so that reviewers, support teams and future project teams can understand what exists and why.

The document should record:

- delivery context and scope
- PSTN connectivity model
- service-entry numbers
- Auto Attendants and Call Queues
- Resource Account mapping
- Direct Routing or Operator Connect boundary
- dial plan and normalization rules
- opening hours and holiday behavior
- outbound routing and caller ID model
- licensing assumptions
- acceptance tests and known limitations

##### Context and scope

Describe the business or service perimeter without exposing client-specific details.

Example scope:

- five service entry points
- one primary reception number
- Auto Attendants for greetings and schedules
- Call Queues for distribution to agents
- Direct Routing through an operator-managed SBCaaS boundary
- Shared Calling for outbound presentation through a service number

Example out of scope:

- contact center integration
- complex IVR tree
- customer-specific SBC administration
- studio-recorded audio files
- personal direct numbers for every user
- compliance recording unless explicitly included

##### Architecture summary

Document the retained architecture in plain language.

Example:

```text
Inbound PSTN call
 -> Operator / SBCaaS boundary
 -> Teams Phone service number
 -> Resource Account
 -> Auto Attendant
 -> Call Queue
 -> Agent or overflow destination
```

Recommended fields:

- tenant placeholder
- business domain placeholder
- technical domain placeholder
- PSTN model
- SBC / operator boundary
- SIP signaling port where relevant
- maximum concurrent sessions if known
- shared calling model if used

##### Service inventory

List every service entry point.

Minimum fields:

- service name
- public number or placeholder
- Auto Attendant name
- Call Queue name
- Resource Account for the Auto Attendant
- Resource Account for the Call Queue
- primary agent or target group
- overflow target

Example naming convention:

- `Phone - AA - Accueil`
- `Phone - CQ - Accueil`
- `phone_aa_accueil@modele.example`
- `phone_cq_accueil@modele.example`

##### Inbound call flows

For each major service entry point, document:

- called number
- PSTN model
- Resource Account target
- Auto Attendant greeting behavior
- schedule behavior
- holiday behavior
- Call Queue routing behavior
- timeout and overflow behavior

Acceptance should not rely on a single successful test call.
The expected behavior must be documented for open hours, closed hours, holidays and timeout cases.

##### Opening hours and holidays

Capture the schedule that was implemented.

Minimum fields:

- timezone
- weekday opening ranges
- closed days
- holiday schedule name
- holiday rule used
- known exceptions

For cross-border France / Monaco services, explicitly state whether closure is based on:

- France only
- Monaco only
- intersection of France and Monaco public holidays
- union of France and Monaco public holidays
- a customer-specific business calendar

##### Dial plan and normalization

Document normalization intent, not only the final object names.

Typical rules:

- local Monaco 8-digit numbers normalize to `+377...`
- French 10-digit numbers starting with `0` normalize to `+33...`
- E.164 numbers remain unchanged

Recommended fields:

- dial plan name
- rule name
- regex pattern
- translation
- example input
- example normalized output

##### Outbound routing and Shared Calling

If Shared Calling is used, record:

- user population
- Shared Calling policy
- voice routing policy applied to users
- Resource Account used for outbound presentation
- presented number
- emergency location requirement
- validation test result

Design note:
Users in a Shared Calling model should not receive personal LineURI assignments unless the design explicitly changes.

##### Licenses, accounts and security

Record the minimum license and account assumptions.

Recommended fields:

- Resource Account license status
- user voice license status
- Shared Calling eligibility
- emergency location requirement
- excluded accounts or known exceptions

Avoid publishing real user names or license screenshots.

##### Acceptance tests

Include a concise validation matrix.

Recommended tests:

- inbound call during open hours
- inbound call outside open hours
- holiday behavior
- Call Queue ringing behavior
- timeout and overflow
- outbound PSTN call
- caller ID presentation
- dial plan normalization
- Shared Calling behavior
- emergency calling configuration check where applicable and approved

##### Known limitations and open points

Document what was intentionally not delivered or still requires business decision.

Examples:

- audio files still using text-to-speech
- holiday schedule requiring annual maintenance
- no contact center reporting
- no complex IVR
- overflow destination subject to business validation

##### Handover summary

The DAT should point support toward the operational package.

At handover, support should receive:

- this as-built DAT
- DEX / RUN operations guide
- evidence pack or validation results
- escalation boundaries
- known limitations
- owner for routine changes

##### Acceptance criteria

This DAT is complete when:

- the delivered scope is clear
- all public service numbers are mapped to Teams objects
- AA/CQ/RA relationships are documented
- PSTN boundary ownership is explicit
- dial plan and outbound behavior are described
- acceptance tests are listed with expected results
- known limitations are visible
- RUN can understand the service without reverse-engineering the tenant
