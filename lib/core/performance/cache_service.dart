import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// In-memory cache service for performance optimization
/// Implements LRU (Least Recently Used) eviction strategy
class CacheService {
  CacheService._();
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;

  // Configuration
  // ignore: unused_field
  static const int _defaultMaxItems = 100;
  static const Duration _defaultTtl = Duration(minutes: 30);

  // Cache stores by type
  final Map<String, _CacheStore<dynamic>> _stores = {};

  /// Get or create a cache store
  _CacheStore<T> _getStore<T>(String storeName) {
    _stores.putIfAbsent(storeName, () => _CacheStore<T>());
    return _stores[storeName] as _CacheStore<T>;
  }

  /// Store an item in cache
  void put<T>(
    String storeName,
    String key,
    T value, {
    Duration? ttl,
  }) {
    final store = _getStore<T>(storeName);
    store.put(key, value, ttl: ttl ?? _defaultTtl);
  }

  /// Get an item from cache
  T? get<T>(String storeName, String key) {
    final store = _getStore<T>(storeName);
    return store.get(key);
  }

  /// Get or compute item
  Future<T> getOrCompute<T>(
    String storeName,
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
  }) async {
    final cached = get<T>(storeName, key);
    if (cached != null) {
      return cached;
    }

    final value = await compute();
    put(storeName, key, value, ttl: ttl);
    return value;
  }

  /// Remove an item from cache
  void remove(String storeName, String key) {
    _stores[storeName]?.remove(key);
  }

  /// Clear a specific store
  void clearStore(String storeName) {
    _stores[storeName]?.clear();
  }

  /// Clear all caches
  void clearAll() {
    for (final store in _stores.values) {
      store.clear();
    }
  }

  /// Get cache statistics
  Map<String, CacheStats> getStats() {
    return _stores.map((key, value) => MapEntry(key, value.getStats()));
  }
}

/// Cache statistics
class CacheStats {
  final int itemCount;
  final int hitCount;
  final int missCount;
  final double hitRate;

  CacheStats({
    required this.itemCount,
    required this.hitCount,
    required this.missCount,
  }) : hitRate = (hitCount + missCount) == 0 
      ? 0 
      : hitCount / (hitCount + missCount);
}

/// Individual cache store with LRU eviction
class _CacheStore<T> {
  final int _maxItems;
  final LinkedHashMap<String, _CacheEntry<T>> _cache = LinkedHashMap();
  
  int _hitCount = 0;
  int _missCount = 0;

  _CacheStore({int maxItems = 100}) : _maxItems = maxItems;

  void put(String key, T value, {required Duration ttl}) {
    // Remove expired entries first
    _cleanExpired();

    // If at capacity, remove LRU item
    if (_cache.length >= _maxItems) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    // Remove existing key to update position in LRU
    _cache.remove(key);
    
    // Add new entry
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  T? get(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      _missCount++;
      return null;
    }

    // Check if expired
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      _missCount++;
      return null;
    }

    _hitCount++;

    // Move to end of LinkedHashMap (most recently used)
    _cache.remove(key);
    _cache[key] = entry;

    return entry.value;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
    _hitCount = 0;
    _missCount = 0;
  }

  CacheStats getStats() {
    return CacheStats(
      itemCount: _cache.length,
      hitCount: _hitCount,
      missCount: _missCount,
    );
  }

  void _cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => now.isAfter(entry.expiresAt));
  }
}

/// Cache entry with expiration
class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });
}

/// Debouncer for rate-limiting expensive operations
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    cancel();
  }
}

/// Throttler for limiting execution frequency
class Throttler {
  final Duration interval;
  DateTime? _lastExecution;

  Throttler({this.interval = const Duration(milliseconds: 300)});

  bool run(VoidCallback action) {
    final now = DateTime.now();
    
    if (_lastExecution == null || 
        now.difference(_lastExecution!) >= interval) {
      _lastExecution = now;
      action();
      return true;
    }
    
    return false;
  }

  void reset() {
    _lastExecution = null;
  }
}

/// Lazy value that computes only once when accessed
class Lazy<T> {
  final T Function() _factory;
  T? _value;
  bool _isInitialized = false;

  Lazy(this._factory);

  T get value {
    if (!_isInitialized) {
      _value = _factory();
      _isInitialized = true;
    }
    return _value!;
  }

  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
    _value = null;
  }
}

/// Async lazy value
class AsyncLazy<T> {
  final Future<T> Function() _factory;
  T? _value;
  bool _isInitialized = false;
  Future<T>? _computing;

  AsyncLazy(this._factory);

  Future<T> get value async {
    if (_isInitialized) {
      return _value!;
    }

    // Prevent multiple concurrent computations
    _computing ??= _compute();
    return _computing!;
  }

  Future<T> _compute() async {
    _value = await _factory();
    _isInitialized = true;
    return _value!;
  }

  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
    _value = null;
    _computing = null;
  }
}

/// Memoization helper for expensive functions
class Memoizer<K, V> {
  final Map<K, V> _cache = {};
  final int _maxSize;

  Memoizer({int maxSize = 100}) : _maxSize = maxSize;

  V memoize(K key, V Function() compute) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Evict oldest if at capacity
    if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }

    final value = compute();
    _cache[key] = value;
    return value;
  }

  void clear() {
    _cache.clear();
  }

  void invalidate(K key) {
    _cache.remove(key);
  }
}

/// Batch processor for grouping multiple operations
class BatchProcessor<T> {
  final Duration batchWindow;
  final int maxBatchSize;
  final Future<void> Function(List<T> items) processor;
  
  final List<T> _pending = [];
  Timer? _timer;

  BatchProcessor({
    this.batchWindow = const Duration(milliseconds: 100),
    this.maxBatchSize = 50,
    required this.processor,
  });

  void add(T item) {
    _pending.add(item);
    
    if (_pending.length >= maxBatchSize) {
      _flush();
    } else {
      _scheduleFlush();
    }
  }

  void _scheduleFlush() {
    _timer?.cancel();
    _timer = Timer(batchWindow, _flush);
  }

  void _flush() {
    _timer?.cancel();
    
    if (_pending.isEmpty) return;
    
    final items = List<T>.from(_pending);
    _pending.clear();
    
    processor(items);
  }

  void dispose() {
    _timer?.cancel();
    _flush();
  }
}

/// Performance profiler for development
class PerformanceProfiler {
  static final Map<String, List<Duration>> _measurements = {};
  static bool _enabled = kDebugMode;

  static void enable() => _enabled = true;
  static void disable() => _enabled = false;

  static T measure<T>(String label, T Function() operation) {
    if (!_enabled) return operation();

    final stopwatch = Stopwatch()..start();
    final result = operation();
    stopwatch.stop();

    _measurements.putIfAbsent(label, () => []).add(stopwatch.elapsed);
    
    if (kDebugMode) {
      debugPrint('⏱ $label: ${stopwatch.elapsedMilliseconds}ms');
    }

    return result;
  }

  static Future<T> measureAsync<T>(String label, Future<T> Function() operation) async {
    if (!_enabled) return operation();

    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();

    _measurements.putIfAbsent(label, () => []).add(stopwatch.elapsed);
    
    if (kDebugMode) {
      debugPrint('⏱ $label: ${stopwatch.elapsedMilliseconds}ms');
    }

    return result;
  }

  static Map<String, PerformanceStats> getStats() {
    return _measurements.map((key, durations) {
      final times = durations.map((d) => d.inMicroseconds).toList();
      times.sort();
      
      return MapEntry(key, PerformanceStats(
        count: times.length,
        totalMs: times.reduce((a, b) => a + b) / 1000,
        avgMs: times.isEmpty ? 0 : (times.reduce((a, b) => a + b) / times.length) / 1000,
        minMs: times.isEmpty ? 0 : times.first / 1000,
        maxMs: times.isEmpty ? 0 : times.last / 1000,
        p50Ms: times.isEmpty ? 0 : times[times.length ~/ 2] / 1000,
        p95Ms: times.isEmpty ? 0 : times[(times.length * 0.95).floor()] / 1000,
      ));
    });
  }

  static void clear() {
    _measurements.clear();
  }

  static void printStats() {
    if (!kDebugMode) return;
    
    debugPrint('=== Performance Stats ===');
    for (final entry in getStats().entries) {
      debugPrint('${entry.key}:');
      debugPrint('  Count: ${entry.value.count}');
      debugPrint('  Avg: ${entry.value.avgMs.toStringAsFixed(2)}ms');
      debugPrint('  Min: ${entry.value.minMs.toStringAsFixed(2)}ms');
      debugPrint('  Max: ${entry.value.maxMs.toStringAsFixed(2)}ms');
      debugPrint('  P50: ${entry.value.p50Ms.toStringAsFixed(2)}ms');
      debugPrint('  P95: ${entry.value.p95Ms.toStringAsFixed(2)}ms');
    }
    debugPrint('=========================');
  }
}

class PerformanceStats {
  final int count;
  final double totalMs;
  final double avgMs;
  final double minMs;
  final double maxMs;
  final double p50Ms;
  final double p95Ms;

  PerformanceStats({
    required this.count,
    required this.totalMs,
    required this.avgMs,
    required this.minMs,
    required this.maxMs,
    required this.p50Ms,
    required this.p95Ms,
  });
}
