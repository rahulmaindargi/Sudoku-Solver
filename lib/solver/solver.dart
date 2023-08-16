import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sudoku_solver/solver/value_cell.dart';

class SudokuSolver {
  static Logger logger = Logger("SudokuSolver");
  List<ValueCell> values;
  bool solved = false;
  bool cancelled = false;
  CellValueFixedStream notifier = CellValueFixedStream();
  Map<ValueCell, StreamSubscription<(int, int, int)>> subscriptionMap = {};
  SudokuSolver({required this.values});
  Future<bool> solve() async {
    values.where((e) => e.value == null && !e.givenValue).forEach((e) {
      subscriptionMap.putIfAbsent(
          e,
          () => notifier.listen(((int, int, int) val) =>
              valueChanged(e, val.$1, val.$2, val.$3).then((valueFixed) {
                if (valueFixed) {
                  notifier.add(e.x, e.y, e.value);
                  subscriptionMap.remove(e)?.cancel();
                }
              })));
    });
    handleInitialValues();
    var f1 = isSolved();
    var f2 = f1.timeout(const Duration(minutes: 1),
        onTimeout: () => cancelled = true);
    await f2;
    subscriptionMap.clear();

    logger.info("subscriptionMap size ${subscriptionMap.length}");
    notifier.clear();
    return solved;
  }

  void smartCheck() {
    logger.fine("smartCheck");
    var unsolved = values.where((e) => e.value == null).toList();
    for (var d in unsolved) {
      var checkList = unsolved.where((e) => e != d).toList();

      checkAndSet(d, checkList, (toCheck) => toCheck.x == d.x);
      checkAndSet(d, checkList, (toCheck) => toCheck.y == d.y);
      checkAndSet(d, checkList, (toCheck) {
        var startX = (((toCheck.x) ~/ 3) + 1) * 3;
        var startY = (((toCheck.y) ~/ 3) + 1) * 3;
        return startX > d.x &&
            (startX - 3) <= d.x &&
            startY > d.y &&
            (startY - 3) <= d.y;
      });
    }
  }

  void checkAndSet(ValueCell d, List<ValueCell> checkList,
      bool Function(ValueCell toCheck) condition) {
    if (d.value != null) {
      return;
    }
    var toCheck = checkList.where((e) => condition(e)).toList();
    var fixedValue = d.allowedValues
        .where((e) =>
            toCheck.indexWhere((tc) => tc.allowedValues.contains(e)) == -1)
        .firstOrNull;
    if (fixedValue != null) {
      d.setValue(input: fixedValue);
      notifier.add(d.x, d.y, d.value);
      subscriptionMap.remove(d)?.cancel();
    }
  }

  Future<bool> valueChanged(
      ValueCell target, int changedX, int changedY, int changedVal) async {
    if (changedX == target.x && changedY == target.y) {
      return false;
    }
    // Check X axis
    if (changedX == target.x) {
      target.allowedValues.remove(changedVal);
    }
    // Check Y axis
    if (changedY == target.y) {
      target.allowedValues.remove(changedVal);
    }
    // Check Square box
    var startX = (((changedX) ~/ 3) + 1) * 3;
    var startY = (((changedY) ~/ 3) + 1) * 3;
    if (startX > target.x &&
        (startX - 3) <= target.x &&
        startY > target.y &&
        (startY - 3) <= target.y) {
      target.allowedValues.remove(changedVal);
    }
    if (target.allowedValues.length == 1) {
      target.setValue(input: target.allowedValues[0]);
      return true;
    }
    return false;
  }

  Future<void> isSolved() async {
    while (!solved && !cancelled) {
      logger.finest(
          "before isSolved Check ${subscriptionMap.length} ${subscriptionMap.isEmpty} ");
      smartCheck();
      solved = await Future.delayed(
          Durations.medium1, () => subscriptionMap.isEmpty);
      logger.finest(
          "after delayed ${subscriptionMap.length} ${subscriptionMap.isEmpty} $solved");
    }
  }

  void handleInitialValues() {
    values.where((e) => e.value != null && e.givenValue).forEach((e) {
      e.setDisabled();
      notifier.add(e.x, e.y, e.value);
    });
  }
}
