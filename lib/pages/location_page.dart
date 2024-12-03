import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LocationData? _currentLocation;
  Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = currentLocation;
      });

      print('${DateTime.fromMillisecondsSinceEpoch(currentLocation.time!.toInt())} ${currentLocation.latitude} ${currentLocation.longitude} ${currentLocation.speed} ${currentLocation.heading}');
      // print('Latitude: ');
      // print('Longitude: ');
      // print('Speed: ');
      // print('Timestamp: ');
      // print('Orientation: ');
      // print('Elevation: ${currentLocation.altitude}');
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Page'),
      ),
      body: Center(
        child: _currentLocation == null
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Latitude: ${_currentLocation!.latitude}'),
            Text('Longitude: ${_currentLocation!.longitude}'),
            Text('Speed: ${_currentLocation!.speed}'),
            Text('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(_currentLocation!.time!.toInt())}'),
            Text('Orientation: ${_currentLocation!.heading}'),
            Text('Elevation: ${_currentLocation!.altitude}'),
          ],
        ),
      ),
    );
  }
}