# Calendar and job map repairs — 25 October 2026

## Calendar design and log findings

Latest UI update: the colour legend has been removed from both calendars at the user's request. Calendar job cards keep their existing status badges, colours, positions and sizing. Completed, Verified and Closed remain distinct, with English and Swahili labels. Horizontal scrolling, two visible overlap lanes and the expandable +more sheet are preserved. A rendered sample preview is in `build/review/calendar-tablet.png`.

Outside the calendar, job status badges are anchored to the top-right edge of operator dashboard/history/detail/map cards and union dashboard/job/detail cards. Arrival, progress and completion also align their status badges to the right. Labels wrap within bounded space on small screens. Dashboard summary tiles share the height needed by their content instead of clipping wrapped labels, and the focus-section heading adapts to small widths. Job actions, API calls and optional photo rules are unchanged.

Both operator and union manager schedules retain the original three-day **time-grid calendar** and week/date selector. The time grid scrolls horizontally with its day headings and job blocks together, and the containing page scrolls vertically through the hours. Each day has enough width for readable jobs instead of shrinking all columns into the viewport. Overnight entries remain visible on both days.

Compact sizing uses a 320-pixel minimum day width and 64 pixels per hour (previously 480 and 100). Day columns share available space on tablets, and scale up when larger accessibility text needs more room. Short blocks have a 52-pixel minimum height and show only the summary that fits; full details remain available on tap.

Overlapping groups show at most two job blocks, followed by a **+N more** control. This opens a large, scrollable panel containing every job in that group, including the two visible jobs. Selecting any entry opens the current full job details. Tapping a day heading opens all assignments for that day. Hidden jobs are only hidden visually; the API data is unchanged. Separate time groups stay at their own times. Short adjacent jobs share lanes when their minimum readable display heights would otherwise collide. Short blocks show only text that fits and expose full details on tap.

The attached device log `1d9eae38-8e76-400a-ba21-75c9b41ae74e/Pasted text.txt`, lines 221 onward, reports a **19-pixel bottom RenderFlex overflow** at the old operator schedule line 476. The inner text Column had only about 46 pixels of available height. The manager grid split simultaneous jobs into increasingly narrow lanes. The shared time-grid now limits visible lanes, clips content to its own day/grid, and calculates a text-line limit for each block instead of squeezing a fixed Column into a short appointment.

Operator cards continue loading current job detail before navigation. Manager cards now do the same and open a full job page reusing the existing job information, evidence and permission-controlled management actions. Errors opening a job are displayed instead of navigating to missing data. Job references are retained separately from request IDs in the manager model.

## API and location boundaries

- **Recorded tractor trail:** documented `GET /api/v1/mech/jobs/{id}/path`, returning `data.path` with timestamps, latitude/longitude, speed and inside/outside flags, plus `data.live`.
- **Tractor position:** the assigned tractor's backend tracker, from tractor live responses, job detail `tractor_live`, or path response `live`. Live payloads are now consumed from job detail and path responses as well as the tractor list.
- **Operator position:** this phone's Geolocator GPS reading. It uses a person icon instead of the ordinary blue pin. It never substitutes tractor or farm coordinates for a missing phone fix.
- **Nearby operator/tractor markers:** when both fixes are fresh, phone accuracy is 25 metres or better, and their reported locations are within 25 metres, the map displays one tractor-with-person marker at the tracker location. Tapping it shows both GPS readings. This is visual grouping and does not assert the operator is aboard. Missing/stale or inaccurate fixes do not merge; separated readings remain separate icons.
- **Road directions to the farm:** the existing Google Routes request. A selector explicitly chooses tractor or operator as the origin; this is a planned route, not a recorded trail. A tractor route requires a fresh online tracker fix. An operator route requires a recent valid phone fix. Stale tracker positions can still appear as last known locations.
- **Farm/geofence:** backend plot boundary or centroid. A trail endpoint is not labelled as a farm when plot coordinates are missing.

Job detail, journey/arrival and work-progress maps now share GPS/tracker wiring. Their map refresh runs every 12 seconds while foreground and on the current route; background timers stop. Work-progress keeps its existing detail/path polling. Invalid or out-of-range tracker/path coordinates are ignored. Phone fixes older than 180 seconds are hidden; tracker freshness also checks timestamps/age rather than treating `online: true` alone as proof of a live fix.

There is no separate recorded operator-trail endpoint in the supplied documentation. Phone position and selectable road directions are available; the documented historical job trail belongs to the tractor.

## Backend observations from the supplied log

The sampled four job-path responses have **empty `path` arrays**. Two responses have `live: null`; the other two include an offline tractor position whose reported age is about **59,180 seconds (16.4 hours)**. These responses cannot supply a recorded tractor trail or a fresh live tractor position. The app now communicates absent trails and last known fixes instead of inventing them.

The log also contains **HTTP 503 Service Unavailable** responses, with Laravel's `PreventRequestsDuringMaintenance` in the stack. These are separate server-side availability failures, not calendar layout exceptions. Existing refresh error handling retains already loaded data; operator schedule now also displays its sync warning.

## Verification

All **44 focused tests** pass across the seven operator/union test files, including `test/calendar_map_flow_test.dart`. Coverage includes 12 overlapping 15-minute assignments, 320×568 and 1200×1920 viewports, double-sized text, horizontal scrolling, expansion into a scrollable full job list, overnight dates, visible and hidden manager job navigation, valid/invalid tracker fixes, stale tracker status, actual map marker coordinates, a rasterised person icon, nearby marker grouping and trail rendering. Google Maps is replaced by a fake platform view for widget tests; no production API writes or real Google Routes requests are made.

`test/calendar_preview_test.dart` renders the actual calendar widget and expanded panel with labelled sample jobs. Run `flutter test --no-pub --dart-define=CALENDAR_PREVIEW=true test/calendar_preview_test.dart` to write screenshots under `build/review/`. This preview test loads a system font for readable screenshots and is skipped during normal test runs. The preview test also passed and the generated screenshots were visually inspected.

The existing six-file operator/union regression suite remains green. Full legacy tests with previously documented obsolete database dependencies are outside this check. Physical-device GPS, Google Maps/Routes rendering and real tracker movement still need an on-device run. Farmer-app logic is unchanged.
