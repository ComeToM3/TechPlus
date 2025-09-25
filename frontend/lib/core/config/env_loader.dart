import 'dart:io';

/// Chargeur de variables d'environnement depuis le fichier .env
class EnvLoader {
  static Map<String, String> _envVars = {};
  
  /// Charger les variables d'environnement depuis le fichier .env
  static Future<void> loadEnv() async {
    try {
      final envFile = File('.env');
      if (await envFile.exists()) {
        final lines = await envFile.readAsLines();
        
        for (final line in lines) {
          // Ignorer les commentaires et lignes vides
          if (line.trim().isEmpty || line.startsWith('#')) continue;
          
          // Parser les variables KEY=VALUE
          final parts = line.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            _envVars[key] = value;
          }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement du fichier .env: $e');
    }
  }
  
  /// Obtenir une variable d'environnement
  static String getEnv(String key, {String defaultValue = ''}) {
    return _envVars[key] ?? defaultValue;
  }
  
  /// Vérifier si une variable d'environnement existe
  static bool hasEnv(String key) {
    return _envVars.containsKey(key) && _envVars[key]!.isNotEmpty;
  }
  
  /// Obtenir toutes les variables d'environnement
  static Map<String, String> get allEnvVars => Map.unmodifiable(_envVars);
}
