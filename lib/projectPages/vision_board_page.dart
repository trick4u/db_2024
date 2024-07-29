import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../projectController/vsion_board_controller.dart';

class VisionBoardPage extends GetWidget<VisionBoardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vision board.'),
      ),
      body: Center(
        child: Text('vision board page'),
      ),
    );
  }
}
