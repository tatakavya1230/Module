import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Container with Glow Effect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          // Pink glow effect using BoxShadow
          decoration: BoxDecoration(
            color: Color(0xFF4DD0E1), // More vibrant light teal color
            borderRadius: BorderRadius.circular(25), // Highly rounded corners
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF4081).withOpacity(0.8), // Bright magenta/pink glow
                blurRadius: 25, // Increased blur for more prominent glow
                spreadRadius: 8, // Increased spread for uniform glow
              ),
              BoxShadow(
                color: Color(0xFFE91E63).withOpacity(0.6), // Additional magenta glow
                blurRadius: 35,
                spreadRadius: 12,
              ),
              BoxShadow(
                color: Color(0xFFF06292).withOpacity(0.4), // Softer outer glow
                blurRadius: 45,
                spreadRadius: 15,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Text(
            "Hello I'm",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Arial', // Sans-serif font
            ),
          ),
        ),
      ),
    );
  }
}
