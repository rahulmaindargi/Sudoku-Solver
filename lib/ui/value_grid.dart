import 'package:flutter/material.dart';
import 'package:sudoku_solver/solver/state.dart';
import 'package:sudoku_solver/ui/value_cell.dart';

class ValueGrid extends StatelessWidget {
  const ValueGrid({
    super.key,
    required this.state,
  });

  final AppState state;

  Color rightBorderColor(int index) {
    if ((index + 1) % 3 == 0) {
      return Colors.redAccent;
    }
    return Colors.blueAccent;
  }

  Color bottomBorderColor(int index) {
    if ((index + 1) % 3 == 0) {
      return Colors.redAccent;
    }
    return Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      children: List.generate(9, (index) {
        return TableRow(
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: bottomBorderColor(index))),
            ),
            children: state.values
                .where((e) => e.x == index)
                .map(
                  (e) => Container(
                      decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(color: rightBorderColor(e.y))),
                      ),
                      padding: const EdgeInsets.all(0.0),
                      alignment: Alignment.center,
                      child: ValueCellWidget(value: e)),
                )
                .toList());
      }),
    );
  }
}
