import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reservation_history.dart';
import '../../../../shared/widgets/cards/bento_card.dart';
import '../../../../shared/widgets/buttons/simple_button.dart';
import '../../../../shared/animations/animated_widget.dart';
import '../../../../shared/animations/animation_constants.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Widget pour gérer les notes internes d'une réservation
class ReservationNotesWidget extends ConsumerStatefulWidget {
  final List<ReservationNote> notes;
  final Function(ReservationNote) onAddNote;
  final Function(ReservationNote) onEditNote;
  final Function(ReservationNote) onDeleteNote;

  const ReservationNotesWidget({
    super.key,
    required this.notes,
    required this.onAddNote,
    required this.onEditNote,
    required this.onDeleteNote,
  });

  @override
  ConsumerState<ReservationNotesWidget> createState() => _ReservationNotesWidgetState();
}

class _ReservationNotesWidgetState extends ConsumerState<ReservationNotesWidget> {
  bool _isExpanded = true;
  bool _isAddingNote = false;
  final TextEditingController _noteController = TextEditingController();
  NoteType _selectedType = NoteType.general;
  bool _isPrivate = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CustomAnimatedWidget(
      config: AnimationConfig(
        type: AnimationType.slideInFromBottom,
        duration: AnimationConstants.normal,
        curve: AnimationConstants.easeOut,
      ),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(theme, l10n),
            
            // Contenu
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Liste des notes
                    _buildNotesList(theme, l10n),
                    
                    // Formulaire d'ajout
                    if (_isAddingNote) ...[
                      const SizedBox(height: 16),
                      _buildAddNoteForm(theme, l10n),
                    ],
                    
                    // Bouton d'ajout
                    if (!_isAddingNote) ...[
                      const SizedBox(height: 8),
                      _buildAddNoteButton(theme, l10n),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.note_alt,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.internalNotes,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.notes.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(ThemeData theme, AppLocalizations l10n) {
    if (widget.notes.isEmpty && !_isAddingNote) {
      return _buildEmptyState(theme, l10n);
    }

    return Column(
      children: widget.notes.map((note) {
        return _buildNoteItem(theme, l10n, note);
      }).toList(),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNotes,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noNotesDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(ThemeData theme, AppLocalizations l10n, ReservationNote note) {
    final typeColor = _getTypeColor(note.type, theme);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la note
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  note.type.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (note.isPrivate)
                Icon(
                  Icons.lock,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              const Spacer(),
              Text(
                _formatTimestamp(note.createdAt, l10n),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) => _handleNoteAction(value, note),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 16),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Contenu de la note
          Text(
            note.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          // Auteur
          if (note.author != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.by} ${note.author}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddNoteForm(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type de note
          Text(
            l10n.noteType,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: NoteType.values.map((type) {
              final isSelected = _selectedType == type;
              return FilterChip(
                label: Text(type.label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                },
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // Contenu de la note
          Text(
            l10n.noteContent,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.noteContentHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Options
          Row(
            children: [
              Checkbox(
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value ?? true;
                  });
                },
              ),
              Text(l10n.privateNote),
            ],
          ),
          const SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: SimpleButton(
                  onPressed: _saveNote,
                  text: l10n.save,
                  type: ButtonType.primary,
                  size: ButtonSize.small,
                  icon: Icons.save,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SimpleButton(
                  onPressed: _cancelAddNote,
                  text: l10n.cancel,
                  type: ButtonType.secondary,
                  size: ButtonSize.small,
                  icon: Icons.cancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteButton(ThemeData theme, AppLocalizations l10n) {
    return SimpleButton(
      onPressed: () {
        setState(() {
          _isAddingNote = true;
        });
      },
      text: l10n.addNote,
      type: ButtonType.primary,
      size: ButtonSize.medium,
      icon: Icons.add,
    );
  }

  Color _getTypeColor(NoteType type, ThemeData theme) {
    switch (type) {
      case NoteType.general:
        return Colors.blue;
      case NoteType.reminder:
        return Colors.orange;
      case NoteType.issue:
        return Colors.red;
      case NoteType.special:
        return Colors.purple;
      case NoteType.payment:
        return Colors.green;
      case NoteType.cancellation:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return l10n.now;
    }
  }

  void _handleNoteAction(String action, ReservationNote note) {
    switch (action) {
      case 'edit':
        _editNote(note);
        break;
      case 'delete':
        _deleteNote(note);
        break;
    }
  }

  void _editNote(ReservationNote note) {
    _noteController.text = note.content;
    _selectedType = note.type;
    _isPrivate = note.isPrivate;
    setState(() {
      _isAddingNote = true;
    });
  }

  void _deleteNote(ReservationNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteNote),
        content: Text(AppLocalizations.of(context)!.deleteNoteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeleteNote(note);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noteContentRequired),
        ),
      );
      return;
    }

    final note = ReservationNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reservationId: '', // TODO: Passer l'ID de la réservation
      content: _noteController.text.trim(),
      author: 'Admin', // TODO: Récupérer l'utilisateur actuel
      type: _selectedType,
      isPrivate: _isPrivate,
      createdAt: DateTime.now(),
    );

    widget.onAddNote(note);
    _cancelAddNote();
  }

  void _cancelAddNote() {
    setState(() {
      _isAddingNote = false;
      _noteController.clear();
      _selectedType = NoteType.general;
      _isPrivate = true;
    });
  }
}
