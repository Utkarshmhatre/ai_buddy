import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing session timeout and automatic lock
class SessionService with WidgetsBindingObserver {
  static SessionService? _instance;
  
  static const String _timeoutMinutesKey = 'session_timeout_minutes';
  static const String _sessionEnabledKey = 'session_timeout_enabled';
  static const String _lastActivityKey = 'last_activity_timestamp';
  static const String _isLockedKey = 'session_locked';
  
  // Default timeout options (in minutes)
  static const int defaultTimeoutMinutes = 30;
  static const List<int> timeoutOptions = [5, 10, 15, 30, 60];
  
  late SharedPreferences _prefs;
  bool _initialized = false;
  Timer? _inactivityTimer;
  DateTime _lastActivity = DateTime.now();
  
  // Callbacks
  VoidCallback? onSessionLocked;
  VoidCallback? onSessionExpired;
  
  SessionService._() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  /// Get singleton instance
  static Future<SessionService> getInstance() async {
    if (_instance == null) {
      _instance = SessionService._();
      await _instance!._initialize();
    }
    return _instance!;
  }
  
  Future<void> _initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _lastActivity = DateTime.now();
    _initialized = true;
    
    // Start monitoring if enabled
    if (isTimeoutEnabled) {
      _startInactivityTimer();
    }
  }
  
  /// Get current timeout duration in minutes
  int get timeoutMinutes {
    return _prefs.getInt(_timeoutMinutesKey) ?? defaultTimeoutMinutes;
  }
  
  /// Set timeout duration in minutes
  Future<void> setTimeoutMinutes(int minutes) async {
    if (!timeoutOptions.contains(minutes)) {
      throw ArgumentError('Invalid timeout value. Must be one of: $timeoutOptions');
    }
    await _prefs.setInt(_timeoutMinutesKey, minutes);
    _restartTimer();
  }
  
  /// Check if session timeout is enabled
  bool get isTimeoutEnabled {
    return _prefs.getBool(_sessionEnabledKey) ?? true;
  }
  
  /// Enable or disable session timeout
  Future<void> setTimeoutEnabled(bool enabled) async {
    await _prefs.setBool(_sessionEnabledKey, enabled);
    if (enabled) {
      _startInactivityTimer();
    } else {
      _stopInactivityTimer();
    }
  }
  
  /// Check if session is currently locked
  bool get isLocked {
    return _prefs.getBool(_isLockedKey) ?? false;
  }
  
  /// Lock the session
  Future<void> lockSession() async {
    await _prefs.setBool(_isLockedKey, true);
    _stopInactivityTimer();
    onSessionLocked?.call();
  }
  
  /// Unlock the session (called after successful authentication)
  Future<void> unlockSession() async {
    await _prefs.setBool(_isLockedKey, false);
    recordActivity();
    if (isTimeoutEnabled) {
      _startInactivityTimer();
    }
  }
  
  /// Record user activity (resets the timeout timer)
  void recordActivity() {
    _lastActivity = DateTime.now();
    _prefs.setInt(_lastActivityKey, _lastActivity.millisecondsSinceEpoch);
    _restartTimer();
  }
  
  /// Get time remaining until session expires
  Duration get timeUntilExpiry {
    final elapsed = DateTime.now().difference(_lastActivity);
    final timeout = Duration(minutes: timeoutMinutes);
    final remaining = timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  /// Get formatted time remaining
  String get timeRemainingFormatted {
    final remaining = timeUntilExpiry;
    if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
    }
    return '${remaining.inSeconds}s';
  }
  
  /// Check if session has expired
  bool get hasExpired {
    if (!isTimeoutEnabled) return false;
    final elapsed = DateTime.now().difference(_lastActivity);
    return elapsed.inMinutes >= timeoutMinutes;
  }
  
  void _startInactivityTimer() {
    _stopInactivityTimer();
    
    // Check every minute
    _inactivityTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkInactivity(),
    );
  }
  
  void _stopInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }
  
  void _restartTimer() {
    if (isTimeoutEnabled && !isLocked) {
      _startInactivityTimer();
    }
  }
  
  void _checkInactivity() {
    if (!isTimeoutEnabled) return;
    if (isLocked) return;
    
    final elapsed = DateTime.now().difference(_lastActivity);
    
    if (elapsed.inMinutes >= timeoutMinutes) {
      debugPrint('SessionService: Session expired after ${elapsed.inMinutes} minutes of inactivity');
      lockSession();
      onSessionExpired?.call();
    }
  }
  
  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        if (hasExpired) {
          lockSession();
          onSessionExpired?.call();
        } else {
          recordActivity();
        }
        break;
        
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App went to background - save last activity time
        _prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch);
        break;
        
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is being destroyed or hidden
        break;
    }
  }
  
  /// Dispose of the service
  void dispose() {
    _stopInactivityTimer();
    WidgetsBinding.instance.removeObserver(this);
  }
}

/// Mixin for screens that need to track user activity
mixin SessionActivityMixin<T extends StatefulWidget> on State<T> {
  SessionService? _sessionService;
  
  @override
  void initState() {
    super.initState();
    _initSessionTracking();
  }
  
  Future<void> _initSessionTracking() async {
    _sessionService = await SessionService.getInstance();
  }
  
  /// Call this when user interacts with the screen
  void recordUserActivity() {
    _sessionService?.recordActivity();
  }
  
  /// Wrap your GestureDetector or other widgets with this to auto-track activity
  Widget withActivityTracking(Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: recordUserActivity,
      onPanDown: (_) => recordUserActivity(),
      onScaleStart: (_) => recordUserActivity(),
      child: child,
    );
  }
}

/// Widget that wraps the app to handle session locking
class SessionLockWrapper extends StatefulWidget {
  final Widget child;
  final Widget lockScreen;
  
  const SessionLockWrapper({
    super.key,
    required this.child,
    required this.lockScreen,
  });
  
  @override
  State<SessionLockWrapper> createState() => _SessionLockWrapperState();
}

class _SessionLockWrapperState extends State<SessionLockWrapper> {
  SessionService? _sessionService;
  bool _isLocked = false;
  
  @override
  void initState() {
    super.initState();
    _initSession();
  }
  
  Future<void> _initSession() async {
    _sessionService = await SessionService.getInstance();
    
    _sessionService!.onSessionLocked = () {
      if (mounted) {
        setState(() => _isLocked = true);
      }
    };
    
    _sessionService!.onSessionExpired = () {
      if (mounted) {
        setState(() => _isLocked = true);
      }
    };
    
    // Check initial state
    if (mounted) {
      setState(() => _isLocked = _sessionService!.isLocked);
    }
  }
  
  @override
  void dispose() {
    _sessionService?.onSessionLocked = null;
    _sessionService?.onSessionExpired = null;
    super.dispose();
  }
  
  void _onUnlock() {
    _sessionService?.unlockSession();
    setState(() => _isLocked = false);
  }

  /// Unlock the session programmatically
  void unlock() => _onUnlock();

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return widget.lockScreen;
    }
    
    // Wrap with activity detector
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _sessionService?.recordActivity(),
      onPanDown: (_) => _sessionService?.recordActivity(),
      child: widget.child,
    );
  }
}
