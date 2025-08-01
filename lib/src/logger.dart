import 'package:tronco/src/interfaces.dart';
import 'package:tronco/src/types.dart';

typedef LogEventHook = void Function(LogEvent);
typedef LogOutputHook = void Function(OutputEvent);

class Logger {
  /// Decides wheter a messasge would be logged or not
  final LogFilter filter;

  /// Takes a log event and returns the lines that would be printed
  final LogPrinter printer;

  /// Write the lines received from the printer
  final LogOutput output;

  /// Functions to be called on every event log, before filters
  final List<LogEventHook> eventHooks;

  /// Functions to be called on every output log
  final List<LogOutputHook> outputHooks;

  Logger({
    required this.filter,
    required this.printer,
    required this.output,
    List<LogEventHook>? eventHooks,
    List<LogOutputHook>? outputHooks,
  }) : eventHooks = eventHooks ?? [],
       outputHooks = outputHooks ?? [];

  Future<void> init() async {
    await Future.wait([filter.init(), printer.init(), output.init()]);
  }

  Future<void> destroy() async {
    await Future.wait([filter.destroy(), printer.destroy(), output.destroy()]);
  }

  void log(
    Level level,
    String message, {
    List<LogEventProperties> properties = const [],
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // if stackTrace is not null error should not be null
    assert(stackTrace == null || error != null);
    final event = LogEvent(
      level,
      message,
      properties: properties,
      error: error,
      stackTrace: stackTrace,
      time: time,
    );
    for (final hook in eventHooks) {
      hook(event);
    }

    if (!filter.shouldLog(event)) {
      return;
    }

    final lines = printer.log(event);

    final outputEvent = OutputEvent(event, lines);

    output.output(outputEvent);
    for (var hook in outputHooks) {
      hook(outputEvent);
    }
  }

  Logger createChild() {
    return _ChildLogger(
      filter: filter,
      printer: printer,
      output: output,
      eventHooks: eventHooks,
      outputHooks: outputHooks,
    );
  }
}

class _ChildLogger extends Logger {
  _ChildLogger({
    required super.filter,
    required super.printer,
    required super.output,
    required super.eventHooks,
    required super.outputHooks,
  });

  @override
  Future<void> init() async {}

  @override
  Future<void> destroy() async {}
}
