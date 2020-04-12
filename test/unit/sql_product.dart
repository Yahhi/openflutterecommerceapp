import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:openflutterecommerce/data/abstract/model/product_attribute.dart';
import 'package:openflutterecommerce/domain/entities/extensions.dart';

main() {
  test('product with variants is loaded from json successfully', () {
    final json = '''
{
  "id": 1,
  "image": "https://тайфун-суши.рф/image/cache/catalog/menu/rolls/klassika_new-500x500.jpg",
  "name": "Классические роллы",
  "description": "КЛАССИЧЕСКИЕ РОЛЛЫ В ЛУЧШИХ ТРАДИЦИЯХ ЯПОНСКОЙ КУХНИ",
  "price": 119.0,
  "final_price": 101.0,
  "weight": 105,
  "additionals": [
    {
      "ingredient": "Сливочный сыр",
      "price": 19.0
    }
  ],
  "options": [
    {"ingredient": "С лососем"},
    {"ingredient": "С тунцом"},
    {"ingredient": "С копченой курицей"},
    {"ingredient": "С креветками"},
    {"ingredient": "С угрем"},
    {"ingredient": "С огурцом, кунжутом", "price": -34.0},
    {"ingredient": "С авокадо, кунжутом", "price": -34.0}
  ]
}''';
    final product = LocalProduct.fromJson(jsonDecode(json));
    expect(product.id, equals(1));
    expect(product.images.length, equals(1));
    expect(product.mainImage.isLocal, equals(false));
    expect(
        product.mainImage.address,
        equals(
            'https://тайфун-суши.рф/image/cache/catalog/menu/rolls/klassika_new-500x500.jpg'));
    expect(product.title, equals('Классические роллы'));
    expect(product.shortDescription,
        equals('КЛАССИЧЕСКИЕ РОЛЛЫ В ЛУЧШИХ ТРАДИЦИЯХ ЯПОНСКОЙ КУХНИ'));
    expect(product.price, equals(119.0));
    expect(product.discountPrice, equals(101.0));
    expect(product.properties.length, equals(1));
    expect(product.properties.entries.first.key, equals('вес'));
    expect(product.properties.entries.first.value, equals(105));
    expect(product.selectableAttributes.length, equals(2));
    final attributeVariant = FoodVariant({
      'С лососем': 0.0,
      'С тунцом': 0.0,
      'С копченой курицей': 0.0,
      'С креветками': 0.0,
      'С угрем': 0.0,
      'С огурцом, кунжутом': -34.0,
      'С авокадо, кунжутом': -34.0
    });
    final attrbuteAdditional = AdditionalIngredient('Сливочный сыр', 19.0);
    if (product.selectableAttributes[0].id == FoodVariant.ID) {
      expect(product.selectableAttributes[0] is FoodVariant, equals(true));
      checkAttribute(product.selectableAttributes[0], attributeVariant);
      expect(product.selectableAttributes[1] is AdditionalIngredient,
          equals(true));
      checkAttribute(product.selectableAttributes[1], attrbuteAdditional);
    } else {
      expect(product.selectableAttributes[1] is FoodVariant, equals(true));
      checkAttribute(product.selectableAttributes[1], attributeVariant);
      expect(product.selectableAttributes[0] is AdditionalIngredient,
          equals(true));
      checkAttribute(product.selectableAttributes[0], attrbuteAdditional);
    }
  });

  test('product with content description is loaded successfully', () {
    final json = '''
	{
	    "id": 2,
	    "image": "https://тайфун-суши.рф/image/cache/catalog/menu/rolls/roninew-500x500.jpg",
	    "name": "Рони",
	    "content": ["ЛОСОСЬ", "СЫР СЛИВОЧНЫЙ", "ЧИПСЫ"],
	    "price": 189.0,
	    "final_price": 161.0,
	    "weight": 210
	}
    ''';
    final product = LocalProduct.fromJson(jsonDecode(json));
    expect(product.id, equals(2));
    expect(product.images.length, equals(1));
    expect(product.mainImage.isLocal, equals(false));
    expect(
        product.mainImage.address,
        equals(
            'https://тайфун-суши.рф/image/cache/catalog/menu/rolls/roninew-500x500.jpg'));
    expect(product.title, equals('Рони'));
    expect(product.price, equals(189.0));
    expect(product.discountPrice, equals(161.0));
    expect(product.properties.length, equals(4));
    expect(
        product.properties,
        equals({
          'вес': 210,
          'ЛОСОСЬ': true,
          'СЫР СЛИВОЧНЫЙ': true,
          'ЧИПСЫ': true
        }));
    expect(product.selectableAttributes.length, equals(0));
  });
}

void checkAttribute(ProductAttribute a1, ProductAttribute a2) {
  expect(a1.id, equals(a2.id));
  expect(a1.name, equals(a2.name));
  expect(a1.info, equals(a2.info));
  expect(a1.optionsWithPriceChanges, equals(a2.optionsWithPriceChanges));
}
