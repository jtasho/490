import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class FlightScheduleScreen extends StatefulWidget {
  @override
  _FlightScheduleScreenState createState() => _FlightScheduleScreenState();
}

class _FlightScheduleScreenState extends State<FlightScheduleScreen> {
  List<Map<String, dynamic>> flightSchedule = [];
  List<Map<String, dynamic>> filteredFlights = [];
  String searchQuery = '';

  Future<void> fetchFlightSchedule() async {
    const apiKey = '70593d0a61d1ae43b98de804420b03e3';
    const baseUrl = 'http://api.aviationstack.com/v1/flights';
    final url = Uri.parse('$baseUrl?access_key=$apiKey&flight_status=active');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final flights = data['data'] ?? [];

        setState(() {
          flightSchedule = flights.map<Map<String, dynamic>>((flight) {
            return {
              'id': flight['flight']['iata'] ?? 'N/A',
              'airline': flight['airline']['name'] ?? 'Unknown',
              'departure_airport': flight['departure']['airport'] ?? 'N/A',
              'arrival_airport': flight['arrival']['airport'] ?? 'N/A',
              'departure_time': flight['departure']['scheduled'] ?? 'N/A',
              'arrival_time': flight['arrival']['scheduled'] ?? 'N/A',
              'arrival_country_iso2': flight['arrival']['country_iso2'] ?? '',
            };
          }).toList();

          filteredFlights = List.from(flightSchedule);
        });
      } else {
        print('Failed to fetch flight schedule. HTTP Status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching flight schedule: $error');
    }
  }

  String formatTime(String time) {
    if (time == 'N/A') return time;
    try {
      final dateTime = DateTime.parse(time);
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime.toLocal());
    } catch (e) {
      return 'Invalid Time';
    }
  }

  void filterFlights(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredFlights = flightSchedule.where((flight) {
        return (flight['id'].toLowerCase().contains(searchQuery) ||
            flight['departure_airport'].toLowerCase().contains(searchQuery) ||
            flight['arrival_airport'].toLowerCase().contains(searchQuery));
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFlightSchedule();
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
              decoration: InputDecoration(
                hintText: 'Search by flight ID or airport...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterFlights,
            ),
          ),
          Expanded(
            child: filteredFlights.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredFlights.length,
              itemBuilder: (context, index) {
                final flight = filteredFlights[index];
                return Card(
                  child: ListTile(
                    title: Text('${flight['airline']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Flight ID: ${flight['id']}'),
                        Text(
                            'From: ${flight['departure_airport']} → To: ${flight['arrival_airport']}'),
                        Text(
                            'Departure: ${formatTime(flight['departure_time'])}'),
                        Text(
                            'Arrival: ${formatTime(flight['arrival_time'])}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
