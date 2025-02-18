import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Love Position App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(0, 0);
  String _locationMessage = "Localisation non disponible.";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _trackLocation();

  }
  void _trackLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mettre à jour la position tous les 10 mètres
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locationMessage =
        "Latitude: ${position.latitude}, Longitude: ${position.longitude}";

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      });

      // Envoyer la position à une base de données
      _sendLocationToServer(position.latitude, position.longitude);
    });
  }

  void _sendLocationToServer(double latitude, double longitude) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("locations/mari").push();
    ref.set({
    "latitude": latitude,
    "longitude": longitude,
    "timeStamps": DateTime.now().millisecondsSinceEpoch}
    );

  }
  // Fonction pour obtenir la localisation
  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si la localisation est activée
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Le service de localisation est désactivé.";
      });
      return;
    }

    // Vérifier la permission d'accès à la localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "La permission de localisation est refusée.";
        });
        return;
      }
    }

    // Obtenir la position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _locationMessage =
      "Latitude: ${position.latitude}, Longitude: ${position.longitude}";

      // Déplacer la caméra sur la nouvelle position
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("LovePos")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId("currentLocation"),
                  position: _currentPosition,
                  infoWindow: InfoWindow(title: "Ma position actuelle"),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(_locationMessage, style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
