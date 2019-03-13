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
  List<Product> _products = <Product>[];
  @override
  void initState() {
    super.initState();
    _dataController = TextEditingController();
  }

  @override
  void dispose() {
    _dataController?.dispose();
    super.dispose();
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
    if (code.contains("\n")) {
      _dataController.clear();
      return;
    }
    int mycode = int.parse(code);
    Product product = check(mycode);
    if (product != null) {
      _products.add(product);
    }
    setState(() {});
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
              padding: const EdgeInsets.all(5),
              child: Container(
                height: 65,
                child: TextField(
                  autofocus: true,
                  maxLines: null,
                  controller: _dataController,
                  keyboardType: TextInputType.number,
                  onEditingComplete: () {
                    addProduct(_dataController.text);
                    print("Hello2");
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
                );
              },
              itemCount: _products.length,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () => addProduct(_dataController.text),
      ),
    );
  }
}
