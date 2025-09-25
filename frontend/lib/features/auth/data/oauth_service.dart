import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:dio/dio.dart';
import '../../../shared/models/user.dart';
import '../../../shared/errors/contextual_errors.dart';
import '../../../core/config/oauth_config.dart';

/// Service OAuth pour l'authentification admin
class OAuthService {
  final Dio _dio;
  final GoogleSignIn _googleSignIn;
  
  OAuthService(this._dio) : _googleSignIn = GoogleSignIn(
    scopes: OAuthConfig.googleScopes,
    serverClientId: OAuthConfig.googleServerClientId,
  );

  /// Connexion Google pour admin
  Future<OAuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return OAuthResult.cancelled();
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      // Envoyer le token au backend pour vérification et création du compte admin
      final response = await _dio.post('${OAuthConfig.backendBaseUrl}${OAuthConfig.googleAuthEndpoint}', data: {
        'accessToken': googleAuth.accessToken,
        'idToken': googleAuth.idToken,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final tokens = response.data['tokens'];
        
        final user = User.fromJson(userData);
        
        return OAuthResult.success(
          user: user,
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
      } else {
        throw Exception('Failed to authenticate with Google');
      }
    } catch (e) {
      return OAuthResult.error(
        ContextualAuthError(
          errorKey: 'oauth_google_failed',
          message: 'Échec de la connexion Google: ${e.toString()}',
        ),
      );
    }
  }

  /// Connexion Facebook pour admin
  Future<OAuthResult> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) {
        if (result.status == LoginStatus.cancelled) {
          return OAuthResult.cancelled();
        }
        throw Exception('Facebook login failed: ${result.message}');
      }

      final AccessToken accessToken = result.accessToken!;
      
      // Envoyer le token au backend pour vérification et création du compte admin
      final response = await _dio.post('${OAuthConfig.backendBaseUrl}${OAuthConfig.facebookAuthEndpoint}', data: {
        'accessToken': accessToken.token,
        'userId': accessToken.userId,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final tokens = response.data['tokens'];
        
        final user = User.fromJson(userData);
        
        return OAuthResult.success(
          user: user,
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
      } else {
        throw Exception('Failed to authenticate with Facebook');
      }
    } catch (e) {
      return OAuthResult.error(
        ContextualAuthError(
          errorKey: 'oauth_facebook_failed',
          message: 'Échec de la connexion Facebook: ${e.toString()}',
        ),
      );
    }
  }

  /// Connexion Apple pour admin
  Future<OAuthResult> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        throw Exception('Failed to get Apple identity token');
      }

      // Envoyer le token au backend pour vérification et création du compte admin
      final response = await _dio.post('${OAuthConfig.backendBaseUrl}${OAuthConfig.appleAuthEndpoint}', data: {
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
        'userIdentifier': credential.userIdentifier,
        'email': credential.email,
        'givenName': credential.givenName,
        'familyName': credential.familyName,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final tokens = response.data['tokens'];
        
        final user = User.fromJson(userData);
        
        return OAuthResult.success(
          user: user,
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
      } else {
        throw Exception('Failed to authenticate with Apple');
      }
    } catch (e) {
      return OAuthResult.error(
        ContextualAuthError(
          errorKey: 'oauth_apple_failed',
          message: 'Échec de la connexion Apple: ${e.toString()}',
        ),
      );
    }
  }

  /// Déconnexion OAuth
  Future<void> signOut() async {
    try {
      // Déconnexion Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Déconnexion Facebook
      await FacebookAuth.instance.logOut();
      
      // Apple ne nécessite pas de déconnexion explicite
    } catch (e) {
      // Log l'erreur mais ne pas la propager
      print('Error during OAuth sign out: $e');
    }
  }

  /// Vérifier si l'utilisateur est connecté via OAuth
  Future<bool> isSignedIn() async {
    try {
      final googleSignedIn = await _googleSignIn.isSignedIn();
      final facebookSignedIn = await FacebookAuth.instance.accessToken != null;
      
      return googleSignedIn || facebookSignedIn;
    } catch (e) {
      return false;
    }
  }
}

/// Résultat d'une authentification OAuth
class OAuthResult {
  final bool isSuccess;
  final bool isCancelled;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final ContextualAuthError? error;

  const OAuthResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  factory OAuthResult.success({
    required User user,
    required String accessToken,
    String? refreshToken,
  }) {
    return OAuthResult._(
      isSuccess: true,
      isCancelled: false,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  factory OAuthResult.cancelled() {
    return const OAuthResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }

  factory OAuthResult.error(ContextualAuthError error) {
    return OAuthResult._(
      isSuccess: false,
      isCancelled: false,
      error: error,
    );
  }
}
