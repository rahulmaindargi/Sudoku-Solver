import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:sudoku_solver/solver/value_cell.dart';

class ValueCellWidget extends StatelessWidget {
  static Logger logger = Logger("ValueCellWidget");
  const ValueCellWidget({
    super.key,
    required this.value,
  });
  final ValueCell value;

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
        color: value.givenValue ? Colors.red : Colors.blue,
        fontWeight: FontWeight.bold,
        fontSize: 20);
    return ListenableBuilder(
      listenable: value,
      builder: (context, child) {
        if (value.disable && value.value != null) {
          return FittedBox(
            fit: BoxFit.fill,
            child: Text(
              "${value.value}",
              style: style,
            ),
          );
        } else {
          return TextField(
            controller: TextEditingController(text: value.value?.toString()),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
            maxLength: 1,
            buildCounter: (context,
                    {currentLength = 0, isFocused = false, maxLength}) =>
                null,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            //expands: true,
            maxLines: null,
            minLines: null,
            onChanged: (txt) {
              logger.info("onChanged ${txt.trim()} ${value.x} ${value.y}");
              if (txt.trim() != "") {
                value.setValue(input: int.tryParse(txt.trim())!, given: true);
              } else {
                value.setValue(input: null);
              }
            },
            textAlign: TextAlign.center,
            style: style,
          );
        }
      },
    );
  }
}
