import 'package:mocktail/mocktail.dart';

class MockPerformanceMonitoring extends Mock {}

class MockTrace extends Mock {
  Future<void> start() async {}

  Future<void> stop() async {}

  void putAttribute(String name, String value) {}

  void incrementMetric(String name, int value) {}

  int getMetric(String name) => 0;
}

class MockHttpMetric extends Mock {
  Future<void> start() async {}

  Future<void> stop() async {}

  void putAttribute(String name, String value) {}
}
