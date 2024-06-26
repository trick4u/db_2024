import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';

import '../widgets/rounded_rect_container.dart';

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      alignment: Alignment.center,
      //  child: RoundedGradientContainer(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Page 1',
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 20),
          // text quick task
          InkWell(
            onTap: () {
              // bottom sheet
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 400,
                    decoration: BoxDecoration(
                      //  color: Colors.white,
                      // border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Quick Task',
                          style: TextStyle(fontSize: 30),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Task Name',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                        const TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Task Name',
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Schedule',
                          style: TextStyle(fontSize: 20),
                        ),
                        
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Text(
              'Quick Task',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
