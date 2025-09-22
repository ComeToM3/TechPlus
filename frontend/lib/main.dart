import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/navigation/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/security/security_service.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'shared/widgets/layouts/bento_card.dart';
import 'shared/widgets/buttons/animated_button.dart';
import 'generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialiser le service de sécurité
    await SecurityService().initialize();
    
    // Initialiser le client API
    await ApiClient().initialize();
    
    print('✅ Application initialized successfully');
  } catch (e) {
    print('❌ Error initializing application: $e');
    // Continuer même en cas d'erreur de sécurité
  }

  runApp(const ProviderScope(child: TechPlusApp()));
}

class TechPlusApp extends ConsumerWidget {
  const TechPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleNotifier.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final localeNotifier = ref.read(localeProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.appTitle} - Admin'),
        centerTitle: true,
        actions: [
          // Bouton de changement de langue
          IconButton(
            icon: Text(
              localeNotifier.getLanguageFlag(ref.watch(localeProvider)),
              style: const TextStyle(fontSize: 20),
            ),
            onPressed: () => localeNotifier.toggleLanguage(),
            tooltip: 'Changer la langue',
          ),
          // Bouton de basculement du thème
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeNotifier.toggleTheme(),
            tooltip: l10n.toggleTheme,
          ),
          // Bouton retour au site public
          IconButton(
            icon: const Icon(Icons.public),
            onPressed: () => context.go('/'),
            tooltip: 'Retour au site public',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/admin/login');
              }
            },
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte de bienvenue
            BentoCard(
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authState.user?.name != null
                        ? 'Bienvenue ${authState.user!.name!} (Admin)'
                        : 'Tableau de bord Admin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestion des réservations et administration',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Grille d'actions simplifiée
            Row(
              children: [
                Expanded(
                  child: BentoInfoCard(
                    icon: Icons.restaurant_menu,
                    title: 'Réservations',
                    subtitle: 'Gérer',
                    onTap: () => context.go('/admin/dashboard/reservations'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BentoInfoCard(
                    icon: Icons.add_circle_outline,
                    title: 'Nouvelle',
                    subtitle: 'Créer',
                    onTap: () =>
                        context.go('/admin/dashboard/reservations/create'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Boutons d'action principaux
            AnimatedButton(
              text: 'Gérer les réservations',
              icon: Icons.restaurant_menu,
              onPressed: () => context.go('/admin/dashboard/reservations'),
              type: ButtonType.primary,
              size: ButtonSize.large,
            ),

            const SizedBox(height: 16),

            AnimatedButton(
              text: 'Nouvelle réservation',
              icon: Icons.add,
              onPressed: () =>
                  context.go('/admin/dashboard/reservations/create'),
              type: ButtonType.secondary,
              size: ButtonSize.large,
            ),

            const SizedBox(height: 32),

            // Statut du système
            BentoCard(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.systemOperational,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                        ),
                        Text(
                          l10n.backendFrontendConfigured,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
