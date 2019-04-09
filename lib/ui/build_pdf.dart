import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as Pdf;
import 'package:printing/printing.dart';
import 'package:shoppy/model/product.dart';

List<Pdf.TableRow> _list = <Pdf.TableRow>[];
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
                child:
                    Pdf.Table(tableWidth: Pdf.TableWidth.max, children: _list),
              ));
        },
      ),
    );
  _list = <Pdf.TableRow>[];
  return pdf.save();
}

void getPrintList(List<Product> _products, double total) {
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
