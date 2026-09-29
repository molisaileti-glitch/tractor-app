import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const appUuid = Uuid();

abstract class UuidTable extends Table {
  TextColumn get id => text().clientDefault(() => appUuid.v4())();
}
