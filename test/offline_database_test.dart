import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tractor/src/core/data/local/app_database.dart';
import 'package:tractor/src/core/data/local/offline_seed_data.dart';

void main() {
  test('seeds offline dashboard data with uuid identities', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await OfflineBootstrapper(db).seedDemoDataIfEmpty();

    final tractors = await db.select(db.tractors).get();
    final requests = await db.select(db.serviceRequests).get();
    final jobs = await db.select(db.jobs).get();

    expect(tractors, hasLength(4));
    expect(requests, hasLength(3));
    expect(jobs, hasLength(2));
    expect(tractors.first.id, contains('-'));
    expect(requests.first.requestNumber, startsWith('SR-'));
  });
}
