# Operator photos and farmer confirmation

Implemented against the supplied KwanzaTrack Mechanization API v1, sections 2.5 and 2.9, and its Postman collection.

Latest calendar/photo update: all 71 focused regression tests passed and Flutter analysis reported no issues. These include before-photo availability after a fit inspection, out-of-order inspection reads, completing work without photos, calendar colour/label agreement and Swahili labels. Logs: `build/calendar_photos_full_tests.log` and `build/calendar_optional_photos_analyze.log`. The real calendar widget was also rendered and visually checked using sample jobs in `build/review/calendar-tablet.png`.

## Operator flow

1. Record arrival and pass the tractor inspection. **Before-service photos (optional)** then appears before the start check. Take a photo or choose an existing image, review it, select its kind, add an optional caption and tap **Upload photo**, or continue without photos.
2. Run the backend start checks, then start service. Photos are optional and never gate starting or completing work. An inspection with faults does not unlock before-service photos; a late inspection read cannot undo a newly passed inspection.
3. **Work photos (optional)** is available during service. **After-service photos (optional)** appears directly before **Finish Job** on the completion form. Job details and history expose photos when appropriate to the work stage or when uploaded evidence already exists. Early access to the photo screen does not expose capture controls before inspection passes.
4. Completion sends only completed work details. The app then opens **Farmer confirmation**. The farmer enters their existing four-digit PIN on the operator's phone, or uses a six-digit SMS code if no PIN is configured. Rating is optional and has no preset value.
5. The farmer can confirm later from history. They can also report dissatisfaction with a note; that uses the documented dispute contract and flags the job for union review.
6. Successful confirmation requires the server's `farmer_confirmed_at`. It does not verify, close or mark the job paid. The union's existing policy-aware verification remains authoritative.

This is the documented operator-assisted proof flow. Farmer registration, orders, the separate farmer application and integration/webhook logic are unchanged. The operator does not set, retrieve or verify the farmer's PIN locally; the backend validates it. PINs/codes are obscured on screen, redacted from API logs and not persisted.

## How photo upload works in Flutter

`OperatorJobPhotosScreen` uses Flutter's `image_picker` for camera/gallery selection. It reads the selected file bytes and calls `OperatorLocalRepository.uploadJobPhoto`. The API client sends:

```text
POST /api/v1/mech/jobs/{job_id}/photos
Authorization: Bearer <operator mobile token>
Accept: application/json
Content-Type: multipart/form-data; boundary=<generated boundary>

kind     = before | during | after | issue | other
caption  = optional text
file     = binary image bytes, filename and image MIME type
```

This is a request body; it is a multipart body, not JSON. No Base64 field or local file path is sent as the image. Boundary/header generation is inside the API client, sharing its normal expired-session handling, structured server errors and Retry-After handling. JPG, PNG and WebP are checked by file signature, with a maximum size of 8 MB. Failed uploads retain the current selection for retry; successful uploads refresh the job's `photos` collection. Photo responses are parsed as photos and never as jobs.

On Android, a pending camera/gallery selection is associated with its job, operator and photo type. If the system restarts the app, reopening that job's photo screen can recover the selection for review; it is never uploaded automatically. This is not a durable offline upload queue. The iOS camera and photo-library usage descriptions are included. A new Flutter run/install is required after adding the native picker plugin; hot reload alone is insufficient.

## Confirmation requests

```text
POST /api/v1/mech/jobs/{job_id}/farmer-otp
```

This reads the farmer's registered phone on the backend. The UI reports success only for `data.sent: true`; a missing phone or SMS credit failure is shown as a failure.

```json
{"method":"pin","pin":"0123","rating":4}
```

```json
{"method":"otp","code":"123456"}
```

Both JSON bodies go to `POST /api/v1/mech/jobs/{job_id}/farmer-confirm`. PIN is a string, preserving leading zeroes. A dispute adds `dispute: true` and a required `note`; it does not record satisfaction.

## Validation

All **53 focused operator/union tests passed**, and analysis of the application and new evidence tests reported no issues. Tests cover multipart boundaries, actual image bytes, mobile authorization, size/type validation, leading-zero PINs, wrong PINs, disputes, unsent SMS, OTP field names, confirmation state, photo-to-job association, photo selection/upload retry and the confirmation screen. The Android debug APK build succeeded with the native picker plugin. Real camera permissions, production uploads, SMS delivery and a real farmer PIN still require a tablet/backend test; no production job was changed during development.

Photo source: [Flutter image_picker documentation](https://pub.dev/packages/image_picker).
