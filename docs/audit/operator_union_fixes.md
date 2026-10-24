# Operator and union manager flow repairs

Implemented against the supplied **KwanzaTrack Mechanization API v1, September 2026** and Postman collection. This is the implementation update following the [baseline audit](project_audit.md); the baseline's connection labels and defect probes describe the earlier source snapshot.

## Scope and farmer-app boundary

This change repairs the existing **operator and union manager mobile client**. It uses the mobile authentication and `/api/v1/mech` endpoints. Farmer-facing registration, ordering, farmer confirmation/disputes, integration tokens, and webhooks remain the responsibility of the separate farmer application and its server.

No integration `client_id`/`api_key`, integration-token client, webhook receiver, or new farmer-facing workflow was added to Flutter. The existing legacy farmer demo files were not changed. Union staff can read the farmers/plots synced into the shared backend and use the documented staff request-registration endpoint. The existing documented staff manual-confirmation action remains available for phone/office confirmations.

## Supported core sequence

```text
Request arrives in shared backend from farmer application
  -> union reviews and approves
  -> union checks resource availability and schedules
  -> union dispatches
  -> operator accepts, travels, and arrives
  -> daily inspection when policy requires it
  -> fresh phone fix and server start-check
     -> start normally, or request/await a permitted override
        and start with its unexpired approved override_id
  -> operator works, pauses/resumes, and completes with reported acres
  -> completed work remains in history awaiting farmer-app confirmation
  -> union reads backend farmer_confirmed_at and verification evidence
  -> union verifies acres, then closes with actual payment status
```

Completion does not confirm, verify, mark paid, or close a job. With `require_farmer_confirmation:true`, verification requires the backend's confirmation timestamp. Setting that policy false permits the documented exception. Cancelling a job with `cancel_request:false` refreshes the related request and backlog instead of treating the demand itself as cancelled.

## Changes and API reference

| Change | Result | Contract reference |
|---|---|---|
| Merge brief/full job and request responses | Omitted fields retain loaded detail; explicit nulls clear fields; reassigning a related record ID drops the old record's details. Farmer/plot boundaries survive action responses. | 2.5 brief/full jobs; action responses may be brief |
| Session and response guards | Logout/account changes invalidate old work, polling and scoped caches. Old 401 responses identify their original token. Slow reads cannot undo newer job mutations. Missing-record screens/commands handle removed records. | Auth 401 handling; tenant/union scope |
| Correct request and resource states | Completed/closed requests retain their actual states. Working, suspended, unavailable, decommissioned and unknown tractor states do not become available. Completed work releases locally inferred resource eligibility. | 2.7 tractor statuses; 2.10 request lifecycle; section 4 lifecycle |
| Paginated reads and canonical action updates | Jobs, terminal history, request lists and farmer lookups follow pagination metadata. Local job mutations update the manager calendar as well as Jobs. Paused/verified jobs are included. Precise event end times are retained. | Pagination convention; 2.4 calendar; 2.5 jobs |
| Policy-aware inspection and start | Read today's inspection; retain policy; allow inspection update. Capture a new phone fix before start/check and let the server evaluate eligibility. An optional implement is not a hard local prerequisite. | 2.3 policy; 2.6 start checks; 2.7 inspections |
| Complete override sequence | Retain pending/approved/denied state, poll job detail, reject expired approvals locally and forward approved `override_id` to start. A failed dry run no longer prevents the server from evaluating a submitted approval. Non-location checks remain server enforced. | 2.6 override flow |
| Accurate progress and trail | Progress subscribes to repository changes; work time uses pause-excluded server `work_seconds`. Trail parses documented `data.path`, retaining inside/outside flags for segment colours. | 2.5 `work_seconds`; 2.8 path/verification |
| Correct units and local times | `reported_acres` remains acres on the wire and is converted before display in hectares. Offset timestamps are normalised for local display; schedule parsing accepts times with or without seconds. | Section 1 conventions |
| Request pickers | Union request registration selects synced backend farmers, mapped plots and service IDs rather than requiring manually entered IDs. Distinct farmer IDs are not hidden merely for sharing a phone. | 2.10 staff registration; 2.12 registry/pickers |
| Evidence, confirmation and payment | Staff can review reported/verified acres, tracker estimates and confirmation state. Verification fetches current detail. Close dialog explicitly selects unpaid/deposit/paid/waived instead of automatically marking paid. | 2.5 union desk; 2.8 verification; 2.9 confirmation |
| Capability checks | Manager and operator commands check their documented permissions; read-only accounts can reach the read workspace. A forbidden/unavailable optional module does not discard all readable data. | 2.2 permissions |
| Retry/error handling | Field retries reuse the same event ID within the current session. Start-denial checklists/field errors are preserved; HTTP body reads are bounded; HTML 401 responses still invalidate the right session; `Retry-After` suppresses early repeated requests. | Offline replay convention; rate limits; 2.6 errors |
| Foreground refresh | Visible operator/union shells refresh every 30 seconds without replacing already-loaded views with initial-load skeletons. Start readiness polls every 6 seconds; progress refreshes every 12 seconds. Pollers pause with application lifecycle and stop when screens are disposed. | 2.6 periodic start-check/detail polling; live job/tractor data |

The server remains authoritative for all permissions, licences, assignments, geofences, tractor fitness, work-state transitions and booking conflicts. UI checks improve behaviour; they do not replace server validation.

## Verification

**35 focused tests passed**, including the subsequent [operator dashboard trace and repair](operator_dashboard_trace.md). The original scoped analysis of `lib` and the six focused test files reported **no issues**; analysis of the subsequent dashboard changes also reported **no issues**.

The checks include:

- the seven originally reproduced client defects, plus slow reads, account switching, retained data after failed module refreshes, pagination, booking overlap, permissions, retry IDs, override expiry and start-denial details;
- actual HTTP requests to a local test server verifying bearer headers, endpoint paths, start/override/phone fields, completion acreage units, structured 422 errors, non-JSON 401 handling and Retry-After;
- a simulated shared backend enforcing request approval, scheduling, dispatch, operator inspection/start/pause/resume/completion, confirmation arriving from the other farmer application, union verification and closure;
- cancellation returning demand to backlog;
- a widget test choosing **waived** in the manager payment dialog and asserting it reaches the close endpoint;
- the existing operator and union repository tests.

Reproduce the focused checks:

```powershell
flutter analyze --no-pub lib test/mechanization_flow_test.dart test/mechanization_transport_test.dart test/mechanization_data_test.dart test/operator_union_lifecycle_test.dart test/operator_local_repository_test.dart test/union_operations_repository_test.dart

flutter test --no-pub test/mechanization_flow_test.dart test/mechanization_transport_test.dart test/mechanization_data_test.dart test/operator_union_lifecycle_test.dart test/operator_local_repository_test.dart test/union_operations_repository_test.dart
```

The older `test/widget_test.dart` and `test/offline_database_test.dart` were not replaced in this flow repair. The baseline audit documented their demo assumptions and removed database dependencies. Therefore the focused green result does **not** mean the entire legacy test directory is green.

## Remaining validation and separate work

- No real backend job was mutated. Test a dedicated union/operator account pair, a linked tractor/tracker and a mapped plot on a phone before production use. Check GPS permission denial/recovery, actual geofence failures, SMS, override notifications and external farmer confirmation delivery.
- Field retry IDs currently survive retries **within the running session**. A durable offline cache/outbox with replay after process restart is separate work.
- Photo/signature uploads, operator-assisted farmer proof, fuel-log UI, broader registry writes and technician maintenance writes were not added. Farmer-facing logic remains in the separate app as requested.
- Tenant-choice login and the remaining non-core audit items are not all resolved by this change. The baseline audit is retained as a record, not a claim that every finding has now been fixed.
- Existing working-tree edits were preserved. No commit, deployment or production API configuration change was made.
