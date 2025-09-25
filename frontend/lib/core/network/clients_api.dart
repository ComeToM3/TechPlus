import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// API pour la gestion des clients
class ClientsApi {
  final Dio _dio;
  final String _baseUrl;

  ClientsApi(this._dio, this._baseUrl);

  /// Obtenir la liste des clients avec recherche
  Future<List<Client>> getClients({
    String? search,
    int page = 1,
    int limit = 20,
    bool vipOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/clients',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
          if (vipOnly) 'vipOnly': true,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> clientsData = response.data['clients'];
        return clientsData.map((client) => Client.fromJson(client)).toList();
      } else {
        throw Exception('Failed to fetch clients');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching clients: $e');
    }
  }

  /// Rechercher des clients par nom, email ou téléphone
  Future<List<Client>> searchClients(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/clients/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> clientsData = response.data['clients'];
        return clientsData.map((client) => Client.fromJson(client)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtenir un client par ID
  Future<Client?> getClientById(String clientId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/clients/$clientId');

      if (response.statusCode == 200) {
        return Client.fromJson(response.data['client']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Créer un nouveau client
  Future<Client> createClient({
    required String name,
    required String email,
    String? phone,
    String? notes,
    bool isVip = false,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/clients',
        data: {
          'name': name,
          'email': email,
          if (phone != null) 'phone': phone,
          if (notes != null) 'notes': notes,
          'isVip': isVip,
        },
      );

      if (response.statusCode == 201) {
        return Client.fromJson(response.data['client']);
      } else {
        throw Exception('Failed to create client');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error creating client: $e');
    }
  }

  /// Mettre à jour un client
  Future<Client> updateClient({
    required String clientId,
    String? name,
    String? email,
    String? phone,
    String? notes,
    bool? isVip,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (notes != null) data['notes'] = notes;
      if (isVip != null) data['isVip'] = isVip;

      final response = await _dio.put(
        '$_baseUrl/api/clients/$clientId',
        data: data,
      );

      if (response.statusCode == 200) {
        return Client.fromJson(response.data['client']);
      } else {
        throw Exception('Failed to update client');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating client: $e');
    }
  }

  /// Supprimer un client
  Future<bool> deleteClient(String clientId) async {
    try {
      final response = await _dio.delete('$_baseUrl/api/clients/$clientId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir l'historique des réservations d'un client
  Future<List<ClientReservation>> getClientReservations(String clientId) async {
    try {
      final response = await _dio.get('$_baseUrl/api/clients/$clientId/reservations');

      if (response.statusCode == 200) {
        final List<dynamic> reservationsData = response.data['reservations'];
        return reservationsData.map((res) => ClientReservation.fromJson(res)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

/// Modèle pour un client
class Client {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? notes;
  final bool isVip;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalReservations;
  final double totalSpent;

  const Client({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.notes,
    required this.isVip,
    required this.createdAt,
    required this.updatedAt,
    required this.totalReservations,
    required this.totalSpent,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      notes: json['notes'],
      isVip: json['isVip'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      totalReservations: json['totalReservations'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'notes': notes,
      'isVip': isVip,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalReservations': totalReservations,
      'totalSpent': totalSpent,
    };
  }
}

/// Modèle pour une réservation de client
class ClientReservation {
  final String id;
  final DateTime date;
  final String time;
  final int partySize;
  final String status;
  final double? totalAmount;

  const ClientReservation({
    required this.id,
    required this.date,
    required this.time,
    required this.partySize,
    required this.status,
    this.totalAmount,
  });

  factory ClientReservation.fromJson(Map<String, dynamic> json) {
    return ClientReservation(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '',
      partySize: json['partySize'] ?? 0,
      status: json['status'] ?? '',
      totalAmount: json['totalAmount']?.toDouble(),
    );
  }
}
