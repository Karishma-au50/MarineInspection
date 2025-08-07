import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/widgets/toast/my_toast.dart';
import '../api/auth_service.dart';

class AuthController extends GetxController {
  final _api = AuthService();

  Future<bool> login({required String mobile, required String password}) async {
    try {
      final res = await _api.login(mobile: mobile, password: password);
      if (res.status ?? false) {
        MyToasts.toastSuccess(res.message ?? "Success");
        return true;
      } else {
        MyToasts.toastError(res.message ?? "Login failed");
        return false;
      }
    } on DioException catch (e) {
      MyToasts.toastError(e.message ?? "An error occurred");
      return false;
    } catch (e) {
      MyToasts.toastError(e.toString());
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await StorageService.instance.clear();
      GoRouter.of(Get.context!).go(AppPages.login);
      MyToasts.toastSuccess("Logged out successfully");
    } catch (e) {
      MyToasts.toastError("Error logging out: ${e.toString()}");
    }
  }
}
