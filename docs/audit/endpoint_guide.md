# KwanzaTrack endpoint guide and app connection map

**Connection-status snapshot:** the connection labels below describe the baseline audit before repairs. See [operator/union flow repairs](operator_union_fixes.md) for the implemented changes. The endpoint definitions remain based on the supplied API contract.

Reviewed 23 October 2026 against the two supplied September 2026 API documents and the current working tree.

The Postman collection contains **78 distinct method/path pairs**: 5 authentication, 57 mobile mechanization, and 16 integration. Different filters, OTP/PIN/signature examples, approve/deny decisions, and webhook registration/removal are variants of the same endpoint. Two additional HTTP endpoints exist in the app source and are described at the end. The extracted examples are in [postman-endpoint-inventory.json](postman-endpoint-inventory.json).

Connection labels describe source wiring, not a successful transaction with the deployed backend:

- **Wired**: a screen reaches the repository and HTTP call.
- **Partial**: the call exists but important data or workflow handling is incomplete.
- **Wrapper only**: an HTTP client method exists but has no application caller.
- **Missing**: no matching implementation was found.
- **External backend**: belongs on the farmer application's server; absence from this operator/union mobile client is expected.

All mobile mechanization paths in the tables are relative to `https://tractor.shambabora.co.tz/api/v1/mech`. The app and supplied Postman collection use that same host. `{id}` means the relevant server record ID, not a display label. Authentication calls use `/api/app`. Integration paths have a different prefix and a different token.

## Common rules that apply to every endpoint

The server wraps successful JSON as `{success:true, message, data, meta?}` and failures as `{success:false, message, code?, errors?}`. Paginated lists describe `page`, `per_page`, `total`, and `last_page` in `meta`. The app currently reads first pages in most places and does not complete pagination.

Mobile calls use the logged-in user's bearer token, normally valid for 30 days. Login, OTP verification, and OTP resend are the exceptions that establish a session. Integration credentials produce a separate 60-minute bearer token and must stay on a server.

Areas are **acres** unless explicitly suffixed `_ha`; distances are metres; coordinates are WGS84 decimal degrees. Dates are `YYYY-MM-DD`, times are `HH:MM`, and timestamps carry an offset. Offset timestamps must be converted consistently before local calendar grouping and display.

The field actions `accept`, `en-route`, `arrive`, `start`, `pause`, `resume`, and `complete` accept `client_event_id`. Create one ID at the time of the user action and keep it for retries of that same action. Replaying the same ID for the same job returns the current state without reapplying the action. The app generates IDs but does not persist an offline queue or reuse IDs after a failed submission.

Send the phone fix on field actions: `{phone:{latitude,longitude,accuracy_m}}`. Start normally requires it. Several current screen actions omit it even though the HTTP client supports it.

Mobile and integration limits are normally 120 requests/minute per token/client; OTP and confirmation are tighter. `429` includes `Retry-After`, which the app currently does not retain or act on.

## 1. Authentication — 5 endpoints

| Method and full path | What it does; inputs and result | Current app connection |
|---|---|---|
| `POST /api/app/login` | Checks `identifier` (phone/email), `password`, and `device_name`. Returns an OTP `challenge_id`, delivery channel, masked destination, resend delay, and expiry. If the account exists in several organisations, returns tenant choices; submit again with `tenant_id`. This call alone does not complete sign-in. | **Partial.** Login screen → `AuthLocalRepository.requestLoginChallenge` → `AuthRemoteDataSource.login`. Normal OTP flow is wired. Multiple-organisation accounts are explicitly rejected instead of showing tenant selection. |
| `POST /api/app/verify-otp` | Submits `challenge_id`, six-digit `code`, and `device_name`. Returns the bearer token, expiry, user permissions, and tenant branding. | **Wired.** OTP screen → `verifyRemoteOtp`. Token is stored in secure storage. Workspace selection uses permissions plus role-name matching, with the limitations in the audit. |
| `POST /api/app/resend-otp` | Requests another code for `challenge_id`; obey the server's cooldown and expiry. | **Partial.** Resend button calls the API and can adopt a new challenge ID, but the server's resend/expiry timing is not passed into the OTP UI. |
| `GET /api/app/me` | Reads the authenticated app identity using a saved token. Used to confirm a restored session is still valid. Different purpose from mechanization `/me`. | **Wired.** Startup → `restoreSavedSession` → `refreshRemoteSession`. An explicit expired session clears the stored token. Network failure retains the token but does not provide an offline authenticated workspace. |
| `POST /api/app/logout` | Revokes the current mobile token. | **Wired.** App clears local auth and calls remote logout. Expected auth API failures are tolerated. In-flight data requests and pushed routes are not fully invalidated when the session changes. |

## 2. Mobile home and calendar — 4 endpoints

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `GET /me` | Returns user, union, linked operator, today's jobs, policy, dynamic inspection checklist, and server time. Staff have `operator:null`; an unlinked operator cannot perform field actions. | **Partial.** Both repositories call it. Operator name, today's jobs, and checklist are used. Policy and server time are discarded, so the UI does not follow configurable inspection/location/confirmation requirements. |
| `GET /dashboard?days=30` | Returns union fleet counts, queues, outcomes, trends, and utilisation for the requested period. | **Partial.** Union dashboard calls it; some counts are extracted using recursive key searches. Full trend/utilisation display and the deployed response shape remain unverified. |
| `GET /calendar` | Reads scheduled job events and day groups. Filters include `from`, `to`, `mine`, `status`, `tractor_id`, and `operator_id`. Events include dates/windows, status colours, farmer/plot, assignments, and acres. Operators default to their own jobs; staff default to union scope. | **Partial.** Both schedule screens are wired. Repositories request a fixed range of about 90 days back to 365 days ahead. Union status filter omits `paused` and `verified`. Offset times and all-day windows are not fully preserved. |
| `GET /calendar/backlog` | Staff list of approved requests without a scheduling slot: reference, farmer, plot, service, preferred date/window, priority, acres, and waiting days. | **Partial.** Union startup fetches it, but consumes only its count. Backlog records and waiting-day data are not mapped into a dedicated scheduling backlog. |

## 3. Mobile job reads — 3 endpoints

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `GET /jobs` | Paginated job list. Filters: `status` (`active` or a comma-separated list), `date`, `from`, `to`, `mine`, `tractor_id`, `page`, `per_page`. This is assignment/work data, while calendar is planning data. | **Partial.** Union fetches one page of 50; operator fetches the first page of active jobs. No full pagination or dedicated completed-history fetch. Brief responses lack some fields the UI expects. |
| `GET /jobs/{id}` | Full job: linked request, farmer, boundary, service, tractor/operator, timestamps, money, work seconds, live tracker, start check, verification evidence, overrides, events, and photos. | **Partial.** Operator refreshes detail before opening jobs. Union has a repository method without a current screen caller. Models discard much of the evidence and do not retain pending/approved operator overrides. |
| `GET /jobs/{id}/path` | Returns `{path:[{t,lat,lng,speed,in}],live}`. Draw the work trail, using `in` to distinguish inside/outside the plot. | **Broken contract mapping.** Operator calls it, but parser looks for `data.points`, not documented `data.path`. It also lacks per-point inside/outside evidence and speed/time preservation. |

## 4. Operator field actions — 13 endpoints

These require `mech.operate` and an authorised operator/job assignment. A successful action can return a brief job; the app must merge it with existing detail or fetch detail again.

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `POST /jobs/{id}/accept` | Optional acknowledgement that the operator accepts the assignment. Logs the event; does not mean work has started. Supports phone fix and `client_event_id`. | **Partial.** Accept button is wired. Acceptance is stored only in a local boolean and is not reconstructed from server events. Brief responses can erase loaded farmer/plot details. |
| `POST /jobs/{id}/en-route` | Marks the assignment `en_route`: operator/tractor are travelling to the field. Supports phone fix and event ID. | **Partial.** Start Journey is wired; screen omits phone fix. Brief-response detail loss applies. |
| `POST /jobs/{id}/arrive` | Marks the job `arrived`. Tracker entry may already have done this; a manual arrival is supported. Supports phone fix and event ID. | **Wired with shared limitations.** Arrival screen sends its captured phone fix. No offline replay persistence; brief-response detail loss applies. |
| `POST /jobs/{id}/start-check` | Dry run with no work-state change. Submit phone fix; receive `can_start`, `override_allowed`, failed keys, detailed checklist, and tractor/phone distance evidence. Checks include job state/day, assignment/licence, tractor fitness, inspection, hours, mapping, fresh tracker, and proximity. | **Partial.** Safety-check dialog renders checks and conditionally offers override. It runs on tap, not periodically. Cached phone location can grow stale; much of the location evidence is discarded. |
| `POST /jobs/{id}/start` | Starts work if checks pass. Body: phone fix, optional `hour_meter`, `implement`, `override_id`, and event ID. Returns `{job,start_check}`. On refusal, `422 code=start_denied` contains checklist details in `errors`. | **Partial/broken override path.** Normal start is wired. UI adds a mandatory configured-implement selection although API field is optional. Repository rejects a failed pre-check before sending an approved override. Structured refusal checklist is lost by the HTTP exception type. |
| `POST /jobs/{id}/pause` | Pauses work; optional `reason`, phone fix, and event ID. Paused time must not count as work time. | **Partial.** Pause button sends reason `Paused`; no phone fix from screen. Progress display computes wall time from `started_at`, so it includes pauses and does not use server `work_seconds`. |
| `POST /jobs/{id}/resume` | Returns paused work to `in_progress`; supports phone fix and event ID. | **Partial.** Resume button is wired, but its standalone progress screen does not listen to repository changes. Controls may remain stale; phone fix omitted. |
| `POST /jobs/{id}/photos` | Uploads multipart `kind` and `file`, optional `caption`; kinds include before, during, after, signature, issue, other. Stores job evidence. | **Missing.** No upload method, multipart transport, or connected capture/upload UI found. |
| `POST /jobs/{id}/issue` | Reports `text`, optional severity (`info`, `warning`, `critical`) and `open_ticket`; creates a union exception, optionally a maintenance ticket. Can include phone fix. | **Partial.** Report Problem is wired. It always sends `warning` and `open_ticket:true`, even for weather or farmer absence; screen omits phone fix. |
| `POST /jobs/{id}/complete` | Records required `reported_acres`, optional `end_hour_meter`, `fuel_used_l`, `notes`, event ID, and phone fix. Moves to `completed` and triggers tractor-trail analysis; it does not verify or close the job. | **Partial.** Finish form sends acres/meters/fuel/notes. Phone fix omitted. Returned acres are stored as hectares; a completed job absent from other local sources can disappear from history. No connected operator confirmation step follows. |
| `POST /jobs/{id}/farmer-otp` | Sends a six-digit confirmation code to the farmer; response includes `sent` and expiry (documented 600 seconds). `sent:false` indicates missing phone or SMS-credit problem. Five wrong attempts burn the code. | **Wrapper only.** `farmerOtp` has no repository/screen caller. |
| `POST /jobs/{id}/farmer-confirm` | Confirms completed work using JSON OTP `{method:"otp",code,rating?}`, JSON PIN `{method:"pin",pin,rating?}`, or multipart signature `{method:"signature",signature:<image>,rating?}`. Include `dispute:true` and `note` to dispute, using the corresponding proof. A dispute flags the job and creates a critical exception. | **Wrapper only, JSON only.** No connected OTP/PIN/signature/dispute UI. Existing generic JSON method cannot upload the documented signature image. Staff manual confirmation is a separate endpoint. |
| `POST /jobs/{id}/override-request` | Submits `reason` for a location-type start failure. Creates a pending override and alerts union contact. Poll job detail for approved/denied status, then send approved `override_id` to start; approval lasts two hours. It cannot override missing inspection, unauthorised operator, or unfit tractor. | **Partial.** Request dialog is wired, but response ID/status is discarded. No job-detail polling or approved-ID forwarding. The message telling operators to rerun checks does not complete the specified flow. |

## 5. Union job actions — 9 endpoints

These are staff actions requiring `mech.jobs.manage`. Farmer proof and final verification are separate steps.

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `POST /jobs/{id}/dispatch` | Assigns/reassigns optional `tractor_id` and `operator_id`. With both set, job becomes `dispatched`; server sends operator/farmer SMS. Restricted tractors cannot be dispatched. | **Wired.** Job action and post-scheduling prompt call it with registry IDs. UI only exposes initial scheduled-job dispatch, not a full reassign flow for dispatched jobs. Local tractor status parsing needs correction. |
| `POST /jobs/{id}/reschedule` | Changes `scheduled_date`, optional `window_start`, `window_end`, and `reason`. This endpoint's documented body does not reassign resources. | **Wired.** Reschedule screen changes date/time and reason. Repository accepts tractor/operator parameters but does not send them; current screen passes existing assignments. Calendar source is not updated immediately. |
| `POST /jobs/{id}/verify` | Staff approves measured `verified_acres`, optional `amount` and `note`; `completed → verified`. Farmer confirmation is required when policy says so. | **Partial.** Acreage/note dialog is wired. The model/UI does not retain/display the confirmation gate, reported/estimated evidence, or final amount needed for an informed decision; amount is supported by client but not UI. |
| `POST /jobs/{id}/confirm` | Staff manually records the farmer's approval from a call/office visit: optional `rating`, `note`, `dispute`. This does not replace acreage verification. | **Wired.** Manual confirmation/dispute dialog. Confirmation timestamps/method are not reflected in the job model. |
| `POST /jobs/{id}/close` | Finalises the job, with optional `payment_status` (`unpaid`, `deposit`, `paid`, `waived`) and `note`. | **Partial.** Close verified job is wired, but always defaults to `paid`. UI explicitly says it closes as paid; no unpaid/deposit/waived choice or close note. |
| `POST /jobs/{id}/flag` | Marks a job for investigation using required `reason`; investigate the concern before normal progression. | **Wired.** Flag dialog. UI action visibility depends on status, not permission. |
| `POST /jobs/{id}/unflag` | Clears the concern with optional `note`; server restores the appropriate prior state. | **Wired.** Clear Flag calls server and uses its result. Dead local fallback code assumes dispatched, but current remote helper returns before that branch. |
| `POST /jobs/{id}/cancel` | Cancels a job before verification; optional `reason` and `cancel_request`. With `cancel_request:false`, the request returns to backlog. | **Partial.** UI sends `cancel_request:false`, but only updates the job locally. It does not immediately refresh the related request or backlog count. UI also lacks cancellation for completed-but-unverified jobs permitted by the lifecycle reference. |
| `POST /jobs/{id}/refresh-verification` | Reanalyses the tractor trail and refreshes the acreage/work evidence. It is a computation request, not staff approval. | **Partial.** Menu action is wired, but returned verification evidence is discarded and no evidence detail screen displays it. |

## 6. Tractors and inspections — 6 endpoints

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `GET /tractors?mine=1&live=1` | Lists visible tractors. `mine` defaults true for operators, false for staff; `live` requests tracker information. Includes identifiers, fitness/status, implements, documents, union, and optional live data. | **Partial.** Operator map polls every 12 seconds; union loads fleet. Four documented statuses map incorrectly to available. Live shape must be verified against deployed responses; union model drops several document/tracker fields. |
| `GET /tractors/{id}` | Full tractor detail, including authorised operators, today's inspection, active job, maintenance due, and live position. | **Partial.** Used through technician tractor detail. Operator does not use it to restore inspection state; active-job/documents detail is incomplete. |
| `GET /tractors/qr/{token}` | Resolves a scanned asset QR token to tractor detail. | **Repository only.** `lookupTractorQr` calls the wrapper, but no screen invokes the lookup and no scanner UI/plugin is connected. |
| `GET /tractors/{id}/inspection/today` | Reads today's inspection so the UI knows whether a required valid inspection already exists. | **Partial.** Technician detail fetches it. Operator start screen does not; it resets its local `inspectionRecorded` flag whenever the screen is recreated. |
| `POST /tractors/{id}/inspections` | Submits dynamic `checklist`, optional fuel percentage, hour meter, defects, fitness, job ID, and phone fix. Checklist keys come from mechanization `/me`. A failed item without explicit `is_fit:true` marks unfit and alerts union; start check enforces the result. | **Wired with policy gap.** Operator inspection dialog uses server checklist and sends fitness/phone. Inspection is always a local prerequisite even when policy disables it, and existing daily inspection is not restored. |
| `POST /tractors/{id}/fuel` | Logs fuel quantity `litres`, optional `cost`, hour meter, `source` (`issue`, `purchase`, `adjustment`), job ID, and note. A fuel log is distinct from completion's estimated fuel used. | **Wrapper only.** No fuel-log repository/screen caller. |

## 7. Service requests — 9 endpoints

Write actions require `mech.requests.manage`; scheduling requires the appropriate job-management permission. A request expresses farmer demand; a job is the actual scheduled assignment.

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `GET /requests` | Paginated demand/review queue. Filters: `status` (`queue`, individual states, `all`), `farmer_id`, search `q`, and `page`. Returns farmer, plot, service/tariff, preference, estimated charge, payment, review, and linked job data. | **Partial.** Union requests screen is wired. Repository repeatedly fetches overlapping status buckets, omits `status=all`, does not page, and misclassifies completed/closed states as pending. |
| `GET /requests/{id}` | Full request detail and any linked brief job. | **Partial.** Opening request triggers refresh; missing boundaries may be enriched through farmer detail. Several charge/review/reference fields and the linked job are not retained. |
| `POST /requests` | Registers farmer demand using `farmer_id`, `plot_id`, `service_type_id`; optional requested acres, preferred date/window, priority, notes. It does not approve, schedule, or dispatch the request. | **Partial.** Register form is wired but requires typing raw IDs; service-type and farmer/plot picker APIs are not connected to the form. |
| `POST /requests/{id}/approve` | Approves demand, optionally setting `estimate_amount`, priority, and note. Approved request waits for scheduling. Approval is not dispatch. | **Wired.** Approve sheet sends these fields. Terminal request-state parsing and permission gating still need correction. |
| `POST /requests/{id}/return` | Sends request back for correction with required `reason`; farmer backend can amend and resubmit it. | **Wired.** Return flow sends the reason. Farmer correction in this repository's local demo is not integrated with the external backend. |
| `POST /requests/{id}/reject` | Declines the demand with a required reason. | **Wired.** Reject sheet sends selected/free-text reason; returned request state is applied. |
| `POST /requests/{id}/cancel` | Cancels the demand, with optional reason. Distinct from cancelling only its job. | **Wired.** Request cancel flow. Wider request/job state refresh still needed after related actions. |
| `POST /requests/{id}/schedule` | Converts approved demand into a job. Required `scheduled_date`; optional start/end window, tractor/operator, planned acres, implement, notes. Returns `201` with job. Dispatch is a separate action in the lifecycle reference. | **Wired.** Scheduling screen checks resources, submits, and offers dispatch. It recognises if backend already returned dispatched. UI is stricter than API by requiring both resources and an implement. |
| `GET /requests/availability` | Reads jobs conflicting with `date`, `tractor_id`, `operator_id`; optional `exclude_job_id` for an existing job. Returns tractor/operator assignments and load hours. | **Partial.** Scheduling calls it, but treats any assignment that day as fully unavailable. It does not compare the requested time window with existing windows. Exclusion is supported by client but not repository/UI. |

## 8. Overrides and exceptions — 5 endpoints

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `GET /overrides?status=pending` | Lists override requests filtered by pending, approved, denied, expired, or all. Includes reason, checks, decision, and expiry data. | **Wired for staff.** Oversight screen loads the list; no connected operator approved-override follow-through. Permission-specific loading is missing. |
| `POST /overrides/{id}/decide` | Requires `mech.override`; submits `approve:true/false`, optional note. Server records decision, notifies operator, and limits approval validity. | **Wired for staff.** Approve/deny buttons call it and refresh oversight. Approval alone does not start the job. |
| `GET /exceptions` | Reads operational alerts filtered by status, severity, tractor, page. Types include leaving plot, movement, tracker offline, idling, denied start, overrides, overdue job, dispute, acreage mismatch, maintenance, documents, issues, speeding. | **Partial.** Oversight list wired; advanced filters and pagination not exposed. Some evidence/location/detail is not represented in the UI model. |
| `POST /exceptions/{id}/ack` | Requires exception-management permission; records that staff have seen the alert. Acknowledgement does not resolve the underlying concern. | **Wired.** Acknowledge button calls API then refreshes list. |
| `POST /exceptions/{id}/resolve` | Closes an alert with required `remarks`; `dismiss:true` records dismissal instead of resolution. | **Wired.** Resolve/dismiss dialog sends remarks and decision. |

## 9. Registry and lookup data — 8 endpoints

Registry writes require `mech.registry.manage`; read access is governed by server permissions and union/tenant scope.

| Method and relative path | What it does; inputs and result | Current app connection |
|---|---|---|
| `GET /farmers?q=&page=` | Searches/lists visible farmers for directory and request pickers. | **Partial.** Union farmer directory fetches first page; no server search/pagination from UI. Client also hides records sharing a normalised phone number, potentially hiding distinct farmers sharing a family phone. |
| `GET /farmers/{id}` | Reads farmer with plots and full boundaries. Useful when list/request data only carries plot summaries. | **Wired for boundary enrichment.** Union repository calls it when request boundaries are missing. Not a fully connected farmer/plot selection flow. |
| `POST /farmers` | Creates a portal farmer record: name, optional phone, union, national ID, sex, birth year, village/ward/district/region. This is staff registry work, not farmer password self-registration. | **Wrapper only.** The app's separate farmer registration screen writes local memory instead of this API. |
| `POST /farmers/{id}/plots` | Maps a farmer's plot: name, ordered boundary of at least three coordinate points, optional crop, tolerance, area in hectares, notes. Server closes polygon and computes area/centroid. | **Wrapper only.** Local Add Plot does not call it. |
| `PUT /plots/{id}` | Updates selected plot fields/boundary; fields are optional. A remap should send valid ordered corners. | **Wrapper only.** No connected plot update flow. |
| `GET /service-types` | Reads server IDs, service codes/names, tariffs, and billing units. Use these values in registration and display rather than hardcoded service enums. | **Wrapper only.** Request form asks users for a service-type ID. Other screens default unrecognised service types to Ploughing. |
| `GET /unions` | Lists visible union choices for registry/pickers. Different from authentication tenant selection. | **Wrapper only.** No app caller. |
| `GET /operators` | Lists union operators for assignment pickers and directory. | **Wired.** Union loads registry and uses it in scheduling/dispatch. Licence details and complete availability rules need fuller treatment. |

## 10. Integration API — 16 endpoints

These are **server-to-server** calls for Shamba Bora. The prefix is `/api/integration/v1/mechanization` except token issuance and the general tracking endpoint. Read operations use `mechanization:read`; writes use `mechanization:write`, as granted by the platform. The vehicles endpoint specifically requires `tracking:read`. Do not use a mobile login token here and do not embed integration `client_id`/`api_key` in Flutter.

All 16 are **External backend: no implementation found in this Flutter repository**. That is expected for the supplied operator/union contract; a working farmer application needs its own backend integration. The local farmer screens in this repository do not implement that external backend.

| Method and full path | What it does; inputs and result |
|---|---|
| `POST /api/integration/token` | Exchanges server-held `client_id` and `api_key` for `access_token`, token type, granted scopes, and `expires_in:3600`. Renew after token expiry. `403 insufficient_scope` means a permission change is needed, not another login retry. |
| `GET /api/integration/v1/mechanization/service-types` | Reads service codes, tariffs, and units so the farmer backend can offer valid services and send `service_code` when ordering. |
| `POST /api/integration/v1/mechanization/farmers` | Upserts farmer by your `external_ref`, with name/phone, optional union code/demographics/PIN, and optional plots. Plots use their own external references and boundaries. Returns created `201` or updated `200` with mapped state, areas, and centroid. Unknown union gives `unknown_union`. |
| `GET /api/integration/v1/mechanization/farmers` | Reads/searches synced farmers using `external_ref`, `phone`, or `q`. Do not confuse external references with portal UUIDs. |
| `GET /api/integration/v1/mechanization/farmers/{external_ref}` | Reads one farmer and synced plots using the farmer application's stable reference. |
| `POST /api/integration/v1/mechanization/farmers/{external_ref}/plots` | Upserts one plot under a synced farmer using plot `external_ref`, name, optional crop/area/tolerance, and ordered boundary. At least three boundary points are necessary for a plot usable in a request. |
| `POST /api/integration/v1/mechanization/requests` | Places a farmer order using stable `external_ref`, `farmer_ref`, `plot_ref`, `service_code`, requested acres, optional date/window/priority/notes/meta. Creates pending demand (`201`). Retrying the same order reference returns existing request (`200`), preventing duplicate orders. Validation codes distinguish unknown farmer/plot/service and unmapped plot. |
| `GET /api/integration/v1/mechanization/requests` | Lists orders, filtered by farmer reference, status, `updated_since` timestamp, and page. Supports incremental synchronisation; follow pagination and persist sync checkpoints on the server. |
| `GET /api/integration/v1/mechanization/requests/{ref}` | Follows a single order using external reference, SR reference, or server ID. Includes linked job, active tractor position, and job-event timeline, allowing the farmer app to show travel/work progress. |
| `PATCH /api/integration/v1/mechanization/requests/{ref}` | Amends pending demand: requested acres, preferred date/window, priority, notes. Also resubmits a returned request after correction. Does not generally change already-started work. |
| `POST /api/integration/v1/mechanization/requests/{ref}/cancel` | Cancels an order before work starts; optional reason. Server must enforce lifecycle restrictions. |
| `POST /api/integration/v1/mechanization/requests/{ref}/confirm` | After completion, relays farmer approval with optional rating 1–5 and note. With `dispute:true` and explanation, records disagreement for union review. Confirm and dispute are variants of this one endpoint. Unlike mobile OTP/PIN proof, the authenticated integration server vouches for its farmer's action. |
| `GET /api/integration/v1/mechanization/calendar` | Reads a farmer's job activity events using `farmer_ref`, date range, and optional status, in the same calendar event shape as the mobile API. |
| `GET /api/integration/v1/mechanization/webhook` | Reads current callback registration. This read operation appears in Postman; the prose guide focuses on writes. Exact response fields should be confirmed with backend because no example response is supplied. |
| `PUT /api/integration/v1/mechanization/webhook` | Registers callback `{url, secret?}`. An optional supplied secret must be at least 16 characters; a generated secret is shown once and must be stored securely. `{url:null}` removes callback. Registration/removal are variants of one endpoint. |
| `GET /api/integration/v1/vehicles` | General vehicle-tracking list using the integration token with `tracking:read`. Appears in Postman, not the mechanization prose reference. It is not required to use mobile job/tractor live data. Response schema and vehicle/tractor linking are not documented in the supplied files. |

## 11. Webhook delivery — outgoing server callback, not another fixed API path

The portal POSTs to **your registered callback URL**. Headers identify `X-KwanzaTrack-Event` and `X-KwanzaTrack-Signature:sha256=<hex>`. Body contains delivery `id`, event name, occurrence time, and request/job object. Verify HMAC-SHA256 against the **raw body**, then deduplicate by delivery ID and process asynchronously. Reply 2xx within eight seconds; documented retries are after 30 seconds, five minutes, and 30 minutes. Repeated deliveries should not apply the same change twice. The sample signature verifier needs a length check before `timingSafeEqual` to safely reject missing/malformed signatures.

The documented events cover request create/approve/return/resubmit/reject/cancel/update/status changes and job schedule/dispatch/reassign/reschedule/travel/arrival/start/pause/resume/complete/farmer-confirm/dispute/verify/close/flag/unflag/cancel/override request/approve/deny. A callback receiver belongs in the farmer backend. None exists in this Flutter repository.

## 12. Additional endpoints found in application code — 2

| Method and endpoint | What it does | Current app connection |
|---|---|---|
| `GET http://45.77.1.62:8080/api/v1/input-requests/service-orders` | Older separate service-order feed. Expects JSON lists or common wrapper keys. It sends no bearer token and is outside both supplied KwanzaTrack API groups. | **Dormant.** `ServiceOrdersRemoteDataSource` and repository forwarding method exist; no screen caller found. It does not connect local farmer requests to union jobs. Android globally permits cleartext and iOS has an exception for this host. Remove or migrate if no longer needed. |
| `POST https://routes.googleapis.com/directions/v2:computeRoutes` | Sends origin/destination, DRIVE/TRAFFIC_AWARE settings, API key/platform headers and field mask; returns driving-route polyline, distance, and duration. Widget selects shortest returned route by distance. This is navigation guidance, not the tractor work trail. | **Wired.** Operator route map calls it directly. Keys and application/certificate settings are compiled into source; cloud restrictions/quota cannot be verified locally. No full response timeout; GoogleMap platform coverage is separate from having desktop/web scaffolding. |

## Correct overall sequence

```text
Farmer backend syncs farmer + mapped plot
  -> places request
  -> union reviews and approves
  -> checks availability and schedules job
  -> dispatches assigned tractor/operator
  -> operator accepts (optional), goes en route, arrives
  -> daily inspection when policy requires it
  -> start-check
     -> passes: start
     -> eligible location failure: request override, await decision,
        start with approved override_id before expiry
  -> work, pause/resume as needed, photos/issues as needed
  -> complete with reported acres
  -> farmer confirms or disputes
  -> union verifies evidence/acres (confirmation required by policy)
  -> union closes with actual payment status
```

A cancelled job with `cancel_request:false` returns demand to scheduling backlog. A dispute/flag needs review; unflag should use the server's restored state. Neither completion, manual confirmation, nor recomputing verification is equivalent to closing the job.

## Error behaviour to preserve in the UI

| Status | Meaning | App treatment needed |
|---|---|---|
| `401` | Session/token invalid | Clear session, cancel/ignore old requests, reset navigation, request login. |
| `402` | Organisation suspended | Show server reason and an actionable account state. |
| `403` | Permission, linked operator, or assignment problem | Show the server's message; do not treat every forbidden action as token expiry. Hide actions not permitted. |
| `404` | Wrong ID or inaccessible tenant/union record | Handle removed/reassigned jobs without `firstWhere` crashes. |
| `422` | Validation; or `start_denied` with structured checklist | Preserve field errors/checklist, keep form values, render actionable details. |
| `429` | Rate limit | Honour `Retry-After`; prevent rapid duplicate taps and uncontrolled polling. |

See [project_audit.md](project_audit.md) for evidence, prioritised defects, test results, and the remediation sequence.
