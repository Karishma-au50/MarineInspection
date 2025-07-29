import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:marine_inspection/model/user_model.dart';

import '../../../core/model/response_model.dart';
import '../../../core/network/base_api_service.dart';
import '../../../shared/services/storage_service.dart';

class AuthEndpoint {
  static const login = 'api/user/login';
}

class AuthService extends BaseApiService {
  Future<ResponseModel> login({
    required String mobile,
    required String password,
  }) async {
    final res = await post(
      AuthEndpoint.login,
      data: {'phone': mobile, 'password': password},
    );
    Map<String, dynamic> decodedToken = JwtDecoder.decode(
      res.data['data']["token"],
    );
    print("Decoded json :- $decodedToken");
    StorageService.instance.setUserId(UserModel.fromJson(decodedToken));
    StorageService.instance.setToken(res.data['data']["token"]);
    ResponseModel responseModel = ResponseModel().fromJson(res.data);

    return responseModel;
  }
}
