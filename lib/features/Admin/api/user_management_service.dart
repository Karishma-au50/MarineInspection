import 'package:dio/dio.dart';
import '../../../core/model/response_model.dart';
import '../../../core/network/base_api_service.dart';
import '../../../models/user_management_model.dart';
import '../../../shared/services/storage_service.dart';

class UserManagementEndpoint {
  static const String getUsers = 'api/user/';
  static const String createUser = 'api/user/register';
  static const String updateUser = 'api/user/';
  static const String deleteUser = 'api/user/';
}

class UserManagementService extends BaseApiService {
  
  /// Get all users (Admin only)
  Future<ResponseModel<List<User>?>> getUsers() async {
    final res = await get(
      UserManagementEndpoint.getUsers,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );

    // Handle response based on the API structure
    List<User>? users;
    if (res.data["data"] != null) {
      if (res.data["data"] is List) {
        users = (res.data["data"] as List).map((e) => User.fromJson(e)).toList();
      }
    }

    ResponseModel<List<User>?> resModel = ResponseModel<List<User>?>(
      message: res.data["message"] ?? "Success",
      status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
      data: users,
    );
    return resModel;
  }

  /// Create new user (Admin only)
  Future<ResponseModel<User?>> createUser(User user) async {
    final res = await post(
      UserManagementEndpoint.createUser,
      data: user.toCreateJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );

    User? createdUser;
    if (res.data["data"] != null) {
      createdUser = User.fromJson(res.data["data"]);
    }

    ResponseModel<User?> resModel = ResponseModel<User?>(
      message: res.data["message"] ?? "User created successfully",
      status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
      data: createdUser,
    );
    return resModel;
  }

  /// Update user (Admin only)
  Future<ResponseModel<User?>> updateUser(String id, User user) async {
    final res = await put(
      '${UserManagementEndpoint.updateUser}$id',
      data: user.toUpdateJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );

    User? updatedUser;
    if (res.data["data"] != null) {
      updatedUser = User.fromJson(res.data["data"]);
    }

    ResponseModel<User?> resModel = ResponseModel<User?>(
      message: res.data["message"] ?? "User updated successfully",
      status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
      data: updatedUser,
    );
    return resModel;
  }

  /// Delete user (Admin only)
  Future<ResponseModel> deleteUser(String id) async {
    final res = await delete(
      '${UserManagementEndpoint.deleteUser}$id',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${StorageService.instance.getToken()}',
        },
      ),
    );

    ResponseModel resModel = ResponseModel(
      message: res.data["message"] ?? "User deleted successfully",
      status: res.data["statusCode"] >= 200 && res.data["statusCode"] < 300,
      data: res.data["data"],
    );
    return resModel;
  }
}
