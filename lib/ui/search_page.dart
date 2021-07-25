import 'package:flutter/material.dart';
import 'package:shoppy/model/product.dart';


class SearchPage extends SearchDelegate {
  final List<ProductData> productData;

  SearchPage(this.productData);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.close), onPressed: () => query = "")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: this.transitionAnimation,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.green,
        child: Container(
          height: 300,
          width: 300,
          child: Text(query),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestionList = query.isEmpty
        ? productData
        : productData.where((p) => p.name.contains(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].name),
          onTap: () {
            showResults(context);
          },
        );
      },
      itemCount: suggestionList.length,
    );
  }
}
