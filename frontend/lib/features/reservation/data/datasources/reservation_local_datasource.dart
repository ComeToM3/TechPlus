import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Source de données locale pour la sauvegarde temporaire des réservations
class ReservationLocalDataSource {
  static const String _reservationDataKey = 'temp_reservation_data';
  static const String _reservationTimestampKey = 'temp_reservation_timestamp';
  
  /// Sauvegarder temporairement les données de réservation
  Future<void> saveTemporaryReservation(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Sauvegarder les données
    await prefs.setString(_reservationDataKey, jsonEncode(data));
    
    // Sauvegarder le timestamp
    await prefs.setInt(_reservationTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Charger les données temporaires de réservation
  Future<Map<String, dynamic>?> loadTemporaryReservation() async {
    final prefs = await SharedPreferences.getInstance();
    
    final dataString = prefs.getString(_reservationDataKey);
    final timestamp = prefs.getInt(_reservationTimestampKey);
    
    if (dataString == null || timestamp == null) {
      return null;
    }
    
    // Vérifier si les données ne sont pas trop anciennes (24h)
    final dataTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dataTime);
    
    if (difference.inHours > 24) {
      // Supprimer les données expirées
      await clearTemporaryReservation();
      return null;
    }
    
    try {
      return jsonDecode(dataString) as Map<String, dynamic>;
    } catch (e) {
      // En cas d'erreur de parsing, supprimer les données corrompues
      await clearTemporaryReservation();
      return null;
    }
  }
  
  /// Supprimer les données temporaires
  Future<void> clearTemporaryReservation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reservationDataKey);
    await prefs.remove(_reservationTimestampKey);
  }
  
  /// Vérifier si des données temporaires existent
  Future<bool> hasTemporaryReservation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_reservationDataKey);
  }
  
  /// Obtenir l'âge des données temporaires
  Future<Duration?> getTemporaryDataAge() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_reservationTimestampKey);
    
    if (timestamp == null) {
      return null;
    }
    
    final dataTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(dataTime);
  }
}
