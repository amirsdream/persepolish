// Drift web worker — compile with:
// dart compile js -O4 -o web/drift_worker.dart.js tool/drift_worker.dart
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
