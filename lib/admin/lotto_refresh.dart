import 'dart:async';

class LottoRefresh {
  LottoRefresh._();
  static final instance = LottoRefresh._();

  final _ctrl = StreamController<void>.broadcast();
  Stream<void> get stream => _ctrl.stream;

  void bump() => _ctrl.add(null); // ยิงสัญญาณรีเฟรช
  void dispose() => _ctrl.close();
}
