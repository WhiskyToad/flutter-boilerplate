import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/utils/app_environment.dart';
import 'package:skelter/utils/app_flavor_env.dart';
import 'package:skelter/utils/extensions/primitive_types_extensions.dart';

class PerformanceMonitoringService {
  final FirebasePerformance _performance;
  final Map<String, Trace> _activeTraces = {};

  PerformanceMonitoringService({FirebasePerformance? performance})
      : _performance = performance ?? FirebasePerformance.instance;

  Future<void> initialize() async {
    try {
      debugPrint(
        '[PerformanceMonitoring] Initializing Performance Monitoring...',
      );

      final isEnabled = _shouldEnablePerformanceMonitoring();

      await _performance.setPerformanceCollectionEnabled(isEnabled);

      debugPrint(
        '[PerformanceMonitoring] Initialized (isEnabled: $isEnabled)',
      );
    } catch (e) {
      debugPrint('[PerformanceMonitoring] Initialization failed: $e');
    }
  }

  bool _shouldEnablePerformanceMonitoring() {
    if (AppEnvironment.isTestEnvironment) {
      debugPrint('[PerformanceMonitoring] Disabled: test environment');
      return false;
    }

    switch (AppConfig.appFlavor) {
      case AppFlavor.dev:
        debugPrint('[PerformanceMonitoring] Disabled: dev flavor');
        return false;
      case AppFlavor.stage:
        debugPrint('[PerformanceMonitoring] Enabled: stage flavor');
        return true;
      case AppFlavor.prod:
        debugPrint('[PerformanceMonitoring] Enabled: prod flavor');
        return true;
    }
  }

  void startTrace(String name) {
    if (!_isValidTraceName(name)) return;
    if (_activeTraces.containsKey(name)) return;

    try {
      final trace = _performance.newTrace(name);
      _activeTraces[name] = trace;
      trace.start().then((_) {
        debugPrint('[PerformanceMonitoring] Started trace: $name');
      }).catchError((e) {
        debugPrint('[PerformanceMonitoring] Error starting trace $name: $e');
        _activeTraces.remove(name);
      });
    } catch (e) {
      debugPrint('[PerformanceMonitoring] Error creating trace $name: $e');
    }
  }

  void stopTrace(String name) {
    final trace = _activeTraces[name];
    if (trace != null) {
      _activeTraces.remove(name);
      trace.stop().then((_) {
        debugPrint('[PerformanceMonitoring] Stopped trace: $name');
      }).catchError((e) {
        debugPrint('[PerformanceMonitoring] Error stopping trace $name: $e');
      });
    }
  }

  void putAttribute(
    String traceName,
    String attribute,
    Object value,
  ) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      try {
        final stringValue = value.toString().truncate(100);
        trace.putAttribute(attribute, stringValue);
        debugPrint(
          '[PerformanceMonitoring] Added attribute to '
          '$traceName: $attribute=$stringValue',
        );
      } catch (e) {
        debugPrint(
          '[PerformanceMonitoring] Error adding attribute to $traceName: $e',
        );
      }
    }
  }

  void setMetric(String traceName, String metricName, int value) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      try {
        trace.setMetric(metricName, value);
        debugPrint(
          '[PerformanceMonitoring] Set metric for '
          '$traceName: $metricName=$value',
        );
      } catch (e) {
        debugPrint(
          '[PerformanceMonitoring] Error setting metric for $traceName: $e',
        );
      }
    }
  }

  void incrementMetric(String traceName, String metricName, [int value = 1]) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      try {
        trace.incrementMetric(metricName, value);
        debugPrint(
          '[PerformanceMonitoring] Incremented metric for '
          '$traceName: $metricName by $value',
        );
      } catch (e) {
        debugPrint(
          '[PerformanceMonitoring] Error incrementing metric '
          'for $traceName: $e',
        );
      }
    }
  }

  int getMetric(String traceName, String metricName) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      return trace.getMetric(metricName);
    }
    return 0;
  }

  Future<HttpMetric?> startHttpMetric(String url, HttpMethod method) async {
    try {
      final metric = _performance.newHttpMetric(url, method);
      await metric.start();
      debugPrint(
        '[PerformanceMonitoring] Started HTTP metric: ${method.name} $url',
      );
      return metric;
    } catch (e) {
      debugPrint('[PerformanceMonitoring] Error starting HTTP metric: $e');
      return null;
    }
  }

  void stopHttpMetric(HttpMetric metric) {
    metric.stop().then((_) {
      debugPrint('[PerformanceMonitoring] Stopped HTTP metric');
    }).catchError((e) {
      debugPrint('[PerformanceMonitoring] Error stopping HTTP metric: $e');
    });
  }

  bool _isValidTraceName(String name) {
    if (name.trim() != name) {
      debugPrint(
        '[PerformanceMonitoring] Invalid trace name "$name": '
        'has leading or trailing whitespace',
      );
      return false;
    }

    if (name.startsWith('_')) {
      debugPrint(
        '[PerformanceMonitoring] Invalid trace name "$name": '
        'starts with underscore',
      );
      return false;
    }

    if (name.length > 100) {
      debugPrint(
        '[PerformanceMonitoring] Invalid trace name "$name": '
        'exceeds 100 characters',
      );
      return false;
    }

    return true;
  }
}
