import 'package:como_gasto/src/shared_prefs/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:como_gasto/src/keys/keys.dart' as keys;

enum LoginType { GOOGLE, FACEBOOK, TWITTER }

///Existen 3 pasos basicos para crear un metodo de login mediante Firebase
///1. Obtener un usuario o sesion utilizando la libreria especifica del proveedor, como google o facebook
///2. Verificar si el usuario le dio permisos de acceder a ese proveedor
///3. Obtener credenciales Firebase a partir del usuario o sesion que se obtuvo
///4. Obtener un usuario de Firebase a partir de las credenciales obtenidas. La informacion necesaria para
///este paso depende del proveedor
class LoginStateProvider with ChangeNotifier {
  //manejo de estado
  bool _loggedIn = false;
  bool _loading = true;

  //necesarias para la autenticacion
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  final _facebookLogin = FacebookLogin();
  // final _twitterLogin = new TwitterLogin(
  //   consumerKey: keys.TWITTER_API,
  //   consumerSecret: keys.TWITTER_SECRET,
  // );

  //guardar las preferencias
  final _prefs = PreferenciasUsuario();

  bool get isLoggedIn => _loggedIn;

  bool get isLoading => _loading;

  FirebaseUser get currentUser => _user;

  LoginStateProvider() {
    loadLoginState();
  }

  void login(LoginType loginType) async {
    _loading = true;
    notifyListeners();

    switch (loginType) {
      case LoginType.GOOGLE:
        _user = await _handleGoogleSignIn();

        break;
      case LoginType.TWITTER:
        // _user = await _handleTwitterSignIn();

        break;

      case LoginType.FACEBOOK:
        _user = await _handleFacebookSignIn();
    }

    _loading = false;

    if (_user != null) {
      _loggedIn = true;
      _prefs.loggedIn = true;
    } else {
      _loggedIn = false;
    }

    notifyListeners();
  }

  void logout() async {
    _prefs.clear();

    if (await _googleSignIn.isSignedIn()) _googleSignIn.signOut();
    else if(await _facebookLogin.isLoggedIn) _facebookLogin.logOut();
    // else if (await _twitterLogin.isSessionActive) _twitterLogin.logOut();
    _auth.signOut();

    _loggedIn = false;
    notifyListeners();
  }

  Future<FirebaseUser> _handleGoogleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    var user = await loginInFirebase(credential);
    return user;
  }

  // Future<FirebaseUser> _handleTwitterSignIn() async {
  //   final twitterResult = await _twitterLogin.authorize();
  //   if (twitterResult.status != TwitterLoginStatus.loggedIn) return null;

  //   final session = twitterResult.session;

  //   AuthCredential credential = TwitterAuthProvider.getCredential(
  //     authToken: session.token,
  //     authTokenSecret: session.secret,
  //   );

  //   var user = await loginInFirebase(credential);
  //   return user;
  // }

  Future<FirebaseUser> _handleFacebookSignIn() async {
    final fbResult = await _facebookLogin.logIn(['email']);
    if (fbResult.status != FacebookLoginStatus.loggedIn) return null;

    AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: fbResult.accessToken.token);

    var user = await loginInFirebase(credential);
    return user;
  }

  Future<FirebaseUser> loginInFirebase(AuthCredential credential) async {
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  void loadLoginState() async {
    if (_prefs.loggedIn) {
      _user = await _auth.currentUser();
      _loggedIn = _user != null;
      _loading = false;
      notifyListeners();
    } else {
      _loading = false;
      notifyListeners();
    }
  }
}
