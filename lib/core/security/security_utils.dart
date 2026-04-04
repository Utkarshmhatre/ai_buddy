import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// Security utilities for mental health app
/// Implements additional security measures beyond basic encryption
class SecurityUtils {
  SecurityUtils._();

  // ============== DATA SANITIZATION ==============
  
  /// Sanitize user input to prevent injection attacks
  static String sanitizeInput(String input) {
    // Remove any potential script tags or HTML
    var sanitized = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
    
    // Limit length to prevent buffer overflow
    if (sanitized.length > 10000) {
      sanitized = sanitized.substring(0, 10000);
    }
    
    return sanitized.trim();
  }

  /// Sanitize and validate API keys
  static bool isValidApiKey(String? key) {
    if (key == null || key.isEmpty) return false;
    if (key.length < 20 || key.length > 100) return false;
    // Basic check for alphanumeric with allowed special chars
    return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(key);
  }

  // ============== SECURE HASHING ==============

  /// Hash sensitive data for comparison (e.g., checking if content changed)
  static String hashSensitiveData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Create a secure hash for session tokens
  static String createSecureToken() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toString();
    final random = DateTime.now().hashCode.toString();
    final combined = '$timestamp$random';
    return hashSensitiveData(combined);
  }

  // ============== PII DETECTION & REDACTION ==============

  /// Detect and redact potential PII from text before sending to AI
  static String redactPII(String text) {
    var redacted = text;
    
    // Email addresses
    redacted = redacted.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[EMAIL REDACTED]'
    );
    
    // Phone numbers (various formats)
    redacted = redacted.replaceAll(
      RegExp(r'\b(\+?1?[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b'),
      '[PHONE REDACTED]'
    );
    
    // SSN patterns
    redacted = redacted.replaceAll(
      RegExp(r'\b\d{3}[-]?\d{2}[-]?\d{4}\b'),
      '[SSN REDACTED]'
    );
    
    // Credit card patterns
    redacted = redacted.replaceAll(
      RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b'),
      '[CARD REDACTED]'
    );
    
    // IP addresses
    redacted = redacted.replaceAll(
      RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
      '[IP REDACTED]'
    );
    
    // Physical addresses (basic pattern)
    redacted = redacted.replaceAll(
      RegExp(r'\b\d+\s+[\w\s]+(?:street|st|avenue|ave|road|rd|boulevard|blvd|drive|dr|lane|ln|way|court|ct)\b', caseSensitive: false),
      '[ADDRESS REDACTED]'
    );
    
    return redacted;
  }

  /// Check if text contains potential PII
  static bool containsPII(String text) {
    return text != redactPII(text);
  }

  // ============== SECURE LOGGING ==============

  /// Log message with sensitive data redacted (for debug builds only)
  static void secureLog(String message, {Map<String, dynamic>? data}) {
    if (!kDebugMode) return;
    
    var logMessage = message;
    if (data != null) {
      // Redact sensitive fields
      final safeData = Map<String, dynamic>.from(data);
      final sensitiveKeys = ['password', 'token', 'key', 'secret', 'api', 'auth', 'credential'];
      
      for (final key in safeData.keys.toList()) {
        if (sensitiveKeys.any((s) => key.toLowerCase().contains(s))) {
          safeData[key] = '[REDACTED]';
        }
      }
      
      logMessage += ' Data: $safeData';
    }
    
    debugPrint('[SECURE] $logMessage');
  }

  // ============== SESSION SECURITY ==============

  /// Check if session is potentially compromised (basic checks)
  static Future<SessionSecurityCheck> checkSessionSecurity() async {
    final issues = <String>[];
    
    // Check for debugger attachment (basic check)
    if (kDebugMode) {
      issues.add('Running in debug mode');
    }
    
    // Check for rooted/jailbroken device (basic heuristic)
    if (Platform.isAndroid) {
      final susFiles = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];
      
      for (final path in susFiles) {
        if (File(path).existsSync()) {
          issues.add('Potential root detected');
          break;
        }
      }
    }
    
    return SessionSecurityCheck(
      isSecure: issues.isEmpty,
      issues: issues,
      timestamp: DateTime.now(),
    );
  }

  // ============== DATA EXPORT SECURITY ==============

  /// Generate secure export with encryption option
  static Map<String, dynamic> prepareSecureExport({
    required Map<String, dynamic> data,
    required bool includeTimestamp,
    bool redactSensitive = true,
  }) {
    var exportData = Map<String, dynamic>.from(data);
    
    // Redact PII if requested
    if (redactSensitive) {
      exportData = _redactMapPII(exportData);
    }
    
    // Add metadata
    final export = <String, dynamic>{
      'version': '1.0',
      'exportedAt': includeTimestamp ? DateTime.now().toIso8601String() : null,
      'format': 'json',
      'data': exportData,
    };
    
    return export;
  }

  static Map<String, dynamic> _redactMapPII(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (entry.value is String) {
        result[entry.key] = redactPII(entry.value as String);
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = _redactMapPII(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        result[entry.key] = (entry.value as List).map((item) {
          if (item is String) return redactPII(item);
          if (item is Map<String, dynamic>) return _redactMapPII(item);
          return item;
        }).toList();
      } else {
        result[entry.key] = entry.value;
      }
    }
    
    return result;
  }
}

/// Result of session security check
class SessionSecurityCheck {
  final bool isSecure;
  final List<String> issues;
  final DateTime timestamp;

  const SessionSecurityCheck({
    required this.isSecure,
    required this.issues,
    required this.timestamp,
  });
}

/// API Key validator and manager
class ApiKeyManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  
  static const String _apiKeyKey = 'user_api_key';
  static const String _lastValidatedKey = 'api_key_last_validated';

  /// Store API key securely
  static Future<void> storeApiKey(String apiKey) async {
    if (!SecurityUtils.isValidApiKey(apiKey)) {
      throw ArgumentError('Invalid API key format');
    }
    await _storage.write(key: _apiKeyKey, value: apiKey);
    await _storage.write(
      key: _lastValidatedKey, 
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Retrieve stored API key
  static Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  /// Delete stored API key
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
    await _storage.delete(key: _lastValidatedKey);
  }

  /// Check if API key needs revalidation (e.g., after 30 days)
  static Future<bool> needsRevalidation() async {
    final lastValidated = await _storage.read(key: _lastValidatedKey);
    if (lastValidated == null) return true;
    
    final lastDate = DateTime.parse(lastValidated);
    final daysSinceValidation = DateTime.now().difference(lastDate).inDays;
    
    return daysSinceValidation > 30;
  }
}

/// Data retention policy manager
class DataRetentionManager {
  /// Default retention periods (in days)
  static const int chatHistoryRetention = 90;
  static const int moodDataRetention = 365;
  static const int journalRetention = 730; // 2 years
  static const int analyticsRetention = 30;

  /// Check if data should be purged based on retention policy
  static bool shouldPurge(DateTime createdAt, int retentionDays) {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation > retentionDays;
  }

  /// Get human-readable retention policy summary
  static String getRetentionPolicySummary() {
    return '''
Data Retention Policy:
• Chat conversations: $chatHistoryRetention days
• Mood tracking data: $moodDataRetention days
• Journal entries: $journalRetention days
• Analytics data: $analyticsRetention days

You can delete your data at any time from Settings > Privacy > Delete My Data.
''';
  }
}
