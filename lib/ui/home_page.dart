import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppy/model/product.dart';
import 'package:shoppy/ui/Product_view.dart';
import 'package:shoppy/ui/catalog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _dataController;
  List<Product> _products = [];
  CollectionReference _ref = Firestore.instance.collection("Products");
  List<ProductData> myProductData = [];
  String path;
  double total;
  @override
  void initState() {
    super.initState();
    total = 0;
    _dataController = TextEditingController();
    getPath();
  }

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
    myProductData = ProductDataList.fromJSOn(jsonResponse).list;
  }

  void addData(Product product) {
    Map<String, String> data = <String, String>{
      "price": product.price.toString(),
      "qty": product.qty.toString(),
      "barcode": product.barCode.toString(),
      "isdone": product.isDone.toString()
    };
    _ref.document(product.item).setData(data).whenComplete(() {
      print("Document ${product.item} Added");
    }).catchError((e) => print("Error :$e"));
  }

  int existIndex(int code) {
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].barCode == code) {
        return i;
      }
    }
    return null;
  }

  ProductData check(int code) {
    for (ProductData product in myProductData) {
      if (product.barCode == code) {
        return product;
      }
    }
    return null;
  }

  void addProduct(String code) {
    print("check $code");
    try {
      if (code.contains("\n")) {
        _dataController.clear();
        return;
      }
      int mycode = int.parse(code);
      int index = existIndex(mycode);
      print("index $index");
      if (index != null) {
        _products[index].qty++;
        addData(_products[index]);
        setState(() {});
        return;
      }
      ProductData myProduct = check(mycode);
      Product product = Product(
          barCode: myProduct.barCode,
          price: myProduct.price,
          qty: 1,
          mrp: myProduct.mrp,
          name: myProduct.name,
          isDone: false);
      print("test ${product.price}");
      print("product ${product.name}");
      if (_products.length == 0)
        product.item = "Item${_products.length + 1}";
      else
        product.item =
            "Item${int.parse(_products.last.item[_products.last.item.length - 1]) + 1}";
      if (product != null) {
        addData(product);
      }
      setState(() {});
    } catch (e) {}
  }

  @override
  void dispose() {
    _dataController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Take Order'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(""),
              accountEmail: Text(""),
            ),
            ListTile(
              leading: Icon(Icons.shop),
              title: Text(
                "Catelog",
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CataLog(
                          productData: myProductData,
                        )));
              },
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot>(
          stream: _ref.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            if (snapshot.data != null) {
              total = 0;
              _products = [];
              snapshot.data.documents.forEach((f) {
                total = total +
                    double.parse(f.data['qty']) * double.parse(f.data['price']);
                ProductData data = check(int.parse(f.data['barcode']));
                _products.add(Product(
                    barCode: data.barCode, name: data.name, mrp: data.mrp));
                _products.last.qty = int.parse(f.data['qty']);
                _products.last.price = double.parse(f.data['price']);
                _products.last.isDone =
                    f.data['isdone'] == "true" ? true : false;
                _products.last.item = f.documentID;
              });
              return Column(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 65,
                            width: 260,
                            child: TextField(
                              autofocus: true,
                              maxLines: null,
                              controller: _dataController,
                              keyboardType: TextInputType.number,
                              onEditingComplete: () {
                                addProduct(_dataController.text);
                              },
                              onChanged: addProduct,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Enter Barcode",
                                  labelStyle: TextStyle(fontSize: 25.0)),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 65,
                            margin: EdgeInsets.only(left: 10),
                            child: Center(
                                child: InputDecorator(
                              child: Text(
                                "$total",
                                style: TextStyle(fontSize: 20),
                              ),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2, color: Colors.green),
                                  ),
                                  labelText: "Total",
                                  labelStyle: TextStyle(fontSize: 25.0)),
                            )),
                          )
                        ],
                      )),
                  Flexible(
                    flex: 5,
                    child: _products.isEmpty
                        ? Center(
                            child: path != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.shop,
                                        color: Colors.green[300],
                                        size: 60,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Add items in cart",
                                        style: TextStyle(fontSize: 25),
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text("Select CSV file"),
                                      RaisedButton(
                                        onPressed: () async {
                                          path = await FilePicker.getFilePath(
                                              type: FileType.ANY);
                                          getPath();
                                          setState(() {});
                                        },
                                        child: Text("SELECT"),
                                      ),
                                    ],
                                  ))
                        : ListView.builder(
                            itemBuilder: (context, i) {
                              return Dismissible(
                                key: Key(_products[i].name),
                                onDismissed: (direction) {
                                  _ref.document(_products[i].item).delete();
                                },
                                child: ProductView(
                                  product: _products[i],
                                  index: i + 1,
                                  documentReference:
                                      _ref.document(_products[i].item),
                                ),
                              );
                            },
                            itemCount: _products.length,
                          ),
                  ),
                ],
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Are u want to confirm"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("YES"),
                      onPressed: () {
                        // getPrintList();
                        // Printing.layoutPdf(onLayout: buildPdf);
                        _ref.getDocuments().then((snap) => snap.documents
                            .forEach((s) => s.reference.delete()));
                        Navigator.pop(context);
                        _dataController.clear();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "NO",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
          );
        },
      ),
    );
  }
}
