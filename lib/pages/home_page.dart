import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';


import '../app_routes.dart';
import '../controller/home_controller.dart';
import '../widgets/registration_form.dart';

class MyHomePage extends GetWidget<HomeController> {
  const MyHomePage({super.key});

  //dispose the tab controller
  @override
  Widget build(BuildContext context) {
    // timeDilation = 10.0;

    return Scaffold(
        backgroundColor:
            controller.isDarkMode.value ? Colors.black : Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: false,
          title: Hero(
            tag: 'logo',
            child: PressableDough(
              onReleased: (s) {
                controller.changeTheme();
              },
              child: AbsorbPointer(
                child: Obx(() => Text(
                      'doBoard',
                      style: TextStyle(
                        fontFamily: GoogleFonts.inder().fontFamily,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: controller.isDarkMode.value
                            ? Colors.white
                            : Colors.black,
                        decoration: TextDecoration.none,
                        inherit: false,
                      ),
                    )),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(10),
            color: controller.isDarkMode.value ? Colors.black : Colors.white,
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Welcome to doBoard!',
                    style: TextStyle(
                      fontFamily: GoogleFonts.ubuntu().fontFamily,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 100,
                  width: 200,
                  decoration: BoxDecoration(
                    color: controller.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: controller.tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    onTap: (index) {
                      controller.tabController.animateTo(index);
                    },
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    tabs: [
                      Tab(
                        text: 'Login',
                      ),
                      Tab(
                        text: 'Register',
                      ),
                    ],
                  ),
                ),

                //sized box
                SizedBox(height: 20),
                // tab bar view
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    clipBehavior: Clip.none,
                    children: [
                      //login
                      LoginForm(controller: controller),
                      //register
                      RegistrationForm(controller: controller),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.PHONEAUTH);
                  },
                  child: Text("Phone Auth"),
                ),
              ],
            ),
          ),
        ));
  }
}


class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //email
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            hintText: 'Email',
          ),
        ),
        //password
        TextField(
          controller: controller.passwordController,
          decoration: InputDecoration(
            hintText: 'Password',
          ),
        ),
        //login button
        TextButton(
          onPressed: () {
            controller.login();
          },
          child: Text('Login'),
        ),
      ],
    );
  }
}
