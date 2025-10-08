import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table_entity.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/table_provider.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour la liste des tables
class TableListWidget extends ConsumerStatefulWidget {
  final Function(TableEntity)? onTableSelected;
  final Function(TableEntity)? onTableEdit;
  final Function(TableEntity)? onTableDelete;
  final bool showActions;

  const TableListWidget({
    super.key,
    this.onTableSelected,
    this.onTableEdit,
    this.onTableDelete,
    this.showActions = true,
  });

  @override
  ConsumerState<TableListWidget> createState() => _TableListWidgetState();
}

class _TableListWidgetState extends ConsumerState<TableListWidget> {
  String? _editingTableId;
  String? _editingField;
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.fadeIn,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: Column(
        children: [
          // Liste des tables (sans filtres)
          _buildTablesList(theme, l10n),
        ],
      ),
    );
  }


  Widget _buildTablesList(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final tables = ref.watch(tablesProvider);

        if (tables.isEmpty) {
          return _buildEmptyState(theme, l10n);
        }

        // Trier les tables par numéro pour un affichage cohérent
        final sortedTables = List<TableEntity>.from(tables)
          ..sort((a, b) => a.number.compareTo(b.number));

        return Column(
          children: [
            // En-tête compact avec légende des couleurs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${tables.length} table${tables.length > 1 ? 's' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Actions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildSectionLegend(theme, sortedTables),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Liste des tables
            ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedTables.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
                final table = sortedTables[index];
            return _buildTableCard(theme, l10n, table);
          },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableCard(ThemeData theme, AppLocalizations l10n, TableEntity table) {
    // Debug: Afficher les données de la table
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
        onTap: () => widget.onTableSelected?.call(table),
          borderRadius: BorderRadius.circular(8),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
            children: [
                // Icône avec numéro de table - édition inline
                _buildEditableNumber(theme, table),
                const SizedBox(width: 12),

                // Informations principales - tout sur une ligne
                Expanded(
                  child: Row(
                children: [
                      // Nom de la section - édition inline
                      Expanded(
                        child: _buildEditableSection(theme, table),
                      ),
                      const SizedBox(width: 12),
                      
                      // Capacité - édition inline
                      _buildEditableCapacity(theme, table),
                  const SizedBox(width: 12),

                      // Statut - cliquable pour basculer disponibilité
                      GestureDetector(
                        onTap: () => _toggleTableStatus(context, theme, l10n, table),
                        child: _buildStatusIndicator(theme, table),
                      ),
                    ],
                  ),
                ),

                // Actions minimales
              if (widget.showActions) ...[
                  const SizedBox(width: 8),
                  _buildMinimalActions(theme, l10n, table),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, TableEntity table) {
    // Utiliser isActive pour déterminer le statut d'affichage
    final displayStatus = table.isActive ? TableStatus.available : TableStatus.outOfOrder;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(theme, displayStatus).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(theme, displayStatus).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(displayStatus),
            size: 10,
            color: _getStatusColor(theme, displayStatus),
          ),
          const SizedBox(width: 3),
          Text(
            displayStatus.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(theme, displayStatus),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalActions(ThemeData theme, AppLocalizations l10n, TableEntity table) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton supprimer seulement (modification directe sur la liste)
        IconButton(
            onPressed: () => _showDeleteConfirmation(context, l10n, table),
          icon: Icon(
            Icons.delete,
            size: 16,
            color: theme.colorScheme.error,
          ),
          tooltip: l10n.delete,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }


  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.table_restaurant,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTables,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noTablesDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Color _getStatusColor(ThemeData theme, TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.maintenance:
        return Colors.blue;
      case TableStatus.outOfOrder:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Icons.check_circle;
      case TableStatus.occupied:
        return Icons.person;
      case TableStatus.reserved:
        return Icons.schedule;
      case TableStatus.maintenance:
        return Icons.build;
      case TableStatus.outOfOrder:
        return Icons.error;
    }
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n, TableEntity table) {
    // Appeler directement la suppression - le dialog sera affiché dans la page parent
    widget.onTableDelete?.call(table);
  }

  /// Construit la légende des couleurs des sections
  Widget _buildSectionLegend(ThemeData theme, List<TableEntity> tables) {
    // Extraire les sections uniques
    final sections = tables
        .map((table) => table.position)
        .where((section) => section != null && section.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: sections.map((section) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getSectionColor(section),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              section!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Construit le numéro de table éditable
  Widget _buildEditableNumber(ThemeData theme, TableEntity table) {
    final isEditing = _editingTableId == table.id && _editingField == 'number';
    
    if (isEditing) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _getSectionColor(table.position),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          controller: _editController,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (value) => _finishEditing(table, 'number', value),
          onTapOutside: (_) => _finishEditing(table, 'number', _editController.text),
        ),
      );
    }
    
    return GestureDetector(
      onTap: () => _startEditing(table, 'number', table.number.toString()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _getSectionColor(table.position),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '${table.number}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Construit la section éditable
  Widget _buildEditableSection(ThemeData theme, TableEntity table) {
    final isEditing = _editingTableId == table.id && _editingField == 'position';
    
    if (isEditing) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextField(
          controller: _editController,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Section',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          onSubmitted: (value) => _finishEditing(table, 'position', value),
          onTapOutside: (_) => _finishEditing(table, 'position', _editController.text),
        ),
      );
    }
    
    return GestureDetector(
      onTap: () => _startEditing(table, 'position', table.position ?? ''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                table.position ?? 'Section non définie',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la capacité éditable
  Widget _buildEditableCapacity(ThemeData theme, TableEntity table) {
    final isEditing = _editingTableId == table.id && _editingField == 'capacity';
    
    if (isEditing) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 30,
              child: TextField(
                controller: _editController,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (value) => _finishEditing(table, 'capacity', value),
                onTapOutside: (_) => _finishEditing(table, 'capacity', _editController.text),
              ),
            ),
          ],
        ),
      );
    }
    
    return GestureDetector(
      onTap: () => _startEditing(table, 'capacity', table.capacity.toString()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${table.capacity}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  /// Démarre l'édition d'un champ
  void _startEditing(TableEntity table, String field, String currentValue) {
    setState(() {
      _editingTableId = table.id;
      _editingField = field;
      _editController.text = currentValue;
    });
    
    // Sélection automatique du contenu après un court délai
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_editingTableId == table.id && _editingField == field) {
        _editController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _editController.text.length,
        );
      }
    });
  }

  /// Termine l'édition d'un champ
  void _finishEditing(TableEntity table, String field, String newValue) {
    final trimmedValue = newValue.trim();
    
    // Validation basique
    if (trimmedValue.isNotEmpty) {
      // Validation spécifique selon le champ
      bool isValid = true;
      String? errorMessage;
      
      switch (field) {
        case 'number':
          final number = int.tryParse(trimmedValue);
          if (number == null || number < 1 || number > 999) {
            isValid = false;
            errorMessage = 'Numéro invalide (1-999)';
          }
          break;
        case 'capacity':
          final capacity = int.tryParse(trimmedValue);
          if (capacity == null || capacity < 1 || capacity > 20) {
            isValid = false;
            errorMessage = 'Capacité invalide (1-20)';
          }
          break;
        case 'position':
          if (trimmedValue.length > 50) {
            isValid = false;
            errorMessage = 'Section trop longue (max 50 caractères)';
          }
          break;
      }
      
      if (isValid) {
        _updateTableField(context, table, field, trimmedValue);
      } else {
        // Afficher l'erreur et garder le mode édition
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Valeur invalide'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return; // Ne pas sortir du mode édition
      }
    }
    
    setState(() {
      _editingTableId = null;
      _editingField = null;
    });
  }

  /// Met à jour un champ spécifique de la table
  Future<void> _updateTableField(BuildContext context, TableEntity table, String field, String value) async {
    
    try {
      // Récupérer le token d'authentification
      final authState = ref.read(authProvider);
      if (authState.accessToken == null) {
        throw Exception('Token d\'authentification manquant');
      }
      
      // Vérifier si la valeur a vraiment changé
      bool hasChanged = false;
      switch (field) {
        case 'number':
          hasChanged = value != table.number.toString();
          break;
        case 'capacity':
          hasChanged = value != table.capacity.toString();
          break;
        case 'position':
          hasChanged = value != (table.position ?? '');
          break;
      }
      
      if (!hasChanged) {
        return;
      }
      
      // Préparer les données de mise à jour - SEULEMENT le champ modifié
      String? name;
      int? capacity;
      String? position;
      
      switch (field) {
        case 'number':
          // Pour le numéro de table, on utilise le champ 'name' dans l'API
          name = value;
          break;
        case 'capacity':
          capacity = int.parse(value);
          break;
        case 'position':
          position = value;
          break;
      }
      
      // Appeler le provider pour mettre à jour SEULEMENT le champ modifié
      await ref.read(tableProvider.notifier).updateTable(
        token: authState.accessToken!,
        tableId: table.id,
        name: name, // null si pas modifié
        capacity: capacity, // null si pas modifié
        status: null, // null car on ne modifie pas le statut
        description: null, // null car on ne modifie pas la description
        position: position, // null si pas modifié
      );
      
      // Afficher le message de succès
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_getFieldDisplayName(field)} modifié avec succès'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
      
    } catch (e) {
      
      // Afficher le message d'erreur
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la modification: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    }
  }
  
  /// Retourne le nom d'affichage du champ
  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'number':
        return 'Numéro';
      case 'capacity':
        return 'Capacité';
      case 'position':
        return 'Section';
      default:
        return field;
    }
  }

  /// Bascule le statut de disponibilité de la table
  Future<void> _toggleTableStatus(BuildContext context, ThemeData theme, AppLocalizations l10n, TableEntity table) async {
    // Le statut disponible correspond à isActive: true, non disponible à isActive: false
    final newStatus = table.isActive ? 'outOfOrder' : 'available';
    
    
    try {
      // Récupérer le token d'authentification
      final authState = ref.read(authProvider);
      if (authState.accessToken == null) {
        throw Exception('Token d\'authentification manquant');
      }
      
      // Mise à jour optimiste de l'état local
      
      // Mise à jour optimiste immédiate de l'état local
      
      // Appeler le provider pour mettre à jour SEULEMENT le statut
      await ref.read(tableProvider.notifier).updateTable(
        token: authState.accessToken!,
        tableId: table.id,
        name: null, // null car on ne modifie pas le nom
        capacity: null, // null car on ne modifie pas la capacité
        status: newStatus, // SEULEMENT le statut
        description: null, // null car on ne modifie pas la description
        position: null, // null car on ne modifie pas la position
      );
      
      
      // Forcer le rafraîchissement de l'interface
      if (mounted) {
        setState(() {
          // Force le rebuild du widget
        });
      }
      
      // Afficher le message de succès
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Statut changé: ${newStatus == 'available' ? 'Disponible' : 'Non disponible'}'),
                backgroundColor: newStatus == 'available' ? Colors.green : Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
      
    } catch (e) {
      
      // Afficher le message d'erreur
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors du changement de statut: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    }
  }

  /// Attribue une couleur unique à chaque section
  Color _getSectionColor(String? section) {
    if (section == null || section.isEmpty) {
      return Colors.grey; // Couleur par défaut pour les sections non définies
    }

    // Liste de couleurs prédéfinies pour les sections
    final colors = [
      Colors.blue,      // Bar
      Colors.green,     // Terrasse
      Colors.orange,    // VIP
      Colors.purple,    // Centre
      Colors.red,       // Avant
      Colors.teal,      // Arrière
      Colors.indigo,    // Étage
      Colors.pink,      // Salon
      Colors.amber,     // Famille
      Colors.cyan,      // Business
      Colors.deepOrange, // Groupe
      Colors.lightBlue,  // Romantique
      Colors.lime,      // Fumoir
      Colors.brown,     // Sous-sol
      Colors.deepPurple, // Mezzanine
      Colors.blueGrey,  // Rooftop
      Colors.lightGreen, // Jardin
    ];

    // Utiliser le hash de la section pour obtenir un index cohérent
    final hash = section.hashCode;
    final index = hash.abs() % colors.length;
    return colors[index];
  }
}



