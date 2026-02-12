import 'package:expensetracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'statistics_screen.dart';
import 'cards_screen.dart';
import 'settings_screen.dart';
import '../controllers/expense_provider.dart';

class BottomNavScaffold extends ConsumerStatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  ConsumerState<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends ConsumerState<BottomNavScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StatisticsScreen(),
    const CardsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.stats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.credit_card),
            label: l10n.cards,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
