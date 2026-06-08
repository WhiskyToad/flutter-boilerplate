import 'package:flutter/foundation.dart';
import 'package:skelter/utils/extensions/primitive_types_extensions.dart';

class PerformanceMonitoringService {
  PerformanceMonitoringService({Object? performance});

  final Map<String, _TraceSnapshot> _activeTraces = {};

  Future<void> initialize() async {
    debugPrint('[PerformanceMonitoring] Supabase boilerplate noop initialized');
  }

  void startTrace(String name) {
    if (!_isValidTraceName(name)) return;
    _activeTraces.putIfAbsent(name, () => _TraceSnapshot(name));
    debugPrint('[PerformanceMonitoring] Started trace: $name');
  }

  void stopTrace(String name) {
    final trace = _activeTraces.remove(name);
    if (trace == null) return;
    debugPrint(
      '[PerformanceMonitoring] Stopped trace: $name '
      '(${DateTime.now().difference(trace.startedAt).inMilliseconds}ms)',
    );
  }

  void putAttribute(String traceName, String attribute, Object value) {
    final trace = _activeTraces[traceName];
    if (trace == null) return;
    trace.attributes[attribute] = value.toString().truncate(100);
  }

  void setMetric(String traceName, String metricName, int value) {
    _activeTraces[traceName]?.metrics[metricName] = value;
  }

  void incrementMetric(String traceName, String metricName, [int value = 1]) {
    final trace = _activeTraces[traceName];
    if (trace == null) return;
    trace.metrics[metricName] = (trace.metrics[metricName] ?? 0) + value;
  }

  int getMetric(String traceName, String metricName) {
    return _activeTraces[traceName]?.metrics[metricName] ?? 0;
  }

  bool _isValidTraceName(String name) {
    if (name.trim() != name) return false;
    if (name.startsWith('_')) return false;
    if (name.length > 100) return false;
    return true;
  }
}

class _TraceSnapshot {
  _TraceSnapshot(this.name) : startedAt = DateTime.now();

  final String name;
  final DateTime startedAt;
  final Map<String, String> attributes = {};
  final Map<String, int> metrics = {};
}
