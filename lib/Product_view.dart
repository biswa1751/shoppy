import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';

class ProductView extends StatefulWidget {
  final Product product;
  final int index;

  const ProductView({Key key, this.product,this.index}) : super(key: key);
  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  int get index=>widget.index;
  TextEditingController _qtyController, _priceController, _totalController;
  Product get product => widget.product;
  StreamSubscription<DocumentSnapshot> data;
   DocumentReference _documentReference ;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
    _priceController = TextEditingController();
    _totalController = TextEditingController();

    // _documentReference.snapshots().listen((snapshot) {
    //   if (snapshot.exists) {
    //     setState(() {
    //       _priceController.text = snapshot.data['price'];
    //       _qtyController.text=snapshot.data['qty'];
    //     });
    //   }
    // });
  }

  void updateTotal(String val) {
    _totalController.text =
        (int.parse(_qtyController.text) * double.parse(_priceController.text))
            .toString();
          updateData();
  }

  void fetchData() {
    _documentReference.get().then((snapshot) {
      print("my snapshot =${snapshot.data}");
      if (snapshot.exists) {
           print("my snapshot2 =${snapshot.data}");
         _priceController.text = snapshot.data['price'];
          _qtyController.text=snapshot.data['qty'];
      }
    });
      _totalController.text =
        (int.parse(_qtyController.text) * double.parse(_priceController.text))
            .toString();
  }
  void updateData() {
    Map<String, String> data = <String, String>{"qty": _qtyController.text, "price": _priceController.text};
    _documentReference.updateData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print("Error :$e"));
  }

  @override
  void dispose() {
    data?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _priceController.text = product.price.toString();
    _qtyController.text = product.qty.toString();
    _documentReference =
      Firestore.instance.document("Products/Item$index");
      fetchData();
          _totalController.text = (product.qty * product.price).toString();
    return Card(
      child: SizedBox(
        height: 90,
        child: ListTile(
          onTap: fetchData,
          leading: Container(
            height: 35,
            width: 40,
            child: TextField(
              onChanged: updateTotal,
              controller: _qtyController,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.green[100]),
            ),
          ),
          title: Text(product.name),
          subtitle: Text("${product.mrp.toString()}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 16.0),
                height: 20,
                width: 80,
                child: TextField(
                  controller: _priceController,
                  onChanged: updateTotal,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      fillColor: Colors.green[100]),
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16.0),
                height: 20,
                width: 100,
                child: TextField(
                  controller: _totalController,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      fillColor: Colors.blue[100]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
