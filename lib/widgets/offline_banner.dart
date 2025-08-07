import 'package:flutter/material.dart';
import '../utils/network_utils.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;
  
  const OfflineBanner({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToNetworkChanges();
  }

  void _checkInitialConnectivity() async {
    final isConnected = await NetworkUtils.isConnected();
    if (mounted) {
      setState(() {
        _isOnline = isConnected;
      });
    }
  }

  void _listenToNetworkChanges() {
    NetworkUtils.connectivityStream.listen((connectivityResults) async {
      final isConnected = await NetworkUtils.isConnected();
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isOnline ? 0 : (40 + MediaQuery.of(context).padding.top),
            child: _isOnline
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    color: Colors.orange,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16,
                      right: 16,
                    ),
                    child: const SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You are offline. Data will sync when connection is restored.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
