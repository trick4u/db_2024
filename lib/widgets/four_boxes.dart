import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/app_routes.dart';

import '../projectController/page_one_controller.dart';

class FourBoxes extends GetWidget<PageOneController> {
  const FourBoxes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          //  color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          //shodow
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'all notes',
                            style: TextStyle(
                              fontFamily: 'Euclid',
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              Get.toNamed(AppRoutes.NOTES);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(color: Colors.grey, width: 0.5),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'Tasks',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey, height: 0.5),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'Upcoming',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(color: Colors.grey, width: 0.5),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'Reminders',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
