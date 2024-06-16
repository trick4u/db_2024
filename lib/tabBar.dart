import 'package:flutter/material.dart';

class TabBarDesign extends StatefulWidget {
  const TabBarDesign({super.key});

  @override
  State<TabBarDesign> createState() => _TabBarDesignState();
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TabBar Example'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(color: Colors.black),
              tabs: [
                Tab(icon: Icon(Icons.directions_car), text: "Car"),
                Tab(icon: Icon(Icons.directions_transit), text: "Transit"),
                Tab(icon: Icon(Icons.directions_bike), text: "Bike"),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CarTab(),
                  TransitTab(),
                  BikeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Car Tab'));
  }
}

class TransitTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Transit Tab'));
  }
}

class BikeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Bike Tab'));
  }
}
