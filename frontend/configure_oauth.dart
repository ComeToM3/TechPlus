#!/usr/bin/env dart

import 'dart:io';

/// Script pour configurer les clés OAuth
void main(List<String> args) async {
  print('🔐 Configuration OAuth pour TechPlus');
  print('=' * 50);
  
  // Lire le fichier .env actuel
  final envFile = File('.env');
  String envContent = '';
  
  if (await envFile.exists()) {
    envContent = await envFile.readAsString();
  }
  
  // Demander les clés OAuth
  print('\n📝 Veuillez fournir vos clés OAuth :');
  print('(Appuyez sur Entrée pour ignorer une clé)\n');
  
  // Google OAuth
  stdout.write('Google Client ID: ');
  final googleClientId = stdin.readLineSync() ?? '';
  
  stdout.write('Google Server Client ID: ');
  final googleServerClientId = stdin.readLineSync() ?? '';
  
  // Facebook OAuth
  stdout.write('Facebook App ID: ');
  final facebookAppId = stdin.readLineSync() ?? '';
  
  stdout.write('Facebook Client Token: ');
  final facebookClientToken = stdin.readLineSync() ?? '';
  
  // Apple OAuth
  stdout.write('Apple Service ID: ');
  final appleServiceId = stdin.readLineSync() ?? '';
  
  stdout.write('Apple Team ID: ');
  final appleTeamId = stdin.readLineSync() ?? '';
  
  stdout.write('Apple Key ID: ');
  final appleKeyId = stdin.readLineSync() ?? '';
  
  stdout.write('Apple Private Key: ');
  final applePrivateKey = stdin.readLineSync() ?? '';
  
  // Construire le nouveau contenu .env
  final newEnvContent = _buildEnvContent(
    envContent,
    googleClientId: googleClientId,
    googleServerClientId: googleServerClientId,
    facebookAppId: facebookAppId,
    facebookClientToken: facebookClientToken,
    appleServiceId: appleServiceId,
    appleTeamId: appleTeamId,
    appleKeyId: appleKeyId,
    applePrivateKey: applePrivateKey,
  );
  
  // Écrire le fichier .env
  await envFile.writeAsString(newEnvContent);
  
  print('\n✅ Configuration OAuth mise à jour !');
  print('\n📋 Résumé de la configuration :');
  print('Google OAuth: ${googleClientId.isNotEmpty ? '✅' : '❌'}');
  print('Facebook OAuth: ${facebookAppId.isNotEmpty ? '✅' : '❌'}');
  print('Apple OAuth: ${appleServiceId.isNotEmpty ? '✅' : '❌'}');
  
  print('\n🚀 Prochaines étapes :');
  print('1. Vérifiez que votre backend supporte les endpoints OAuth');
  print('2. Testez la connexion OAuth dans l\'interface admin');
  print('3. Configurez les redirects dans vos applications OAuth');
}

String _buildEnvContent(
  String existingContent, {
  required String googleClientId,
  required String googleServerClientId,
  required String facebookAppId,
  required String facebookClientToken,
  required String appleServiceId,
  required String appleTeamId,
  required String appleKeyId,
  required String applePrivateKey,
}) {
  final lines = existingContent.split('\n');
  final newLines = <String>[];
  
  // Variables à mettre à jour
  final updates = {
    'GOOGLE_CLIENT_ID': googleClientId,
    'GOOGLE_SERVER_CLIENT_ID': googleServerClientId,
    'FACEBOOK_APP_ID': facebookAppId,
    'FACEBOOK_CLIENT_TOKEN': facebookClientToken,
    'APPLE_SERVICE_ID': appleServiceId,
    'APPLE_TEAM_ID': appleTeamId,
    'APPLE_KEY_ID': appleKeyId,
    'APPLE_PRIVATE_KEY': applePrivateKey,
  };
  
  final updatedKeys = <String>{};
  
  for (final line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) {
      newLines.add(line);
      continue;
    }
    
    final parts = line.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      if (updates.containsKey(key)) {
        final value = updates[key]!;
        if (value.isNotEmpty) {
          newLines.add('$key=$value');
          updatedKeys.add(key);
        } else {
          newLines.add(line); // Garder la valeur existante
        }
      } else {
        newLines.add(line);
      }
    } else {
      newLines.add(line);
    }
  }
  
  // Ajouter les nouvelles clés qui n'existaient pas
  for (final entry in updates.entries) {
    if (!updatedKeys.contains(entry.key) && entry.value.isNotEmpty) {
      newLines.add('${entry.key}=${entry.value}');
    }
  }
  
  return newLines.join('\n');
}
