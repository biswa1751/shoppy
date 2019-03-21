import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppy/Product_view.dart';
import 'package:shoppy/data/product_data.dart';
import 'package:shoppy/model/product.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as Pdf;
import 'package:printing/printing.dart';

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
  List<Pdf.TableRow> _list = <Pdf.TableRow>[];
  double total = 0;
  @override
  void initState() {
    super.initState();
    total=0;
    _dataController = TextEditingController();
    _ref.snapshots().listen((snap) {
      print("barcode :${snap.documents}");
      if (snap.documents.length == 0) {
        print("0 length");
        setState(() {
          _products = [];
        });
      } else if (existIndex(int.parse(snap.documents.last.data['barcode'])) ==
          null) {
        setState(() {
          _products.add(check(int.parse(snap.documents.last.data['barcode'])));
          calcTotal();
        });
      }
    });
  }

  List<int> buildPdf(PdfPageFormat format) {
    final PdfDoc pdf = PdfDoc()
      ..addPage(
        Pdf.Page(
          pageFormat: format,
          build: (Pdf.Context context) {
            return Pdf.Padding(
                padding: Pdf.EdgeInsets.all(50),
                child: Pdf.ConstrainedBox(
                  constraints: const Pdf.BoxConstraints.expand(),
                  child: Pdf.Table(
                      tableWidth: Pdf.TableWidth.max, children: _list),
                ));
          },
        ),
      );
    _list = <Pdf.TableRow>[];
    return pdf.save();
  }

  void addData(Product product, int index) {
    _documentReference = Firestore.instance.document("Products/Item$index");
    Map<String, String> data = <String, String>{
      "price": product.price.toString(),
      "qty": product.qty.toString(),
      "barcode": product.barCode.toString()
    };
    _documentReference.setData(data).whenComplete(() {
      print("Document $index Added");
    }).catchError((e) => print("Error :$e"));
  }

  void deleteData() {
    setState(() {
      _products = <Product>[];
    });
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
        calcTotal();
        addData(product, productIndex);
        productIndex++;
      }
      setState(() {});
    } catch (e) {}
  }

  @override
  void dispose() {
    _dataController?.dispose();
    deleteData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    calcTotal();
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Take Order'),
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
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
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 120,
                    height: 65,
                    child: Center(
                        child: InputDecorator(
                      child: Text(
                        "$total",
                        style: TextStyle(fontSize: 20),
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 2,color: Colors.green),
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
                    child: Column(
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
                    ),
                  )
                : ListView.builder(
                    itemBuilder: (context, i) {
                      return ProductView(
                        product: _products[i],
                        index: i + 1,
                        documentReference: Firestore.instance
                            .document("Products/Item${i + 1}"),
                      );
                    },
                    itemCount: _products.length,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () {
          getPrintList();
          Printing.layoutPdf(onLayout: buildPdf);
          deleteData();
        },
      ),
    );
  }
  void calcTotal(){
    total=0;
      _products.forEach((p) => total = total + (p.qty * p.price)); 
    setState(() {
    
    });
  }
  void getPrintList() {

    _list.add(Pdf.TableRow(children: [
      Pdf.Text("Name"),
      Pdf.Text("Qty"),
      Pdf.Text("Price"),
      Pdf.Text("Total")
    ]));

    _products.forEach((p) => _list.add(Pdf.TableRow(children: [
          Pdf.Text(p.name),
          Pdf.Text(p.qty.toString()),
          Pdf.Text(p.price.toString()),
          Pdf.Text((p.price * p.qty).toString()),
        ])));
    _list.add(Pdf.TableRow(children: [
      Pdf.Text(""),
      Pdf.Text(""),
      Pdf.Text("Total : "),
      Pdf.Text(total.toString()),
    ]));
        total = 0;
  }
}
