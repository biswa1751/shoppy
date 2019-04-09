import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';

class ProductView extends StatefulWidget {
  final Product product;
  final int index;
  final DocumentReference documentReference;
  const ProductView({
    Key key,
    this.product,
    this.index,
    this.documentReference,
  }) : super(key: key);
  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  int get index => widget.index;
  TextEditingController _qtyController, _priceController, _totalController;
  Product get product => widget.product;
  DocumentReference get _documentReference => widget.documentReference;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
    _priceController = TextEditingController();
    _totalController = TextEditingController();
    _documentReference.snapshots().listen((d){
      print("test :${d.data}");
    });
  }

  void updateTotal([String val]) {
    try {
      _totalController.text =
          (int.parse(_qtyController.text) * double.parse(_priceController.text))
              .toString();
      updateData();
    } catch (e) {}
  }

  void updateData() {
    Map<String, String> data = <String, String>{
      "qty": _qtyController.text,
      "price": _priceController.text,
      "barcode": product.barCode.toString()
    };
    product.qty = int.parse(_qtyController.text);
    product.price = double.parse(_priceController.text);
    _documentReference.updateData(data).whenComplete(() {
      print("Document $index Updated");
    }).catchError((e) => print("Error :$e"));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _documentReference.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        if (snapshot.data.data != null) {
          print("snap: ${snapshot.data.data}");
          _priceController.value = TextEditingValue(text:snapshot.data.data['price'],selection: TextSelection.collapsed(offset: snapshot.data.data['price'].length));
          _qtyController.value = TextEditingValue(text:snapshot.data.data['qty'],selection: TextSelection.collapsed(offset: snapshot.data.data['qty'].length));
          _totalController.text = (int.parse(_qtyController.text) *
                  double.parse(_priceController.text))
              .toString();
          product.qty = int.parse(_qtyController.text);
          product.price = double.parse(_priceController.text);
        }
        return Card(
          child: SizedBox(
            height: 75,
            child: ListTile(
              leading: Container(
                height: 42,
                width: 45,
                child: TextField(
                  autofocus: true,
                  onChanged: updateTotal,
                  controller: _qtyController,
                  onEditingComplete: updateTotal,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
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
                    height: 43,
                    width: 80,
                    child: TextField(
                      controller: _priceController,
                      onSubmitted: updateTotal,
                      autofocus: true,
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
                    height: 43,
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
      },
    );
  }
}
