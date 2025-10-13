import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../admin/presentation/widgets/availability_selector_widget.dart';
import '../../../admin/domain/entities/table_entity.dart';
import '../../../admin/presentation/providers/table_provider.dart' as data;
import '../providers/public_reservation_provider.dart';
import '../../../../shared/models/reservation.dart';

/// Widget de formulaire de réservation réutilisable
/// Peut être utilisé côté admin ou côté client
class ReservationFormWidget extends ConsumerStatefulWidget {
  final bool isAdminMode;
  final Function(Reservation) onReservationCreated;
  final VoidCallback? onCancel;

  const ReservationFormWidget({
    super.key,
    this.isAdminMode = false,
    required this.onReservationCreated,
    this.onCancel,
  });

  @override
  ConsumerState<ReservationFormWidget> createState() => _ReservationFormWidgetState();
}

class _ReservationFormWidgetState extends ConsumerState<ReservationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTime;
  int _partySize = 2;
  bool _isCreating = false;
  
  // Données sélectionnées
  TableEntity? _selectedTable;
  
  @override
  void initState() {
    super.initState();
    // Charger les tables disponibles
    ref.read(data.tableProvider.notifier).loadTables();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tableState = ref.watch(data.tableProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection de date et heure
          _buildDateTimeSection(theme, l10n),
          
          const SizedBox(height: 24),
          
          // Sélection du nombre de personnes
          _buildPartySizeSection(theme, l10n),
          
          const SizedBox(height: 24),
          
          // Sélection de table
          if (_selectedTime != null) _buildTableSection(theme, l10n, tableState),
          
          const SizedBox(height: 24),
          
          // Informations client
          _buildClientSection(theme, l10n),
          
          const SizedBox(height: 32),
          
          // Boutons d'action
          _buildActionButtons(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(ThemeData theme, AppLocalizations l10n) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionner Date & Heure',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AvailabilitySelectorWidget(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                  _selectedTable = null;
                });
              },
              onTimeSelected: (time) {
                setState(() {
                  _selectedTime = time;
                  _selectedTable = null;
                });
                _loadAvailableTables();
              },
            ),
          ],
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
      child: BentoCard(
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
                  onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null,
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
                  onPressed: _partySize < 20 ? () => setState(() => _partySize++) : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(ThemeData theme, AppLocalizations l10n, data.TableState tableState) {
    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromLeft,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectTable,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (tableState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (tableState.tables.isEmpty)
              Text(
                l10n.noTablesAvailable,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tableState.tables
                    .where((table) => table.capacity >= _partySize)
                    .map((table) => _buildTableChip(theme, l10n, table))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableChip(ThemeData theme, AppLocalizations l10n, TableEntity table) {
    final isSelected = _selectedTable?.id == table.id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTable = table),
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
              '${l10n.table} ${table.number}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${table.capacity} ${l10n.people}',
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
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isAdminMode ? l10n.clientInformation : 'Vos Informations',
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
          if (widget.onCancel != null) ...[
            Expanded(
              child: SimpleButton(
                onPressed: widget.onCancel,
                text: l10n.cancel,
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SimpleButton(
              onPressed: _isCreating ? null : _createReservation,
              text: _isCreating ? l10n.creating : l10n.createReservation,
              type: ButtonType.primary,
              isLoading: _isCreating,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAvailableTables() async {
    if (_selectedDate == null || _selectedTime == null) return;
    
    await ref.read(data.tableProvider.notifier).loadTables();
  }

  Future<void> _createReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedTable == null) {
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
        restaurantId: 'restaurant_1', // TODO: Récupérer depuis la configuration
        tableId: _selectedTable!.id,
      );

      widget.onReservationCreated(reservation);
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
}