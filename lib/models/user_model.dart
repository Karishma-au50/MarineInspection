import 'dart:convert';


import '../core/model/base_model.dart';

class UserModel implements BaseModel {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? role;


  UserModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.role,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}


