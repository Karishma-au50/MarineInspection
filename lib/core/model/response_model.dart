

import 'base_model.dart';

class ResponseModel<T> {
  final String? message;
  final bool? status;
  final T? data;

  ResponseModel({this.message, this.status, this.data});

  ResponseModel.error({this.message, this.data}) : status = false;

  // default constructor
  ResponseModel.empty()
      : message = null,
        status = null,
        data = null;

  Map<String, dynamic> toJson() {
    return {'message': message, 'status': status, 'data': data};
  }

  ResponseModel fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      message: json['message'],
      status: json['status'],
      data: T == BaseModel
          ? BaseModel.fromJson(json['data']) as T?
          : json['data'] as T?,
    );
  }

  // copyWith method
  ResponseModel copyWith({
    String? message,
    bool? status,
    T? data,
  }) {
    return ResponseModel(
      message: message ?? this.message,
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }
}
