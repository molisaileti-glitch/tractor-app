# Shamba Bora tractor calendar and map porting guide

This guide moves the SB Mechanization calendar and live tractor map into the
Shamba Bora tractor module while preserving their current behaviour.

## 1. What to copy

### Calendar

Copy these files first:

```text
lib/src/components/schedule_assignment.dart
lib/src/components/job_schedule_calendar.dart
lib/src/components/app_empty_state.dart
```

The operator and union screens use the same `JobScheduleCalendar`. Their only
difference is how a backend job is converted into `ScheduleAssignment` and
which detail screen opens when a card is tapped.

Reference integrations:

```text
lib/src/features/operator/presentation/screens/operator_schedule_screen.dart
lib/src/features/manager/presentation/screens/operations_schedule_view.dart
```

The shared calendar preserves:

- a horizontally scrollable three-day time board;
- a horizontally scrollable seven-day selector;
- date picker and previous/next-day controls;
- readable minimum card height at large text sizes;
- two visible lanes when jobs overlap;
- a `+N more` card when more than two jobs collide;
- a scrollable bottom sheet containing every hidden job;
- status text on every job card;
- a centred empty state for a day with no assignments;
- tapping either a visible or expanded job to open its full details;
- overnight jobs appearing on both affected dates.

### Operator live map

Copy these files:

```text
lib/src/features/operator/presentation/widgets/operator_live_job_map.dart
lib/src/features/operator/presentation/widgets/operator_widgets.dart
lib/src/features/operator/presentation/widgets/map_position_grouping.dart
lib/src/features/operator/presentation/widgets/operator_phone_location_stabilizer.dart
lib/src/features/operator/presentation/widgets/operator_location_evidence_collector.dart
lib/src/additional_data/location/domain/entities/device_location.dart
lib/src/additional_data/location/domain/repositories/location_repository.dart
lib/src/additional_data/location/data/repositories/geolocator_location_repository.dart
lib/src/additional_data/location/domain/usecases/check_plot_geofence.dart
lib/src/features/farmer/domain/entities/farm_plot.dart
lib/src/features/operator/domain/entities/operator_job.dart
```

`OperatorLiveJobMap` owns refresh and lifecycle behaviour. `OperatorMapCard`
inside `operator_widgets.dart` draws the map.

### Union trail map

The union work-evidence map is currently private inside:

```text
lib/src/features/manager/presentation/screens/operations_jobs_view.dart
```

Move `_UnionTrailMap` and its helper functions into a public file such as:

```text
lib/features/tractor/presentation/widgets/union_trail_map.dart
```

Rename `_UnionTrailMap` to `UnionTrailMap`. It renders the same farm boundary,
live tractor fix and colour-coded work trail for union verification.

## 2. Flutter packages

Add these versions or compatible newer versions to Shamba Bora:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  google_maps_flutter: ^2.13.1
  geolocator: ^14.0.3
```

The calendar itself only needs Flutter. The map needs both map and location
packages.

## 3. Calendar data adapter

Keep API models out of the calendar. Convert each tractor job into the small
view model below:

```dart
JobScheduleCalendar(
  initialDate: jobs.isEmpty ? DateTime.now() : jobs.first.scheduledAt,
  assignments: [
    for (final job in jobs)
      ScheduleAssignment(
        id: job.id,
        reference: job.reference ?? job.id,
        start: job.scheduledAt,
        end: job.scheduledEndAt ??
            job.scheduledAt.add(const Duration(hours: 1)),
        title: '${job.serviceName} - ${job.farmerName}',
        details: [
          job.plotName,
          job.tractorLabel,
          if (job.operatorName != null) job.operatorName!,
        ],
        status: job.statusLabel,
        statusKey: job.statusKey,
        color: scheduleStatusColor(
          job.statusKey,
          Theme.of(context).colorScheme,
        ),
        onOpen: () async {
          final loaded = await repository.refreshJobDetail(job.id);
          if (!context.mounted || !loaded) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TractorJobDetailScreen(jobId: job.id),
            ),
          );
        },
      ),
  ],
)
```

Use these exact status keys to retain the existing labels and colours:

```text
scheduled
assigned
dispatched
enRoute
arrived
inProgress
paused
completedPendingConfirmation
verified
closed
cancelled
flagged
```

If Shamba Bora receives snake-case statuses from the API, normalize them once
in the repository:

```dart
String calendarStatusKey(String apiStatus) => switch (apiStatus) {
  'en_route' => 'enRoute',
  'in_progress' => 'inProgress',
  'completed' => 'completedPendingConfirmation',
  _ => apiStatus,
};
```

Keep the screen refresh scoped to the calendar screen:

```dart
RefreshIndicator(
  onRefresh: repository.refreshSchedule,
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: JobScheduleCalendar(assignments: assignments),
  ),
)
```

Do not globally refresh the dashboard, map and job list when the user refreshes
the calendar.

## 4. Calendar API shape

The shared UI needs these fields from each calendar event:

```json
{
  "id": "job-22",
  "reference": "JOB-000022",
  "status": "dispatched",
  "start": "2026-11-17T08:00:00+03:00",
  "end": "2026-11-17T12:00:00+03:00",
  "farmer": "Farmer name",
  "plot": "Farm name",
  "tractor": "SB-TR-2026-002",
  "operator": "Operator name",
  "service_type": "Ploughing"
}
```

Use the mechanization calendar endpoint rather than downloading every job and
filtering it on the device:

```http
GET /api/v1/mech/calendar?from=2026-11-01&to=2027-11-30&mine=1
```

For the union view omit `mine=1`, or use the documented operator/tractor/status
filters. Parse ISO timestamps as `DateTime` values and preserve their timezone
offsets before displaying local time.

## 5. Map data rules

The three positions have different sources and must remain separate:

| Map item | Source |
| --- | --- |
| Operator marker | Current device GPS from `geolocator` |
| Tractor marker | Backend tracker fix for the assigned tractor |
| Farm polygon | Registered plot boundary returned by the backend |

Never use phone GPS as the tractor location. Never use the farm centre as the
operator or tractor location.

The map model needs:

```dart
class TractorMapJob {
  const TractorMapJob({
    required this.id,
    required this.tractorId,
    required this.plot,
    required this.status,
    this.trackPoints = const [],
  });

  final String id;
  final String tractorId;
  final FarmPlot plot;
  final String status;
  final List<WorkTrackPoint> trackPoints;
}

class LiveTractorFix {
  const LiveTractorFix({
    required this.tractorId,
    required this.latitude,
    required this.longitude,
    required this.online,
    required this.fixTime,
    this.speedKph,
    this.course,
  });

  final String tractorId;
  final double latitude;
  final double longitude;
  final bool online;
  final DateTime? fixTime;
  final double? speedKph;
  final double? course;

  bool get isLive => online &&
      fixTime != null &&
      DateTime.now().difference(fixTime!).inSeconds <= 180;
}
```

Use the existing `OperatorJob`, `TractorTrackerPosition`, `FarmPlot`,
`BoundaryPoint` and `WorkTrackPoint` directly if the tractor module is copied
as a feature package.

## 6. Map repository adapter

For easier reuse, change `OperatorLiveJobMap` to depend on an interface instead
of the concrete SB repository:

```dart
abstract interface class TractorLiveMapRepository implements Listenable {
  OperatorJob? maybeJobById(String jobId);
  TractorTrackerPosition? trackerPositionFor(String tractorId);
  Future<void> refreshWorkProgress(String jobId);
  Duration get phoneFixMaximumAge;
  double get phoneAccuracyMaximumMeters;
}
```

Then change the widget field from:

```dart
final OperatorLocalRepository repository;
```

to:

```dart
final TractorLiveMapRepository repository;
```

The Shamba Bora repository implements this interface and remains responsible
for authentication, API calls and JSON parsing. The map remains a presentation
widget.

Use it on the operator job screen like this:

```dart
OperatorLiveJobMap(
  repository: tractorRepository,
  jobId: job.id,
  routeEnabled: true,
  refreshPath: true,
  refreshOnOpen: true,
  pollingEnabled: true,
)
```

For a work-progress screen where road navigation is no longer needed:

```dart
OperatorLiveJobMap(
  repository: tractorRepository,
  jobId: job.id,
  routeEnabled: false,
  refreshPath: true,
  pollingEnabled: !submittingAction,
)
```

## 7. Path and live-position API

The live map uses:

```http
GET /api/v1/mech/jobs/{job_id}
GET /api/v1/mech/jobs/{job_id}/path
```

The path parser accepts this response:

```json
{
  "data": {
    "live": {
      "online": true,
      "position": {
        "latitude": -6.2001,
        "longitude": 35.8002,
        "speed_kph": 7.5,
        "course": 120,
        "fix_time": "2026-11-17T09:20:00Z",
        "age_s": 5
      }
    },
    "path": [
      {
        "lat": -6.1800,
        "lng": 35.7500,
        "in": true,
        "speed": 6.8,
        "t": "2026-11-17T09:00:00Z"
      },
      {
        "lat": -6.1810,
        "lng": 35.7510,
        "in": false,
        "speed": 5.4,
        "t": "2026-11-17T09:01:00Z"
      }
    ]
  }
}
```

Validate every coordinate before storing it:

```dart
bool validCoordinate(double? lat, double? lng) =>
    lat != null &&
    lng != null &&
    lat.isFinite &&
    lng.isFinite &&
    lat.abs() <= 90 &&
    lng.abs() <= 180;
```

Keep the previous valid tracker fix and trail if a later response contains an
invalid coordinate.

## 8. Polling and performance

Keep the existing behaviour:

- poll the active job every 12 seconds;
- poll only for statuses that need live updates;
- stop polling while the app is in the background;
- stop polling when this route is covered by another screen;
- stop polling while a POST action is being submitted;
- refresh only this job detail and path;
- use pull-to-refresh for an immediate manual update;
- reuse the existing phone GPS stream rather than starting a new request for
  every button tap.

The map listens to phone GPS with a five-metre distance filter and roughly a
five-second Android interval. The display stabilizer rejects stale, mocked,
invalid, inaccurate and physically impossible fixes, then smooths acceptable
readings. Keep raw verified evidence separate from the smoothed display marker.

## 9. Marker and trail behaviour

Preserve these rules:

- operator marker uses a person icon and phone GPS;
- tractor marker uses a tractor icon and tracker GPS;
- farm marker/polygon uses registered plot coordinates;
- a fresh tractor fix is live only while its age is at most 180 seconds;
- stale tractor fixes are labelled as last known rather than live;
- operator and tractor markers combine only when they are within 25 metres,
  phone accuracy is 25 metres or better, and the tractor fix is live;
- a combined marker means only that the two fixes overlap; it does not prove
  the operator is seated on the tractor;
- work trail segments are green inside the plot, red outside and grey when the
  backend has not classified them;
- camera bounds include the boundary, phone, tractor, trail and route points;
- missing farm coordinates still allow phone and tractor markers to display.

## 10. Farm boundary and geofence data

Accept either a polygon or a centroid from the job detail response:

```json
{
  "plot": {
    "id": "plot-1",
    "name": "North field",
    "mapped": true,
    "tolerance_m": 20,
    "boundary": [
      {"latitude": -6.1800, "longitude": 35.7500},
      {"latitude": -6.1900, "longitude": 35.7500},
      {"latitude": -6.1900, "longitude": 35.7600}
    ]
  }
}
```

At least three valid boundary points are required for the polygon and local
geofence estimate. The backend remains authoritative for start checks and
completion evidence.

## 11. Google Maps platform setup

Use Shamba Bora's own restricted Google Maps keys. Do not copy API keys from
SB Mechanization source files.

Android permissions:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Android application metadata:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="@string/google_maps_key" />
```

Store the key in the Shamba Bora native configuration and restrict it by
Android package name and signing certificate. Configure the iOS key in
`AppDelegate.swift`, restrict it by bundle identifier, and add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Shamba Bora uses your location to guide tractor work and verify the assigned farm.</string>
```

Enable Maps SDK for Android/iOS. If road navigation is required, enable Routes
API and use a separately restricted key. Remove the hard-coded route key
constants from `operator_widgets.dart` and inject configuration instead:

```dart
const routesApiKey = String.fromEnvironment('GOOGLE_ROUTES_API_KEY');
```

For production, a backend proxy for route requests gives stronger key control.

## 12. Localization

The calendar expects translations for:

```text
assignmentsOn
noAssignmentsOn
openJob
scheduled
assigned
dispatched
enRoute
arrived
calendarStatusInProgress
calendarStatusPaused
calendarStatusCompleted
calendarStatusVerified
calendarStatusClosed
calendarStatusCancelled
calendarStatusFlagged
```

Copy the English and Kiswahili values into Shamba Bora's localization system,
then update the two calendar imports to point at Shamba Bora's generated
localizations.

## 13. Theme

The widgets read colours from `Theme.of(context).colorScheme`. To retain the SB
look, set Shamba Bora's tractor module primary seed to the existing teal/green
brand and keep Material 3 enabled:

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009688)),
)
```

Status colours are defined in `scheduleStatusColor`; copy that function without
changing its keys.

## 14. Regression tests to copy

Copy the relevant cases from:

```text
test/calendar_map_flow_test.dart
```

Keep coverage for:

- horizontal calendar scrolling on a narrow device;
- large text without overflow;
- overlapping jobs showing two cards and `+N more`;
- opening every hidden assignment from the bottom sheet;
- empty-day centred state;
- overnight assignments;
- operator and manager calendars opening the correct job;
- phone and tractor markers using different sources;
- marker grouping rules;
- farm polygon and trail colours;
- invalid tracker fixes being ignored;
- old tracker fixes displaying as last known.

## 15. Recommended migration order

1. Add packages and native map configuration.
2. Copy the three calendar files and localization strings.
3. Connect `GET /calendar` and build `ScheduleAssignment` objects.
4. Copy map domain and location files.
5. Copy `OperatorMapCard`, then verify static farm polygons and markers.
6. Implement the map repository interface and job-detail refresh.
7. Connect `GET /jobs/{id}/path` and verify trail colours.
8. Enable route-aware polling and lifecycle stopping.
9. Extract and connect `UnionTrailMap` for union verification.
10. Copy and run the calendar/map regression tests.

Following this order keeps calendar work independent from GPS work and makes
each failure easier to isolate.
