import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/table_entity.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/table_provider.dart' as data;
import '../../../../core/providers/theme_provider.dart';
import '../widgets/public_navigation_button.dart';

/// Page de création de table moderne et ergonomique
class CreateTablePage extends ConsumerStatefulWidget {
  const CreateTablePage({super.key});

  @override
  ConsumerState<CreateTablePage> createState() => _CreateTablePageState();
}

class _CreateTablePageState extends ConsumerState<CreateTablePage> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customSectionController = TextEditingController();
  
  bool _isActive = true;
  bool _isCreating = false;
  TableEntity? _editingTable; // Table en cours d'édition
  int _batchCount = 1; // Nombre de tables à créer en lot
  bool _isCustomSection = true; // Mode section personnalisée activé par défaut

  @override
  void initState() {
    super.initState();
    // Vérifier si on est en mode édition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is TableEntity) {
        _editingTable = extra;
        _initializeForm();
      }
    });
  }

  void _initializeForm() {
    if (_editingTable != null) {
      _numberController.text = _editingTable!.number.toString();
      _capacityController.text = _editingTable!.capacity.toString();
      _positionController.text = _editingTable!.position ?? '';
      _descriptionController.text = _editingTable!.description ?? '';
      _customSectionController.text = _editingTable!.position ?? ''; // Initialiser la section
      _isActive = _editingTable!.isActive;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    _customSectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createTable),
        centerTitle: true,
        actions: [
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
                _buildBasicInfoSection(theme, l10n),
                const SizedBox(height: 24),
                _buildBatchCreationSection(theme, l10n),
                const SizedBox(height: 24),
                _buildSectionSelection(theme, l10n),
                const SizedBox(height: 24),
                _buildStatusSection(theme, l10n),
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
          _editingTable != null ? 'Modifier la table' : 'Nouvelle table',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _editingTable != null 
              ? 'Modifiez les informations de la table ${_editingTable!.number}'
              : 'Ajoutez une nouvelle table au restaurant',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Informations de base',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numberController,
                    decoration: InputDecoration(
                      labelText: 'Numéro de table',
                      hintText: '1',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le numéro est requis';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Numéro invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    decoration: InputDecoration(
                      labelText: 'Capacité',
                      hintText: '4',
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La capacité est requise';
                      }
                      final capacity = int.tryParse(value);
                      if (capacity == null || capacity <= 0) {
                        return 'Capacité invalide';
                      }
                      if (capacity > 20) {
                        return 'Capacité trop élevée (max 20)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBatchCreationSection(ThemeData theme, AppLocalizations l10n) {
    // Ne pas afficher cette section en mode édition
    if (_editingTable != null) {
      return const SizedBox.shrink();
    }

    return BentoCard(
      title: 'Création en lot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nombre de tables à créer :',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _batchCount,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: List.generate(10, (index) {
              final count = index + 1;
              return DropdownMenuItem<int>(
                value: count,
                child: Text('$count table${count > 1 ? 's' : ''}'),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _batchCount = value;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          if (_batchCount > 1)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                      Expanded(
                    child: Text(
                      'Les tables seront créées avec les numéros ${_numberController.text} à ${int.tryParse(_numberController.text) != null ? int.parse(_numberController.text) + _batchCount - 1 : '?'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionSelection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Section de la table',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nommez la section du restaurant :',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _customSectionController,
            decoration: InputDecoration(
              labelText: 'Nom de la section',
              hintText: 'Ex: Bar, Terrasse, VIP, Centre, Étage...',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir un nom de section';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }



  Widget _buildStatusSection(ThemeData theme, AppLocalizations l10n) {
    return BentoCard(
      title: 'Statut de la table',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Table active'),
            subtitle: const Text('La table peut recevoir des réservations'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: theme.colorScheme.primary,
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
            onPressed: _isCreating ? null : _cancel,
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
          child: ElevatedButton(
            onPressed: _isCreating ? null : _createTable,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_editingTable != null 
                    ? 'Modifier la table' 
                    : _batchCount == 1 
                        ? 'Créer la table' 
                        : 'Créer $_batchCount tables'),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: const PublicNavigationButton(),
    );
  }

  void _cancel() {
    context.pop();
  }

  Future<void> _createTable() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final authState = ref.read(authProvider);
      if (authState.accessToken != null && !authState.isLoading) {
        final isEditing = _editingTable != null;
        
        // Log des données pour le debug
        if (kDebugMode) {
        }

        if (isEditing) {
          // Mode édition
          final section = _customSectionController.text;
          
          await ref.read(data.tableProvider.notifier).updateTable(
            token: authState.accessToken!,
            tableId: _editingTable!.id,
            name: _numberController.text,
            capacity: int.parse(_capacityController.text),
            status: _isActive ? 'available' : 'unavailable',
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            position: section, // Ajouter la section comme position
          );
        } else {
          // Mode création - gérer la création en lot
          final baseNumber = int.parse(_numberController.text);
          final capacity = int.parse(_capacityController.text);
          final section = _customSectionController.text;
          
          // Debug: Afficher les données à envoyer
          
          // Vérifier les conflits de numéros de table
          if (_batchCount > 1) {
            final existingTables = ref.read(data.tableProvider).items;
            final existingNumbers = existingTables.map((table) => table.number).toSet();
            
            List<int> conflictingNumbers = [];
            for (int i = 0; i < _batchCount; i++) {
              final tableNumber = baseNumber + i;
              if (existingNumbers.contains(tableNumber)) {
                conflictingNumbers.add(tableNumber);
              }
            }
            
            if (conflictingNumbers.isNotEmpty) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Les tables ${conflictingNumbers.join(', ')} existent déjà'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
                setState(() {
                  _isCreating = false;
                });
                return;
              }
            }
          }
          
          int successCount = 0;
          int errorCount = 0;
          
          for (int i = 0; i < _batchCount; i++) {
            try {
              final tableNumber = baseNumber + i;
              await ref.read(data.tableProvider.notifier).createTable(
                token: authState.accessToken!,
                number: tableNumber,
                capacity: capacity,
                position: section,
                status: 'AVAILABLE',
              );
              successCount++;
            } catch (e) {
              errorCount++;
            }
          }
          
        }

        if (mounted) {
          String message;
          Color backgroundColor;
          
          if (isEditing) {
            message = 'Table modifiée avec succès';
            backgroundColor = Colors.green;
          } else if (_batchCount == 1) {
            message = 'Table créée avec succès';
            backgroundColor = Colors.green;
          } else {
            // Message pour création en lot
            final baseNumber = int.parse(_numberController.text);
            final lastNumber = baseNumber + _batchCount - 1;
            message = 'Tables $baseNumber à $lastNumber créées avec succès';
            backgroundColor = Colors.green;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 3),
            ),
          );
          context.pop();
        }
      } else {
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de ${_editingTable != null ? "la modification" : "la création"}: $e'),
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
}
