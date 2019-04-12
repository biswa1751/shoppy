import 'package:flutter/material.dart';
import 'package:shoppy/data/product_data.dart';

class CataLog extends StatefulWidget {
  @override
  _CataLogState createState() => _CataLogState();
}

class _CataLogState extends State<CataLog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CateLog"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: myProductData.map((p)=>
        Card(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(p.name),
                Text(p.price.toString())
              ],
            ),
          ),
        )
        ).toList(),
      ),
    );
  }
}