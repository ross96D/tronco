import 'package:tronco/tronco.dart';

class Printer extends LogPrinter {
  final String childIdentation;
  final String _identation;

  Printer._(this.childIdentation, this._identation);
  Printer([this.childIdentation = "\t"]) : _identation = "";

  factory Printer._withIdentation(String identation, String childIdentation) {
    return Printer._(childIdentation, identation + childIdentation);
  }

  Iterable<String> logError(Object error, StackTrace? st) sync* {
    yield "${_identation + childIdentation}error: $error";
    if (st != null) {
      int i = 0;
      int j = 0;
      final lines = st.toString().split("\n");
      yield* lines
          .map((e) {
            String response;
            if (i == 0) {
              response = "${_identation + childIdentation}Stacktrace: $e";
            } else {
              response = e == "" ? "" : "${_identation + childIdentation}$e";
            }
            i += 1;
            return response;
          })
          .where((e) {
            j += 1;
            return j != lines.length || e != "";
          });
    }
  }

  @override
  Iterable<String> log(LogEvent event) sync* {
    final buffer = StringBuffer();
    buffer.write("$_identation${event.time.toIso8601String()} ${event.level.name} ");

    final properties = event.properties.map((e) => e.print()).join(' ');
    if (properties != "") {
      buffer.write("$properties ");
    }
    buffer.write(event.message);
    yield buffer.toString();

    if (event.error != null) {
      yield* logError(event.error!, event.stackTrace);
    }

    for (final child in event.childEvents) {
      yield* Printer._withIdentation(_identation, childIdentation).log(child);
    }
  }
}

class ChildLogger extends Logger {
  final List<LogEvent> _events;
  late LogEvent _start;

  ChildLogger({
    required super.filter,
    required super.printer,
    required super.output,
    super.eventHooks,
    super.outputHooks,
  }) : _events = [];

  void start(
    Level level,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    List<LogEventProperty> properties = const [],
  }) {
    _start = LogEvent(
      level,
      message,
      time: time,
      error: error,
      stackTrace: stackTrace,
      properties: properties,
    );
  }

  void end() {
    super.log(
      _start.level,
      _start.message,
      time: _start.time,
      error: _start.error,
      stackTrace: _start.stackTrace,
      childEvents: _events,
      properties: _start.properties,
    );
  }

  void add(
    Level level,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    List<LogEventProperty> properties = const [],
  }) {
    final event = LogEvent(
      level,
      message,
      time: time,
      error: error,
      stackTrace: stackTrace,
      properties: properties,
    );
    if (filter.value.shouldLog(event)) {
      _events.add(event);
    }
  }

  @override
  void log(
    Level level,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    List<LogEvent> childEvents = const [],
    List<LogEventProperty> properties = const [],
  }) {
    throw AssertionError("ChildLogger does not use log function");
  }
}

void main() async {
  final logger = Logger(
    filter: LevelFilter(Level.info),
    printer: NewLinePrinter(Printer()),
    output: ConsoleOutput(),
  );
  await logger.init();

  logger.log(Level.info, "message\nmessage\nmessage");

  try {
    throw StateError("Test error");
  } catch (e, st) {
    logger.log(Level.info, "message", error: e, stackTrace: st);
  }

  somefunc(logger);

  await logger.destroy();
}

// Consumes the logger for some reason
Future<void> somefunc(Logger parentLogger) async {
  final logger = parentLogger.clone(
    properties: [StringProperty("somefunc"), EntryProperty("key", "value")],
  );
  try {
    throw StateError("Test error");
  } catch (e, st) {
    logger.log(
      Level.info,
      "message",
      error: e,
      stackTrace: st,
      childEvents: [LogEvent(Level.info, "child log1"), LogEvent(Level.info, "child log2")],
    );
  }
  await logger.destroy();
}
