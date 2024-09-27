import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List> fetchFlights() async {
  final apiKey = '70593d0a61d1ae43b98de804420b03e3';
  final response = await http.get(Uri.parse(
      'http://api.aviationstack.com/v1/flights?access_key=$apiKey'
  ));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['data']; // Returns a list of flight data
  } else {
    throw Exception('Failed to load flights');
  }
}

class FlightMap extends StatefulWidget {
  @override
  _FlightMapState createState() => _FlightMapState();
}

class _FlightMapState extends State<FlightMap> {
  GoogleMapController? _controller;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    fetchFlights().then((flights) {
      setState(() {
        _markers = flights.map((flight) {
          return Marker(
            markerId: MarkerId(flight['flight']['iata']),
            position: LatLng(flight['live']['latitude'], flight['live']['longitude']),
            infoWindow: InfoWindow(
              title: flight['flight']['iata'],
              snippet: flight['airline']['name'],
            ),
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Real-Time Flight Map"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Start the map centered at a global position
          zoom: 2, // Zoom level to see most of the world
        ),
        markers: Set.from(_markers),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
    );
  }
}
