import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/features/Auth/controller/auth_controller.dart';
import 'package:marine_inspection/shared/widgets/toast/my_toast.dart';
import '../../routes/app_pages.dart';
import '../../shared/widgets/buttons/my_button.dart';
import '../../shared/widgets/inputs/my_text_field.dart';
import '../../shared/constant/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthController controller = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_boat,
              size: 80,
              color: AppColors.kcPrimaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Marine Inspection Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.kcPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  MyTextField(
                    controller: _usernameController,
                    hintText: 'Enter your username',
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    isPass: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  MyButton(
                    text: 'Login',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          bool res = await controller.login(
                            mobile: _usernameController.text,
                            password: _passwordController.text,
                          );
                          if (res) {
                            // Navigate to home page on successful login
                            if (mounted) GoRouter.of(context).go(AppPages.home);
                          } else {
                            MyToasts.toastError(
                              'Login failed. Please check your credentials.',
                            );
                          }

                          // Error handling is already done in the controller via toast
                        } catch (e) {
                          MyToasts.toastError(
                            'Login failed. Please try again.',
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
