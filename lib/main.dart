import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/ui/home_page.dart';

void main() async{
  await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  runApp(new MyApp());}

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
