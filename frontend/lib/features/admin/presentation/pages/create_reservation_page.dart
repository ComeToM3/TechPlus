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
import '../providers/schedule_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
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
  Map<String, dynamic>? _selectedTable;
  
  // Contrôleurs pour nouveau client
  final _newClientNameController = TextEditingController();
  final _newClientEmailController = TextEditingController();
  final _newClientPhoneController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _clientSearchController.addListener(_onClientSearchChanged);
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les données seulement si nécessaire
    // Éviter les appels multiples qui causent des boucles infinies
  }
  
  Future<void> _loadInitialData() async {
    // Charger la configuration des créneaux
    final authState = ref.read(authProvider);
    if (authState.accessToken != null) {
      await ref.read(scheduleProvider.notifier).loadScheduleConfig(
        token: authState.accessToken!,
      );
    }
  }
  
  void _onClientSearchChanged() {
    // Recherche de clients via l'API - à implémenter selon les besoins
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
            Icons.schedule_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun créneau configuré',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous devez d\'abord configurer les créneaux horaires de votre restaurant avant de pouvoir créer des réservations.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/admin/dashboard/schedule');
            },
            icon: const Icon(Icons.schedule),
            label: const Text('Configurer les créneaux'),
          ),
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
    // Charger les tables depuis l'API
    // TODO: Intégrer avec tableProvider pour charger les vraies tables
    return _buildNoTablesMessage(theme);
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
          ElevatedButton.icon(
            onPressed: () {
              context.go('/admin/dashboard/tables');
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configurer les tables'),
          ),
        ],
      ),
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
                onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null,
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
                onPressed: _partySize < 20 ? () => setState(() => _partySize++) : null,
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
      // Toujours recharger la configuration pour avoir les dernières données
      final authState = ref.read(authProvider);
      if (authState.accessToken != null) {
        // Recharger la configuration depuis l'API
        await ref.read(scheduleProvider.notifier).loadScheduleConfig(
          token: authState.accessToken!,
        );
        
        final scheduleState = ref.read(scheduleProvider);
        
        if (scheduleState.config != null) {
          // Utiliser la configuration des créneaux
          final dayOfWeek = _getDayOfWeek(_selectedDate!);
          final daySchedule = scheduleState.config!['daySchedules']?.firstWhere(
            (day) => day['dayOfWeek'] == dayOfWeek,
            orElse: () => null,
          );
          
          if (daySchedule != null && daySchedule['isOpen'] == true) {
            final timeSlots = daySchedule['timeSlots'] ?? [];
            setState(() {
              _availableSlots = timeSlots
                  .where((slot) => slot['isAvailable'] == true)
                  .map((slot) => {
                    'time': slot['time'],
                    'capacity': slot['capacity'] ?? 20,
                    'isRecommended': slot['isRecommended'] ?? false,
                  })
                  .toList();
            });
          } else {
            setState(() {
              _availableSlots = [];
            });
          }
        } else {
          setState(() {
            _availableSlots = [];
          });
        }
      }
    } catch (e) {
      setState(() {
        _availableSlots = [];
      });
    }
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    return days[date.weekday % 7];
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
      final calendarNotifier = ref.read(reservationCalendarProvider.notifier);
      
      // Préparer les données du client
      final clientName = _newClientNameController.text.trim();
      final clientEmail = _newClientEmailController.text.trim();
      final clientPhone = _newClientPhoneController.text.trim().isNotEmpty
          ? _newClientPhoneController.text.trim()
          : null;
      
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
        status: 'pending',
        tableNumber: _selectedTable!['number'], // Ajouter le numéro de table
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        specialRequests: specialRequests,
      );

      final createdReservation = await calendarNotifier.createReservation(reservation);

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