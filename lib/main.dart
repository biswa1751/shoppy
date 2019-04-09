import 'package:flutter/material.dart';
import 'package:shoppy/ui/home_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
     title: 'Shoppy',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}
