import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PaperGridScreen extends StatefulWidget {
  @override
  _PaperGridScreenState createState() => _PaperGridScreenState();
}

class _PaperGridScreenState extends State<PaperGridScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    int numRows = 6; // Number of rows in the grid
    int numCols = 3; // Number of columns in the grid
    int numCells = numRows * numCols; // Total number of cells in the grid

    _controllers = List.generate(numCells, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 1200),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      int delay = _calculateRandomDelay(i);
      Future.delayed(Duration(milliseconds: delay), () {
        _controllers[i].repeat(reverse: true);
      });
    }
  }

  int _calculateRandomDelay(int index) {
    int row = index ~/ 100;
    int col = index % 100;
    int baseDelay = _random.nextInt(6) * 100; // Random base delay
    int direction = _random.nextInt(
        4); // Random direction: 0 (top), 1 (bottom), 2 (left), 3 (right)
    switch (direction) {
      case 0: // Top to bottom
        return (row * 100 + col) * 10 + baseDelay;
      case 1: // Bottom to top
        return ((5 - row) * 100 + col) * 10 + baseDelay;
      case 2: // Left to right
        return (row * 100 + col) * 10 + baseDelay;
      case 3: // Right to left
        return (row * 100 + (99 - col)) * 10 + baseDelay;
      default:
        return (row * 100 + col) * 10 + baseDelay;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
          ),
          itemCount: _controllers.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Opacity(
                  opacity: _animations[index].value,
                  child: Container(
                    margin:
                        EdgeInsets.all(1.0), // Reduced margin to fit more cells
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(4.0), // Adjusted border radius
                      child: Stack(
                        children: [
                          // The blurred background
                          BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          // The frosted glass effect
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          // The letter overlay
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// class PaperGridScreen extends StatefulWidget {
//   @override
//   _PaperGridScreenState createState() => _PaperGridScreenState();
// }

// class _PaperGridScreenState extends State<PaperGridScreen>
//     with TickerProviderStateMixin {
//   late List<AnimationController> _controllers;
//   late List<Animation<double>> _animations;
//   final Random _random = Random();

//   @override
//   void initState() {
//     super.initState();

//     int numRows = 6; // Number of rows in the grid
//     int numCols = 100; // Number of columns in the grid
//     int numCells = numRows * numCols; // Total number of cells in the grid

//     _controllers = List.generate(numCells, (index) {
//       return AnimationController(
//         duration: Duration(milliseconds: 1200),
//         vsync: this,
//       );
//     });

//     _animations = _controllers.map((controller) {
//       return Tween<double>(begin: 0, end: 1).animate(
//         CurvedAnimation(parent: controller, curve: Curves.easeInOut),
//       );
//     }).toList();

//     _startAnimations();
//   }

//   void _startAnimations() {
//     for (int i = 0; i < _controllers.length; i++) {
//       int delay = _calculateRandomDelay(i);
//       Future.delayed(Duration(milliseconds: delay), () {
//         _controllers[i].repeat(reverse: true);
//       });
//     }
//   }

//   int _calculateRandomDelay(int index) {
//     int row = index ~/ 100;
//     int col = index % 100;
//     int baseDelay = _random.nextInt(6) * 100; // Random base delay
//     int direction = _random.nextInt(
//         4); // Random direction: 0 (top), 1 (bottom), 2 (left), 3 (right)
//     switch (direction) {
//       case 0: // Top to bottom
//         return (row * 100 + col) * 10 + baseDelay;

//       case 1: // Bottom to top
//         return ((5 - row) * 100 + col) * 10 + baseDelay;
//       case 2: // Left to right
//         return (row * 100 + col) * 10 + baseDelay;
//       case 3: // Right to left
//         return (row * 100 + (99 - col)) * 10 + baseDelay;
//       default:
//         return (row * 100 + col) * 10 + baseDelay;
//     }
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 5,
//             childAspectRatio: 1.0,
//           ),
//           itemCount: _controllers.length,
//           itemBuilder: (context, index) {
//             return AnimatedBuilder(
//               animation: _animations[index],
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _animations[index].value,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Container(
//                       margin: EdgeInsets.all(4.0),
//                       height: 50,
//                       width: 50,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8.0),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.2),
//                         ),
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.white.withOpacity(0.25),
//                             Colors.white.withOpacity(0.05),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
