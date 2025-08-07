import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_management_model.dart';
import '../../../shared/widgets/toast/my_toast.dart';
import '../api/user_management_service.dart';

class UserManagementController extends GetxController {
  final _api = UserManagementService();

  // Observable variables
  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Form controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxString selectedRole = 'employee'.obs;

  // Selected user for editing
  final Rxn<User> selectedUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Load all users
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;

      final response = await _api.getUsers();

      if (response.status == true && response.data != null) {
        users.assignAll(response.data!);
      } else {
        MyToasts.toastError(response.message ?? "Failed to load users");
      }
    } on DioException catch (e) {
      MyToasts.toastError("Network error: ${e.message}");
    } catch (e) {
      MyToasts.toastError("Error loading users: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Search users locally
  List<User> get filteredUsers {
    if (searchQuery.value.isEmpty) {
      return users;
    }
    return users.where((user) {
      final query = searchQuery.value.toLowerCase();
      return (user.name?.toLowerCase().contains(query) ?? false) ||
             (user.email?.toLowerCase().contains(query) ?? false) ||
             (user.phone?.contains(query) ?? false) ||
             (user.role?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Create new user
  Future<bool> createUser() async {
    // if (!_validateForm()) return false;

    try {
      isCreating.value = true;

      final user = User(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: selectedRole.value,
      );

      final response = await _api.createUser(user);

      if (response.status == true) {
        MyToasts.toastSuccess(response.message ?? "User created successfully");
        _clearForm();
        await loadUsers();
        return true;
      } else {
        MyToasts.toastError(response.message ?? "Failed to create user");
        return false;
      }
    } on DioException catch (e) {
      MyToasts.toastError("Network error: ${e.message}");
      return false;
    } catch (e) {
      MyToasts.toastError("Error creating user: ${e.toString()}");
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  /// Update user
  Future<bool> updateUser(String id) async {
    if (!_validateForm(isUpdate: true)) return false;

    try {
      isUpdating.value = true;

      final user = User(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
        role: selectedRole.value,
      );

      final response = await _api.updateUser(id, user);

      if (response.status == true) {
        MyToasts.toastSuccess(response.message ?? "User updated successfully");
        _clearForm();
        await loadUsers();
        return true;
      } else {
        MyToasts.toastError(response.message ?? "Failed to update user");
        return false;
      }
    } on DioException catch (e) {
      MyToasts.toastError("Network error: ${e.message}");
      return false;
    } catch (e) {
      MyToasts.toastError("Error updating user: ${e.toString()}");
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String id, String name) async {
    try {
      isDeleting.value = true;

      final response = await _api.deleteUser(id);

      if (response.status == true) {
        MyToasts.toastSuccess("User '$name' deleted successfully");
        await loadUsers();
        return true;
      } else {
        MyToasts.toastError(response.message ?? "Failed to delete user");
        return false;
      }
    } on DioException catch (e) {
      MyToasts.toastError("Network error: ${e.message}");
      return false;
    } catch (e) {
      MyToasts.toastError("Error deleting user: ${e.toString()}");
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  /// Load user for editing
  void loadUserForEdit(User user) {
    selectedUser.value = user;
    
    // Populate form
    nameController.text = user.name ?? '';
    phoneController.text = user.phone ?? '';
    emailController.text = user.email ?? '';
    passwordController.clear(); // Don't populate password
    selectedRole.value = user.role ?? 'employee';
  }

  /// Clear form
  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    selectedRole.value = 'employee';
    selectedUser.value = null;
  }

  /// Validate form
  bool _validateForm({bool isUpdate = false}) {
    if (nameController.text.trim().isEmpty) {
      MyToasts.toastError("Name is required");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      MyToasts.toastError("Phone number is required");
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      MyToasts.toastError("Email is required");
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      MyToasts.toastError("Please enter a valid email");
      return false;
    }

    if (!isUpdate && passwordController.text.isEmpty) {
      MyToasts.toastError("Password is required");
      return false;
    }

    if (passwordController.text.isNotEmpty && passwordController.text.length < 6) {
      MyToasts.toastError("Password must be at least 6 characters");
      return false;
    }

    return true;
  }

  /// Search users
  void searchUsers(String query) {
    searchQuery.value = query;
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
  }

  /// Refresh users list
  Future<void> refreshUsers() async {
    await loadUsers();
  }

  /// Get user count by role
  int getUserCountByRole(String role) {
    return users.where((user) => user.role == role).length;
  }

  /// Get total users count
  int get totalUsers => users.length;
}
