import 'package:openflutterecommerce/data/abstract/model/category.dart';
import 'package:openflutterecommerce/data/abstract/model/commerce_image.dart';

class LocalCategory extends Category {
  static const create_sql = 'CREATE TABLE category ('
      'id INTEGER PRIMARY KEY, '
      'name TEXT, '
      'description TEXT, '
      'parentId INTEGER, '
      'isCategoryContainer INTEGER, '
      'imageAddress: TEXT, '
      'hasLocalImage: INTEGER)';
  static const create_product_category_link =
      'CREATE TABLE productCategoryLink ('
      'id INTEGER PRIMARY KEY, '
      'categoryId INTEGER, '
      'productId INTEGER)';

  LocalCategory.fromMap(Map<String, dynamic> map)
      : super(map['id'],
            name: map['name'],
            parentId: map['parentId'],
            description: map['description'],
            isCategoryContainer: map['isCategoryContainer'] > 0,
            image: map['imageAddress'] == null
                ? CommerceImage.placeHolder()
                : CommerceImage(
                    map['imageAddress'],
                    '',
                    isLocal: map['hasLocalImage'] > 0,
                  ));

  Map<String, dynamic> toMap() => {
        'id': id,
        'parentId': parentId,
        'name': name,
        'description': description,
        'isCategoryContainer': isCategoryContainer ? 1 : 0,
        'imageAddress': image.address,
        'hasLocalImage': image.isLocal,
      };

  LocalCategory.fromJson(Map<String, dynamic> map)
      : super(
          map['id'],
          name: map['name'],
          parentId: 0,
          isCategoryContainer: false,
        );
}
