import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/features/Auth/controller/auth_controller.dart';
import '../../routes/app_pages.dart';
import '../../routes/app_routes.dart';
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
  bool _isLoading = false;
  AuthController controller = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await controller.login(
          mobile: _usernameController.text,
          password: _passwordController.text,
        );
       
      } catch (e) {
        // Handle error
        Get.snackbar('Error', e.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
          }
    }}

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
                    onPressed:()async{
                         if (_formKey.currentState!.validate()) {
                            await controller.login(
                              mobile: _usernameController.text,
                              password: _passwordController.text,
                            );
                            if (Get.isRegistered<AuthController>()) {
                              context.push(AppPages.home);
                            } else {
                              Get.snackbar('Error', 'Login failed',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                            }
                         
                      }

                    }
                  ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50,
                  //   child: ElevatedButton(
                  //     onPressed: _isLoading ? null : _login,
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: AppColors.kcPrimaryColor,
                  //       foregroundColor: Colors.white,
                  //       disabledBackgroundColor: AppColors.kcButtonDisabledColor,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       elevation: 2,
                  //     ),
                  //     child: _isLoading
                  //         ? const CircularProgressIndicator(
                  //             valueColor:
                  //                 AlwaysStoppedAnimation<Color>(Colors.white),
                  //           )
                  //         : const Text(
                  //             'Login',
                  //             style: TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //   ),
                  // ),
               
                ],
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}
