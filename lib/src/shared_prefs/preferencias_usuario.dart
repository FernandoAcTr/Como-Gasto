import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {

  static final PreferenciasUsuario _instancia = new PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }
  
  void clear(){
    _prefs.clear();
  }

  // GET y SET del loggedInd
  bool get loggedIn => _prefs.getBool('loggedIn') ?? false;
  
  bool get containsLoggedIn => _prefs.containsKey('loggedIn');
  
  set loggedIn( bool value ) {
    _prefs.setBool('loggedIn', value);
  }  
  

}

