import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sudoku_solver/solver/state.dart';
import 'package:sudoku_solver/ui/value_grid.dart';

void main() {
  //Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('${record.level.name}: ${record.time}: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('${record.level.name}: ${record.time}: ${record.stackTrace}');
    }
  });
  AppState state = AppState();
  runApp(MyApp(state: state));
}

class MyApp extends StatelessWidget {
  static Logger logger = Logger("MyApp");
  const MyApp({super.key, required this.state});
  final AppState state;
  void resetPressed() {
    state.clear();
  }

  void hideSol() {
    state.clearSol();
  }

  void solvePressed(BuildContext context) async {
    logger.info("solve");
    showDialog<bool>(
        barrierDismissible: false,
        context: context,
        useRootNavigator: false,
        builder: (intCntx) => AlertDialog(
              title: const Center(child: Text("Solving...")),
              content: Builder(builder: (context) {
                Future.delayed(Durations.short4, () => state.solve())
                    .then((value) => Navigator.pop(intCntx));
                return const RefreshProgressIndicator();
              }),
            ));
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Sudoku Solver';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: Builder(builder: (context) {
          const textStyle = TextStyle(
              fontSize: 20.0,
              color: Color(0xFF000000),
              fontWeight: FontWeight.w200,
              fontFamily: "Roboto");
          return Column(
            children: [
              ValueGrid(state: state),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => solvePressed(context),
                      child: const Text("Solve", style: textStyle)),
                  ElevatedButton(
                      onPressed: hideSol,
                      child: const Text("Hide Solution", style: textStyle)),
                  ElevatedButton(
                      onPressed: resetPressed,
                      child: const Text("Reset", style: textStyle)),
                ],
              )
            ],
          );
        }),
      ),
    );
  }
}
