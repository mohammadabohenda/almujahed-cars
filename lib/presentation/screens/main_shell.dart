// ============================================================================
// ملف: main_shell.dart
// الوظيفة: الحاوية الرئيسية بعد تسجيل الدخول، تحتوي شريط تنقّل سفلي (Bottom
// Navigation) بين ثلاث تبويبات: العقود، الأسطول (السيارات)، والإعدادات.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:almugahed_cars/presentation/screens/home_screen.dart';
import 'package:almugahed_cars/presentation/screens/settings_screen.dart';
import 'package:almugahed_cars/presentation/screens/vehicles_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    VehiclesListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'العقود',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: 'الأسطول',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
