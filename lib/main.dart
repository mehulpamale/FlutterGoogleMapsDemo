import 'dart:math';

import 'package:flutter/material.dart';

// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:latlong/latlong.dart' as latlong;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class FromOrTo {
  var from = true;

  String get fromOrTo => from ? 'from' : 'to';

  void toggle() => from = !from;
}

class Distance {
  /**
   * After searching a long for readymade plugin,'geolocator' throws error and
   * 'latlong' isnt null safe
   * ended up copying function
   * from SO
   */
  double between(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _mapController;
  final _fromOrTo = FromOrTo();
  final _markers = <Marker>{};
  late Marker from;
  late Marker to;

  // final _distanceLib = const latlong.Distance();
  double _distanceInKm = -1;

  // final _center = const LatLng(45.521563, -122.677433);
  final _center = const LatLng(19.076033, 72.892502);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
          onTap: (latLng) {
            setState(() {
              print('markers: ${_markers}');
              _fromOrTo.toggle();
              final markerId = MarkerId(_fromOrTo.fromOrTo);
              final marker = Marker(markerId: markerId, position: latLng);
              // _mapController.showMarkerInfoWindow(markerId);
              _markers.length == 2 ? _markers.remove(_markers.first) : null;
              _markers.add(marker);
              from = _markers.first;
              to = _markers.last;
              // final from1 = latlong.LatLng(
              //     from.position.latitude, from.position.longitude);
              // final to1 =
              //     latlong.LatLng(to.position.latitude, to.position.longitude);
              // _distanceInKm = _distanceLib
              //     .as(latlong.LengthUnit.Kilometer, from1, to1)
              //     .toInt();
              // _distanceInKm = Geolocator.distanceBetween(
              //         from.position.latitude,
              //         from.position.longitude,
              //         to.position.latitude,
              //         to.position.longitude)
              //     .toInt();
              _distanceInKm = Distance().between(
                  from.position.latitude,
                  from.position.longitude,
                  to.position.latitude,
                  to.position.longitude);
              print('_markers.length: ${_markers.length}');
            });
          },
          markers: _markers,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _center, zoom: 11)),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('${_distanceInKm} KM'),
                )),
            SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'fab_send',
              child: Icon(Icons.send),
              onPressed: () => setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ShowDistancePage('${_distanceInKm} KM')),
                );
              }),
            ),
            SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'fab_clear',
              child: Icon(Icons.clear_all),
              onPressed: () => setState(() {
                _markers.clear();
                _distanceInKm = -1;
              }),
            ),
            SizedBox(
              width: 15,
            )
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
}

class ShowDistancePage extends StatelessWidget {
  var text;

  ShowDistancePage(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Distance'),
        ),
        body: Center(child: Text('distance is: ${text}')));
  }
}
