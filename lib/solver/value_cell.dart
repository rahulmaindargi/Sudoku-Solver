import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ValueCell extends ChangeNotifier {
  static Logger logger = Logger("ValueCell");
  int x, y;
  int? value;
  bool givenValue = false;
  List<int> allowedValues = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  bool disable = false;
  ValueCell({required this.x, required this.y});

  void reset([bool withGiven = false]) {
    disable = false;
    if (withGiven && givenValue) {
      logger.finest(
          "reset withGiven $x, $y, $value, $givenValue $disable $allowedValues");
      notifyListeners();
      return;
    }
    allowedValues = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    value = null;
    givenValue = false;
    logger.finest("reset $x, $y, $value, $givenValue $disable");
    notifyListeners();
  }

  void setDisabled() {
    disable = true;
    logger.finest("setDisabled $x, $y, $value, $givenValue $disable");
    notifyListeners();
  }

  void setValue({int? input, bool given = false}) {
    givenValue = given;
    if (!given && input != null) {
      disable = true;
    } else {
      disable = false;
    }
    value = input;
    allowedValues = [];
    logger.finest("setValue $x, $y, $value, $givenValue $disable");
    notifyListeners();
  }

  @override
  String toString() {
    return "Value $x, $y, $value, $givenValue $disable $allowedValues";
  }
}

typedef PositionListener = void Function((int x, int y, int value));

class CellValueFixedStream {
//  List<(int x, int y, int value)> values = [];
  StreamController<(int x, int y, int value)> controller =
      StreamController.broadcast();
  clear() {
    controller.close();
  }

  StreamSubscription<(int, int, int)> listen(PositionListener listener) {
    return controller.stream.listen(listener);
  }

  add(int x, y, z) async {
    controller.sink.add((x, y, z));
  }
}
