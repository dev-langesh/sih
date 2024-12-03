import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackerPage extends StatefulWidget {
  @override
  _LocationTrackerPageState createState() => _LocationTrackerPageState();
}

class _LocationTrackerPageState extends State<LocationTrackerPage> {
  Position? _currentPosition;
  String _locationMessage = "Fetching location...";
  late Stream<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permissions are permanently denied.";
      });
      return;
    }

    // Initialize position stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Notify on every movement
      ),
    );

    _positionStream.listen((Position position) {
      setState(() {
        _currentPosition = position;
        _locationMessage =
        "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      });

      // Print location in terminal
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location Tracker"),
      ),
      body: Center(
        child: _currentPosition == null
            ? Text(_locationMessage)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Current Location:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _locationMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
