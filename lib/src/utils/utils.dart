import 'package:flutter/material.dart';

void mostrarSnackbar(GlobalKey<ScaffoldState> scaffoldKey, String mensaje){

    final snackbar = SnackBar(
        content: Text(mensaje),
        duration: Duration(milliseconds: 1500),
    );
    
    scaffoldKey.currentState.showSnackBar(snackbar);
}

int daysInMonth(int month){
  var now = DateTime.now();

  var lastDateTime = (month < 12) ? new DateTime(now.year, month+1, 0) : new DateTime(now.year + 1, 1, 0);

  return lastDateTime.day;
}