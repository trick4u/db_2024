import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tushar_db/app_routes.dart';
import 'package:tushar_db/services/app_text_style.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../projectController/profile_controller.dart';
import '../services/app_theme.dart';

class ProfileScreen extends GetWidget<ProfileController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    appTheme.updateStatusBarColor();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: ScaleUtil.height(80),
              floating: false,
              pinned: true,
              flexibleSpace: PressableDough(
                onReleased: (d) {
                  controller.toggleGradientDirection();
                },
                child: Obx(() => FlexibleSpaceBar(
                      background: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                        decoration: BoxDecoration(
                          
                          gradient: LinearGradient(
                            begin: controller.isGradientReversed.value
                                ? Alignment.bottomRight
                                : Alignment.topLeft,
                            end: controller.isGradientReversed.value
                                ? Alignment.topLeft
                                : Alignment.bottomRight,
                            colors: [
                              appTheme.colorScheme.primary,
                              Colors.deepPurpleAccent,
                            ],
                          ),
                        ),
                      ),
                      title: Obx(() => Text(
                            controller.name.value,
                            style: TextStyle(
                              fontSize: ScaleUtil.fontSize(15),
                            ),
                          )),
                      centerTitle: true,
                    )),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: ScaleUtil.iconSize(15),
                  ),
                  onPressed: () => _showEditBottomSheet(context),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: ScaleUtil.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: ScaleUtil.circular(12),
                      ),
                      child: Padding(
                        padding: ScaleUtil.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profile Info',
                                style: TextStyle(
                                    fontSize: ScaleUtil.fontSize(18),
                                    fontWeight: FontWeight.bold)),
                            ScaleUtil.sizedBox(height: 12),
                            _buildSettingTile('Username', Icons.person,
                                valueBuilder: () => controller.username.value),
                            _buildSettingTile('Email', Icons.email,
                                valueBuilder: () =>
                                    controller.email.value ?? ''),
                          ],
                        ),
                      ),
                    ),
                    ScaleUtil.sizedBox(height: 24),
                    Text('Settings',
                        style: TextStyle(
                            fontSize: ScaleUtil.fontSize(18),
                            fontWeight: FontWeight.bold)),
                    ScaleUtil.sizedBox(height: 12),
                    _buildSettingTile('Theme', Icons.brightness_6, onTap: () {
                      appTheme.toggleTheme();
                      appTheme.updateStatusBarColor();
                    }),
                    _buildSettingTile('Change Password', Icons.lock,
                        onTap: () => _showChangePasswordBottomSheet(context)),
                    _buildSettingTile('Logout', Icons.exit_to_app,
                        onTap: () => controller.logout()),
                    _buildSettingTile('Delete Account', Icons.delete_forever,
                        onTap: () => controller.deleteAccount(),
                        color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon,
      {VoidCallback? onTap, Color? color, String Function()? valueBuilder}) {
    return ListTile(
      leading: Icon(icon, size: ScaleUtil.iconSize(15)),
      title: Text(title, style: AppTextTheme.textTheme.bodySmall),
      trailing: valueBuilder != null
          ? Obx(
              () =>
                  Text(valueBuilder(), style: AppTextTheme.textTheme.bodySmall),
            )
          : Icon(
              Icons.chevron_right,
              size: ScaleUtil.iconSize(15),
            ),
      onTap: onTap,
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditProfileBottomSheet(),
        );
      },
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ChangePasswordBottomSheet(),
        );
      },
    );
  }


}

class EditProfileBottomSheet extends GetWidget<ProfileController> {
  final AppTheme appTheme = Get.find<AppTheme>();
  final RxBool _isNameChanged = false.obs;
  final RxBool _isUsernameChanged = false.obs;
  final RxBool canSave = false.obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    nameController.text = controller.name.value;
    usernameController.text = controller.username.value;
    return Padding(
      padding: ScaleUtil.only(left: 20, right: 20, bottom: 50),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(
            ScaleUtil.width(20),
          ),
        ),
        child: Padding(
          padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Edit Profile',
                    style: appTheme.titleLarge.copyWith(
                      fontSize: ScaleUtil.fontSize(15),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: appTheme.textColor,
                        size: ScaleUtil.iconSize(15)),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              ScaleUtil.sizedBox(height: 16),
              _buildTextField('Name', nameController, _updateCanSave),
              ScaleUtil.sizedBox(height: 16),
              _buildTextField('Username', usernameController, _updateCanSave),
              ScaleUtil.sizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: _buildSaveButton(context),
              ),
              ScaleUtil.sizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController,
      VoidCallback onChanged) {
    return ClipRRect(
      borderRadius: ScaleUtil.circular(10),
      child: TextField(
        controller: textController,
        style: appTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: appTheme.textFieldFillColor,
          labelStyle: appTheme.bodyMedium.copyWith(
            color: appTheme.secondaryTextColor,
            fontSize: ScaleUtil.fontSize(12),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 6),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: canSave.value ? appTheme.colorScheme.primary : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: ScaleUtil.circular(20),
              onTap: canSave.value
                  ? () async {
                      try {
                        await controller.updateName(nameController.text);
                        await controller
                            .updateUsername(usernameController.text);
                        Navigator.of(context).pop(); // Close the bottom sheet
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to update profile: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  : null,
              child: Padding(
                padding: ScaleUtil.all(10),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: ScaleUtil.iconSize(15),
                ),
              ),
            ),
          ),
        ));
  }

  void _updateCanSave() {
    canSave.value = nameController.text.trim().isNotEmpty &&
        usernameController.text.trim().isNotEmpty &&
        (nameController.text != controller.name.value ||
            usernameController.text != controller.username.value);
  }
}

class ChangePasswordBottomSheet extends GetWidget<ProfileController> {
  final AppTheme appTheme = Get.find<AppTheme>();
  final RxBool canSave = false.obs;
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return Padding(
      padding: ScaleUtil.only(left: 20, right: 20, bottom: 50),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(
            ScaleUtil.width(20),
          ),
        ),
        child: Padding(
          padding: ScaleUtil.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Change Password',
                    style: appTheme.titleLarge.copyWith(
                      fontSize: ScaleUtil.fontSize(15),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: appTheme.textColor,
                        size: ScaleUtil.iconSize(15)),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              ScaleUtil.sizedBox(height: 16),
              _buildTextField('Current Password', currentPasswordController,
                  _updateCanSave),
              ScaleUtil.sizedBox(height: 16),
              _buildTextField(
                  'New Password', newPasswordController, _updateCanSave),
              ScaleUtil.sizedBox(height: 16),
              _buildTextField('Confirm New Password',
                  confirmNewPasswordController, _updateCanSave),
              ScaleUtil.sizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: _buildSaveButton(context),
              ),
              ScaleUtil.sizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController,
      VoidCallback onChanged) {
    return ClipRRect(
      borderRadius: ScaleUtil.circular(10),
      child: TextField(
        controller: textController,
        style: appTheme.bodyMedium,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: appTheme.textFieldFillColor,
          labelStyle: appTheme.bodyMedium.copyWith(
            color: appTheme.secondaryTextColor,
            fontSize: ScaleUtil.fontSize(12),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 6),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: canSave.value ? appTheme.colorScheme.primary : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: ScaleUtil.circular(20),
              onTap: canSave.value
                  ? () async {
                      try {
                        if (newPasswordController.text !=
                            confirmNewPasswordController.text) {
                          Get.snackbar('Error', 'New passwords do not match');
                          return;
                        }
                        await controller.changePassword(
                          currentPasswordController.text,
                          newPasswordController.text,
                        );
                        Navigator.of(context).pop(); // Close the bottom sheet
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to change password: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  : null,
              child: Padding(
                padding: ScaleUtil.all(10),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: ScaleUtil.iconSize(15),
                ),
              ),
            ),
          ),
        ));
  }

  void _updateCanSave() {
    canSave.value = currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmNewPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmNewPasswordController.text;
  }
}
