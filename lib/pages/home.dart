import 'package:flutter/material.dart';
import 'package:schedule2/pages/map.dart';

class HomePage extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: Text('Home Page'),  
      ),  
      body: Center(  
        child: ElevatedButton(  
          onPressed: () {  
            // Navigate to the map page  
            Navigator.push(  
              context,  
              MaterialPageRoute(builder: (context) => FlightMap()),
            );  
          },  
          child: Text('To Map'),
        ),  
      ),  
    );  
  }  
}