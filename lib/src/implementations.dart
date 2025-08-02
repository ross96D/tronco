import 'package:tronco/src/interfaces.dart';
import 'package:tronco/src/types.dart';

/// This is the most simple filter implementation based on the log level
/// Create your own implementation to support more complex cases like logs types
class LevelFilter extends LogFilter {
  /// Will not log anything below this level
  final Level level;
  LevelFilter(this.level);

  @override
  bool shouldLog(LogEvent event) {
    return event.level >= level;
  }
}

/// Example implementation of a console output.
/// Even if this can be used without problems,
/// the user is encourage to implement a custom one
/// that batches output events
class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(print);
  }
}

class NewLinePrinter extends LogPrinter {
  final LogPrinter printer;
  NewLinePrinter(this.printer);

  @override
  Future<void> init() => printer.init();

  @override
  Future<void> destroy() => printer.destroy();

  @override
  Iterable<String> log(LogEvent event) sync* {
    yield* printer.log(event);
    yield "";
  }
}

/// Example implementation of a printer.
/// Printer is meant to be implemented by the user,
/// this implementation is purposely simple and not feature complete
class SimplePrinter extends LogPrinter {
  final String childIdentation;
  final String _identation;

  SimplePrinter._(this.childIdentation, this._identation);
  SimplePrinter([this.childIdentation = "\t"]) : _identation = "";

  factory SimplePrinter._withIdentation(String identation, String childIdentation) {
    return SimplePrinter._(childIdentation, identation + childIdentation);
  }

  @override
  Iterable<String> log(LogEvent event) sync* {
    final buffer = StringBuffer();
    buffer.write("${event.level.name} ");
    final properties = event.properties.map((e) => e.print()).join(' ');
    if (properties != "") {
      buffer.write("$properties ");
    }
    buffer.write(event.message);

    if (event.error != null) {
      buffer.write(" error: ${event.error}");
    }
    yield buffer.toString();

    for (final child in event.childEvents) {
      yield* SimplePrinter._withIdentation(_identation, childIdentation).log(child);
    }
  }
}
