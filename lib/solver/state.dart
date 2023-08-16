import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sudoku_solver/solver/solver.dart';
import 'package:sudoku_solver/solver/value_cell.dart';

class AppState with ChangeNotifier {
  late List<ValueCell> values;
  bool solving = false;
  AppState() {
    values = List.generate(81, (index) {
      int x = index % 9;
      int y = index ~/ 9;
      return ValueCell(x: x, y: y);
    });
  }
  void clear() {
    for (var e in values) {
      e.reset();
    }
  }

  void clearSol() {
    for (var e in values) {
      e.reset(true);
    }
  }

  Future<bool> solve() async {
    var result = await SudokuSolver(values: values).solve();
    return result;
  }
}
