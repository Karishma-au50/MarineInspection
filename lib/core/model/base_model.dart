abstract class BaseModel {
  Map<String, dynamic> toJson();
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}

// class BaseModelImpl implements BaseModel {
//   @override
//   Map<String, dynamic> toJson() {
//     throw UnimplementedError();
//   }

//   @override
//   BaseModel fromJson(Map<String, dynamic> json) {
//     throw UnimplementedError();
//   }
// }
