import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';

import '../widgets/rounded_rect_container.dart';

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      alignment: Alignment.center,
      child: RoundedGradientContainer(),
    );
  }
}
