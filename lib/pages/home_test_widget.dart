import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class HomeTestWidget extends StatefulWidget {
  @override
  State<HomeTestWidget> createState() => _HomeTestWidgetState();
}

class _HomeTestWidgetState extends State<HomeTestWidget> {

  final globalKey = GlobalKey();
  String? imagePath;



  // text editing controller
  final TextEditingController _controller = TextEditingController();

  String appGroupId = 'group.com.example.home_widget_example';
  String iosWidgetName = "test_home_screen";

  @override
  void initState() {
    // TODO: implement initState
    HomeWidget.setAppGroupId(appGroupId);
    super.initState();
  }

  updateWidgetFun() {
    HomeWidget.saveWidgetData<String>('title', 'John Doe');
    HomeWidget.saveWidgetData<String>('description', 'Home Widget Example');
    //update
    HomeWidget.saveWidgetData('filename', imagePath);
    HomeWidget.updateWidget(iOSName: iosWidgetName);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Home Test Widget'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // textfield and elevated button
              ContentBldr(globalKey: globalKey),
              ElevatedButton(
                onPressed: () async {
                  var path = await HomeWidget.renderFlutterWidget(
                   ContentBldr(globalKey: globalKey,),
                   key: 'filename',
                   pixelRatio: 0.5,
                  );
                  setState(() {
                    imagePath = path as String;
                  
                  });
                  updateWidgetFun();
                },
                child: Text('Update Widget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetData {
  final String text;
  WidgetData({required this.text});

  factory WidgetData.fromJson(Map<String, dynamic> json) {
    return WidgetData(text: json['text']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}


class ContentBldr extends StatelessWidget {
  final GlobalKey globalKey;

  ContentBldr({required this.globalKey});


  @override
  Widget build(BuildContext context) {
    return FlutterLogo(size: 200,);
  }
}