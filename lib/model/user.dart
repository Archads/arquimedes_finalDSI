import 'package:cloud_firestore/cloud_firestore.dart';

//user.dart
class User {
  String id;
  final String name;
  final int age;
  final DateTime appointmentDateTime;

  User({
    this.id = '',
    required this.name,
    required this.age,
    required this.appointmentDateTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'appointmentDateTime': appointmentDateTime.toUtc(),
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        appointmentDateTime:
            (json['appointmentDateTime'] as Timestamp).toDate(),
      );
}
