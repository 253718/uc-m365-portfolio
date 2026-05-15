### DAT Template — Teams Phone receptionist flow

Purpose: provide a reusable, anonymized structure for a Teams Phone receptionist flow based on Auto Attendant, Call Queue, Resource Accounts and shared physical Teams phone endpoints.

This template is intentionally generic. It must not contain client names, real numbers, tenant domains, real UPNs, screenshots, private escalation paths or customer-specific PowerShell output.

#### Scope

In scope:

- Auto Attendant service entry design
- Call Queue distribution model
- Resource Accounts for service objects
- shared endpoint / Common Area Phone accounts
- physical Teams phone mapping
- minimal Common Area Phone interface through Teams IP Phone Policy
- timeout, overflow and closed-hours behavior
- acceptance tests and RUN handover notes

Out of scope:

- full SBC or operator-side configuration
- tenant-changing implementation runbook
- contact center integration
- compliance recording design unless explicitly added
- customer-specific operational procedures

#### Reference flow

```text
Inbound PSTN call
  -> Reception Auto Attendant
  -> open-hours routing
  -> Reception Call Queue
  -> shared Teams phone endpoints
  -> timeout / no-answer / overflow target
```

#### Object model

| Object type | Example name | Example account | Purpose |
| --- | --- | --- | --- |
| Auto Attendant | AA-RECEPTION | `aa-reception@contoso.example` | Public reception entry point |
| Call Queue | CQ-RECEPTION | `cq-reception@contoso.example` | Distribution to reception endpoints |
| Call Queue | CQ-OVERFLOW | `cq-overflow@contoso.example` | Optional overflow handling |
| Shared endpoint | Reception desk 01 | `cap-reception-01@contoso.example` | Physical Teams phone sign-in |
| Shared endpoint | Reception desk 02 | `cap-reception-02@contoso.example` | Physical Teams phone sign-in |

#### Design principles

- The public number represents the reception service, not an individual phone.
- Auto Attendants and Call Queues use Resource Accounts.
- Physical Teams phones use dedicated shared endpoint accounts.
- Shared endpoint accounts receive a Teams IP Phone Policy configured with `SignInMode CommonAreaPhoneSignIn` to provide the minimal Common Area Phone interface on physical Teams phones.
- Shared endpoint accounts are added as Call Queue agents.
- Shared endpoint accounts do not receive direct public numbers by default.
- Timeout, overflow and closed-hours behavior are explicit and tested.
- RUN support receives a clear object-to-service-to-device mapping.

#### Configuration summary

##### Auto Attendant

| Parameter | Target value |
| --- | --- |
| Name | AA-RECEPTION |
| Resource Account | `aa-reception@contoso.example` |
| Public number | +XX X XX XX XX XX |
| Open-hours action | Transfer to CQ-RECEPTION |
| Closed-hours action | Message or validated destination |
| Holiday behavior | Defined and validated |

##### Call Queue

| Parameter | Target value |
| --- | --- |
| Name | CQ-RECEPTION |
| Resource Account | `cq-reception@contoso.example` |
| Agents | `cap-reception-01`, `cap-reception-02` |
| Routing method | `<Attendant / Round Robin / Serial / Longest idle>` |
| Presence-based routing | `<Enabled / Disabled>` |
| Timeout | `<n>` seconds |
| Timeout target | `<overflow target>` |

##### Device mapping

| Location / desk | Endpoint account | Device model | Queue | Direct DID |
| --- | --- | --- | --- | --- |
| Reception desk 01 | `cap-reception-01@contoso.example` | `<Teams phone model>` | CQ-RECEPTION | No |
| Reception desk 02 | `cap-reception-02@contoso.example` | `<Teams phone model>` | CQ-RECEPTION | No |

#### Acceptance tests

| ID | Test | Expected result | Status |
| --- | --- | --- | --- |
| RF-01 | Inbound call to public reception number during open hours | Auto Attendant answers and routes to primary queue | TBD |
| RF-02 | Reception endpoints ring | Phones ring according to the selected routing method | TBD |
| RF-03 | Answer from shared endpoint | Communication is established | TBD |
| RF-04 | No-answer on primary queue | Timeout routes to the documented target | TBD |
| RF-05 | Closed-hours call | Closed-hours behavior matches the design | TBD |
| RF-06 | Physical phone state | Device is signed in and operational | TBD |
| RF-07 | Queue membership | Shared endpoint accounts are active queue agents | TBD |
| RF-08 | Outbound call, if required | Caller ID behavior matches the documented design | TBD |

#### RUN handover notes

Support must know:

- public reception number
- Auto Attendant name and purpose
- Call Queue name and purpose
- shared endpoint account list
- phone-to-account mapping
- Teams IP Phone Policy assigned to shared endpoint accounts
- confirmation that the minimal Common Area Phone interface is expected on shared physical phones
- timeout and overflow behavior
- closed-hours and holiday behavior
- outbound caller ID behavior, if enabled
- operator / SBC escalation boundary when PSTN behavior is impacted

#### Decision log

| ID | Decision | Rationale | Status |
| --- | --- | --- | --- |
| ADR-01 | Public number assigned to the service entry point | Keeps the service stable and supportable | Accepted |
| ADR-02 | Shared endpoint accounts used for physical phones | Clear mapping between account, phone and desk | Accepted |
| ADR-03 | No direct DID on shared endpoints by default | Prevents bypassing the controlled reception flow | Accepted |
| ADR-04 | Explicit timeout and overflow handling | Avoids ambiguous no-answer behavior | Accepted |

#### Public anonymization checklist

Before publishing or reusing publicly, remove or replace:

- client name
- real phone numbers
- tenant domains
- real UPNs
- names of people
- internal escalation paths
- screenshots containing tenant data
- operator circuit IDs or trunk identifiers
- customer-specific command output
