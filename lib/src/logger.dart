import 'package:tronco/src/count.dart';
import 'package:tronco/src/interfaces.dart';
import 'package:tronco/src/types.dart';

typedef LogEventHook = void Function(LogEvent);
typedef LogOutputHook = void Function(OutputEvent);

class Logger {
  /// Decides wheter a messasge would be logged or not
  ///
  /// This uses a ref count strategy to know when to call destroy or init
  final Rc<LogFilter> filter;

  /// Takes a log event and returns the lines that would be printed
  ///
  /// This uses a ref count strategy to know when to call destroy or init
  final Rc<LogPrinter> printer;

  /// Write the lines received from the printer
  ///
  /// This uses a ref count strategy to know when to call destroy or init
  final Rc<LogOutput> output;

  /// Functions to be called on every event log, before filters
  final List<LogEventHook> eventHooks;

  /// Functions to be called on every output log
  final List<LogOutputHook> outputHooks;

  final List<LogEventProperty> defaultProperties;

  Logger.raw({
    required this.filter,
    required this.printer,
    required this.output,
    required this.eventHooks,
    required this.outputHooks,
    required this.defaultProperties,
  });

  Logger({
    required LogFilter filter,
    required LogPrinter printer,
    required LogOutput output,
    List<LogEventHook>? eventHooks,
    List<LogOutputHook>? outputHooks,
    List<LogEventProperty>? properties,
  }) : eventHooks = eventHooks ?? [],
       outputHooks = outputHooks ?? [],
       defaultProperties = properties ?? [],
       filter = Rc.create(filter),
       printer = Rc.create(printer),
       output = Rc.create(output);

  Future<void> init() async {
    await Future.wait([filter.init(), printer.init(), output.init()]);
  }

  Future<void> destroy() async {
    await Future.wait([filter.destroy(), printer.destroy(), output.destroy()]);
  }

  void log(
    Level level,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    List<LogEvent> childEvents = const [],
    List<LogEventProperty> properties = const [],
  }) {
    // if stackTrace is not null error should not be null
    assert(stackTrace == null || error != null);
    final event = LogEvent(
      level,
      message,
      time: time,
      error: error,
      stackTrace: stackTrace,
      properties: List.from(defaultProperties)..addAll(properties),
      childEvents: childEvents,
    );
    for (final hook in eventHooks) {
      hook(event);
    }

    if (!filter.value.shouldLog(event)) {
      return;
    }

    final lines = printer.value.log(event);

    final outputEvent = OutputEvent(event, lines);

    output.value.output(outputEvent);
    for (var hook in outputHooks) {
      hook(outputEvent);
    }
  }

  /// Returns a [Logger] already initialized with the values of the parent logger
  /// that wont trigger destroy calls
  Logger clone({List<LogEventProperty>? properties}) {
    return Logger.raw(
      filter: filter.clone(),
      printer: printer.clone(),
      output: output.clone(),
      eventHooks: eventHooks,
      outputHooks: outputHooks,
      defaultProperties: properties ?? defaultProperties,
    );
  }
}
