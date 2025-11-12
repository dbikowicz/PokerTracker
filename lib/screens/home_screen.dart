import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'sessions_screen.dart';
import 'social_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Start on Sessions by default

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SessionsScreen(),
    const SocialScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 24),
            activeIcon: Icon(Icons.dashboard, size: 24),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino_outlined, size: 28),
            activeIcon: Icon(Icons.casino, size: 28),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 24),
            activeIcon: Icon(Icons.people, size: 24),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined, size: 24),
            activeIcon: Icon(Icons.analytics, size: 24),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}