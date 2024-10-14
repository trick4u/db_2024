import 'package:animate_do/animate_do.dart';
import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:tushar_db/services/app_text_style.dart';
import 'package:tushar_db/services/scale_util.dart';

import '../projectController/profile_controller.dart';
import '../services/app_theme.dart';
import '../services/toast_util.dart';

class ProfileScreen extends GetWidget<ProfileController> {
  final appTheme = Get.find<AppTheme>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    appTheme.updateStatusBarColor();
    var customScrollView = CustomScrollView(
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
                            valueBuilder: () =>
                                "@" + controller.username.value),
                        _buildSettingTile('Email', Icons.email,
                            valueBuilder: () => controller.email.value ?? ''),
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
                    onTap: () => controller.deleteAccount(), color: Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(
               color: Colors.deepPurpleAccent,
            ),);
          } else if (controller.hasError.value) {
            return Center(
              child: Text('An error occurred. Please try again.'),
            );
          } else {
            return customScrollView;
          }
        }),
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
  final RxBool canSave = false.obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    nameController.text = controller.name.value;
    usernameController.text = controller.username.value;
    return Padding(
      padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: ScaleUtil.scale(8),
        color: appTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: ScaleUtil.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Container(
            padding: ScaleUtil.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                ScaleUtil.sizedBox(height: 16),
                _buildNameField(context),
                ScaleUtil.sizedBox(height: 16),
                _buildUsernameField(context),
                ScaleUtil.sizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Edit Profile',
          style: appTheme.titleLarge.copyWith(
            fontSize: ScaleUtil.fontSize(15),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close,
              color: appTheme.textColor, size: ScaleUtil.iconSize(18)),
          onPressed: () => Get.back(),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    return FadeIn(
      child: ClipRRect(
        borderRadius: ScaleUtil.circular(10),
        child: TextFormField(
          controller: nameController,
          style: appTheme.bodyMedium.copyWith(
            fontSize: ScaleUtil.fontSize(12),
          ),
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(12)),
            filled: true,
            fillColor: appTheme.textFieldFillColor,
            border: InputBorder.none,
            contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) => _updateCanSave(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return FadeIn(
      child: ClipRRect(
        borderRadius: ScaleUtil.circular(10),
        child: TextFormField(
          controller: usernameController,
          style: appTheme.bodyMedium.copyWith(
            fontSize: ScaleUtil.fontSize(12),
          ),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(12)),
            filled: true,
            fillColor: appTheme.textFieldFillColor,
            border: InputBorder.none,
            contentPadding: ScaleUtil.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) => _updateCanSave(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SlideInRight(
      child: Obx(() => Container(
            decoration: BoxDecoration(
              color: canSave.value ? appTheme.colorScheme.primary : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: ScaleUtil.circular(20),
                onTap: canSave.value ? _handleSave : null,
                child: Padding(
                  padding: ScaleUtil.all(10),
                  child: Icon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                    size: ScaleUtil.iconSize(15),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void _updateCanSave() {
    canSave.value = nameController.text.trim().isNotEmpty &&
        usernameController.text.trim().isNotEmpty &&
        (nameController.text != controller.name.value ||
            usernameController.text != controller.username.value);
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      controller.updateName(nameController.text);
      controller.updateUsername(usernameController.text);
      Get.back();
      ToastUtil.showToast(
        'Success',
        'Profile updated successfully',
     
        backgroundColor: Colors.green,
      
        duration: Duration(seconds: 2),
      );
    }
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
  final _formKey = GlobalKey<FormState>();

  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmNewPassword = false.obs;

  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return Padding(
      padding: ScaleUtil.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: ScaleUtil.scale(8),
        color: appTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: ScaleUtil.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Container(
            padding: ScaleUtil.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                ScaleUtil.sizedBox(height: 16),
                _buildPasswordField(context, 'Current Password',
                    currentPasswordController, showCurrentPassword),
                ScaleUtil.sizedBox(height: 16),
                _buildPasswordField(context, 'New Password',
                    newPasswordController, showNewPassword),
                ScaleUtil.sizedBox(height: 16),
                _buildPasswordField(context, 'Confirm New Password',
                    confirmNewPasswordController, showConfirmNewPassword),
                ScaleUtil.sizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Change Password',
          style: appTheme.titleLarge.copyWith(
            fontSize: ScaleUtil.fontSize(15),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close,
              color: appTheme.textColor, size: ScaleUtil.iconSize(18)),
          onPressed: () => Get.back(),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, String label,
      TextEditingController controller, RxBool showPassword) {
    return FadeIn(
      child: ClipRRect(
        borderRadius: ScaleUtil.circular(10),
        child: Obx(() => TextFormField(
              controller: controller,
              obscureText: !showPassword.value,
              style: appTheme.bodyMedium.copyWith(
                fontSize: ScaleUtil.fontSize(12),
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(fontSize: ScaleUtil.fontSize(12)),
                filled: true,
                fillColor: appTheme.textFieldFillColor,
                border: InputBorder.none,
                contentPadding:
                    ScaleUtil.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: appTheme.textColor,
                    size: ScaleUtil.iconSize(15),
                  ),
                  onPressed: () => showPassword.toggle(),
                ),
              ),
              onChanged: (_) => _updateCanSave(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
            )),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSaveButton(context),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SlideInRight(
      child: Obx(() => Container(
            decoration: BoxDecoration(
              color: canSave.value ? appTheme.colorScheme.primary : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: ScaleUtil.circular(20),
                onTap: canSave.value ? _handleSave : null,
                child: Padding(
                  padding: ScaleUtil.all(10),
                  child: Icon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                    size: ScaleUtil.iconSize(15),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void _updateCanSave() {
    canSave.value = currentPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmNewPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmNewPasswordController.text;
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (newPasswordController.text != confirmNewPasswordController.text) {
        ToastUtil.showToast('Error', 'New passwords do not match');
        return;
      }
      controller.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
      Get.back();
    }
  }
}
