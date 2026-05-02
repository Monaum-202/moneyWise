import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  static final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.appdata',
      // appdata scope = private folder, user can't see/delete files manually
      // safer than drive.file for backup purposes
    ],
  );

  // Sign in silently first (no popup if already signed in)
  static Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  // Full sign in with Google account picker
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      return null;
    }
  }

  static Future<GoogleSignInAccount?> signOut() => _googleSignIn.signOut();

  static Future<bool> get isSignedIn => _googleSignIn.isSignedIn();

  static Future<GoogleSignInAccount?> get currentUser async =>
      _googleSignIn.currentUser;

  // Get authenticated HTTP client for googleapis
  static Future<AuthClient?> getAuthClient() async {
    final account = _googleSignIn.currentUser ??
        await _googleSignIn.signInSilently();
    if (account == null) return null;
    final auth = await account.authentication;
    final credentials = AccessCredentials(
      AccessToken('Bearer', auth.accessToken!,
        DateTime.now().toUtc().add(const Duration(hours: 1))),
      auth.idToken,
      ['https://www.googleapis.com/auth/drive.appdata'],
    );
    return authenticatedClient(http.Client(), credentials);
  }
}
