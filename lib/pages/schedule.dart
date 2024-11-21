import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  TextEditingController searchController = TextEditingController();
  List flights = [];
  List filteredFlights = [];

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
        setState(() {
          flights = data['states'] ?? [];
          filteredFlights = flights;
        });
      } else {
        print('Failed to fetch flight data.');
      }
    } catch (error) {
      print('Error fetching flight data: $error');
    }
  }

  // Filter flights based on the search query
  void filterFlights(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredFlights = flights;
      });
      return;
    }

    setState(() {
      filteredFlights = flights.where((flight) {
        final callsign = flight[1]?.toString().toLowerCase() ?? '';
        return callsign.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Convert Unix timestamp to readable date/time
  String formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'N/A';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Schedule'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterFlights,
              decoration: InputDecoration(
                labelText: 'Search Flights',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredFlights.isNotEmpty
                ? ListView.builder(
              itemCount: filteredFlights.length,
              itemBuilder: (context, index) {
                final flight = filteredFlights[index];
                final callsign = flight[1] ?? 'Unknown';
                final originCountry = flight[2] ?? 'Unknown Country';
                final departureTime = formatTimestamp(flight[3]);
                final arrivalTime = formatTimestamp(flight[4]);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text('Callsign: $callsign'),
                    subtitle: Text(
                      'Origin: $originCountry\n'
                          'Departure: $departureTime\n'
                          'Arrival: $arrivalTime',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            )
                : Center(
              child: Text('No flights found.'),
            ),
          ),
        ],
      ),
    );
  }
}

