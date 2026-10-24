# Operator dashboard trace — 23 October 2026

Evidence: the supplied SM T515 debug log (`e17a7211-9c71-4e49-8506-f83160f75461/Pasted text.txt`). No live backend requests or changes were made for this investigation.

## Confirmed API disagreement

The affected assignment is **JOB-000014**, ID `01a167a7-0198-7151-bb74-0446702973be`, scheduled for 23 October at 10:45, dispatched at `2026-10-23T07:26:00+00:00`.

| Log evidence | Result |
| --- | --- |
| Manager `GET /api/v1/mech/jobs?mine=0&page=1&per_page=50` (repeated, including request #125) | JOB-000014 is dispatched to operator `01a0fd23-3f64-72b7-83b2-c418b92c93b8`. |
| Operator login and `GET /api/v1/mech/me`, request #143, lines 4285–4287 | Same operator profile; `today` contains JOB-000014. |
| Operator `GET /api/v1/mech/jobs?status=active&mine=1&page=1`, request #145, lines 4268–4274 | Only JOB-000001, JOB-000002, JOB-000003; total 3, last page 1. This is not a missed pagination page. |
| Operator calendar, request #144, lines 4276–4283 | JOB-000001/2/3 and cancelled JOB-000009; JOB-000014 absent despite being within the requested date range. |
| Operator `GET /api/v1/mech/jobs/01a167a7-0198-7151-bb74-0446702973be`, request #147, lines 4302–4339 | HTTP 404: no query results for MechJob. |
| Client sync, lines 4340–4341 | Drops the `me.today` fallback, reducing today assignments from 1 to 0. |

The documentation section 2.1 defines `/me.today` as the operator's active assignments today. Section 2.5 provides the job list/detail contract. Its error table says 404 can mean a wrong ID or a record outside the caller's union/organisation. The same job ID and linked operator appear in successful responses, so the precise backend cause cannot be established from this Flutter repository.

The backend investigation should compare tenant/organisation/union scoping, operator-to-user linkage, and assignment filters across `/me`, jobs list, calendar, and detail **using the operator account**. User ID `01a0fd23-408e-70fd-b28a-0c16ff744344` and operator profile ID `01a0fd23-3f64-72b7-83b2-c418b92c93b8` are distinct, as expected; check that queries use the appropriate key. These are investigation targets, not proven backend defects in any particular query.

## Client changes

- Preserve an assignment explicitly returned in `/me.today` when its detail request fails, and display a warning instead of silently deleting it. Retry detail loading normally; navigation remains blocked until the detail request succeeds.
- Keep the focus card and render the other active assignments below it. Previously only one card was rendered, with older arrived jobs taking priority over newly dispatched jobs.
- Keep unfinished jobs from the active assignment feeds visible even when their scheduled date has passed; exclude those active jobs from past assignments.
- Clear assignment warnings when detail access recovers, when the next successful assignment refresh removes the job, or when the account changes.

No API permission checks are bypassed. Farmer confirmation remains in the separate farmer app/backend. The frontend changes make the assignment visible but cannot make the server's 404 detail/action routes succeed.

Regression coverage includes the conflicting `/me` + 404 responses, access recovery and assignment removal, and rendering multiple jobs including an overdue dispatched job below an older arrived focus job.

Validation: all 35 tests in the six focused operator/union test files passed. Analysis of the changed repository, dashboard and flow test reported no issues; formatting checks passed. The device log was inspected, but the patched app has not yet been rerun on the device.
