import 'package:openflutterecommerce/data/abstract/model/product_attribute.dart';

class LocalProductAttribute extends ProductAttribute {
  static const create_sql = 'CREATE TABLE productAttribute ('
      'id INTEGER PRIMARY KEY AUYOINCREMENT, '
      'name TEXT, '
      'info TEXT)';

  static const create_many_to_many = 'CREATE TABLE productAttributeLink ('
      'id INTEGER PRIMARY KEY, '
      'productId INTEGER, '
      'attributeId INTEGER, '
      'textValue TEXT, '
      'priceChange FLOAT)';

  LocalProductAttribute.fromMap(List<Map<String, dynamic>> options)
      : super(
          id: options.first['id'],
          name: options.first['name'],
          info: options.first['info'],
          optionsWithPriceChanges: Map.fromEntries(options
              .map((map) => MapEntry(map['textValue'], map['priceChange']))),
        );
  static const query_for_product_by_id = '''
SELECT 
  a.attributeId AS id, 
  a.textValue AS textValue, 
  a.priceChange AS priceChange,
  b.name AS name, 
  b.info AS info 
FROM 
  (
    SELECT 
      attributeId, 
      textValue 
    FROM productAttributeLink 
    WHERE productId=?
  ) AS a 
  LEFT JOIN productAttribute AS b 
  ON a.attributeId = b.id 
ORDER BY a.attributeId
''';

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'info': info,
      };

  List<Map<String, dynamic>> toProductLinkMap(int productId) =>
      optionsWithPriceChanges.entries
          .map((value) => {
                'product_id': productId,
                'attributeId': id,
                'textValue': value.key,
                'priceChange': value.value,
              })
          .toList(growable: false);
}
