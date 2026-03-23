import 'package:firebase_performance/firebase_performance.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebasePerformance extends Mock implements FirebasePerformance {
  @override
  Trace newTrace(String name) {
    return MockTrace();
  }

  @override
  HttpMetric newHttpMetric(String url, HttpMethod httpMethod) {
    return MockHttpMetric();
  }
}

class MockTrace extends Mock implements Trace {
  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void putAttribute(String name, String value) {}

  @override
  void incrementMetric(String name, int value) {}

  @override
  int getMetric(String name) => 0;
}

class MockHttpMetric extends Mock implements HttpMetric {
  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void putAttribute(String name, String value) {}
}
