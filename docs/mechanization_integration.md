# Mechanization mobile integration

This document records the current operator and union-manager behavior implemented against the supplied Mechanization API v1 and Postman collection. The farmer application remains a separate product. This app only supports the documented operator-assisted farmer confirmation flow.

## Supported workflow

### Operator

1. The dashboard loads `/me` and the operator's active jobs. An assignment returned by `/me.today` remains visible when its detail endpoint temporarily fails, with a clear access warning.
2. The operator opens the full job, accepts it when required, starts the journey and records arrival.
3. The phone location and assigned tractor tracker are displayed separately. The backend start check remains authoritative for geofence, freshness, proximity, inspection and assignment rules.
4. A passed daily inspection unlocks optional before-service photos. Photos never block starting or completing work.
5. During work, the operator can upload optional progress photos and pause or resume using the documented endpoints.
6. Completion submits the reported work measurements. Optional after-service photos can be uploaded before completion.
7. Farmer satisfaction is recorded separately using the farmer's existing PIN or a requested SMS code. A dispute sends a note and flags the job for union review.
8. Union verification and closure remain separate actions. Operator confirmation does not verify, close or mark a job paid.

### Union manager

1. Review, approve, return or reject service requests.
2. Schedule an eligible tractor, operator and time window.
3. Dispatch jobs and monitor them through the dashboard, jobs view and calendar.
4. Review exceptions, overrides, inspection results, work measurements and farmer confirmation.
5. Verify or flag completed work, then close it with the actual payment status.

## Screen refresh behavior

- Sign-in loads the relevant dashboard. Other screens load on first visit.
- Returning to a loaded screen uses its cached data until the user refreshes that screen.
- Pull-to-refresh and refresh buttons reload only the data required by the visible screen.
- Concurrent refreshes of one screen share the same request, and errors remain attached to that screen.
- A successful action applies its response to the affected record and fetches detail only when needed.
- Session changes clear screen-load state and data caches. Late responses from an older session or pre-action read cannot overwrite newer state.
- The visible live-job map owns one approximately 12-second update cycle while the app is foregrounded. It stops when another route covers the map or the app enters the background.

Pagination can produce several HTTP requests for one refresh. That is expected and is different from reloading unrelated screens.

## Calendar behavior

Operator and manager schedules use the same three-day time grid and date selector. The time grid scrolls horizontally so each day and job card retain a readable width. The page can scroll vertically through the hours.

When jobs overlap, the grid displays at most two visible lanes and a `+N more` control. Opening it shows every job in the overlap group in a scrollable panel. Selecting a visible or hidden entry opens the full job. Overnight assignments appear on both affected dates. Status is written on each job card, so a separate color legend is not shown.

The manual calendar renderer lives at `tool/previews/calendar_preview_test.dart`. Run:

```powershell
flutter test --no-pub --dart-define=CALENDAR_PREVIEW=true tool/previews/calendar_preview_test.dart
```

It writes review images under `build/review/` and is not part of the normal automated test scan.

## Location and map rules

| Item | Source | Behavior |
| --- | --- | --- |
| Operator | Current device GPS through Geolocator | Displayed with a person marker when the reading is valid and fresh. |
| Assigned tractor | Tractor live response, job detail `tractor_live`, or job path `live` | Matched by the assigned tractor ID. The newest valid captured fix wins. |
| Farm | Job plot boundary; centroid only as a display fallback | Three or more valid boundary points form the local polygon. A centroid alone does not establish geofence presence. |
| Recorded tractor trail | `GET /api/v1/mech/jobs/{id}/path`, `data.path` | Displays recorded tractor movement with inside/outside state when supplied. |
| Road route | Google Routes from the chosen fresh phone or tractor position | Provides directions toward the farm; it is not recorded work history. |

Phone readings older than 180 seconds are not sent as current field evidence. A tractor marked online still needs a recent valid fix to count as live. Invalid coordinates are ignored.

When phone and tractor readings are both fresh, phone accuracy is 25 metres or better, and the positions are within 25 metres, the map can group them into a tractor-with-person marker. This is a visual grouping and does not prove the operator is aboard.

The farm centre is a map destination only. Local boundary estimates are guidance. `POST /jobs/{id}/start-check` and `POST /jobs/{id}/start` enforce the server's `phone_on_plot`, `tractor_on_plot`, tracker freshness, phone-to-tractor proximity, inspection and override policy.

## Photo uploads

`POST /api/v1/mech/jobs/{job_id}/photos` uses `multipart/form-data`:

| Field | Value |
| --- | --- |
| `kind` | `before`, `during`, `after`, `issue` or `other` |
| `caption` | Optional text |
| `file` | JPG, PNG or WebP binary bytes, maximum 8 MB |

The app sends image bytes, filename and MIME type. It does not send Base64 JSON or a local file path. A failed upload retains the selected image for retry. Successful uploads refresh that job's photo collection. Camera/gallery recovery is associated with the current job, operator and photo kind, but it is not a durable offline upload queue.

## Farmer confirmation

The farmer enters credentials on the operator's device in a two-step bottom sheet. The first step collects a PIN or SMS code. The second step offers an optional 1–5 star rating or a service dispute. The app never retrieves, stores or locally validates the farmer's secret.

PIN confirmation sends:

```json
{"method":"pin","pin":"0123","rating":4}
```

SMS confirmation first requests `POST /jobs/{id}/farmer-otp`, then sends:

```json
{"method":"otp","code":"123456"}
```

A PIN remains a string so leading zeroes are preserved. Selecting **Skip rating** omits `rating`; selecting a star sends its integer value in the same confirmation request. A dispute sends `dispute: true` and a required note. Dismissing the sheet sends nothing, repeated taps cannot create duplicate requests, and a rejected credential returns to the first step while retaining the selected rating. Confirmation succeeds only when the server returns confirmation state such as `farmer_confirmed_at`.

## Validation and remaining field checks

The normal suite currently covers transport payloads, multipart bytes, confirmation, job lifecycle, screen-specific refresh, calendar behavior, map markers, tracker freshness, geofence calculations and union verification/closure. Run `flutter analyze --no-pub` and `flutter test --no-pub` after integration changes.

Production acceptance still requires linked test accounts, a mapped farm and an active tracker. On a physical device, compare the assigned tractor ID, fix timestamp, reported age and coordinates with the marker; compare the phone marker with the device GPS accuracy; and compare the farm polygon with its saved backend boundary. Complete one authorized test job through photo upload, farmer confirmation, union verification and closure.

Known product gaps include the absence of a manager fleet map, no durable offline action/photo outbox, incomplete Swahili coverage, limited viewing of previously uploaded photos and technician maintenance data that still depends on local seeded behavior.
