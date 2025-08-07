import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// A utility class for network-related operations and connectivity checks
class NetworkUtils {
  // Private constructor to prevent instantiation
  NetworkUtils._();

  static final Connectivity _connectivity = Connectivity();

  /// Checks if device has internet connectivity
  /// Returns true if connected to mobile or wifi, false otherwise
  static Future<bool> isConnected() async {
    try {
      final List<ConnectivityResult> connectivityResult = 
          await _connectivity.checkConnectivity();
      
      return connectivityResult.contains(ConnectivityResult.mobile) ||
             connectivityResult.contains(ConnectivityResult.wifi) ||
             connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }

  /// Checks if device has internet access by attempting to reach a reliable host
  /// This is more thorough than just checking connectivity status
  static Future<bool> hasInternetAccess({
    String host = 'google.com',
    int port = 443,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(timeout);
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking internet access: $e');
      }
      return false;
    }
  }

  /// Get current connectivity status
  /// Returns ConnectivityResult indicating the type of connection
  static Future<List<ConnectivityResult>> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting connectivity status: $e');
      }
      return [ConnectivityResult.none];
    }
  }

  /// Check if connected to WiFi
  static Future<bool> isConnectedToWiFi() async {
    try {
      final List<ConnectivityResult> connectivityResult = 
          await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking WiFi connectivity: $e');
      }
      return false;
    }
  }

  /// Check if connected to mobile data
  static Future<bool> isConnectedToMobile() async {
    try {
      final List<ConnectivityResult> connectivityResult = 
          await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking mobile connectivity: $e');
      }
      return false;
    }
  }

  /// Check if connected to ethernet
  static Future<bool> isConnectedToEthernet() async {
    try {
      final List<ConnectivityResult> connectivityResult = 
          await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking ethernet connectivity: $e');
      }
      return false;
    }
  }

  /// Get a stream of connectivity changes
  /// Useful for listening to network status changes in real-time
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Wait for internet connection to be available
  /// Useful when you need to ensure connectivity before proceeding
  static Future<void> waitForConnection({
    Duration checkInterval = const Duration(seconds: 2),
    Duration? timeout,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (true) {
      if (await isConnected()) {
        return;
      }
      
      if (timeout != null && stopwatch.elapsed >= timeout) {
        throw TimeoutException('Timeout waiting for internet connection', timeout);
      }
      
      await Future.delayed(checkInterval);
    }
  }

  /// Check network connectivity with retry mechanism
  /// Attempts to check connectivity multiple times before giving up
  static Future<bool> isConnectedWithRetry({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        if (await isConnected()) {
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Retry $i failed: $e');
        }
      }
      
      if (i < maxRetries - 1) {
        await Future.delayed(retryDelay);
      }
    }
    return false;
  }

  /// Get human-readable connection type string
  static Future<String> getConnectionTypeString() async {
    try {
      final List<ConnectivityResult> connectivityResult = 
          await _connectivity.checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else {
        return 'No Connection';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting connection type: $e');
      }
      return 'Unknown';
    }
  }

  /// Ping a specific host to check reachability
  static Future<bool> pingHost({
    required String host,
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final socket = await Socket.connect(host, port)
          .timeout(timeout);
      socket.destroy();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error pinging $host:$port - $e');
      }
      return false;
    }
  }
}

/// Exception thrown when network operations timeout
class TimeoutException implements Exception {
  final String message;
  final Duration? timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message${timeout != null ? ' (${timeout!.inSeconds}s)' : ''}';
}