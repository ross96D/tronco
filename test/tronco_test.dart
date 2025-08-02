import 'package:tronco/tronco.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      final logger = Logger(filter: LevelFilter(Level.trace), output: ConsoleOutput(), printer: SimplePrinter());

      logger.log(Level.info, "something");
      logger.log(Level.info, "something", properties: [EntryProperty("type", "test")]);
      logger.log(Level.info, "something", properties: [EntryProperty("type", "test")], error: StateError("some"), stackTrace: StackTrace.current);
    });
  });
}
