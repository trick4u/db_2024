import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalsContainer extends StatelessWidget {
  const GoalsContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Goals',
          style: TextStyle(
            fontSize: 20,
            //  fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
      ),
    );
  }
}
