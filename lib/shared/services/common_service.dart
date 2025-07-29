import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

import '../../core/network/base_api_service.dart';

class CommonService extends BaseApiService {
  static CommonService get to => Get.find();

  Future<CommonService> init() async => this;

  Future<Response> getImage(String url) {
    return get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
