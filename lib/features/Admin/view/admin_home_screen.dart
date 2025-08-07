import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_management_model.dart';
import '../../../shared/constant/default_appbar.dart';
import '../controller/user_management_controller.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserManagementController());

    return Scaffold(
      appBar: defaultAppBar(context, title: 'Admin'),
      backgroundColor: Colors.grey.shade100,

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
            child: TextField(
              decoration: InputDecoration(
               
                hintText: 'Search Engineers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  return userController.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: userController.clearSearch,
                        )
                      : const SizedBox.shrink();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: userController.searchUsers,
            ),
          ),

          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: Obx(() {
              if (userController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredUsers = userController.filteredUsers;

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userController.searchQuery.value.isNotEmpty
                            ? 'No users found'
                            : 'No users yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userController.searchQuery.value.isNotEmpty
                            ? 'Try a different search term'
                            : 'Add your first user to get started',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: userController.refreshUsers,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(context, user, userController);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserDialog(context, userController),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    User user,
    UserManagementController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.role == 'admin'
                      ? Colors.red
                      : Colors.blue,
                  child: Text(
                    user.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            user.phone ?? 'No phone',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(context, value, user, controller),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    User user,
    UserManagementController controller,
  ) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, user, controller);
        break;
      case 'delete':
        _showDeleteDialog(context, user, controller);
        break;
    }
  }

  void _showCreateUserDialog(
    BuildContext context,
    UserManagementController controller,
  ) {
    controller.nameController.clear();
    controller.phoneController.clear();
    controller.emailController.clear();
    controller.passwordController.clear();
    controller.selectedRole.value = 'employee';

    _showUserFormDialog(context, controller, 'Create User', false);
  }

  void _showEditUserDialog(
    BuildContext context,
    User user,
    UserManagementController controller,
  ) {
    controller.loadUserForEdit(user);
    _showUserFormDialog(context, controller, 'Edit User', true);
  }

  void _showUserFormDialog(
    BuildContext context,
    UserManagementController controller,
    String title,
    bool isEdit,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                //     TextField(
                //   controller: controller.emailController,
                //   decoration: const InputDecoration(
                //     labelText: 'Email',
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                // const SizedBox(height: 16),
                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: isEdit ? 'New Password (Optional)' : 'Password',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedRole.value,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'employee',
                        child: Text('Employee'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedRole.value = value;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isCreating.value || controller.isUpdating.value
                  ? null
                  : () async {
                      bool success = false;
                      if (isEdit) {
                        success = await controller.updateUser(
                          controller.selectedUser.value!.id!,
                        );
                      } else {
                        success = await controller.createUser();
                      }
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
              child: controller.isCreating.value || controller.isUpdating.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Update' : 'Create'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    User user,
    UserManagementController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteUser(user.id!, user.name ?? 'Unknown');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


}
