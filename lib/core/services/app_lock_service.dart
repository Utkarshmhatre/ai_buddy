import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app lock with biometrics
class AppLockService extends ChangeNotifier {
  static const String _appLockEnabledKey = 'app_lock_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  // Singleton instance for global access
  static final AppLockService _instance = AppLockService._internal();
  static AppLockService get instance => _instance;
  
  // Factory constructor that returns the singleton
  factory AppLockService() => _instance;
  
  // Private constructor
  AppLockService._internal();
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Cached values for synchronous access
  bool _appLockEnabled = false;
  bool _biometricEnabled = false;
  bool _initialized = false;
  
  bool get appLockEnabled => _appLockEnabled;
  bool get biometricEnabled => _biometricEnabled;
  
  /// Initialize the service and load cached values
  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _appLockEnabled = prefs.getBool(_appLockEnabledKey) ?? false;
    _biometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    _initialized = true;
  }
  
  /// Check if device supports biometrics
  Future<bool> isBiometricSupported() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// Check if app lock is enabled
  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    _appLockEnabled = prefs.getBool(_appLockEnabledKey) ?? false;
    return _appLockEnabled;
  }
  
  /// Enable or disable app lock
  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockEnabledKey, enabled);
    _appLockEnabled = enabled;
    if (!enabled) {
      // If disabling app lock, also disable biometric
      await prefs.setBool(_biometricEnabledKey, false);
      _biometricEnabled = false;
    }
    notifyListeners(); // Notify listeners about the change
  }
  
  /// Check if biometric is enabled for app lock
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    return _biometricEnabled;
  }
  
  /// Enable or disable biometric for app lock
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    _biometricEnabled = enabled;
    notifyListeners(); // Notify listeners about the change
  }
  
  /// Authenticate with biometrics
  Future<BiometricAuthResult> authenticate({
    String reason = 'Authenticate to access AI Buddy',
  }) async {
    try {
      final isSupported = await isBiometricSupported();
      if (!isSupported) {
        return BiometricAuthResult(
          success: false,
          error: 'Biometric authentication is not available on this device',
        );
      }
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern as fallback
        ),
      );
      
      return BiometricAuthResult(success: authenticated);
    } on PlatformException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'NotAvailable':
          errorMessage = 'Biometric authentication is not available';
          break;
        case 'NotEnrolled':
          errorMessage = 'No biometrics enrolled. Please set up fingerprint or face unlock in device settings';
          break;
        case 'LockedOut':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        case 'PermanentlyLockedOut':
          errorMessage = 'Biometric locked. Please unlock using your device PIN';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed';
      }
      return BiometricAuthResult(success: false, error: errorMessage);
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: 'An unexpected error occurred',
      );
    }
  }
  
  /// Get a human-readable string for biometric type
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Biometric';
    }
  }
}

/// Result of biometric authentication attempt
class BiometricAuthResult {
  final bool success;
  final String? error;
  
  BiometricAuthResult({
    required this.success,
    this.error,
  });
}
