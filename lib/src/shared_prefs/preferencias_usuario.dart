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
  
  set loggedIn( bool value ) {
    _prefs.setBool('loggedIn', value);
  }

  // GET y SET del darkMode
  bool get darkMode => _prefs.getBool('darkMode') ?? false;
  
  set darkMode( bool value ) {
    _prefs.setBool('darkMode', value);  
  }
  
}
