import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';
class CataLog extends StatefulWidget {
  @override
  _CataLogState createState() => _CataLogState();
}

class _CataLogState extends State<CataLog> {
  List<ProductData> productData = [];
  String path;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CateLog"),
      ),
      body: 
      // Center(
      //   child: productData.isEmpty
      //       ? Column(
      //         mainAxisAlignment: MainAxisAlignment.spaceAround,
      //         children: <Widget>[
      //           Text("Select csv file"),
      //           RaisedButton(
      //             onPressed: ()async{
                  
      //             },
      //             child: Text("SELECT"),
                  
      //           ),
      //           Text(path??"Select plese")
      //         ],
      //       )
      //       : 
            FutureBuilder(
              future: DefaultAssetBundle.of(context).loadString("lib/data/data.json"),
              builder: (context,snapshot){
                var jsonResponse=json.decode(snapshot.data.toString());
                List<ProductData> mydata=ProductDataList.fromJSOn(jsonResponse).list;
                return GridView.count(
                crossAxisCount: 2,
                children: mydata
                    .map((p) => Card(
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
                        ))
                    .toList(),
              );
              },
            )
      
    );
  }
}
