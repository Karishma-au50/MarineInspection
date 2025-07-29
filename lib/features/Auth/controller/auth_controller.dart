import 'package:get/get.dart';
import 'package:marine_inspection/routes/app_pages.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/widgets/toast/my_toast.dart';
import '../api/auth_service.dart';

class AuthController extends GetxController {
  final _api = AuthService();

  Future<bool> login({required String mobile, required String password}) async {
    try {
      final res = await _api.login(mobile: mobile, password: password);
      if (res.status ?? false) {
        // Get.offAllNamed(AppPages.home);
        
        MyToasts.toastSuccess(res.message ?? "Success");
        return true;
      }
      else {
        MyToasts.toastError(res.message ?? "Login failed");
        return false;
      }
    } catch (e) {
      MyToasts.toastError(e.toString());
      return false;
    }
  }

}
