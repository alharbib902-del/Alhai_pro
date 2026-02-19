// Drift Web Worker
// Compile with: dart compile js -O2 -o web/drift_worker.dart.js web/drift_worker.dart

import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
