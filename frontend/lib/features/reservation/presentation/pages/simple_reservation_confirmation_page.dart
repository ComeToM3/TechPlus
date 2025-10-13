import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../core/network/api_service.dart';
import 'package:intl/intl.dart';

/// Page de confirmation de réservation simplifiée
class SimpleReservationConfirmationPage extends StatefulWidget {
  final String reservationId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final DateTime date;
  final String time;
  final int partySize;
  final String status;
  
  const SimpleReservationConfirmationPage({
    super.key,
    required this.reservationId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.date,
    required this.time,
    required this.partySize,
    required this.status,
  });

  @override
  State<SimpleReservationConfirmationPage> createState() => _SimpleReservationConfirmationPageState();
}

class _SimpleReservationConfirmationPageState extends State<SimpleReservationConfirmationPage> {
  Map<String, dynamic>? _reservationData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservationData();
  }

  Future<void> _loadReservationData() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/reservations/${widget.reservationId}');
      
      if (response.statusCode == 200) {
        setState(() {
          _reservationData = response.data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement de la réservation';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.reservationConfirmation),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.reservationConfirmation),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      );
    }

    // Utiliser les données de l'API ou les données par défaut
    final reservationData = _reservationData ?? {};
    final clientName = reservationData['clientName'] ?? widget.clientName;
    final clientEmail = reservationData['clientEmail'] ?? widget.clientEmail;
    final clientPhone = reservationData['clientPhone'] ?? widget.clientPhone;
    final date = reservationData['date'] != null 
        ? DateTime.parse(reservationData['date']) 
        : widget.date;
    final time = reservationData['time'] ?? widget.time;
    final partySize = reservationData['partySize'] ?? widget.partySize;
    final status = reservationData['status'] ?? widget.status;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservationConfirmation),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: CustomAnimatedWidget(
        config: AnimationConfig(
          type: AnimationType.fadeIn,
          duration: AnimationConstants.normal,
          curve: AnimationConstants.easeOut,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message de succès
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Réservation créée avec succès !',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Détails de la réservation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails de la réservation',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow(theme, 'ID de réservation', widget.reservationId),
                      _buildDetailRow(theme, 'Nom', clientName),
                      _buildDetailRow(theme, 'Email', clientEmail),
                      _buildDetailRow(theme, 'Téléphone', clientPhone),
                      _buildDetailRow(theme, 'Date', dateFormat.format(date)),
                      _buildDetailRow(theme, 'Heure', time),
                      _buildDetailRow(theme, 'Nombre de personnes', partySize.toString()),
                      _buildDetailRow(theme, 'Table', _getTableInfo(reservationData)),
                      _buildDetailRow(theme, 'Statut', status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Informations importantes
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Informations importantes',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Vous recevrez un email de confirmation\n'
                        '• Arrivez 5 minutes avant votre réservation\n'
                        '• Contactez-nous en cas de modification\n'
                        '• Annulation possible jusqu\'à 2h avant',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: SimpleButton(
                      onPressed: () => context.go('/'),
                      text: 'Retour à l\'accueil',
                      type: ButtonType.secondary,
                      icon: Icons.home,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SimpleButton(
                      onPressed: () {
                        // TODO: Implémenter la gestion de réservation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité en cours de développement'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      text: 'Gérer ma réservation',
                      type: ButtonType.primary,
                      icon: Icons.edit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTableInfo(Map<String, dynamic> reservationData) {
    final table = reservationData['table'];
    if (table != null) {
      return 'Table ${table['number']} (${table['capacity']} personnes) - ${table['position']}';
    }
    return 'Non spécifiée';
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
