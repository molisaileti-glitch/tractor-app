# Screen refresh and farm boundary changes

Implemented on 25 October 2026 against the supplied Mechanization API v1 guide. This supersedes earlier notes about shell-wide automatic refresh and multiple live map pollers. Farmer-app logic is unchanged.

## Refresh behavior

- Operator and union shells have no periodic network timer and do not refresh the workspace when the app resumes.
- Signing in loads the dashboard. Other tabs load on their first visit. Returning to a visited tab uses cached data until pull-to-refresh or its refresh button is used.
- Refresh loading indicators and errors belong to the selected screen. Requests for the same screen that overlap share the same pending load. Failed initial loads show their error and wait for an explicit retry, rather than creating a retry loop.
- After an action, the affected job/request is updated using the action response and, where needed, that record's detail endpoint. Cancellation no longer fetches an unused calendar backlog.
- Scheduling loads its tractor/operator choices when the scheduling form opens. Request lists no longer fetch every farmer's full plot detail in advance; opening a request fetches/enriches that request's geometry.
- Session changes clear loaded-screen state and caches. Late reads from an old session or before a mutation cannot overwrite newer job state.

| Screen | Data fetched for its refresh |
| --- | --- |
| Operator dashboard | `/me` and paginated `/jobs?status=active&mine=1`; detail only to validate a `/me.today` assignment missing from the list |
| Operator calendar | `/calendar?mine=1` |
| Operator history | Paginated completed/verified/closed/cancelled jobs with `mine=1` |
| Operator profile | `/me`; assignment summary is labelled as loaded/cached assignments |
| Union dashboard | `/me`, `/dashboard`, jobs, overrides and exceptions used by its cards/counts |
| Union requests | Paginated requests |
| Union calendar | `/calendar?mine=0` |
| Union jobs | Paginated jobs |
| Union oversight | Overrides and exceptions |
| Union tractors | Tractor registry plus assigned/live tractor data |
| Union operators / farmers | Only the respective registry |
| Union maintenance | Tractor registry needed for maintenance status |
| Union reports | Requests, jobs, tractors and operators used by the report |
| Union settings | `/me` |

Pagination and backend inconsistencies can require more than one HTTP request; a screen refresh is not necessarily a single endpoint.

## Limited field updates

One visible `OperatorLiveJobMap` owns a 12-second refresh cycle during en-route, arrived, in-progress or paused work. It reads phone GPS and this job's detail, plus its recorded path where applicable. It does not reload the calendar, history or entire tractor list on each tick.

Arrival no longer has independent six-second job-detail/start-check polling or a second tracker timer. It refreshes inspection and tractor/implement data on entry or an explicit pull. Once the operator has run Start Check, the map cycle can recheck readiness using the phone reading it already captured. This also observes a pending override through job detail. Progress has only a local elapsed-time clock; its map owns the network cycle.

No automatic field requests start while another route covers the job or the app is backgrounded. Requests already in flight may finish. Overlapping map refreshes share one cycle. The job detail refresh icon and arrival/progress pull gestures refresh that job. The initial detail screen uses the full job already fetched when opening it, rather than immediately fetching it again.

## Boundary rules

The map centre is only a display/navigation destination. It does not grant permission to start work.

Local estimates use the farm polygon, including its closing edge. Points on an edge count as inside. Outside distance is measured to the nearest boundary segment, not the nearest corner. A centre without at least three boundary corners cannot establish boundary presence. Invalid or expired GPS readings cannot establish local presence; expired phone readings are omitted from field-event/start-check payloads.

Arrival/progress maps show separate operator and tractor boundary estimates using the phone GPS and the assigned tractor's fresh tracker coordinates. These estimates are guidance. `POST /jobs/{id}/start-check` and `POST /jobs/{id}/start` enforce the actual server rules, including:

- `phone_on_plot` and `tractor_on_plot`;
- `tractor_fix_fresh` and phone location availability;
- the configured plot tolerance;
- the documented `phone_near_tractor` check;
- inspection, assignment, operating time and other non-location checks.

A false or missing `can_start` does not start normal work. A location override is submitted only when the backend allows overrides; the server still validates its approval. Being inside the farm does not bypass the documented operator-to-tractor proximity rule. There is no new centre-distance gate or frontend bypass of server policy.

## Verification

All 67 focused regression tests passed. Flutter analysis reported no issues, and `git diff --check` found no whitespace errors.

The focused regression suite covers idle dashboard call counts over three minutes, app pause/resume, first tab loads and revisits, explicit screen refresh, duplicate refresh suppression, errors staying on their screen, visible-job polling, hidden/background job screens, phone/tractor server failures, expired GPS payloads, positions far from the farm centre, edge inclusion and nearest-edge distance. Existing photo/PIN, lifecycle, calendar, transport and parsing tests are included.

Logs: `build/screen_refresh_final_tests.log` and `build/screen_refresh_analyze.log`. A physical phone/tractor check with current backend data remains necessary to confirm the deployed tracker assignment, GPS accuracy and backend tolerance/proximity settings.

Use a full hot restart or relaunch after installing these changes. Hot reload can leave timers created by the previous code running in the existing Dart isolate.
