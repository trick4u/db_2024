import 'package:flutter/material.dart';

class AccountRegister extends StatelessWidget {
  const AccountRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("doBoard"),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.pinkAccent,
          child: Center(
            child: Text('Account Register'),
          ),
        ));
  }
}
