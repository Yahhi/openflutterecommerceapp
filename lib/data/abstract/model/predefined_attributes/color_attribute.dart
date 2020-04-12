import 'dart:ui';

import 'package:openflutterecommerce/data/abstract/model/product_attribute.dart';

class ColorAttribute extends ProductAttribute {
  final Map<String, Color> visibleColors;

  ColorAttribute({int id, String info, this.visibleColors})
      : super(
            id: id,
            name: 'Color',
            info: info,
            optionsWithPriceChanges:
                Map.fromIterable(visibleColors.keys, value: (_) => 0.0));
}
