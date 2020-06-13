import 'package:como_gasto/src/shared_prefs/preferencias_usuario.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeStateProvider with ChangeNotifier {

  // bool _isDarkEnable;
  PreferenciasUsuario _prefs = new PreferenciasUsuario();

  ThemeStateProvider(){
    // _isDarkEnable = _prefs.darkMode;
  }

  ThemeData get currentTheme =>
      isDarkModeEnable ? ThemeData.dark().copyWith(
        accentColor: Colors.white,
        primaryColor: Colors.red,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.red
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white
        ),
        toggleableActiveColor: Colors.red,
      ) : ThemeData.light();

  set darkMode(bool enable) {
    // _isDarkEnable = enable;
    _prefs.darkMode = enable;
    notifyListeners();
  }

  get isDarkModeEnable => _prefs.darkMode;
}
