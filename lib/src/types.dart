enum Level {
  trace(1000),
  debug(2000),
  info(3000),
  warning(4000),
  error(5000),
  fatal(6000);

  final int value;
  const Level(this.value);

  bool operator <(Level other) => value < other.value;

  bool operator <=(Level other) => value <= other.value;

  bool operator >(Level other) => value > other.value;

  bool operator >=(Level other) => value >= other.value;
}


class LogEvent {
  final Level level;
  final List<LogEventProperty> properties;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final List<LogEvent> childEvents;

  /// Time when this log was created.
  final DateTime time;

  LogEvent(
    this.level,
    this.message, {
    this.properties = const [],
    DateTime? time,
    this.error,
    this.stackTrace,
    this.childEvents = const [],
  }) : time = time ?? DateTime.now();
}

class OutputEvent {
  final Iterable<String> lines;
  final LogEvent origin;

  Level get level => origin.level;

  const OutputEvent(this.origin, this.lines);
}

abstract class LogEventProperty {
  const LogEventProperty();

  String print();
}

class StringProperty extends LogEventProperty{
  final String value;
  const StringProperty(this.value);

  @override
  String toString() => value;

  @override
  String print() => toString();
}

class EntryProperty extends LogEventProperty {
  final (String, String) value;
  const EntryProperty(String key, String value): value = (key, value);

  @override
  String toString() => "${value.$1}: ${value.$2}";

  @override
  String print() => toString();
}
