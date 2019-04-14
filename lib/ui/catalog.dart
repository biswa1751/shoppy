import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';
import 'package:shoppy/ui/search_page.dart';

class CataLog extends StatefulWidget {
  final List<ProductData> productData;

  const CataLog({Key key, this.productData}) : super(key: key);
  @override
  _CataLogState createState() => _CataLogState();
}

class _CataLogState extends State<CataLog> {
  List<ProductData> get productData => widget.productData;

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
      body: GridView.count(
        crossAxisCount: 2,
        children: productData
            .map(
              (p) => Card(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(p.name),
                          Text(p.price.toString()),
                          Text(p.barCode.toString())
                        ],
                      ),
                    ),
                  ),
            )
            .toList(),
      ),
    );
  }
}
