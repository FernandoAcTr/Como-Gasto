// To parse this JSON data, do
//
//     final Expense = ExpenseFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Expense {
    Expense({
        @required this.category,
        @required this.day,
        @required this.month,
        @required this.year,
        @required this.value,
    });

    final String category;
    final int day;
    final int month;
    final int year;
    final double value;

    factory Expense.fromJson(String str) => Expense.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Expense.fromMap(Map<String, dynamic> json) => Expense(
        category: json["category"],
        day: json["day"],
        month: json["month"],
        year: json["year"],
        value: json["value"].toDouble(),
    );

    Map<String, dynamic> toMap() => {
        "category": category,
        "day": day,
        "month": month,
        "year": year,
        "value": value,
    };
}
