import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart'; // Ensure this file exists in your project

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Employee App',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
