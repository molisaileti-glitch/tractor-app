# User guidance and map review — 25 October 2026

## Scope and conclusion

Later update: [screen-specific refresh and farm boundary changes](screen_refresh_and_geofence.md) replaces the earlier polling behavior described below. It also clarifies that the API's operator-to-tractor proximity rule remains enforced.

Reviewed the current app source, concentrating on operator and union manager journeys, role routing, calendar navigation, GPS and tracker reads, plot geometry, photos and farmer confirmation. Compared those paths against the supplied KwanzaTrack September 2026 API guide and Postman collection. The supplied screenshot is a reference for the multipart photo request.

The main operator/manager workflow is connected, but this review does not establish that every deployed tracker, farm boundary or phone reading is correct. No authenticated production session or physical device was exercised in this review. Farmer-app business logic was not changed.

## Confirmed defects corrected in this review

1. **Dashboard/history/profile could remain stale after a repository refresh.** `OperatorShell` previously constructed its screen widgets outside its repository listener. It now creates them inside the listener, so fresh status, confirmation and assignment data reach the visible screen without changing tabs. Regression coverage exercises the real shell.
2. **An older tracker reading could replace a newer reading.** Tractor-list, job-detail and path responses now merge by tractor ID and capture time (`fix_time`, or response time minus `age_s`). A null/missing list fix does not erase a valid job/path reading. Retained readings continue to age; they are not refreshed merely because a response arrived. Equal-time readings can update online/offline state.
3. **Missing farm geometry hid available phone/tractor GPS.** The map now displays available real coordinates even without farm geometry. It draws no invented farm polygon or route destination. Arrival/progress and job details explain missing plot coordinates. Map bounds also include the entire recorded trail.
4. **Some job-detail buttons led nowhere.** Scheduled, confirmed-completed, verified, closed, cancelled and flagged jobs now show the relevant next-step guidance and a disabled status action. Pending farmer confirmation remains actionable.
5. **Manager confirmation guidance excluded the operator-assisted route.** It now explains farmer PIN/SMS confirmation with the operator, farmer-app confirmation and the authorised union officer option.
6. **Manager plot parsing accepted invalid coordinates.** It now rejects non-finite/out-of-range latitude/longitude values, including invalid fallback centroids. A polygon requires at least three valid corners. The map label says plot centre rather than claiming an exact request coordinate.
7. **Road-route retry guidance lacked a retry action.** Failed route requests now have an explicit Retry control. Arrival/progress explain that a dashed line is a direction guideline, not a road route, and expose phone GPS failure messages.
8. **Long status labels competed with job text.** Status labels can wrap within the dashboard, history and job-detail cards rather than consuming unlimited row width.

## Where map coordinates come from

| Item | Source | What is displayed / limitation |
| --- | --- | --- |
| Operator | Current device GPS through `GeolocatorLocationRepository` | A person marker at this phone's fresh coordinates. This is not a remote feed for all operators. |
| Assigned tractor | `GET /tractors?mine=1&live=1`, job detail `tractor_live`, and job path `live` | Looked up using the job's tractor ID. The newest timestamped reading wins. Offline/old fixes are last-known positions. |
| Farm | Job detail `plot.boundary`; fallback `plot.centroid` | Three or more valid corners form a polygon. A centroid alone gives one farm marker, not a geofence polygon. |
| Recorded work trail | `GET /jobs/{id}/path`, `data.path` | Green inside, red outside, grey unknown. This is recorded tractor movement, not directions to the farm. |
| Road directions | Google Routes from the selected fresh tractor/phone origin | Destination is the approximate plot centre, not a surveyed entrance. Availability depends on the configured map service and road coverage. |
| Union request map | Request plot geometry, enriched from farmer plot detail where available | Shows the selected farm. It is not a fleet-wide live map. |

Operator live job maps request updates approximately every 12 seconds while their route is visible and the app is foregrounded; this is polling, not continuous turn-by-turn navigation. Phone fixes older than 180 seconds are omitted. Tractor fixes require `online` and a known age of at most 180 seconds (with a 30-second clock tolerance) to be considered live. Older tractor coordinates can remain visible as last known.

Separate person/tractor icons appear when their readings differ. A combined icon is used only for fresh locations within 25 m and phone accuracy at most 25 m; tapping it shows both readings. Proximity does not prove that the operator is aboard the tractor. GPS coordinates are validated before drawing. Actual field accuracy still depends on phone accuracy, correct tractor/tracker association and current backend data.

The backend `POST /jobs/{id}/start-check` and `start` response remain authoritative for starting work. A local phone check or a farm marker alone does not prove the tractor is inside the geofence.

## User journeys

**Operator:** dashboard/calendar assignment → full job → accept assignment → start journey → check phone location → record arrival → before-service photos → required daily inspection → backend start-check → start work or request an allowed override → pause/resume and work photos → after-service photos and completion → farmer PIN/OTP confirmation or dispute → history while union verifies/closes.

The arrival screen already provides numbered workflow steps and failed-check details. Photos are accessible from arrival, work progress, completion, job detail and history. Do not add a blanket frontend photo-count gate without a documented backend policy. Completion, farmer satisfaction, union verification and closure remain separate states.

**Union manager:** requests → review farm and request → approve/return/reject → schedule tractor/operator/time → dispatch → monitor jobs/calendar and resolve exceptions/overrides → review completed work evidence and farmer confirmation → verify or flag → close. Calendar jobs open full job detail; overlapping jobs can be expanded without changing their scheduled times.

## Screenshot / photos contract

`POST /api/v1/mech/jobs/{job_id}/photos` uses multipart form-data:

| Key | Type | Example |
| --- | --- | --- |
| `kind` | Text | `after` |
| `caption` | Optional text | `Finished rows` |
| `file` | Actual binary file | JPG/PNG/WebP, maximum 8 MB |

The app's camera/gallery screen supplies the bytes. The API client builds the multipart request with a generated boundary, file name and MIME type. A local path is not sent as a substitute for file contents. Existing transport tests inspect a real local HTTP request, including binary data and fields. Failed uploads retain the selected image for retry. Farmer PIN and SMS code use their separate confirmation endpoint; they do not belong in the photo form.

## Remaining gaps and suggested next work

- **A manager live fleet map is absent.** The APIs provide tractor live coordinates, but manager tractor data is not wired to a fleet map. Add that as a separate feature if the manager needs to see all tractors together. The supplied API guide does not describe a remote GPS feed for every operator; that would require a defined backend contract and operator location publishing.
- **Farm-centre directions are approximate.** A centre derived from corners is not necessarily a road entrance or even inside an irregular plot. An explicit access/entrance coordinate would improve navigation if the backend supports one.
- **Full job-map overlays need further visual review on a physical small screen.** The existing job header/action sheet can cover map badges or bottom route notices; arrival/progress expose the map and textual guidance separately. These overlays were not redesigned in this review.
- **Uploaded evidence review is limited.** The operator photo screen currently lists uploaded photo kind/caption; it does not yet open previously uploaded image URLs. The union evidence dialog shows verification metrics, rather than a complete photo gallery.
- **Language coverage is incomplete.** The app supports English/Swahili, but a number of workflow/error messages remain English literals. These should be moved into the localisation resources before a full Swahili usability review.
- **The technician workspace still contains seeded local maintenance/parts data.** It is outside the requested operator/manager repair scope and should not be represented as fully connected production maintenance. The operator and union repositories start with empty lists despite their `seeded` constructor names and load API data.
- **No offline submission outbox for this workflow.** A failed photo/action needs an explicit retry; camera recovery is not a durable synced queue.

## Validation and field check

All 56 focused operator/union regression tests passed. Flutter analysis of `lib` and the updated map/flow tests reported no issues. These checks cover source/API parsing, timestamp ordering, tractor ID isolation, GPS-only maps, stale readings, distinct/combined markers, dashboard refresh, calendars, actions, multipart photo data and PIN/OTP confirmation. See `build/location_guidance_full_tests.log` and `build/location_guidance_analyze.log`. This is the focused suite, not a claim that every legacy test in the repository passes.

On a device, compare the assigned tractor's ID/IMEI, `fix_time`, `age_s`, latitude and longitude with its marker; compare the person marker with that phone's GPS and accuracy; then compare the farm corners with its saved backend boundary. Move phone and tractor separately and then together. Test GPS permission denial, an offline tracker and a plot with missing geometry. Finally complete a real authorised test job, upload evidence, confirm with the farmer and refresh the union job. Those checks distinguish map rendering defects from incorrect/stale backend tracker data.
