import 'package:equatable/equatable.dart';
import 'package:openflutterecommerce/data/abstract/model/product_attribute.dart';

import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final Map<ProductAttribute, MapEntry<String, double>> selectedAttributes;
  final int quantity;

  double get price =>
      quantity * product.price +
      selectedAttributes.values
          .fold(0.0, (sum, mapEntry) => sum += mapEntry.value);

  CartItem({
    this.product,
    this.quantity,
    this.selectedAttributes,
  });

  @override
  List<Object> get props => [product, selectedAttributes, quantity];
}
