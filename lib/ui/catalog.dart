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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          showSearch(
            context: context,
            delegate: MyDelegate(productData),
          );
        },
      ),
      body: FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString("lib/data/data.json"),
        builder: (context, snapshot) {
          var jsonResponse = json.decode(snapshot.data.toString());
          productData = ProductDataList.fromJSOn(jsonResponse).list;

          return productData.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text("Select csv file"),
                    RaisedButton(
                      onPressed: () async {},
                      child: Text("SELECT"),
                    ),
                    Text(path ?? "Select plese")
                  ],
                ))
              : GridView.count(
                  crossAxisCount: 2,
                  children: productData
                      .map((p) => Card(
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
                          ))
                      .toList(),
                );
        },
      ),
    );
  }
}

class MyDelegate extends SearchDelegate {
  final List<ProductData> productData;

  MyDelegate(this.productData);
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.close), onPressed: () => query = "")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: this.transitionAnimation,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.green,
        child: Container(
              height: 300,
              width: 300,
              child: Text(query),
      ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestionList=query.isEmpty?productData:productData.where((p)=>p.name.contains(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].name),
          onTap: (){
            showResults(context);
          },
        );
      },
      itemCount: suggestionList.length,
    );
  }
}
