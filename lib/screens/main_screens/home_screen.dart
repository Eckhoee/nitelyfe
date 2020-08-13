import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nitelyfe/utils/map.dart';
import 'package:nitelyfe/screens/chat_screens/messages_screen.dart';
import 'package:nitelyfe/utils/geolocator_service.dart';
import 'package:provider/provider.dart';
import 'package:nitelyfe/utils/authentication.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final geoService = GeolocatorService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Authentication _auth = new Authentication(context);
              _auth.logoutUser();
            }),
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: new IconThemeData(color: Colors.black),
        title: Image.asset('images/nite_lyfe_3.png',
            height: 50, width: 100, fit: BoxFit.scaleDown),
        centerTitle: true,
        actions: <Widget>[
          Container(
            child: FlatButton(
              splashColor: Colors.transparent,
              child: Icon(Icons.chat), // or Send Icon
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesScreen(),
                ),
              ),
            ),
            width: 60,
          ),
        ],
      ),
      body: FutureProvider(
        create: (context) => geoService.getInitialLocation(),
        child: Consumer<Position>(
          builder: (context, position, widget) {
            return FireMap(position);
          },
        ),
      ),
    );
  }
}