import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tushar_db/constants/colors.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          // initialChildSize: 1,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: ColorsConstants().lightOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          'Daftar Task & Event',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shadowColor: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Meeting with Client",
                            style: TextStyle(
                              fontSize: 15,
                              //   fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "10:00 AM - 11:00 AM",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          //gradient color
          color: ColorsConstants().lightOrange,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistics",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "This Week",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
              const SizedBox(height: 16),
              TabBarDesign(),
              const SizedBox(height: 16),

              // const SizedBox(height: 16),
              // const Text(
              //   'Goals',
              //   style: TextStyle(
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // const Text(
              //   'You have no goals yet. Click the + button to add a new goal.',
              //   textAlign: TextAlign.center,
              // ),
              Spacer(),
              ExpansionTile(
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                title: Text(
                  "Event",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                onExpansionChanged: (value) {
                  _showBottomSheet(context);
                },
                children: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularEventWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PressableDough(
      onReleased: (details) {},
      child: SizedBox(
        width: 250,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Base circle with color and opacity
            Positioned(
              top: 0,
              bottom: 30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    stops: [0.2, 0.8],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [Colors.cyanAccent, Colors.blueAccent],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 5,
              left: 60,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.4),
                      Colors.white.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
            // Text in the center
            Center(
              child: Text(
                'Event\n17',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: [
                  CustomPaint(
                    size: Size(30, 40),
                    painter: ConnectorPainter(),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple,
                          Colors.pink,
                        ],
                      ),
                    ),
                    child: Text(
                      '78% done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

class ConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.purple.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.2)
      ..lineTo(size.width, size.height * 0.8)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DraggableTaskWidget extends StatefulWidget {
  @override
  _DraggableTaskWidgetState createState() => _DraggableTaskWidgetState();
}

class _DraggableTaskWidgetState extends State<DraggableTaskWidget> {
  Offset position = Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 300,
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              feedback: Material(
                elevation: 10,
                shape: CircleBorder(),
                shadowColor: Colors.black.withOpacity(0.5),
                child: buildTaskWidget(),
              ),
              childWhenDragging:
                  Container(), // This keeps the original position empty while dragging
              onDragEnd: (details) {
                setState(() {
                  position = details.offset;
                });
              },
              child: Material(
                elevation: 10,
                shape: CircleBorder(),
                shadowColor: Colors.black.withOpacity(0.5),
                child: buildTaskWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskWidget() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.purple.withOpacity(0.7),
            Colors.blue.withOpacity(0.6),
            Colors.orange.withOpacity(0.5),
          ],
          stops: [0.3, 0.6, 1.0],
        ),
      ),
      child: Center(
        child: Text(
          'Task\n34',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TabBarDesign extends StatefulWidget {
  @override
  _TabBarDesignState createState() => _TabBarDesignState();
}

class _TabBarDesignState extends State<TabBarDesign>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: ColorsConstants().lightOrange,
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          //shadow
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],

          border: Border.all(
            color: Colors.white,
            width: 1.0,
          ),
        ),
        indicatorWeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(
            fontSize: 16.0,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.0,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        tabs: [
          Tab(text: 'Neha'),
          Tab(text: 'Neha bua'),
          Tab(text: 'Diya bua'),
        ],
      ),
    );
  }
}
