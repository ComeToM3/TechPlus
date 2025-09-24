import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/widgets/forms/custom_text_field.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour la sélection de client lors de la création de réservation
class ClientSelectionWidget extends ConsumerStatefulWidget {
  final String? selectedClientId;
  final Function(String?) onClientSelected;
  final VoidCallback? onNewClient;

  const ClientSelectionWidget({
    super.key,
    this.selectedClientId,
    required this.onClientSelected,
    this.onNewClient,
  });

  @override
  ConsumerState<ClientSelectionWidget> createState() => _ClientSelectionWidgetState();
}

class _ClientSelectionWidgetState extends ConsumerState<ClientSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedClientId;
  List<ClientOption> _clients = [];
  List<ClientOption> _filteredClients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.selectedClientId;
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromTop,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, l10n),
            const SizedBox(height: 16),

            // Recherche
            _buildSearchField(theme, l10n),
            const SizedBox(height: 16),

            // Liste des clients
            _buildClientsList(theme, l10n),

            // Actions
            _buildActions(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          Icons.person_search,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.selectClient,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (_selectedClientId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.selected,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.searchClient,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _searchController,
          hintText: l10n.searchClientHint,
          prefixIcon: Icons.search,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _filterClients();
            });
          },
        ),
      ],
    );
  }

  Widget _buildClientsList(ThemeData theme, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_filteredClients.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredClients.length,
        itemBuilder: (context, index) {
          final client = _filteredClients[index];
          return _buildClientItem(theme, l10n, client);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.person_off,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? l10n.noClients : l10n.noClientsFound,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? l10n.noClientsDescription 
                : l10n.noClientsFoundDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClientItem(ThemeData theme, AppLocalizations l10n, ClientOption client) {
    final isSelected = _selectedClientId == client.id;

    return InkWell(
      onTap: () => _selectClient(client),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Informations client
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? theme.colorScheme.onPrimaryContainer 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (client.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      client.email!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (client.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      client.phone!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Indicateur de sélection
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SimpleButton(
            onPressed: widget.onNewClient,
            text: l10n.newClient,
            type: ButtonType.secondary,
            size: ButtonSize.medium,
            icon: Icons.person_add,
          ),
        ),
        if (_selectedClientId != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: SimpleButton(
              onPressed: _clearSelection,
              text: l10n.clearSelection,
              type: ButtonType.secondary,
              size: ButtonSize.medium,
              icon: Icons.clear,
            ),
          ),
        ],
      ],
    );
  }

  void _loadClients() {
    setState(() {
      _isLoading = true;
    });

    // Simulation du chargement des clients
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _clients = [
          ClientOption(
            id: '1',
            name: 'Jean Tremblay',
            email: 'jean.tremblay@email.ca',
            phone: '+1 514 123 4567',
            isVip: true,
          ),
          ClientOption(
            id: '2',
            name: 'Marie Gagnon',
            email: 'marie.gagnon@email.ca',
            phone: '+1 514 234 5678',
            isVip: false,
          ),
          ClientOption(
            id: '3',
            name: 'Pierre Bouchard',
            email: 'pierre.bouchard@email.ca',
            phone: '+1 514 345 6789',
            isVip: false,
          ),
          ClientOption(
            id: '4',
            name: 'Sophie Lavoie',
            email: 'sophie.lavoie@email.ca',
            phone: '+1 514 456 7890',
            isVip: true,
          ),
          ClientOption(
            id: '5',
            name: 'Client sans compte',
            email: null,
            phone: null,
            isVip: false,
          ),
        ];
        _filteredClients = _clients;
        _isLoading = false;
      });
    });
  }

  void _filterClients() {
    if (_searchQuery.isEmpty) {
      _filteredClients = _clients;
    } else {
      _filteredClients = _clients.where((client) {
        return client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (client.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (client.phone?.contains(_searchQuery) ?? false);
      }).toList();
    }
  }

  void _selectClient(ClientOption client) {
    setState(() {
      _selectedClientId = client.id;
    });
    widget.onClientSelected(client.id);
  }

  void _clearSelection() {
    setState(() {
      _selectedClientId = null;
    });
    widget.onClientSelected(null);
  }
}

/// Modèle pour les options de client
class ClientOption {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool isVip;

  const ClientOption({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.isVip = false,
  });
}

