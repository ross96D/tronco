import 'package:tronco/src/types.dart';

/// An abstract handler of log events.
///
/// A log printer creates and formats the output, which is then sent to
/// [LogOutput]. Every implementation has to use the [LogPrinter.log]
/// method to send the output.
abstract class LogPrinter {
  Future<void> init() async {}
  Future<void> destroy() async {}

  /// Is called every time a new [LogEvent] is sent and handles printing
  ///
  /// Returns the lines to be printed
  Iterable<String> log(LogEvent event);
}

/// Log output receives a [OutputEvent] from [LogPrinter] and sends it to the
/// desired destination.
///
/// This can be an output stream, a file or a network target. [LogOutput] may
/// cache multiple log messages.
abstract class LogOutput {
  Future<void> init() async {}
  Future<void> destroy() async {}

  void output(OutputEvent event);
}

/// An abstract filter of log messages.
abstract class LogFilter {
  Future<void> init() async {}
  Future<void> destroy() async {}

  /// Is called every time a new log message is sent and decides if
  /// it will be printed or canceled.
  ///
  /// Returns `true` if the message should be logged.
  bool shouldLog(LogEvent event);
}
