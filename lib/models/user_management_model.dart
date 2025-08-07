import '../core/model/base_model.dart';

class User implements BaseModel {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? role;
  String? password;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.role,
    this.password,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      password: json['password'], // Usually not returned from API
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
      'password': password,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // For create requests
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'phone': phone,
      // 'email': email,
      'role': role ?? 'employee',
      'password': password,
    };
  }

  // For update requests
  Map<String, dynamic> toUpdateJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (phone != null) json['phone'] = phone;
    if (email != null) json['email'] = email;
    if (role != null) json['role'] = role;
    if (password != null && password!.isNotEmpty) json['password'] = password;
    return json;
  }
}

class UsersListResponse {
  List<User>? users;
  int? total;
  int? page;
  int? limit;

  UsersListResponse({
    this.users,
    this.total,
    this.page,
    this.limit,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(
      users: json['users'] != null
          ? (json['users'] as List).map((e) => User.fromJson(e)).toList()
          : null,
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users?.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
    };
  }
}
