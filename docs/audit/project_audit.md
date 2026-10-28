# Tractor app deep integration audit

**Historical baseline:** this report describes the pre-fix source snapshot. See the [current mechanization integration guide](../mechanization_integration.md) for the implemented behavior and current validation. The historical findings below deliberately describe the old behavior; use the current regression tests for the repaired flow.

Review date: **23 October 2026**, Africa/Nairobi. This audit uses the **current working tree**, including the changes and two untracked repository tests that were already present when the review began.

**Verdict: the app is partially integrated, and the supplied contract is not connected correctly end to end.** The normal union/operator HTTP calls are substantially implemented, but several reproducible client defects affect job detail, overrides, history, resource eligibility, and session isolation. Farmer and technician business writes remain local demonstrations.

The complete explanation of every endpoint is in [endpoint_guide.md](endpoint_guide.md). It covers all **78 distinct endpoints** in Postman plus **2 additional endpoints** found in the application.

## Scope and confidence

The project inventory contains 106 Dart files under `lib` (including generated localisation files). Review covered application startup/routing, authentication/session storage, every HTTP transport and URL, repository call sites, job/request/tractor state mappings, operator and union screen actions, farmer/technician data paths, GPS/geofence/navigation code, tests, dependencies, platform configuration, and existing documentation. Generated platform bindings, image assets, SQLite binaries, and build/cache output were not individually audited as application business logic.

The workspace contains the SB Mechanization Flutter client, not the mechanization server or the other team's Shamba Bora backend. No authenticated production requests, OTP messages, job mutations, webhook registrations, or Google billing calls were performed. Server enforcement, actual response schemas beyond the supplied examples, deployed availability, real SMS, tracker accuracy, key restrictions, and real-device behaviour remain unverified. Findings below explicitly separate executable client reproductions, source-confirmed gaps, and deployment checks.

Application source was not changed. Audit artifacts were added only under `docs/audit/`.

## What is connected

| Area | Observed implementation | Assessment |
|---|---|---|
| Login and session | Password → OTP → token; secure token persistence; session restore; logout; shared unauthorised callback | Main path wired; tenant choice, permission UX, session races, and navigation reset incomplete. |
| Union operations | Dashboard, request queue/detail/create/review, scheduling/availability, dispatch/reschedule, verify/confirm/close/flag/cancel, oversight, registries | Substantial integration; status, pagination, evidence, calendar consistency and permission issues remain. |
| Operator | Profile/today/active/calendar reads; accept/journey/arrival; checklist; safety check/start; pause/resume/complete; issues; override request; tracker polling | Main actions wired; brief-response merging and overrides break important flows. |
| Farmer | Seeded plots/requests, local registration, local submit/confirm/dispute | No backend connection for these screens. Standard remote login routing rejects farmer accounts; legacy local registration is not a real remote account. |
| Technician | Tractor reads reuse union API; maintenance records and parts are seeded; saving changes local lists/status | Reads partly wired; maintenance/parts writes do not reach backend. No maintenance-write endpoints are supplied in this API contract. |
| Offline | In-memory business collections, UUID generation for individual field actions; secure auth/preferences | No durable job cache/outbox/replay implementation. Existing offline documentation and database test refer to removed code. |
| Photos, farmer OTP/PIN/signature, fuel, registry writes | Mostly unused client wrappers; photo endpoint absent | Not connected to working feature flows. |

The shared mobile API client implements **56 of the 57 mobile method/path pairs** at wrapper level. `POST /jobs/{id}/photos` is missing; signature confirmation also needs multipart support. Eight wrappers have no application caller: farmer OTP, farmer confirmation, fuel log, farmer create, farmer plot create, plot update, service types, and unions. Tractor QR has a repository method but no screen caller. A wrapper count is not a count of fully working features.

## Executable verification

| Check | Result | Interpretation |
|---|---|---|
| `flutter analyze --no-pub` before adding audit files | **Failed: 7 issues** — 6 errors and 1 info, all in `test/offline_database_test.dart` | Missing Drift dependency and removed database/seed imports. No other issues were reported by that run. |
| `flutter test --no-pub` | **Failed: 4 passed, 6 widget tests failed, 1 test-file load failure** | Three operator repository cases and one union repository case passed. Offline database test did not compile. Six widget cases failed at the initial `Shamba Bora` text expectation; they did not exercise authenticated workflows. |
| `flutter test --no-pub docs/audit/contract_probes_test.dart` | **7/7 defect reproductions passed** | Each probe asserts the currently wrong result described by its name. This is evidence of defects, not a clean acceptance-test result. Uses fake API responses; no external network. |
| `flutter analyze --no-pub lib docs/audit` after formatting probes | **Passed: no issues** | Application source and added audit probes analyse cleanly. This does not remove the separately verified failures in the original test suite. |

The initial sandboxed Flutter launchers stalled before output; rerunning with the tool's approved outside-sandbox execution produced these results. Existing repository tests have limited coverage: they mainly check that calendar and assignment sources remain separate and that invalid today-only fallback jobs are removed. They do not verify the full lifecycle, actual transport payloads, permissions, retries, or multipart uploads.

## Findings to address first

P1 means a significant lifecycle, data correctness, or account-isolation defect. P2 means incomplete behaviour or reliability that can mislead users or block valid operations. No claim is made that server authorisation has been bypassed.

### A01 — P1: old requests can restore previous-account data after logout

**Reproduced.** Operator `setMechanizationAccessToken` clears data on logout but does not advance `_syncGeneration`; generation advances only when a refresh starts. A delayed refresh with the old token therefore passes the generation comparison and repopulates jobs after logout. Union repository has the same generation pattern; tracker/detail/action refreshes lack session-identity guards too. A fast subsequent login can also skip its own initial refresh because `_isSyncingMechanization` remains true for the old one.

Evidence: [operator token setter](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:101), [operator refresh](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:126), [union token setter](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:79). Probe: `in-flight refresh restores data after logout`.

Fix: invalidate a session generation on every token/account change, clear all scoped collections, and check captured token/generation after **each await** before applying results. Cancel or ignore old polling/actions and ensure the new account gets its own refresh. A generation check only before later awaited enrichment is insufficient.

### A02 — P1: successful brief action responses erase job detail

**Reproduced.** The contract explicitly permits action responses to contain only a brief job. `_applyJobResponse` constructs an entirely new `OperatorJob`; missing farmer/plot/service values become generic defaults. It retains acceptance and trail but replaces the full boundary, farmer and other detail. A full job followed by brief acceptance produced an empty boundary and farmer `Farmer` in the probe. Further actions have the same risk.

Union `_tryRemoteJobUpdate` also replaces detailed jobs with parsed action results. In union lists even a valid brief list response can render generic farmer/plot values; the full-detail repository method has no current union screen caller.

Evidence: [operator response application](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:760), [union response application](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:1295). Probe: `brief accept erases full plot and farmer`.

Fix: separate brief/full DTOs; merge only supplied fields or refetch full detail after actions. Do not invent data for omitted fields. Preserve explicit null versus absent fields intentionally.

### A03 — P1: requested/approved geofence overrides cannot finish the documented start flow

**Reproduced and source-confirmed.** UI can request an override, but discards the returned ID, never polls job detail for its decision, and has no pending/approved override on `OperatorJob`. It never passes `overrideId` from the start screen. Even a direct repository call with an approved ID is blocked whenever the separate pre-check returns `can_start:false`, so the actual start call is never sent with the override.

Evidence: [start pre-check](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:337), [request dialog](../../lib/src/features/operator/presentation/screens/operator_arrival_screen.dart:543). Probe: `approved override never reaches start endpoint`.

Fix: retain override state, poll detail while pending, show approved/denied/expired state, and submit the approved ID to server start. Keep non-overridable checks enforced server-side. Do not assume rerunning an unchanged location check will use an approval automatically.

### A04 — P1: working/restricted tractors are displayed as available

**Reproduced.** `_tractorAssetStatus` recognises maintenance and a few legacy names, but the documented statuses `working`, `suspended`, `unavailable`, and `decommissioned` fall into `available`. All four became `canSchedule:true` in the probe. This makes pickers misleading; backend checks may still reject assignment, so this is not evidence that the backend allows it.

Evidence: [status parser](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:2153), [eligibility enum](../../lib/src/features/manager/domain/entities/operations_models.dart:16). Probe: `restricted/working tractors become schedulable`.

Fix: model all server statuses explicitly; unknown values must not default to schedulable. Separate asset fitness from time-slot availability.

### A05 — P1: terminal request states become pending

**Reproduced.** `_requestStatus` does not preserve `completed`/`closed`; they default to `pending`. Request state `in_progress` is collapsed into scheduled. When terminal rows are returned, finished work can enter the pending-review view and counts. The enum lacks complete request lifecycle coverage.

Evidence: [request status parser](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:2111), [request enum](../../lib/src/features/manager/domain/entities/operations_models.dart:4). Probe: `completed/closed requests become pending`.

Fix: retain every documented state and map unknown values to a visible unsupported/unknown state. Enable request actions only for valid state/permission combinations.

### A06 — P1: completed jobs can disappear instead of entering history

**Reproduced.** After completion, `_applyJobResponse` removes a terminal job from `_activeJobs`. It updates today/calendar only if the record already exists in those sources. `_rebuildJobs` then rebuilds solely from those source lists. An active job absent from today/calendar disappears from `_jobs` and history despite successful completion. This matters for overdue assignments or incomplete feeds. History also depends on a bounded calendar range rather than a paginated terminal-job query.

Evidence: [response rebuild](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:760), [merged collections](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:561). Probe: `completed active job disappears from history`.

Fix: retain canonical jobs independently of feed membership; maintain explicit assignment/planning/history indexes and load completed history from the server.

### A07 — P1: tractor trail parser disagrees with the supplied contract

**Reproduced.** API specifies `data.path`; parser looks for `data.points`. Two valid documented fixes produced zero trail points. It also drops `t`, speed, and inside/outside `in`; the map draws a single colour rather than inside/outside evidence. The existing fake repository test itself uses `points`, so it misses the mismatch.

Evidence: [path parser](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:1017), [path fetch](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:742), [trail rendering](../../lib/src/features/operator/presentation/widgets/operator_widgets.dart:602). Probe: `documented data.path produces no trail points`.

Fix: parse the documented payload and retain typed timestamp, speed and inside/outside flags. Keep navigation routes distinct from actual work evidence; refresh path/live data in the work screen.

### A08 — P1: session expiry changes root content without clearing pushed job routes

**Source-confirmed navigation risk; not device-reproduced.** `_handleSessionExpired` clears repositories and changes `_workspace`, but does not reset the navigator stack. A pushed job detail/progress route may remain above login. Several such screens use `jobById`/`firstWhere` against the now-cleared list, which can throw. The same risk exists if a job is removed/reassigned while a screen remains open.

Evidence: [expiry handler](../../lib/src/app.dart:187), [job detail builder](../../lib/src/features/operator/presentation/screens/operator_job_detail_screen.dart:27), [progress builder](../../lib/src/features/operator/presentation/screens/operator_progress_screen.dart:21). Arrival screen already handles missing jobs more defensively.

Fix: reset protected navigation on session termination and make all record screens handle missing/deleted records gracefully. Avoid a global static callback as the sole session ownership mechanism.

## Remaining functional and reliability gaps

| ID / priority | Finding and practical effect | Evidence / needed change |
|---|---|---|
| A09 / P1 | **Permissions choose a workspace, not its actions.** Any management permission or matching role opens the entire union shell. Every such account fetches dashboard/backlog/overrides/etc in one `Future.wait`; one forbidden endpoint rejects the entire initial batch before useful results are applied. Viewer (`mech.view` only) is rejected altogether. | [workspace routing](../../lib/src/app.dart:245), [union load](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:104), [all shell sections](../../lib/src/features/manager/presentation/screens/operations_shell.dart:51). Store capabilities in repositories/UI; load/show only authorised modules and support documented read-only roles. Server remains the authorisation authority. |
| A10 / P2 | **Start UI ignores policy and today's existing inspection.** GPS and a new local inspection are always prerequisites; leaving/reopening screen resets inspection flag. The API can disable these requirements. Implement is optional in API but required by UI, blocking otherwise valid starts with empty configured implements. | [arrival gating](../../lib/src/features/operator/presentation/screens/operator_arrival_screen.dart:229), [operator profile parsing](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:522). Retain policy; read tractor/inspection-today; derive gates from server checks and policy. |
| A11 / P2 | **GPS is cached through the start workflow.** Inspection and confirmation dialogs can outlast a fresh fix. Start-check runs only on tap; polling refreshes tractors, not phone/start eligibility. No GPS request timeout; permission checks sit outside its try/catch. | [GPS repository](../../lib/src/additional_data/location/data/repositories/geolocator_location_repository.dart:12), [arrival location](../../lib/src/features/operator/presentation/screens/operator_arrival_screen.dart:372). Refresh location before sensitive actions; bound waits and handle permission/plugin errors. Send phone fix on accept, journey, pause, resume, issue and complete too. |
| A12 / P2 | **Progress screen stays stale and shows inaccurate work duration.** It is a standalone `StatelessWidget` with no repository listener or periodic timer. Pause/resume changes may not rebuild controls. Display uses now minus start, includes paused time, and asserts 'Current location verified' unconditionally. | [progress screen](../../lib/src/features/operator/presentation/screens/operator_progress_screen.dart:10). Subscribe to changes; use server `work_seconds`, update displayed elapsed time appropriately, show actual location state. |
| A13 / P2 | **Acres are stored/displayed as hectares.** API `reported_acres` goes straight into `areaServicedHectares`; history label says `ha`. Example: 5 acres appears as 5 ha instead of about 2.02 ha. | [job parser](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:896), [history](../../lib/src/features/operator/presentation/screens/operator_history_screen.dart:69), `lib/l10n/app_en.arb:81`. Use explicit units throughout or convert at a defined boundary. |
| A14 / P2 | **Offset times are not normalised for local calendars/display.** Dart parsing of `07:00+03:00` yields UTC 04:00, and formatters read `.hour` directly. Our existing test output showed this UTC result. Mixes with local scheduled dates; early-hour jobs can group on wrong day. All-day events lose `allDay` and window semantics. | [formatters](../../lib/src/features/farmer/presentation/widgets/farmer_formatters.dart:1), [calendar parser](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:807). Use consistent local timezone conversion and explicit date-only handling. Test midnight boundaries and timed/all-day feeds. |
| A15 / P2 | **Pagination and history are incomplete.** Union jobs fetch only 50, most directories/exceptions first page, operator jobs first active page. Fixed calendar range is 90 days back but union date picker offers 365 days back. | [union fetches](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:118), [operator fetches](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:137), [calendar picker](../../lib/src/features/manager/presentation/screens/operations_schedule_view.dart:102). Follow `meta.last_page`, or expose load-more/search/date-dependent requests. |
| A16 / P2 | **Calendar loses paused/verified work and can stay stale after writes.** Union requests an explicit status set omitting these states. `_upsertJob` changes `_jobs`, not `_calendarJobs`; schedule/reschedule/cancel/dispatch changes may not appear in Schedule until a full refresh. | [calendar filter](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:122), [upsert](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:1787). Derive views from canonical state or refresh affected feeds after writes. |
| A17 / P2 | **Availability treats any job that day as a whole-day conflict.** Requested start/end window is never compared with returned windows. A tractor with a morning job cannot be booked for a separate afternoon slot by this UI. | [availability](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:633), [schedule submit](../../lib/src/features/manager/presentation/screens/schedule_service_screen.dart:397). Compare time overlap and policy/load hours; keep server conflict validation authoritative. |
| A18 / P1 feature gap | **Operator farmer confirmation and photos are absent.** OTP/PIN/signature proof cannot be completed here; no photo evidence uploads. Completion says farmer can confirm in Shamba Bora, but that server integration is outside this repo. Manual union confirmation is wired. | Unused `farmerOtp`/`farmerConfirm` wrappers in [client](../../lib/src/core/network/mechanization_mobile_api_client.dart:272); [completion](../../lib/src/features/operator/presentation/screens/operator_complete_job_screen.dart:183). Add proof/evidence UI and multipart transport; connect real farmer backend separately. |
| A19 / P2 | **Verification actions discard their evidence.** Union model lacks verification metrics, reported/verified acres, amount/payment, farmer confirmation, and server event/photo timeline. Refresh-verification tells users new details are shown, though these fields are not stored/rendered. Verify dialog defaults to entire plot area, not recorded evidence. | [job model](../../lib/src/features/manager/domain/entities/operations_models.dart:313), [verify dialog](../../lib/src/features/manager/presentation/screens/operations_jobs_view.dart:524), [parser](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:1535). Add evidence model/screen and confirmation gate before verification. |
| A20 / P2 | **Cancelling only a job does not immediately return its request to local backlog.** API correctly receives `cancel_request:false`, but related request/counts are not updated. Close supports only paid in UI, though API supports unpaid/deposit/waived. | [cancel](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:776), [close](../../lib/src/features/manager/presentation/screens/operations_jobs_view.dart:375). Refresh related request/backlog and let staff choose actual payment status. |
| A21 / P1 feature gap | **No durable offline operation/replay.** Jobs/actions live in memory; new tap generates new UUID. On network failure there is no outbox holding event/payload and same event ID for retry. | [event IDs](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:1185) and `pubspec.yaml`. The obsolete Drift design, test, worker and WASM files were removed on 2026-10-27 because the implementation and dependencies no longer existed. Either implement durable per-account cache/outbox and ordered reconciliation, or explicitly scope product to online operation. |
| A22 / P2 | **Network layer discards useful error/rate data and does not bound the entire response read.** Exceptions retain message/code/status only, lose `errors`, metadata and headers including `Retry-After`. JSON decode occurs before HTTP handling, so a non-JSON 401 will not trigger normal expiry path. Timeouts cover opening/headers, not response-body completion. | [mobile transport](../../lib/src/core/network/mechanization_mobile_api_client.dart:807), [auth transport](../../lib/src/features/auth/data/remote/auth_remote_data_source.dart:125). Preserve structured error payloads/headers; inspect status before relying on JSON; apply complete-request timeout and controlled retries. |
| A23 / P2 | **Tenant login, OTP timing, and unsupported-account feedback incomplete.** Remote login throws on tenant choice; repository never forwards a selected tenant. OTP screen ignores resend/expiry values. Unsupported role starts asynchronous logout but verify handler returns success, allowing a verified-success message before sign-out. | [login remote](../../lib/src/features/auth/data/remote/auth_remote_data_source.dart:53), [login routing](../../lib/src/features/auth/presentation/screens/login_screen.dart:160), [OTP verify](../../lib/src/features/auth/presentation/screens/otp_verification_screen.dart:131). Finish tenant selection/cooldown and return a routing/access failure to OTP UI. |
| A24 / P1 feature gap | **Farmer/technician saves are local-only and not durable.** Farmer registration creates in-memory pending-sync profile; submit/confirm/dispute only mutate seeded lists. Technician maintenance saves an in-memory record and locally marks tractor available/maintenance, which next API refresh can overwrite. Parts inventory is demo data. | [farmer repository](../../lib/src/features/farmer/data/repositories/farmer_local_repository.dart:5), [registration](../../lib/src/features/auth/data/repositories/auth_local_repository.dart:99), [technician repository](../../lib/src/features/technician/data/repositories/technician_local_repository.dart:5), [maintenance save](../../lib/src/features/technician/presentation/screens/log_maintenance_screen.dart:206). Decide app scope. Farmer integration must live on a server; maintenance writes need a backend contract beyond supplied endpoints. |
| A25 / P2 | **Lookup/registry support is mostly unused.** Request entry requires raw farmer/plot/service IDs; farmer creation and plot mapping wrappers have no caller; QR method has no scanner caller; fuel log unused. Hardcoded three-service enum labels unknown types as Ploughing. | [register request form](../../lib/src/features/manager/presentation/screens/operations_requests_view.dart:1066), [service mapping](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:2104). Wire searchable pickers and registry UI, use server service codes/labels. |
| A26 / P2 | **Redundant bucket loads and brittle all-or-nothing startup.** Union starts 12 requests, then nine overlapping request bucket calls (including undocumented `canceled` spelling), then optional farmer-boundary calls. Failed bucket calls can be silently ignored; terminal states may be missed without `all`. | [startup](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:118), [bucket loop](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:1098). Use supported filters with pagination, capability-aware independent loads and visible per-module errors; avoid duplicate requests. |
| A27 / P2 | **Some record identities are inferred/hide valid rows.** Calendar parser prefers tractor display label over its ID; dispatch repairs this by matching registry. Farmer directory deduplicates on phone even when IDs differ, hiding distinct farmers who share one phone. | [calendar mapping](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:1400), [farmer dedup](../../lib/src/features/manager/data/repositories/union_operations_repository.dart:1224). Keep stable server IDs; don't merge distinct farmers based on phone without an explicit business rule. |
| A28 / P2 | **Issue reporting is overgeneralised.** All problem reasons, including weather/farmer absence, become warning-severity maintenance-ticket requests. There is no severity or maintenance-ticket choice. | [reportProblem](../../lib/src/features/operator/data/repositories/operator_local_repository.dart:504). Map problem types intentionally and let appropriate issues open maintenance tickets. |
| A29 / P2 | **Local boundary distance is distance to nearest corner, not boundary edge.** An operator close to a long plot edge may see a much larger distance. It ignores server tolerance/accuracy policy. It is currently advisory and does not replace the server start check. | [geofence distance](../../lib/src/additional_data/location/domain/usecases/check_plot_geofence.dart:76). Compute point-to-segment distance, retain tolerance, and label any local estimate appropriately. |
| A30 / P2 | **Status colours differ from portal contract.** Examples: dispatched is purple instead of amber; in-progress green/purple instead of blue; completed warning instead of green. | [operator colours](../../lib/src/features/operator/presentation/widgets/operator_widgets.dart:53), [union colours](../../lib/src/features/manager/presentation/widgets/operations_widgets.dart:168). Centralise documented palette or use server colour consistently, with accessible contrast. |

## Platform, deployment and project hygiene

| Finding | Evidence and limitation |
|---|---|
| Android release uses debug signing and example application ID. | `android/app/build.gradle.kts:20` and `:33`. Configure production identity/signing before store distribution; no release package/signature was tested. |
| Google Maps/Routes keys are in Dart/native source. | `operator_widgets.dart`, Android manifest, iOS AppDelegate. Client Maps keys are visible by design; this alone does not prove compromise. Confirm separate API/platform restrictions, signing certificates, enabled APIs and quotas in cloud console. Routes calls contain package/certificate headers, but local code cannot prove cloud enforcement. Values are intentionally omitted from this report. |
| Broad cleartext allowance and a legacy host exception remain. | `android/app/src/main/AndroidManifest.xml:10`; `ios/Runner/Info.plist` has the legacy host exception. The unused unauthenticated `ServiceOrdersRemoteDataSource` was removed on 2026-10-27. Review the remaining platform exceptions against the active API hosts before release. |
| Web/desktop folders do not imply these features work there. | Network clients and route widget use `dart:io` `HttpClient`/`Platform`; no web transport abstraction. Google Maps plugin support also needs platform-specific implementation. No browser or desktop app smoke test was performed. |
| macOS release sandbox has no network-client entitlement. | `macos/Runner/Release.entitlements` only enables sandbox; GPS usage configuration is also incomplete for macOS. Treat macOS deployment as unverified/incomplete. |
| Logging can reveal operational/location data. | GPS/route debugPrint calls are not consistently `kDebugMode` gated. Mobile JSON logger redacts many secrets but not farmer OTP submitted under key `code`; QR token appears in request URL logs. Restrict logging and redact by schema/path. No server-side log exposure was tested. |
| Local save/documentation examples are stale. | The obsolete Drift document/test and demo widget test were removed on 2026-10-27; README is still a Flutter starter. Several farmer/technician dates are hardcoded September 2026. Update remaining docs/tests after intended supported workspaces and storage approach are decided. |
| Async/resource handling needs cleanup. | Root disposes preferences but not owned repositories; repository pollers are shared and screen-owned; several long-running form submissions lack generic-error/finally handling. Preference load storage failures are unhandled. Add explicit lifecycle ownership and loading/error recovery for real platforms. |

## Contract questions that cannot be settled from this client

1. Confirm exact deployed shapes for dashboard, tractor `live`, `/api/app/me`, paginated data and dispatch responses. Prose examples are abbreviated; client assumptions are not proof of a server bug.
2. Postman adds integration webhook GET and general vehicles GET not detailed in the prose. Obtain their schemas and precise webhook-read scope.
3. Confirm whether any deployed scheduling endpoint auto-dispatches with both resources; the lifecycle says separate dispatch, while the current UI accommodates both possibilities.
4. Confirm the intended product scope: supplied document calls this the operator/union app and names Shamba Bora as another team's application. Local farmer and technician workspaces should not be represented as fully integrated production functionality.
5. Obtain the maintenance/parts API contract if those local technician features are required. Do not invent endpoints or mark tractor fitness remotely using an unrelated action.

## Suggested repair order and meaningful acceptance checks

1. **Correct data/session integrity first:** A01–A08. Convert the supplied reproduction probes into expected-correct regression tests after fixes. Verify account A → logout → account B during delayed reads/actions, brief/full response merging, complete/history, override approval expiry, tractor eligibility, terminal request states, and documented trail shape.
2. **Finish capabilities and policy:** support read-only and restricted staff, isolate module failures, enforce UI permission visibility, restore valid daily inspection, refresh phone/start checks, reset navigation on expiry.
3. **Make state consistent:** canonical jobs and feed membership, paginated reads/history, timezone/units, actual pause-excluded duration, time-window conflicts, related request/backlog refresh after job writes.
4. **Complete required feature flows:** operator confirmation and multipart evidence; registry pickers and writes; fuel; server farmer integration and maintenance contract only within agreed scope. Preserve actual payment status and verification evidence.
5. **Repair validation/reliability/release:** structured errors and Retry-After, durable retry queue if offline is required, realistic mocked widget tests, native GPS/maps/secure-storage checks, production signing/config and appropriate log redaction.

Final acceptance needs a test tenant and linked accounts/tractors/plots to exercise a full request → approval → scheduling → dispatch → inspection/start → pause/resume → complete → farmer proof → verify → close sequence. Include permitted override, denied non-location check, dispute, job cancellation returning request to backlog, expired session, rate limit and offline retry. This audit did not mutate real backend records.

## Artifacts

- [Every endpoint explained, with app connection status](endpoint_guide.md)
- [Extracted Postman examples](postman-endpoint-inventory.json)
The historical defect probes and source fingerprint snapshot were removed on 2026-10-27 after the audited behavior and source had changed.
