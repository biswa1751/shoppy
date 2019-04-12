class Product extends ProductData {
  String item;
  int qty;
  bool isDone;
  Product(
      {String name, double price, this.qty, double mrp, int barCode, this.item,this.isDone})
      : super(
          name: name,
          price: price,
          barCode: barCode,
          mrp: mrp,
        );
}

class ProductData {
  String name;
  double price;
  double mrp;
  int barCode;
  ProductData({
    this.name,
    this.price,
    this.mrp,
    this.barCode,
  });
  factory ProductData.fromJson(Map<String,dynamic> json){
    print(double.parse(json["PRICE"].toString()).runtimeType);
      return ProductData(
        barCode: json["BARCODE"].runtimeType==int?json["BARCODE"]:int.parse(json["BARCODE"]),
        mrp:double.parse(json["PRICE"].toString()),
        name: json["NAME"],
        price:double.parse(json["PRICE"].toString())
      );
  }
}
class ProductDataList{
  List<ProductData> list;
  ProductDataList({this.list});
  factory ProductDataList.fromJSOn(List<dynamic> json){
    List<ProductData> mylist=List<ProductData>();
    mylist=json.map((p)=>ProductData.fromJson(p)).toList();
    return new ProductDataList(
      list: mylist
    );
  }
}
