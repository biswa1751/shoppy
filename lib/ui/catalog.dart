import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppy/ui/search_page.dart';

class CataLog extends StatefulWidget {
  @override
  _CataLogState createState() => _CataLogState();
}

class _CataLogState extends State<CataLog> {
  List<ProductData> productData = [];
  String path;
  Future<void> getPath() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (path == null) path = pref.getString("path");
    if (path != null) {
      pref.setString("path", path);
      read();
      setState(() {});
    }
  }

  void read() async {
    File file = File(path);
    String ss = await file.readAsString();
    var jsonResponse = json.decode(ss);
    productData = ProductDataList.fromJSOn(jsonResponse).list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CateLog"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () async {
            showSearch(
              context: context,
              delegate: SearchPage(productData),
            );
          },
        ),
        body: FutureBuilder(
          future: getPath(),
          builder: (context, snapshot) => path == null
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text("Select CSV file"),
                    RaisedButton(
                      onPressed: () async {
                        path = await FilePicker.getFilePath(type: FileType.ANY);
                        getPath();
                        setState(() {});
                      },
                      child: Text("SELECT"),
                    ),
                  ],
                ))
              : GridView.count(
                  crossAxisCount: 2,
                  children: productData
                      .map(
                        (p) => Card(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text(p.name),
                                    Text(p.price.toString())
                                  ],
                                ),
                              ),
                            ),
                      )
                      .toList(),
                ),
        ));
  }
}
