import 'package:tronco/src/interfaces.dart';
import 'package:tronco/src/types.dart';

class LevelFilter extends LogFilter {
  /// Will not log anything below this level
  final Level level;
  LevelFilter(this.level);

  @override
  bool shouldLog(LogEvent event) {
    return event.level >= level;
  }
}

class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(print);
  }
}

class SimplePrinter extends LogPrinter {
  @override
  Iterable<String> log(LogEvent event) sync* {


    yield "";
  }
}
