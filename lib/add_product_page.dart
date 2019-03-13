import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  TextEditingController _dataController;
  TextEditingController _priceController;
  String text;
  StreamSubscription<DocumentSnapshot> data;
  List<Product> _products = <Product>[];
    final DocumentReference _documentReference =
      Firestore.instance.document("mydata/dummy");

  @override
  void initState() {
    super.initState();
    data = _documentReference.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          text = snapshot.data['egg'];
        });
      }
    });
  }

  @override
  void dispose() {
    data?.cancel();
    super.dispose();
  }

  void addProduct() {
    Product product = new Product(name: "tt", price: 1222, qty: 1);
    setState(() {
      _products.insert(0, product);
    });
  }

  void addData(String price) {
    Map<String, String> data = <String, String>{"apple": price, "egg": "10"};
    _documentReference.setData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print("Error :$e"));
  }

  void fetchData() {
    _documentReference.get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          text = snapshot.data['apple'];
        });
      }
    });
  }

  void updateData(String price) {
    Map<String, String> data = <String, String>{"apple": price, "egg": "15"};
    _documentReference.updateData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print("Error :$e"));
  }

  void deleteData() {
    _documentReference.delete().whenComplete(() {
      print("Document Deleted");
      setState(() {});
    }).catchError((e) => debugPrint("Error :$e"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Take Order'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              child: Center(
                  child: Text(
                "Name",
                style: TextStyle(fontSize: 40.0),
              )),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          TextField(
            controller: _dataController,
            keyboardType: TextInputType.numberWithOptions(),
            onSubmitted: addData,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Qty",
                labelStyle: TextStyle(fontSize: 30.0)),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80.0, right: 80),
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(),
              onChanged: updateData,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Rate",
                  labelStyle: TextStyle(fontSize: 30.0)),
            ),
          ),
          RaisedButton(
            onPressed: fetchData,
            child: Text("fetch"),
            color: Colors.green,
          ),
          Text(text == null ? "No data" : text),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addProduct,
      ),
    );
  }
}
