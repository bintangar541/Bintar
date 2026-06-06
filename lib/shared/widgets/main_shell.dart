import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/ai_coach/presentation/pages/ai_coach_page.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static final GlobalKey<MainShellState> shellKey = GlobalKey<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void switchToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  final _pages = [
    const DashboardPage(),
    const ReportsPage(),
    const SizedBox.shrink(),
    const AnalyticsPage(),
    const AICoachPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 2) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const AddTransactionPage(),
                    transitionsBuilder: (_, a, __, c) =>
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                          child: c,
                        ),
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.emeraldGreen,
            unselectedItemColor: AppTheme.mutedText,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, height: 2),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, height: 2),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 22),
                activeIcon: Icon(Icons.home_rounded, size: 24),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.assessment_rounded, size: 22),
                activeIcon: Icon(Icons.assessment_rounded, size: 24),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppTheme.emeraldGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.emeraldShadow,
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.insights_rounded, size: 22),
                activeIcon: Icon(Icons.insights_rounded, size: 24),
                label: 'Analisis',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_rounded, size: 22),
                activeIcon: Icon(Icons.auto_awesome_rounded, size: 24),
                label: 'AI Coach',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
