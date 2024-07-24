import 'dart:math';

import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_routes.dart';
import '../controller/home_controller.dart';
import '../services/size_config.dart';
import '../widgets/registration_form.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScaleUtil.init(context);
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          //   _buildCircularIcons(),
          Positioned(
            bottom: ScaleUtil.height(20),
            left: 0,
            right: 0,
            child: _buildGetStartedWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.pink[50]!],
        ),
      ),
    );
  }

  Widget _buildCircularIcons() {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        child: Stack(
          children: [
            for (int i = 0; i < 6; i++)
              Positioned(
                left: 150 + 120 * cos(i * pi / 3),
                top: 150 + 120 * sin(i * pi / 3),
                child: _buildIcon(i),
              ),
            Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.pink],
                  ),
                ),
                child: Icon(Icons.star, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    List<IconData> icons = [
      Icons.thumb_up,
      Icons.person,
      Icons.location_on,
      Icons.calendar_today,
      Icons.person_outline,
      Icons.person,
    ];
    List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.yellow,
    ];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors[index],
      ),
      child: Icon(icons[index], color: Colors.white),
    );
  }

  Widget _buildGetStartedWidget(BuildContext context) {
    return Container(
      height: ScaleUtil.height(300),
      margin: EdgeInsets.all(16),
      padding: ScaleUtil.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Get Started',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Euclid"),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  // Implement close functionality if needed
                },
              ),
            ],
          ),
          Text(
            'Register for events, subscribe to calendars and manage events you\'re going to.',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Continue with Phone'),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: Size(double.infinity, 50),
            ),
          ),
          SizedBox(height: 10),
          OutlinedButton(
            child: Text('Continue with Email'),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  child: Icon(Icons.apple),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 50),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  child: Text('G'),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 50),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class MyHomePage extends GetWidget<HomeController> {
//   const MyHomePage({super.key});

//   //dispose the tab controller
//   @override
//   Widget build(BuildContext context) {
//     // timeDilation = 10.0;

//     return Scaffold(
//         backgroundColor:
//             controller.isDarkMode.value ? Colors.black : Colors.white,
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           centerTitle: false,
//           title: Hero(
//             tag: 'logo',
//             child: PressableDough(
//               onReleased: (s) {
//                 controller.changeTheme();
//               },
//               child: AbsorbPointer(
//                 child: Obx(() => Text(
//                       'doBoard',
//                       style: TextStyle(
//                         fontFamily: GoogleFonts.inder().fontFamily,
//                         fontSize: 40,
//                         fontWeight: FontWeight.bold,
//                         color: controller.isDarkMode.value
//                             ? Colors.white
//                             : Colors.black,
//                         decoration: TextDecoration.none,
//                         inherit: false,
//                       ),
//                     )),
//               ),
//             ),
//           ),
//         ),
//         body: SafeArea(
//           child: Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             margin: EdgeInsets.all(10),
//             color: controller.isDarkMode.value ? Colors.black : Colors.white,
//             child: Column(
//               children: [
//                 Center(
//                   child: Text(
//                     'Welcome to doBoard!',
//                     style: TextStyle(
//                       fontFamily: GoogleFonts.ubuntu().fontFamily,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Container(
//                   height: 100,
//                   width: 200,
//                   decoration: BoxDecoration(
//                     color: controller.isDarkMode.value
//                         ? Colors.white
//                         : Colors.black,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TabBar(
//                     controller: controller.tabController,
//                     indicatorColor: Colors.transparent,
//                     labelColor: Colors.white,
//                     unselectedLabelColor: Colors.white70,
//                     onTap: (index) {
//                       controller.tabController.animateTo(index);
//                     },
//                     labelStyle: TextStyle(
//                       color: Colors.black,
//                     ),
//                     tabs: [
//                       Tab(
//                         text: 'Login',
//                       ),
//                       Tab(
//                         text: 'Register',
//                       ),
//                     ],
//                   ),
//                 ),

//                 //sized box
//                 SizedBox(height: 20),
//                 // tab bar view
//                 Expanded(
//                   child: TabBarView(
//                     controller: controller.tabController,
//                     clipBehavior: Clip.none,
//                     children: [
//                       //login
//                       LoginForm(controller: controller),
//                       //register
//                       RegistrationForm(controller: controller),
//                     ],
//                   ),
//                 ),

//                 TextButton(
//                   onPressed: () {
//                     Get.toNamed(AppRoutes.PHONEAUTH);
//                   },
//                   child: Text("Phone Auth"),
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
// }


// class LoginForm extends StatelessWidget {
//   const LoginForm({
//     super.key,
//     required this.controller,
//   });

//   final HomeController controller;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         //email
//         TextField(
//           controller: controller.emailController,
//           decoration: InputDecoration(
//             hintText: 'Email',
//           ),
//         ),
//         //password
//         TextField(
//           controller: controller.passwordController,
//           decoration: InputDecoration(
//             hintText: 'Password',
//           ),
//         ),
//         //login button
//         TextButton(
//           onPressed: () {
//             controller.login();
//           },
//           child: Text('Login'),
//         ),
//       ],
//     );
//   }
// }
