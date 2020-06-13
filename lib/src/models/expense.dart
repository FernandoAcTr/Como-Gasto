class Expense {
  final _category;
  final _day;
  final _month; 
  final _year; 
  final _value;

  Expense(this._category, this._day, this._month, this._year, this._value);

  get category => _category;
  get day => _day;
  get month => _month;
  get year => _year;
  get value => _value;
  
}