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
  final Iterable<LogEventProperties> properties;
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

sealed class LogEventProperties {
  const LogEventProperties();
}

class StringProperty extends LogEventProperties{
  final String value;
  const StringProperty(this.value);
}

class MapProperty extends LogEventProperties {
  final Map<String, dynamic> value;
  const MapProperty(this.value);
}
