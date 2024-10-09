import 'package:flutter/material.dart';
import 'package:schedule2/pages/map.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/SFO-Oblique_980x550.jpg'),
            fit: BoxFit.cover, // Covers the entire container
          ),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the map page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage()),
              );
            },
            child: Text('To Map'),
          ),
        ),
      ),
    );
  }
}