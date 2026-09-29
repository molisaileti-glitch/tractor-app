# Offline Data Model

This app uses Drift for offline-first storage. Business entities use UUID string
primary keys. There is no separate `localId`; the UUID is the stable identity
used locally and later by sync/API payloads.

## Sync Fields

Most business tables include:

- `id`
- `syncStatus`
- `createdAt`
- `updatedAt`
- `deletedAt`
- `lastSyncedAt`

`SyncOutbox` stores pending backend operations with `entityTable`, `entityId`,
`operation`, `payloadJson`, retry count and error fields.

## Dashboard Coverage

Farmer:

- `Farmers`
- `FarmPlots`
- `FarmBoundaryPoints`
- `ServiceRequests`
- `Disputes`
- `Attachments`

Union manager / dispatcher:

- `ServiceRequests`
- `Tractors`
- `Operators`
- `Jobs`
- `JobTrackingPoints`
- `JobNotes`

Operator:

- `Jobs`
- `JobTrackingPoints`
- `JobNotes`
- `Attachments`

Technician:

- `Tractors`
- `MaintenanceRecords`
- `Parts`
- `MaintenancePartsUsed`

## Important Rules

- Approval is not dispatch.
- Under-maintenance and out-of-service tractors are not schedulable.
- Operators can only start a job after geofence validation against the registered
  farm boundary.
- Completed operator work becomes `completedPendingConfirmation`, not `closed`.
- Farmer disputes stay linked to both the service request and job when available.
