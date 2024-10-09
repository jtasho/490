import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = Set<Marker>();

  //SFO starting map location
  final LatLng _initialPosition = LatLng(37.619, -122.381);

  @override
  void initState() {
    super.initState();
    fetchFlightData();
  }

  // Fetch real-time flight data from OpenSky API
  Future<void> fetchFlightData() async {
    final url = 'https://opensky-network.org/api/states/all';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract relevant flight information
        List flights = data['states'];

        Set<Marker> flightMarkers = Set();

        for (var flight in flights) {
          // Ensure that both longitude (5) and latitude (6) are of type double and handle nulls
          double? longitude = flight[5] != null ? (flight[5] as num).toDouble() : null;
          double? latitude = flight[6] != null ? (flight[6] as num).toDouble() : null;

          if (longitude != null && latitude != null) {
            flightMarkers.add(
              Marker(
                markerId: MarkerId(flight[0].toString()), // Unique ID
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(
                  title: flight[1] ?? 'Unknown Aircraft',
                  snippet: 'Altitude: ${flight[7]?.toString() ?? 'N/A'} meters',
                ),
              ),
            );
          }
        }

        setState(() {
          markers = flightMarkers;
        });
      } else {
        print('Failed to fetch flight data.');
      }
    } catch (error) {
      print('Error fetching flight data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Aircraft Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 5.0,
        ),
        markers: markers, // Display the fetched flight markers
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
