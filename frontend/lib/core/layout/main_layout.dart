import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../navigation/unified_navigation.dart';

/// Layout principal unifié avec bottom navigation seulement
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  // Pages principales
  final List<Widget> _pages = [
    const HomePage(),
    const ReservationsPage(),
    const TablesPage(),
    const SchedulePage(),
    const MenuPage(),
    const AnalyticsPage(),
    const ReportsPage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: UnifiedBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// Pages placeholder - à remplacer par les vraies pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedPageLayout(
      title: 'Accueil',
      body: Center(
        child: Text('Page d\'accueil - Dashboard principal'),
      ),
    );
  }
}

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedPageLayout(
      title: 'Réservations',
      body: Center(
        child: Text('Gestion des réservations'),
      ),
    );
  }
}

class TablesPage extends StatelessWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedPageLayout(
      title: 'Tables',
      body: Center(
        child: Text('Gestion des tables'),
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedPageLayout(
      title: 'Horaires',
      body: Center(
        child: Text('Gestion des horaires'),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedPageLayout(
      title: 'Menu',
      body: Center(
        child: Text('Gestion du menu'),
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedPageLayout(
      title: 'Analytiques',
      body: Center(
        child: Text('Statistiques et analyses'),
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedPageLayout(
      title: 'Rapports',
      body: Center(
        child: Text('Rapports détaillés'),
      ),
    );
  }
}
