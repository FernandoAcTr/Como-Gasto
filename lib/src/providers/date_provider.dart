
import 'package:flutter/material.dart';

class DateProvider with ChangeNotifier{

  int _year;
  int _month;

  DateProvider(){
    _year = DateTime.now().year;
    _month = DateTime.now().month -1;
  }

  int get year => _year;

  int get month => _month;

 set year(int year){
   _year = year;
   notifyListeners();
 }

 set month(int month) {
   _month = month;
   notifyListeners();
 }
}