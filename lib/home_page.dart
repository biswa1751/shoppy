import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/Product_view.dart';
import 'package:shoppy/data/product_data.dart';
import 'package:shoppy/model/product.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _dataController;
  int productIndex = 1;
  List<Product> _products = <Product>[];
  DocumentReference _documentReference;
  CollectionReference _ref = Firestore.instance.collection("Products");
  @override
  void initState() {
    super.initState();
    _dataController = TextEditingController();
    _ref.snapshots().listen((snap) {
      print("barcode :${snap.documents.last.data['barcode']}");
     if(existIndex(int.parse(snap.documents.last.data['barcode']))==null)
     {
        setState(() {
         _products.add(check(int.parse(snap.documents.last.data['barcode']))); 
        });
     }
    });
  }

  void addData(Product product, int index) {
    _documentReference = Firestore.instance.document("Products/Item$index");
    Map<String, String> data = <String, String>{
      "price": product.price.toString(),
      "qty": product.qty.toString(),
      "barcode":product.barCode.toString()
    };
    _documentReference.setData(data).whenComplete(() {
      print("Document $index Added");
    }).catchError((e) => print("Error :$e"));
  }

  void deleteData() {
    _products = <Product>[];
    for (int i = 1; i <= productIndex; i++) {
      _documentReference = Firestore.instance.document("Products/Item$i");
      _documentReference.delete().whenComplete(() {
        print("Document $i Deleted");
        setState(() {});
      }).catchError((e) => debugPrint("Error :$e"));
    }
    productIndex = 1;
  }

  int existIndex(int code) {
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].barCode == code) {
        return i;
      }
    }
    return null;
  }

  Product check(int code) {
    for (Product product in productData) {
      if (product.barCode == code) {
        return product;
      }
    }
    return null;
  }

  void addProduct(String code) {
    try {
      if (code.contains("\n")) {
        _dataController.clear();
        return;
      }
      int mycode = int.parse(code);
      int index = existIndex(mycode);
      if (index != null) {
        _products[index].qty++;
        addData(_products[index], index + 1);
        setState(() {});
        return;
      }
      Product product = check(mycode);
      if (product != null) {
        _products.add(product);
        addData(product, productIndex);
        productIndex++;
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
      backgroundColor: Colors.grey[300],
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                height: 65,
                child: TextField(
                  autofocus: true,
                  maxLines: null,
                  controller: _dataController,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    addProduct(_dataController.text);
                    print("Product added");
                    setState(() {});
                  },
                  onChanged: addProduct,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter Barcode",
                      labelStyle: TextStyle(fontSize: 25.0)),
                ),
              )),
          Flexible(
            flex: 5,
            child: ListView.builder(
              itemBuilder: (context, i) {
                return ProductView(
                  product: _products[i],
                  index: i + 1,
                  documentReference:
                      Firestore.instance.document("Products/Item${i + 1}"),
                );
              },
              itemCount: _products.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () => deleteData(),
      ),
    );
  }
}
