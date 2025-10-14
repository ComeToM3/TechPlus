import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reservation_calendar_provider.dart';
import '../../domain/entities/reservation_calendar.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/table_provider.dart' as data;
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../providers/schedule_provider.dart';
import '../../../../core/navigation/unified_navigation.dart';
import '../../../../core/providers/theme_provider.dart';
import '../widgets/public_navigation_button.dart';

/// Page de création de réservation moderne et ergonomique
class CreateReservationPage extends ConsumerStatefulWidget {
  const CreateReservationPage({super.key});

  @override
  ConsumerState<CreateReservationPage> createState() => _CreateReservationPageState();
}

class _CreateReservationPageState extends ConsumerState<CreateReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientSearchController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTime;
  int _partySize = 2;
  bool _isCreating = false;
  
  // Données sélectionnées
  List<Map<String, dynamic>> _availableSlots = [];
  TableEntity? _selectedTable;
  
  // Contrôleurs pour nouveau client
  final _newClientNameController = TextEditingController();
  final _newClientEmailController = TextEditingController();
  final _newClientPhoneController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _clientSearchController.addListener(_onClientSearchChanged);
    // Déplacer le chargement dans didChangeDependencies pour éviter les problèmes de timing
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Charger les données seulement si elles ne sont pas déjà chargées
    _loadInitialDataIfNeeded();
  }
  
  Future<void> _loadInitialDataIfNeeded() async {
    final authState = ref.read(authProvider);
    final tableState = ref.read(data.tableProvider);
    
    // Ne charger que si on a un token et que les tables ne sont pas déjà chargées
    if (authState.accessToken != null && 
        !tableState.isLoading && 
        tableState.items.isEmpty && 
        tableState.error == null) {
      await _loadInitialData();
    }
  }
  
  Future<void> _loadInitialData() async {
    // Charger les tables et les créneaux pour la création de réservation
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        await ref.read(data.tableProvider.notifier).loadTables(
          token: authState.accessToken!,
        );
        await ref.read(scheduleProvider.notifier).loadScheduleConfig(
          token: authState.accessToken!,
        );
      } catch (e) {
        // Gérer les erreurs de chargement
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement des données: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  void _onClientSearchChanged() {
    // Recherche de clients via l'API - à implémenter selon les besoins
  }

  /// Rafraîchir les tables
  Future<void> _refreshTables() async {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        await ref.read(data.tableProvider.notifier).loadTables(
          token: authState.accessToken!,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du rafraîchissement des tables: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Rafraîchir la configuration des créneaux
  Future<void> _refreshScheduleConfig() async {
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      try {
        // Vérifier si on a déjà des données avant de recharger
        final scheduleState = ref.read(scheduleProvider);
        if (scheduleState.config != null && scheduleState.config!['daySchedules'] != null && (scheduleState.config!['daySchedules'] as List).isNotEmpty) {
          print('🔍 [CreateReservationPage] Schedule config already loaded, skipping refresh');
          return;
        }
        
        await ref.read(scheduleProvider.notifier).loadScheduleConfig(
          token: authState.accessToken!,
        );
        // Recharger les créneaux après avoir mis à jour la configuration
        if (_selectedDate != null) {
          await _loadAvailableSlots();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du rafraîchissement de la configuration: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _clientSearchController.dispose();
    _specialRequestsController.dispose();
    _newClientNameController.dispose();
    _newClientEmailController.dispose();
    _newClientPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createReservation),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/admin/dashboard/reservations'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          const CompactPublicNavigationButton(),
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeProvider);
              return IconButton(
                icon: Icon(
                  themeMode == ThemeMode.dark 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                tooltip: themeMode == ThemeMode.dark 
                    ? 'Passer au thème clair' 
                    : 'Passer au thème sombre',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme, l10n),
      body: CustomAnimatedWidget(
        config: AnimationConfig(
          type: AnimationType.fadeIn,
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, l10n),
                const SizedBox(height: 24),
                _buildClientSearchSection(theme, l10n),
                const SizedBox(height: 24),
                      _buildDateTimeSection(theme, l10n),
                      const SizedBox(height: 24),
                      _buildTableSelectionSection(theme, l10n),
                      const SizedBox(height: 24),
                      _buildPartySizeSection(theme, l10n),
                const SizedBox(height: 24),
                _buildSpecialRequestsSection(theme, l10n),
                const SizedBox(height: 32),
                _buildActionButtons(theme, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nouvelle réservation',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Créez une réservation pour un client existant',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildClientSearchSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Sélection du client',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Seulement l'option nouveau client
                  _buildNewClientForm(theme),
        ],
      ),
    );
  }


  Widget _buildNewClientForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du nouveau client',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newClientNameController,
          decoration: InputDecoration(
            labelText: 'Nom complet *',
            hintText: 'Ex: Jean Dupont',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom est obligatoire';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newClientEmailController,
          decoration: InputDecoration(
            labelText: 'Email *',
            hintText: 'jean@example.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'L\'email est obligatoire';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format d\'email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newClientPhoneController,
          decoration: InputDecoration(
            labelText: 'Téléphone',
            hintText: '06 12 34 56 78',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Date et créneaux',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            'Sélectionnez la date et le créneau de la réservation',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildDateSelector(theme),
          if (_selectedDate != null) ...[
            const SizedBox(height: 16),
            _buildAvailableSlots(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Sélectionner une date',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAvailableSlots(ThemeData theme) {
    // Si aucun créneau n'est configuré, afficher un message
    if (_availableSlots.isEmpty) {
      return _buildNoSlotsMessage(theme);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créneaux disponibles',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSlots.map((slot) {
            final isSelected = _selectedTime == slot['time'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTime = slot['time'];
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  slot['time'],
                  style: TextStyle(
                    color: isSelected
                      ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoSlotsMessage(ThemeData theme) {
    // Déterminer le message selon le jour sélectionné
    final dayOfWeek = _selectedDate != null ? _getDayOfWeek(_selectedDate!) : '';
    final isWeekend = dayOfWeek == 'saturday' || dayOfWeek == 'sunday';
    final isMonday = dayOfWeek == 'monday';
    
    String title;
    String message;
    IconData icon;
    
    if (isMonday) {
      title = 'Lundi fermé';
      message = 'Le restaurant est fermé le lundi. Veuillez choisir un autre jour pour votre réservation.';
      icon = Icons.event_busy;
    } else if (isWeekend) {
      title = 'Weekend fermé';
      message = 'Le restaurant est fermé le weekend. Veuillez choisir un jour de semaine pour votre réservation.';
      icon = Icons.event_busy;
    } else {
      title = 'Aucun créneau configuré';
      message = 'Vous devez d\'abord configurer les créneaux horaires de votre restaurant avant de pouvoir créer des réservations.';
      icon = Icons.schedule_outlined;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (!isMonday && !isWeekend) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _refreshScheduleConfig,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/admin/dashboard/schedule');
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Configurer les créneaux'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Choisir une autre date'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableSelectionSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Sélection de table',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez une table pour cette réservation',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildTableGrid(theme),
        ],
      ),
    );
  }

  Widget _buildTableGrid(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        // Utiliser select pour éviter les rebuilds inutiles
        final tableState = ref.watch(data.tableProvider);
        final isLoading = tableState.isLoading;
        final error = tableState.error;
        final tables = tableState.items;
        
        // Debug: Afficher l'état actuel
        print('🔍 [DEBUG] _buildTableGrid - État des tables:');
        print('  - isLoading: $isLoading');
        print('  - error: $error');
        print('  - tables count: ${tables.length}');
        
        // Si on est en train de charger et qu'il n'y a pas de tables, afficher le loading
        if (isLoading && tables.isEmpty) {
          return _buildLoadingTables(theme);
        }
        
        // Si il y a une erreur et pas de tables, afficher l'erreur
        if (error != null && tables.isEmpty) {
          return _buildTablesError(theme, error);
        }
        
        // Si pas de tables et pas de loading, afficher le message
        if (tables.isEmpty && !isLoading) {
          return _buildNoTablesMessage(theme);
        }
        
        // Filtrer les tables disponibles et adaptées à la taille du groupe
        final availableTables = tables
            .where((table) => table.isActive && table.capacity >= _partySize)
            .toList();
            
        print('  - available tables count: ${availableTables.length}');
        print('  - party size: $_partySize');
        
        if (availableTables.isEmpty && tables.isNotEmpty) {
          return _buildNoSuitableTablesMessage(theme);
        }
        
        return _buildTablesGrid(theme, availableTables);
      },
    );
  }

  Widget _buildLoadingTables(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTablesError(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement des tables',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshTables,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTablesMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune table configurée',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous devez d\'abord configurer les tables de votre restaurant avant de pouvoir créer des réservations.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _refreshTables,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/admin/dashboard/tables');
                },
                icon: const Icon(Icons.settings),
                label: const Text('Configurer les tables'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSuitableTablesMessage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune table adaptée',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune table disponible ne peut accueillir $_partySize personnes. Essayez de réduire le nombre de personnes ou configurez des tables plus grandes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesGrid(ThemeData theme, List<TableEntity> tables) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tables disponibles (${tables.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            final isSelected = _selectedTable?.id == table.id;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTable = table;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_restaurant,
                      size: 24,
                      color: isSelected 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Table ${table.number}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? theme.colorScheme.onPrimary 
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${table.capacity} places',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.onPrimary.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (table.position != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        table.position!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected 
                              ? theme.colorScheme.onPrimary.withOpacity(0.6)
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPartySizeSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Nombre de personnes',
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            'Combien de personnes pour cette réservation ?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
              IconButton(
                onPressed: _partySize > 1 ? () {
                  setState(() {
                    _partySize--;
                    _selectedTable = null; // Reset table selection when party size changes
                  });
                } : null,
                icon: const Icon(Icons.remove),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_partySize',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                onPressed: _partySize < 20 ? () {
                  setState(() {
                    _partySize++;
                    _selectedTable = null; // Reset table selection when party size changes
                  });
                } : null,
                icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildSpecialRequestsSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Demandes spéciales',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Y a-t-il des demandes particulières pour cette réservation ?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specialRequestsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Table près de la fenêtre, anniversaire, allergie...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/admin/dashboard/reservations'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child:           Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SimpleButton(
              onPressed: _isCreating ? null : _createReservation,
              text: _isCreating ? 'Création...' : 'Créer la réservation',
              type: ButtonType.primary,
              isLoading: _isCreating,
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
        _availableSlots = [];
      });
      await _loadAvailableSlots();
    }
  }


  Future<void> _loadAvailableSlots() async {
    if (_selectedDate == null) return;
    
    try {
      // Utiliser les données déjà chargées du provider (éviter les appels multiples)
      final scheduleState = ref.read(scheduleProvider);
      
      if (scheduleState.config != null) {
        // Convertir les données brutes en entités typées
        final scheduleConfig = ScheduleConfig.fromJson(scheduleState.config!);
        final dayOfWeek = _getDayOfWeek(_selectedDate!);
        
        // Trouver le jour correspondant
        final daySchedule = scheduleConfig.daySchedules.firstWhere(
          (day) => day.dayOfWeek == dayOfWeek,
          orElse: () => DaySchedule(
            dayOfWeek: dayOfWeek,
            isOpen: false,
            timeSlots: [],
          ),
        );
        
        print('🔍 [DEBUG] _loadAvailableSlots - Utilisation des entités typées:');
        print('  - dayOfWeek: $dayOfWeek');
        print('  - daySchedule.isOpen: ${daySchedule.isOpen}');
        print('  - daySchedule.timeSlots.length: ${daySchedule.timeSlots.length}');
        
        if (daySchedule.isOpen) {
          // Vérifier si la date n'est pas trop en avance
          final now = DateTime.now();
          final daysDifference = _selectedDate!.difference(now).inDays;
          final maxAdvanceDays = scheduleConfig.timeSlotSettings.maxAdvanceBookingDays;
          
          if (daysDifference > maxAdvanceDays) {
            print('  - Date trop en avance (${daysDifference} jours > ${maxAdvanceDays} jours)');
            setState(() {
              _availableSlots = [];
            });
            return;
          }
          
          // Vérifier les contraintes de réservation
          final isToday = daysDifference == 0;
          final isWeekend = _selectedDate!.weekday == DateTime.saturday || _selectedDate!.weekday == DateTime.sunday;
          final allowSameDay = scheduleConfig.timeSlotSettings.allowSameDayBooking;
          final allowWeekend = scheduleConfig.timeSlotSettings.allowWeekendBooking;
          
          if (isToday && !allowSameDay) {
            print('  - Réservation le même jour non autorisée');
            setState(() {
              _availableSlots = [];
            });
            return;
          }
          
          if (isWeekend && !allowWeekend) {
            print('  - Réservation le weekend non autorisée');
            setState(() {
              _availableSlots = [];
            });
            return;
          }
          
          // Générer les créneaux selon les paramètres de configuration
          final generatedSlots = _generateSlotsFromSettings(
            daySchedule, 
            scheduleConfig.timeSlotSettings,
            _selectedDate!
          );
          
          print('  - Créneaux générés: ${generatedSlots.length}');
          print('  - Heures d\'ouverture: ${daySchedule.openingTime} - ${daySchedule.closingTime}');
          print('  - Durée des créneaux: ${scheduleConfig.timeSlotSettings.slotDurationMinutes} minutes');
          print('  - Temps de pause: ${scheduleConfig.timeSlotSettings.bufferTimeMinutes} minutes');
          
          for (final slot in generatedSlots) {
            print('    - ${slot['time']}');
          }
          
          setState(() {
            _availableSlots = generatedSlots;
          });
        } else {
          // Jour fermé
          print('  - Jour fermé');
          setState(() {
            _availableSlots = [];
          });
        }
      } else {
        // Pas de configuration du tout
        setState(() {
          _availableSlots = [];
        });
      }
    } catch (e) {
      // En cas d'erreur, ne pas afficher de créneaux par défaut
      setState(() {
        _availableSlots = [];
      });
    }
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return days[date.weekday % 7];
  }

  /// Génère les créneaux selon les paramètres de configuration
  List<Map<String, dynamic>> _generateSlotsFromSettings(
    DaySchedule daySchedule,
    TimeSlotSettings settings,
    DateTime selectedDate,
  ) {
    if (!daySchedule.isOpen || 
        daySchedule.openingTime == null || 
        daySchedule.closingTime == null) {
      return [];
    }

    final openingTime = _parseTimeString(daySchedule.openingTime!);
    final closingTime = _parseTimeString(daySchedule.closingTime!);
    
    if (openingTime == null || closingTime == null) {
      return [];
    }

    final slots = <Map<String, dynamic>>[];
    final slotDuration = settings.slotDurationMinutes;
    final bufferTime = settings.bufferTimeMinutes;
    final minAdvanceHours = settings.minAdvanceBookingHours;
    
    print('  - Génération des créneaux:');
    print('    - Ouverture: ${daySchedule.openingTime}');
    print('    - Fermeture: ${daySchedule.closingTime}');
    print('    - Durée: ${slotDuration} minutes');
    print('    - Pause: ${bufferTime} minutes');
    print('    - Réservation minimum: ${minAdvanceHours} heures');
    
    var currentTime = openingTime;
    while (currentTime.isBefore(closingTime)) {
      final endTime = currentTime.add(Duration(minutes: slotDuration));
      
      // Vérifier si le créneau ne dépasse pas l'heure de fermeture
      if (endTime.isAfter(closingTime)) {
        break;
      }
      
      final timeString = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      
      // Créer le DateTime complet du créneau
      final slotDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        currentTime.hour,
        currentTime.minute,
      );
      
      // Vérifier si le créneau respecte la contrainte de réservation minimum
      final now = DateTime.now();
      final minBookingTime = now.add(Duration(hours: minAdvanceHours));
      final isAvailable = slotDateTime.isAfter(minBookingTime);
      
      if (isAvailable) {
        slots.add({
          'time': timeString,
          'capacity': settings.defaultCapacityPerSlot,
          'isAvailable': true,
        });
      } else {
        print('    - Créneau ${timeString} exclu (trop proche: ${slotDateTime.difference(now).inHours}h < ${minAdvanceHours}h)');
      }
      
      // Ajouter le temps de pause entre les créneaux
      currentTime = endTime.add(Duration(minutes: bufferTime));
    }
    
    print('    - Créneaux générés: ${slots.length}');
    return slots;
  }

  /// Parse une chaîne de temps (HH:MM) en DateTime
  DateTime? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return DateTime(2000, 1, 1, hour, minute);
    } catch (e) {
      return null;
    }
  }



  

  void _createReservation() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Vérifier les informations du nouveau client
    if (_newClientNameController.text.trim().isEmpty ||
        _newClientEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir les informations du client')),
      );
      return;
    }
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date et un créneau')),
      );
      return;
    }
    
    if (_selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une table')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      print('🔍 [DEBUG] _createReservation - Début de la création');
      print('  - Date sélectionnée: $_selectedDate');
      print('  - Heure sélectionnée: $_selectedTime');
      print('  - Table sélectionnée: ${_selectedTable?.number}');
      print('  - Taille du groupe: $_partySize');
      
      final calendarNotifier = ref.read(reservationCalendarProvider.notifier);
      
      // Préparer les données du client
      final clientName = _newClientNameController.text.trim();
      final clientEmail = _newClientEmailController.text.trim();
      final clientPhone = _newClientPhoneController.text.trim().isNotEmpty
          ? _newClientPhoneController.text.trim()
          : null;
          
      print('  - Client: $clientName ($clientEmail)');
      print('  - Téléphone: $clientPhone');
      
      // Extraire l'heure de début du créneau sélectionné
      String timeForBackend = _selectedTime!;
      if (_selectedTime!.contains(' - ')) {
        timeForBackend = _selectedTime!.split(' - ')[0]; // Prendre l'heure de début
      }
      
      // Gérer les demandes spéciales vides
      String specialRequests = _specialRequestsController.text.trim();
      if (specialRequests.isEmpty) {
        specialRequests = ''; // Envoyer une chaîne vide au lieu de null
      }
      
      final reservation = ReservationCalendar(
        id: '', // Sera généré par le backend
        clientName: clientName,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
        date: _selectedDate!,
        time: timeForBackend, // Utiliser l'heure de début seulement
        partySize: _partySize,
        status: 'PENDING', // Utiliser le format en majuscules
        tableNumber: _selectedTable!.number.toString(), // Ajouter le numéro de table
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        specialRequests: specialRequests,
      );
      
      print('  - Réservation créée:');
      print('    - ID: ${reservation.id}');
      print('    - Date: ${reservation.date}');
      print('    - Heure: ${reservation.time}');
      print('    - Table: ${reservation.tableNumber}');
      print('    - Statut: ${reservation.status}');

      print('  - Appel de l\'API...');
      final createdReservation = await calendarNotifier.createReservation(reservation);
      print('  - Résultat API: ${createdReservation != null ? "Succès" : "Échec"}');
      print('  - createdReservation: $createdReservation');
      print('  - createdReservation != null: ${createdReservation != null}');

      if (mounted && createdReservation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/admin/dashboard/reservations');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création de la réservation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Widget _buildBottomNavigationBar(ThemeData theme, AppLocalizations l10n) {
    return UnifiedBottomNavigation(
      currentIndex: 1, // Réservations est l'index 1
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/admin/dashboard');
            break;
          case 1:
            context.go('/admin/dashboard/reservations');
            break;
          case 2:
            context.go('/admin/dashboard/tables');
            break;
          case 3:
            context.go('/admin/dashboard/schedule');
            break;
          case 4:
            context.go('/admin/dashboard/menu');
            break;
          case 5:
            context.go('/admin/dashboard/analytics');
            break;
          case 6:
            context.go('/admin/dashboard/reports');
            break;
        }
      },
    );
  }

}