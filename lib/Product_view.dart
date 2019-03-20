import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';

class ProductView extends StatefulWidget {
  final Product product;
  final int index;
  final DocumentReference documentReference;

  const ProductView({Key key, this.product, this.index, this.documentReference})
      : super(key: key);
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
  }

  void updateTotal(String val) {
    try{
    _totalController.text =
        (int.parse(_qtyController.text) * double.parse(_priceController.text))
            .toString();
    updateData();}catch(e){}
  }

  void updateData() {
    Map<String, String> data = <String, String>{
      "qty": _qtyController.text,
      "price": _priceController.text,
      "barcode": product.barCode.toString()
    };
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
        if(snapshot.data.data != null)
        {
        print("snap: ${snapshot.data.data}");
        _priceController.text = snapshot.data.data['price'];
        _qtyController.text = snapshot.data.data['qty'];
        _totalController.text = (int.parse(_qtyController.text) *
                double.parse(_priceController.text))
            .toString();
        }
        return Card(
          child: SizedBox(
            height: 90,
            child: ListTile(
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
      },
    );
  }
}
