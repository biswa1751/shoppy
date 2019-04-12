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
}
