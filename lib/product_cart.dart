import 'model/product_model.dart';

class ProductCart {
  List<Product> products;
  PriceDetails? priceDetails;

  ProductCart() : products = [], priceDetails = PriceDetails();

  void addProduct(Product product) {
    int index = products.indexWhere((p) => p == product);
    if (index == -1) {
      product.quantity = 1;  // Reset quantity to default 1
      product.totalPrice = double.parse(product.price!);
      products.add(product);
    } else {
      products[index].quantity++;
      products[index].totalPrice += double.parse(product.price!);
    }
    priceCalculation();
  }

  void removeProduct(Product product) {
    int index = products.indexWhere((p) => p == product);
    if (index != -1) {
      products[index].quantity--;
      products[index].totalPrice -= double.parse(product.price!);
      if (products[index].quantity <= 0) {
        products.removeAt(index);
      }
      priceCalculation();
    }
  }

  void priceCalculation() {
    priceDetails!.subTotal = products.fold(0.0, (sum, p) => sum + p.totalPrice);
    priceDetails!.taxPercentage = "20";
    priceDetails!.tax = roundOffDecimal(priceDetails!.subTotal * 0.2);
    priceDetails!.parcelFee = 0.0;
    priceDetails!.total = priceDetails!.subTotal + priceDetails!.tax + priceDetails!.parcelFee + priceDetails!.serviceCharge;
  }

  double roundOffDecimal(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

class PriceDetails {
  double subTotal = 0.0;
  double tax = 0.0;
  double parcelFee = 0.0;
  double serviceCharge = 0.0;
  double total = 0.0;
  String message = "";
  String taxPercentage = "";
  String serviceChargePercentage = "";
  String parcelPercentage = "";
  String roundOff = "";
}
