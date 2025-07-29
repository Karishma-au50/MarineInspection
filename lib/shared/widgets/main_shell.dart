import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': Icons.home,
      'label': 'Home',
      'path': '/home',
    },
    {
      'icon': Icons.assignment,
      'label': 'Inspections',
      'path': '/inspections',
    },
    {
      'icon': Icons.analytics,
      'label': 'Reports',
      'path': '/reports',
    },
    {
      'icon': Icons.person,
      'label': 'Profile',
      'path': '/profile',
    },
  ];

  void _onItemTapped(int index) {
    final path = _navigationItems[index]['path'] as String;
    context.go(path);
  }

  int _calculateSelectedIndex(String location) {
    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.startsWith(_navigationItems[i]['path'])) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    _selectedIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 8,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon']),
            label: item['label'],
          );
        }).toList(),
      ),
    );
  }
}
