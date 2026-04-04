import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pos_terminals_table.dart';

part 'pos_terminals_dao.g.dart';

@DriftAccessor(tables: [PosTerminalsTable])
class PosTerminalsDao extends DatabaseAccessor<AppDatabase>
    with _$PosTerminalsDaoMixin {
  PosTerminalsDao(super.db);

  Future<PosTerminalsTableData?> getTerminal(String id) {
    return (select(posTerminalsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<PosTerminalsTableData>> getStoreTerminals(String storeId) {
    return (select(posTerminalsTable)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<PosTerminalsTableData>> watchStoreTerminals(String storeId) {
    return (select(posTerminalsTable)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<PosTerminalsTableData>> getActiveTerminals(String storeId) {
    return (select(posTerminalsTable)
          ..where((t) => t.storeId.equals(storeId) & t.isActive.equals(true)))
        .get();
  }

  Future<int> upsertTerminal(PosTerminalsTableCompanion terminal) =>
      into(posTerminalsTable)
          .insert(terminal, mode: InsertMode.insertOrReplace);

  Future<int> deleteTerminal(String id) =>
      (delete(posTerminalsTable)..where((t) => t.id.equals(id))).go();

  Future<int> updateHeartbeat(String id) {
    return (update(posTerminalsTable)..where((t) => t.id.equals(id))).write(
        PosTerminalsTableCompanion(lastHeartbeatAt: Value(DateTime.now())));
  }

  Future<int> updateCurrentShift(String terminalId, String? shiftId) {
    return (update(posTerminalsTable)..where((t) => t.id.equals(terminalId)))
        .write(PosTerminalsTableCompanion(currentShiftId: Value(shiftId)));
  }

  Future<int> updateCurrentUser(String terminalId, String? userId) {
    return (update(posTerminalsTable)..where((t) => t.id.equals(terminalId)))
        .write(PosTerminalsTableCompanion(currentUserId: Value(userId)));
  }

  Future<int> markAsSynced(String id) {
    return (update(posTerminalsTable)..where((t) => t.id.equals(id)))
        .write(PosTerminalsTableCompanion(syncedAt: Value(DateTime.now())));
  }
}
