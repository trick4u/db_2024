import 'package:flutter/material.dart';

class NoteDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Handle share action
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'how I found a new dream',
                style: TextStyle(
                  fontFamily: 'Euclid',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'PERSONAL - 13/06/2022',
                style: TextStyle(
                  fontFamily: 'Euclid',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                value: true,
                onChanged: (bool? value) {},
                title: Text(
                  'Reflection on my place in life',
                  style: TextStyle(
                    fontFamily: 'Euclid',
                    fontSize: 16,
                  ),
                ),
              ),
              CheckboxListTile(
                value: false,
                onChanged: (bool? value) {},
                title: Text(
                  'Read a non-fiction book about goals in life and how to set them correctly',
                  style: TextStyle(
                    fontFamily: 'Euclid',
                    fontSize: 16,
                  ),
                ),
              ),
              CheckboxListTile(
                value: false,
                onChanged: (bool? value) {},
                title: Text(
                  'Watch a life-affirming movie about love and finding yourself',
                  style: TextStyle(
                    fontFamily: 'Euclid',
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'what was my dream',
                style: TextStyle(
                  fontFamily: 'Euclid',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'It was a cold and clear night and the stars were twinkling brightly above. My mum was reading the Ben 10 Omniverse bedtime storybook and I started falling asleep. I think it should be around midnight I was dreaming about something...',
                style: TextStyle(
                  fontFamily: 'Euclid',
                  fontSize: 16,
                ),
              ),
              // Add more content as needed
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.check_box, color: Colors.white),
                onPressed: () {
                  // Handle checkbox action
                },
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  // Handle add action
                },
              ),
              SizedBox(width: 40), // The dummy child for the notch
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // Handle favorite action
                },
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Handle edit action
                },
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Handle FAB action
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
