import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

//main widget for page
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

//class for page to manage the map and flight data
class _MapPageState extends State<MapPage> {
  //controller to interact with map
  GoogleMapController? mapController;
  //set to hold map markers for aircraft locations
  Set<Marker> markers = Set<Marker>();
  //timer for data refresh
  Timer? timer;

  //SFO starting map location
  final LatLng _initialPosition = LatLng(37.619, -122.381);

  @override
  void initState() {
    //fetch initial data and refresh flight data every 30s
    super.initState();
    fetchFlightData();
    startTimer();
  }

  //start the timer to refresh flight data every 30 seconds
  void startTimer() {
    //fetch flight data every 30 seconds
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      fetchFlightData();
    });
  }

  //fetch real-time flight data from OpenSky API
  Future<void> fetchFlightData() async {
    final url = 'https://opensky-network.org/api/states/all';

    try {
      //GET request for API
      final response = await http.get(Uri.parse(url));

      //response successful?
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); //parse JSON response

        //extract relevant flight information (list of flight details)
        List flights = data['states'];

        Set<Marker> flightMarkers = Set();

        for (var flight in flights) {
          //gets long and lat then stores as doubles
          double? longitude = flight[5] != null ? (flight[5] as num).toDouble() : null;
          double? latitude = flight[6] != null ? (flight[6] as num).toDouble() : null;

          //create a marker when there's a long and lat
          if (longitude != null && latitude != null) {
            flightMarkers.add(
              Marker(
                markerId: MarkerId(flight[0].toString()), //unique ID
                position: LatLng(latitude, longitude), //position on map
                infoWindow: InfoWindow(
                  title: flight[1] ?? 'Unknown Aircraft', //flight info display or default for null
                  snippet: 'Altitude: ${flight[7]?.toString() ?? 'N/A'} meters', //altitiude when available
                ),
              ),
            );
          }
        }
        //update markers with new set of flight data
        setState(() {
          markers = flightMarkers;
        });
        //error for failed requests
      } else {
        print('Failed to fetch flight data.');
      }
      //error for log exceptions
    } catch (error) {
      print('Error fetching flight data: $error');
    }
  }

  @override
  void dispose() {
    timer?.cancel(); //cancel the timer when the state is disposed
    super.dispose();
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
        markers: markers, //display the fetched flight markers
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}