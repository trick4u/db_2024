import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../projectController/three_tasks_controller.dart';

// class ThreeTasksScreen extends GetWidget<ThreeTasksController> {
//   ThreeTasksScreen({super.key});

//   final TextEditingController _controller = TextEditingController();
// bool _isExpanded = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: Center(
//               child: Text('Your content here'),
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _isExpanded = true;
//               });
//             },
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               height: _isExpanded ? null : 100,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   top: BorderSide(color: Colors.grey[300]!, width: 0.5),
//                 ),
//               ),
//               child: _isExpanded
//                   ? _buildExpandedInput()
//                   : _buildCollapsedInput(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCollapsedInput() {
//     return Center(
//       child: Text(
//         'Tap to add a comment...',
//         style: TextStyle(color: Colors.grey[600]),
//       ),
//     );
//   }

//   Widget _buildExpandedInput() {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 decoration: InputDecoration(
//                   hintText: 'Add a comment...',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
//                 ),
//                 maxLines: 1,
//                 autofocus: true,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Handle comment submission
//                 print('Comment submitted: ${_controller.text}');
//                 _controller.clear();
//                 setState(() {
//                   _isExpanded = false;
//                 });
//               },
//               child: Text(
//                 'Post',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }

class CommentScreen extends StatelessWidget {
  void _showCommentBox(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CommentBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _showCommentBox(context),
        child: Text('Add Comment'),
      ),
    );
  }
}

class CommentBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}