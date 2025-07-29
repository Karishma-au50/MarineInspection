import 'dart:convert';


import '../core/model/base_model.dart';

class UserModel implements BaseModel {
  String? id;
  String? firstName;
  String? lastName;
  String? gender;
  int? dob;
  String? email;
  int? otp;
  bool? isVerified;
  bool? notify;
  int? mobile;
  List<String> followedShops;
  List<String> likedProducts;
  String? password;
  List<Address> address;
  String? snsEndpoint;
  bool? isDeleted;
  int? createdAt;
  int? updatedAt;
  int? v;


  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.gender,
    this.dob,
    this.email,
    this.otp,
    this.isVerified,
    this.notify,
    this.mobile,
    this.followedShops = const [],
    this.likedProducts = const [],
    this.password,
    this.address = const [],
    this.snsEndpoint,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? gender,
    int? dob,
    String? email,
    int? otp,
    bool? isVerified,
    bool? notify,
    int? mobile,
    List<String>? followedShops,
    List<String>? likedProducts,
    String? password,
    List<Address>? address,
    String? snsEndpoint,
    bool? isDeleted,
    int? createdAt,
    int? updatedAt,
    int? v,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      isVerified: isVerified ?? this.isVerified,
      notify: notify ?? this.notify,
      mobile: mobile ?? this.mobile,
      followedShops: followedShops ?? this.followedShops,
      likedProducts: likedProducts ?? this.likedProducts,
      password: password ?? this.password,
      address: address ?? this.address,
      snsEndpoint: snsEndpoint ?? this.snsEndpoint,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  @override
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      dob: json['dob'],
      email: json['email'],
      otp: json['otp'],
      isVerified: json['isVerified'],
      notify: json['notify'],
      mobile: json['mobile'],
      followedShops: List<String>.from(json['followedShops'] ?? []),
      likedProducts: List<String>.from(json['likedProducts'] ?? []),
      password: json['password'],
      address: List<Address>.from(
          (json['address'] ?? []).map((x) => Address.fromJson(x))),
      snsEndpoint: json['snsEndpoint'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
      'email': email,
      'otp': otp,
      'isVerified': isVerified,
      'notify': notify,
      'mobile': mobile,
      'followedShops': followedShops,
      'likedProducts': likedProducts,
      'password': password,
      'address': address.map((x) => x.toJson()).toList(),
      'snsEndpoint': snsEndpoint,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Address {
  int? houseNo;
  String? street;
  String? city;
  String? state;
  String? country;
  int? pincode;
  String? landmark;
  String? name;
  int? phoneNumber;
  int? alternateNumber;
  String? type;
  bool? isDefault;
  String? id;

  Address({
    this.houseNo,
    this.street,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.landmark,
    this.name,
    this.phoneNumber,
    this.alternateNumber,
    this.type,
    this.isDefault,
    this.id,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      houseNo: json['houseNo'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      landmark: json['landmark'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      alternateNumber: json['alternateNumber'],
      type: json['type'],
      isDefault: json['isDefault'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'houseNo': houseNo,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'landmark': landmark,
      'name': name,
      'phoneNumber': phoneNumber,
      'alternateNumber': alternateNumber,
      'type': type,
      'isDefault': isDefault,
      '_id': id,
    };
  }
}
