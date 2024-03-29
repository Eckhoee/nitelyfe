import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitelyfe/constants.dart';
import 'package:nitelyfe/utils/authentication.dart';
import 'package:nitelyfe/utils/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GeolocatorService _geolocatorService = new GeolocatorService();
  String profilePicMarkerWindow;
  BitmapDescriptor _mapMarker;
  Geoflutterfire _geo;
  LatLng _initalPosition;
  FirebaseFirestore _firestore;
  Stream<List<DocumentSnapshot>> markerStream;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  String addressForMarkerWindow;
  double markerWindowLocation = -175;
  final Authentication _authentication = new Authentication();

  @override
  void initState() {
    super.initState();
    getLocation();

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'images/marker.png')
        .then((onValue) {
      _mapMarker = onValue;
    });

    _firestore = _geolocatorService.firestore;
    _geo = Geoflutterfire();
    Query collectionRef = _firestore.collection('locations');
    markerStream = _geo
        .collection(
          collectionRef: collectionRef,
        )
        .within(
            center: _geo.point(latitude: 0, longitude: 0),
            radius: 40075,
            field: 'position',
            strictMode: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: new IconThemeData(color: Colors.black),
        title: Image.asset('images/nite_lyfe_3.png',
            height: 75, width: 125, fit: BoxFit.scaleDown),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: kNiteLyfeRed,
                boxShadow: <BoxShadow>[
                  BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(.7)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            // backgroundImage: ,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Column(
                                    children: [Text('Followers'), Text('999')],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                ),
                                Container(
                                  child: Column(
                                    children: [Text('Following'), Text('999')],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.home_outlined),
                                      Text('15')
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.local_bar),
                                      Text('5'),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _authentication.getUserName(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Comfortaa',
                              ),
                            ),
                            Text(
                              _authentication.getEmail(),
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined),
                            Text(' \$9999999'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Center(
                child: Text(
                  'Achievements',
                  style: kListTileStyle,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Center(
                child: Text('Profile', style: kListTileStyle),
              ),
              onTap: () {},
            ),
            ListTile(
              title: Center(
                child: Text('Settings', style: kListTileStyle),
              ),
              onTap: () {},
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.resolveWith((states) =>
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => kNiteLyfeRed),
                    ),
                    child: Text('nitelyfe +'),
                    onPressed: () {},
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initalPosition,
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            rotateGesturesEnabled: false,
            trafficEnabled: false,
            liteModeEnabled: false,
            mapType: MapType.normal,
            markers: Set<Marker>.of(markers.values),
          ),
          AnimatedPositioned(
            top: markerWindowLocation,
            right: 0,
            left: 0,
            duration: Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 150,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      blurRadius: 30,
                      offset: Offset.zero,
                      color: Colors.grey.withOpacity(.5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(2.5),
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.topLeft,
                      child: CircleAvatar(
                        child: Image(
                          image: profilePicMarkerWindow != null
                              ? AssetImage(profilePicMarkerWindow)
                              : AssetImage('images/marker.png'),
                        ), //insert the profile picture for the makers
                        backgroundColor: kNiteLyfeRed,
                        radius: 25,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: addressForMarkerWindow != null
                                  ? Text(
                                      addressForMarkerWindow,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Comfortaa',
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Container(
                      alignment: Alignment.topRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            alignment: Alignment.topCenter,
                            icon: Icon(
                              Icons.cancel,
                            ),
                            iconSize: 16,
                            onPressed: () {
                              setState(() {
                                markerWindowLocation = -175;
                              });
                            },
                          ),
                          IconButton(
                            alignment: Alignment.bottomCenter,
                            padding:
                                EdgeInsets.only(top: 65, right: 10, bottom: 5),
                            icon: Icon(
                              Icons.check,
                            ),
                            iconSize: 30,
                            onPressed: () {
                              setState(
                                () {
                                  markerWindowLocation = -175;
                                },
                              );
                              //go and send request ot user to join the party and maybe push user to the message screen*
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      markerStream.listen((List<DocumentSnapshot> documentList) {
        _updateMarkers(documentList);
      });
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      final String feature = document.data()['feature'];
      final String locality = document.data()['locality'];
      final String postal = document.data()['postal'];
      final GeoPoint point = document.data()['position']['geopoint'];
      final String address = feature + ', ' + locality + ', ' + postal;
      _addMarker(point.latitude, point.longitude, address);
    });
  }

  void _addMarker(double lat, double lng, String address) {
    final id = MarkerId(lat.toString() + " " + lng.toString());
    final _marker = Marker(
      markerId: id,
      position: LatLng(lat, lng),
      icon: _mapMarker,
      onTap: () {
        setState(() {
          addressForMarkerWindow = address;
          markerWindowLocation = -10;
        });
      },
    );
    setState(() {
      markers[id] = _marker;
    });
  }

  void getLocation() async {
    Position _position = await _geolocatorService.getInitalPositionforCamera();
    setState(() {
      _initalPosition = new LatLng(_position.latitude, _position.longitude);
    });
  }
}
