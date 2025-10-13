import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/reservation.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/public_reservation_provider.dart';
import '../providers/public_restaurant_provider.dart';

/// Page de réservation publique pour les clients
/// Version simplifiée qui fonctionne sans dépendances complexes
/// Supporte le mode modification avec token
class PublicReservationPage extends ConsumerStatefulWidget {
  const PublicReservationPage({super.key});

  @override
  ConsumerState<PublicReservationPage> createState() => _PublicReservationPageState();
}

class _PublicReservationPageState extends ConsumerState<PublicReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTime;
  int _partySize = 2;
  bool _isCreating = false;
  
  String? _selectedTableId;
  
  // Variables pour le mode modification
  String? _managementToken;
  bool _isEditMode = false;
  String? _reservationId;
  bool _hasCheckedEditMode = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedEditMode) {
      _checkEditMode();
      _hasCheckedEditMode = true;
    }
  }

  @override
  void didUpdateWidget(PublicReservationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Vérifier à nouveau le mode edit si les paramètres ont changé
    _checkEditMode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _checkEditMode() {
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    final token = uri.queryParameters['token'];
    final mode = uri.queryParameters['mode'];
    
    if (token != null && mode == 'edit') {
      setState(() {
        _managementToken = token;
        _isEditMode = true;
      });
      _loadReservationData();
    }
  }

  Future<void> _loadReservationData() async {
    if (_managementToken == null) return;
    
    // Différer l'appel pour éviter de modifier le provider pendant la construction
    await Future.microtask(() async {
      try {
        // Charger les données de la réservation via le token
        final reservation = await ref.read(publicReservationProvider.notifier).validateManagementToken(_managementToken!);
        
        if (mounted) {
          // Pré-remplir les champs avec les données existantes
          _nameController.text = reservation?.clientName ?? '';
          _emailController.text = reservation?.clientEmail ?? '';
          _phoneController.text = reservation?.clientPhone ?? '';
          _specialRequestsController.text = reservation?.specialRequests ?? '';
          _selectedDate = reservation?.date;
          _selectedTime = reservation?.time;
          _partySize = reservation?.partySize ?? 2;
          _reservationId = reservation?.id;
          
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement: $e'),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Utiliser les nouveaux providers pour les créneaux et tables
    final timeSlotsState = _selectedDate != null 
        ? ref.watch(availableTimeSlotsProvider((date: _selectedDate!, partySize: _partySize)))
        : const AvailableTimeSlotsState();
    
    final tablesState = _selectedTime != null && _selectedDate != null
        ? ref.watch(availableTablesProvider((date: _selectedDate!, time: _selectedTime!, partySize: _partySize)))
        : const AvailableTablesState();
    
    // Charger les informations du restaurant au démarrage
    ref.listen(restaurantInfoProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    
    // Charger les informations du restaurant si pas encore chargées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantInfo = ref.read(restaurantInfoProvider);
      if (restaurantInfo.restaurantInfo == null && !restaurantInfo.isLoading) {
        ref.read(restaurantInfoProvider.notifier).loadRestaurantInfo();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier ma réservation' : l10n.newReservation),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: _isEditMode ? [
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: _showCancelDialog,
            tooltip: 'Annuler la réservation',
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(theme, l10n),
              const SizedBox(height: 24),
              
              // Sélection de date
              _buildDateSection(theme, l10n),
              const SizedBox(height: 24),
              
              // Sélection de l'heure
                      _buildTimeSection(theme, l10n, timeSlotsState),
              const SizedBox(height: 24),
              
              // Sélection du nombre de personnes
              _buildPartySizeSection(theme, l10n),
              const SizedBox(height: 24),
              
              // Sélection de table
              if (_selectedTime != null) _buildTableSection(theme, l10n, tablesState),
              if (_selectedTime != null) const SizedBox(height: 24),
              
              // Informations client
              _buildClientSection(theme, l10n),
              const SizedBox(height: 32),
              
              // Boutons d'action
              _buildActionButtons(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromTop,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onlineReservation,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onlineReservationDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner la date',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Choisir une date',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection(ThemeData theme, AppLocalizations l10n, AvailableTimeSlotsState timeSlotsState) {
    if (_selectedDate == null) return const SizedBox.shrink();

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner l\'heure',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (timeSlotsState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (timeSlotsState.timeSlots.isEmpty)
                Text(
                  'Aucun créneau disponible pour cette date',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: timeSlotsState.timeSlots
                      .map((time) => _buildTimeChip(theme, time))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(ThemeData theme, String time) {
    final isSelected = _selectedTime == time;
    
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedTime = time;
          _selectedTableId = null;
        });
        // Charger les créneaux disponibles pour cette date
        await ref.read(availableTimeSlotsProvider((date: _selectedDate!, partySize: _partySize)).notifier).loadTimeSlots();
        
        // Charger les tables disponibles pour ce créneau
        await ref.read(availableTablesProvider((date: _selectedDate!, time: time, partySize: _partySize)).notifier).loadTables();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
          ),
        ),
        child: Text(
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPartySizeSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.partySize,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                            onPressed: _partySize > 1 ? () async {
                              setState(() {
                                _partySize--;
                                _selectedTableId = null;
                              });
                              // Recharger les créneaux et tables si une date/heure est sélectionnée
                              if (_selectedDate != null) {
                                await ref.read(availableTimeSlotsProvider((date: _selectedDate!, partySize: _partySize)).notifier).loadTimeSlots();
                                if (_selectedTime != null) {
                                  await ref.read(availableTablesProvider((date: _selectedDate!, time: _selectedTime!, partySize: _partySize)).notifier).loadTables();
                                }
                              }
                            } : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_partySize ${_partySize == 1 ? l10n.person : l10n.people}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                            onPressed: _partySize < 20 ? () async {
                              setState(() {
                                _partySize++;
                                _selectedTableId = null;
                              });
                              // Recharger les créneaux et tables si une date/heure est sélectionnée
                              if (_selectedDate != null) {
                                await ref.read(availableTimeSlotsProvider((date: _selectedDate!, partySize: _partySize)).notifier).loadTimeSlots();
                                if (_selectedTime != null) {
                                  await ref.read(availableTablesProvider((date: _selectedDate!, time: _selectedTime!, partySize: _partySize)).notifier).loadTables();
                                }
                              }
                            } : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSection(ThemeData theme, AppLocalizations l10n, AvailableTablesState tablesState) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner une table',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (tablesState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (tablesState.tables.isEmpty)
                Text(
                  'Aucune table disponible pour ce créneau',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tablesState.tables
                      .where((table) => table['capacity'] >= _partySize)
                      .map((table) => _buildTableChip(theme, l10n, table))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableChip(ThemeData theme, AppLocalizations l10n, Map<String, dynamic> table) {
    final isSelected = _selectedTableId == table['id'];
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTableId = table['id']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l10n.table} ${table['number']}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${table['capacity']} ${l10n.people}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos Informations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Nom
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  if (!value.contains('@')) {
                    return l10n.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Téléphone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Demandes spéciales
              TextFormField(
                controller: _specialRequestsController,
                decoration: InputDecoration(
                  labelText: l10n.specialRequests,
                  prefixIcon: const Icon(Icons.note),
                  hintText: l10n.specialRequestsHint,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Row(
        children: [
          Expanded(
            child: SimpleButton(
              onPressed: () => context.go('/reservations'),
              text: l10n.cancel,
              type: ButtonType.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SimpleButton(
              onPressed: _isCreating ? null : _createReservation,
              text: _isCreating 
                ? (_isEditMode ? 'Modification...' : 'Création...')
                : (_isEditMode ? 'Sauvegarder les modifications' : l10n.createReservation),
              type: ButtonType.primary,
              isLoading: _isCreating,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
        _selectedTableId = null;
      });
      // Charger les créneaux disponibles pour cette date
      await ref.read(availableTimeSlotsProvider((date: date, partySize: _partySize)).notifier).loadTimeSlots();
    }
  }


  Future<void> _createReservation() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseCompleteAllFields),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      if (_isEditMode && _managementToken != null) {
        // Mode modification
        final reservation = Reservation(
          id: _reservationId!,
          date: _selectedDate!,
          time: _selectedTime!,
          duration: _partySize <= 4 ? 90 : 120,
          partySize: _partySize,
          status: 'PENDING',
          clientName: _nameController.text.trim(),
          clientEmail: _emailController.text.trim(),
          clientPhone: _phoneController.text.trim(),
          specialRequests: _specialRequestsController.text.trim().isEmpty
              ? null
              : _specialRequestsController.text.trim(),
          restaurantId: '', // Sera récupéré depuis la configuration du backend
          tableId: _selectedTableId!,
        );

        await ref
            .read(publicReservationProvider.notifier)
            .updateReservationWithToken(_managementToken!, reservation);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation modifiée avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/');
        }
      } else {
        // Mode création
        final reservation = Reservation(
          id: '', // Sera généré par le backend
          date: _selectedDate!,
          time: _selectedTime!,
          duration: _partySize <= 4 ? 90 : 120,
          partySize: _partySize,
          status: 'PENDING',
          clientName: _nameController.text.trim(),
          clientEmail: _emailController.text.trim(),
          clientPhone: _phoneController.text.trim(),
          specialRequests: _specialRequestsController.text.trim().isEmpty
              ? null
              : _specialRequestsController.text.trim(),
          restaurantId: '', // Sera récupéré depuis la configuration du backend
          tableId: _selectedTableId!,
        );

        final createdReservation = await ref
            .read(publicReservationProvider.notifier)
            .createPublicReservation(reservation);

        if (mounted && createdReservation != null) {
          // Rediriger vers la page de confirmation
          context.go('/reservation/confirmation/${createdReservation.id}');
        } else if (mounted) {
          final error = ref.read(publicReservationProvider).creationError;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${error ?? l10n.unknownError}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true && _managementToken != null) {
      try {
        await ref.read(publicReservationProvider.notifier).cancelReservationWithToken(
          _managementToken!,
          reason: 'Annulée par le client',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation annulée avec succès'),
              backgroundColor: Colors.orange,
            ),
          );
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'annulation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}