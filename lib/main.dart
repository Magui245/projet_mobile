import 'package:flutter/material.dart';
import 'taches.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tasks',
      home: ListPage(), 
    );
  }
}
