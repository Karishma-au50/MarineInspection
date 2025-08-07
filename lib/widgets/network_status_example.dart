import 'package:flutter/material.dart';
import '../utils/network_utils.dart';

/// Example widget demonstrating how to use NetworkUtils
class NetworkStatusExample extends StatefulWidget {
  const NetworkStatusExample({super.key});

  @override
  State<NetworkStatusExample> createState() => _NetworkStatusExampleState();
}

class _NetworkStatusExampleState extends State<NetworkStatusExample> {
  bool _isConnected = false;
  String _connectionType = 'Unknown';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkNetworkStatus();
    _listenToConnectivityChanges();
  }

  /// Check initial network status
  void _checkNetworkStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final isConnected = await NetworkUtils.isConnected();
      final connectionType = await NetworkUtils.getConnectionTypeString();
      
      setState(() {
        _isConnected = isConnected;
        _connectionType = connectionType;
      });
    } catch (e) {
      print('Error checking network status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Listen to real-time connectivity changes
  void _listenToConnectivityChanges() {
    NetworkUtils.connectivityStream.listen((connectivityResults) {
      _checkNetworkStatus();
    });
  }

  /// Check internet access (more thorough check)
  void _checkInternetAccess() async {
    setState(() => _isLoading = true);
    
    try {
      final hasInternet = await NetworkUtils.hasInternetAccess();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasInternet 
                ? 'Internet access confirmed' 
                : 'No internet access detected',
          ),
          backgroundColor: hasInternet ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking internet: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Status'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 64,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connection Type: $_connectionType',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkNetworkStatus,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Refresh Status'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkInternetAccess,
              child: const Text('Test Internet Access'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Network Utils Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('• Basic connectivity check'),
            const Text('• Internet access verification'),
            const Text('• Connection type detection'),
            const Text('• Real-time connectivity monitoring'),
            const Text('• WiFi/Mobile/Ethernet specific checks'),
            const Text('• Host ping functionality'),
            const Text('• Wait for connection with timeout'),
            const Text('• Retry mechanisms'),
          ],
        ),
      ),
    );
  }
}
