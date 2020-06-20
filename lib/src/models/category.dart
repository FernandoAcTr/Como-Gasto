// To parse this JSON data, do
//
//     final category = categoryFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Category {
    Category({
        @required this.icon,
        @required this.name,
    });

    final String icon;
    final String name;

    factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Category.fromMap(Map<String, dynamic> json) => Category(
        icon: json["icon"],
        name: json["name"],
    );

    Map<String, dynamic> toMap() => {
        "icon": icon,
        "name": name,
    };
}
