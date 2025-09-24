/// Entité pour l'historique des modifications d'une réservation
class ReservationHistory {
  final String id;
  final String reservationId;
  final String action;
  final String description;
  final String? oldValue;
  final String? newValue;
  final String? changedBy;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ReservationHistory({
    required this.id,
    required this.reservationId,
    required this.action,
    required this.description,
    this.oldValue,
    this.newValue,
    this.changedBy,
    required this.timestamp,
    this.metadata,
  });

  /// Crée une copie avec des valeurs modifiées
  ReservationHistory copyWith({
    String? id,
    String? reservationId,
    String? action,
    String? description,
    String? oldValue,
    String? newValue,
    String? changedBy,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ReservationHistory(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      action: action ?? this.action,
      description: description ?? this.description,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      changedBy: changedBy ?? this.changedBy,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationId': reservationId,
      'action': action,
      'description': description,
      'oldValue': oldValue,
      'newValue': newValue,
      'changedBy': changedBy,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Crée depuis un Map
  factory ReservationHistory.fromJson(Map<String, dynamic> json) {
    return ReservationHistory(
      id: json['id'] as String,
      reservationId: json['reservationId'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      oldValue: json['oldValue'] as String?,
      newValue: json['newValue'] as String?,
      changedBy: json['changedBy'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReservationHistory(id: $id, action: $action, description: $description, timestamp: $timestamp)';
  }
}

/// Entité pour les notes internes d'une réservation
class ReservationNote {
  final String id;
  final String reservationId;
  final String content;
  final String? author;
  final NoteType type;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReservationNote({
    required this.id,
    required this.reservationId,
    required this.content,
    this.author,
    required this.type,
    this.isPrivate = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Crée une copie avec des valeurs modifiées
  ReservationNote copyWith({
    String? id,
    String? reservationId,
    String? content,
    String? author,
    NoteType? type,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReservationNote(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      content: content ?? this.content,
      author: author ?? this.author,
      type: type ?? this.type,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationId': reservationId,
      'content': content,
      'author': author,
      'type': type.value,
      'isPrivate': isPrivate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Crée depuis un Map
  factory ReservationNote.fromJson(Map<String, dynamic> json) {
    return ReservationNote(
      id: json['id'] as String,
      reservationId: json['reservationId'] as String,
      content: json['content'] as String,
      author: json['author'] as String?,
      type: NoteType.fromString(json['type'] as String),
      isPrivate: json['isPrivate'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationNote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReservationNote(id: $id, type: $type, content: $content, createdAt: $createdAt)';
  }
}

/// Énumération des types de notes
enum NoteType {
  general('GENERAL', 'Général'),
  reminder('REMINDER', 'Rappel'),
  issue('ISSUE', 'Problème'),
  special('SPECIAL', 'Demande spéciale'),
  payment('PAYMENT', 'Paiement'),
  cancellation('CANCELLATION', 'Annulation');

  const NoteType(this.value, this.label);

  final String value;
  final String label;

  static NoteType fromString(String value) {
    return NoteType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NoteType.general,
    );
  }
}

/// Énumération des actions d'historique
enum HistoryAction {
  created('CREATED', 'Créée'),
  updated('UPDATED', 'Modifiée'),
  confirmed('CONFIRMED', 'Confirmée'),
  cancelled('CANCELLED', 'Annulée'),
  completed('COMPLETED', 'Terminée'),
  noShow('NO_SHOW', 'No-show'),
  tableAssigned('TABLE_ASSIGNED', 'Table assignée'),
  tableUnassigned('TABLE_UNASSIGNED', 'Table désassignée'),
  paymentReceived('PAYMENT_RECEIVED', 'Paiement reçu'),
  paymentRefunded('PAYMENT_REFUNDED', 'Paiement remboursé'),
  noteAdded('NOTE_ADDED', 'Note ajoutée'),
  emailSent('EMAIL_SENT', 'Email envoyé'),
  reminderSent('REMINDER_SENT', 'Rappel envoyé');

  const HistoryAction(this.value, this.label);

  final String value;
  final String label;

  static HistoryAction fromString(String value) {
    return HistoryAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => HistoryAction.updated,
    );
  }
}
