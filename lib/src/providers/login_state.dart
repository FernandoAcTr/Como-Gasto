import 'package:como_gasto/src/shared_prefs/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginState with ChangeNotifier {

  //manejo de estado
  bool _loggedIn = false;
  bool _loading = true;

  //necesarias para la autenticacion
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  //guardar las preferencias
  final _prefs = PreferenciasUsuario();


  bool get isLoggedIn => _loggedIn;

  bool get isLoading => _loading;

  FirebaseUser get currentUser => _user;

  LoginState() {
    loginState();    
  }

  void login() async {
    _loading = true;
    notifyListeners();

    _user  = await _handleSignIn();

    _loading = false;
    if(_user != null){
      _loggedIn = true;     
      _prefs.loggedIn = true; 
    }else{
      _loggedIn = false;
    }

    notifyListeners();
  }

  void logout() {
    _prefs.clear();
    _googleSignIn.signOut();
    _loggedIn = false;
    notifyListeners();
  }
 
  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  void loginState() async {
    if(_prefs.loggedIn){
      _user = await _auth.currentUser();
      _loggedIn = _user != null;
      _loading = false;
      notifyListeners();
    }else{
      _loading = false;
      notifyListeners();
    }
  }
}
