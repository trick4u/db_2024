import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';

class RegistrationForm extends StatelessWidget {
  const RegistrationForm({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      // child: Column(
      //   children: [
      //     //email
      //     TextField(
      //       controller: controller.emailController,
      //       decoration: InputDecoration(
      //         hintText: 'Email',
      //       ),
      //     ),
      //     //password
      //     Obx(
      //       () => TextField(
      //         controller: controller.passwordController,
      //         obscureText: !controller.isPasswordVisibleRegister.value,
      //         decoration: InputDecoration(
      //           hintText: 'Password',
      //           suffixIcon: IconButton(
      //             onPressed: () {
      //               controller.togglePasswordVisibility();
      //             },
      //             icon: Icon(controller.isPasswordVisibleRegister.value
      //                 ? Icons.visibility
      //                 : Icons.visibility_off),
      //           ),
      //         ),
      //       ),
      //     ),
      //     //username
      //     Obx(
      //       () => TextField(
      //         controller: controller.userNameController,
      //         onChanged: (value) {
      //           controller.isUsernameAvailable.value = false;
      //           controller.userName.value = value;
      //         },
      //         decoration: InputDecoration(
      //           hintText: 'Create a unique username',
      //           suffixIcon: controller.userName.value.isNotEmpty
      //               ? IconButton(
      //                   onPressed: () async {
      //                     controller.userNameController.text =
      //                         await controller.createUsername(
      //                             controller.userNameController.text);
      //                   },
      //                   icon: Icon(Icons.check))
      //               : null,
      //         ),
      //       ),
      //     ),
      //     //name
      //     TextField(
      //       controller: controller.nameController,
      //       decoration: InputDecoration(
      //         hintText: 'Name',
      //       ),
      //     ),

      //     //register button
      //     TextButton(
      //       onPressed: () {
      //         // controller
      //         //     .checkUser(controller.emailController.text);

      //         controller.register();
      //       },
      //       child: Text('Register'),
      //     ),
      //   ],
      // ),
   
   
    );
  }
}
