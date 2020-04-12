import 'package:openflutterecommerce/data/abstract/model/commerce_image.dart';
import 'package:openflutterecommerce/data/abstract/model/product.dart';
import 'package:openflutterecommerce/data/abstract/model/product_attribute.dart';

class LocalProduct extends Product {
  static const create_sql = 'CREATE TABLE product ('
      'id INTEGER PRIMARY KEY, '
      'title TEXT, '
      'shortDescription TEXT, '
      'description TEXT, '
      'isFavorite INTEGER, '
      'price REAL, '
      'finalPrice REAL, '
      'discountPercent INTEGER, '
      'amountAvailable INTEGER, '
      'created INTEGER, '
      'averageRating REAL, '
      'ratingCount INTEGER)';
  static const create_properties_sql = 'CREATE TABLE productProperty ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'productId INTEGER, '
      'propertyName TEXT, '
      'propertyValue TEXT)';

  LocalProduct(
      {int id,
      String title,
      String shortDescription,
      double price,
      double finalPrice,
      List<CommerceImage> images,
      Map<String, dynamic> properties,
      List<ProductAttribute> selectableAttributes})
      : super(id,
            title: title,
            shortDescription: shortDescription,
            isFavorite: false,
            price: price,
            finalPrice: finalPrice,
            images: images,
            properties: properties,
            selectableAttributes: selectableAttributes);

  LocalProduct.fromMap(
      Map<String, dynamic> map,
      List<CommerceImage> images,
      Map<String, dynamic> properties,
      List<ProductAttribute> selectableAttributes)
      : super(map['id'],
            title: map['title'],
            shortDescription: map['shortDescription'],
            description: map['description'],
            isFavorite: map['isFavorite'] > 0,
            price: map['price'],
            discountPercent: map['discountPercent'],
            amountAvailable: map['amountAvailable'],
            created: DateTime.fromMillisecondsSinceEpoch(map['created']),
            averageRating: map['averageRating'],
            ratingCount: map['ratingCount'],
            images: images,
            properties: properties,
            selectableAttributes: selectableAttributes);

  factory LocalProduct.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> properties = {};
    if (map.containsKey('content')) {
      properties.addAll(Map<String, dynamic>.fromEntries(
          (map['content'] as List).map((item) => MapEntry(item, true))));
    }
    properties['вес'] = map['weight'];

    final List<ProductAttribute> attributes = [];
    if (map.containsKey('additionals')) {
      map['additionals']
          .map((map) => AdditionalIngredient(map['ingredient'], map['price']))
          .forEach((item) => attributes.add(item));
    }
    if (map.containsKey('options')) {
      attributes.add(FoodVariant.fromJson(map['options']));
    }

    return LocalProduct(
        id: map['id'],
        title: map['name'],
        shortDescription: map['description'],
        price: map['price'],
        finalPrice: map['final_price'],
        images: [CommerceImage.remote(map['image'])],
        properties: properties,
        selectableAttributes: attributes);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'shortDescription': shortDescription,
        'description': description,
        'isFavorite': isFavorite ? 1 : 0,
        'price': price,
        'discountPercent': discountPercent,
        'amountAvailable': amountAvailable,
        'created': created.millisecondsSinceEpoch,
        'averageRating': averageRating,
        'ratingCount': ratingCount,
      };
}

class AdditionalIngredient extends ProductAttribute {
  static const ID = 1;
  AdditionalIngredient(String ingredient, double priceChange)
      : super(
            id: ID,
            name: 'Дополнительный ингредиент',
            info: 'Добавьте ингредиенты, чтобы сделать блюдо особенным',
            optionsWithPriceChanges: {
              'Без дополнений': 0.0,
              ingredient: priceChange ?? 0.0
            });
}

class FoodVariant extends ProductAttribute {
  static const ID = 2;
  FoodVariant(Map<String, double> variants)
      : super(
            id: ID,
            name: 'Вариант приготовления',
            info: '',
            optionsWithPriceChanges: variants);

  factory FoodVariant.fromJson(List variants) {
    Map<String, double> resultMap = Map.fromEntries(variants
        .map((map) => MapEntry(map['ingredient'], map['price'] ?? 0.0)));
    return FoodVariant(resultMap);
  }
}
