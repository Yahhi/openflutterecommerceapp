import 'package:openflutterecommerce/config/theme.dart';
import 'package:openflutterecommerce/data/abstract/category_repository.dart';
import 'package:openflutterecommerce/data/abstract/model/category.dart';
import 'package:openflutterecommerce/data/abstract/model/commerce_image.dart';
import 'package:openflutterecommerce/data/abstract/model/filter_rules.dart';
import 'package:openflutterecommerce/data/abstract/model/product.dart';
import 'package:openflutterecommerce/data/abstract/model/product_attribute.dart';
import 'package:openflutterecommerce/data/abstract/model/sort_rules.dart';
import 'package:openflutterecommerce/data/abstract/product_repository.dart';
import 'package:openflutterecommerce/domain/entities/extensions.dart';
import 'package:openflutterecommerce/domain/entities/product_attribute.dart';
import 'package:openflutterecommerce/domain/entities/query_utils.dart';
import 'package:openflutterecommerce/domain/local_database.dart';

class ProductLocalRepository implements ProductRepository, CategoryRepository {
  final LocalDatabase localDatabase;

  ProductLocalRepository(this.localDatabase);

  @override
  Future<Product> getProduct(int id) async {
    final result = await localDatabase.database
        .query('product', where: 'id = ?', whereArgs: [id]);
    if (result != null && result.isNotEmpty) {
      final List<CommerceImage> images = await _getImagesOfProduct(id);
      final properties = await _getProductProperties(id);
      final selectableAttributes = await _getSelectableAttributes(id);
      return LocalProduct.fromMap(
          result.first, images, properties, selectableAttributes);
    } else {
      return null;
    }
  }

  Future<List<CommerceImage>> _getImagesOfProduct(int id) async {
    final result = await localDatabase.database
        .query('commerceImage', where: 'productId = ?', whereArgs: [id]);
    if (result != null && result.isNotEmpty) {
      return result
          .map((resultItem) => LocalCommerceImage.fromMap(resultItem))
          .toList(growable: false);
    } else {
      return [CommerceImage.placeHolder()];
    }
  }

  Future<List<ProductAttribute>> _getSelectableAttributes(int productId) async {
    final result = await localDatabase.database
        .rawQuery(LocalProductAttribute.query_for_product_by_id, [productId]);
    if (result != null && result.isNotEmpty) {
      return result
          .fold(
              <List<Map<String, dynamic>>>[],
              (list, mapItem) => list.last == null ||
                      list.last['attributeId'] != mapItem['attributeId']
                  ? list.add([mapItem])
                  : list.last.add(mapItem))
          .map((subList) => LocalProductAttribute.fromMap(subList))
          .toList(growable: false);
    } else {
      return [];
    }
  }

  Future<Map<String, String>> _getProductProperties(int id) async {
    final result = await localDatabase.database
        .query('productProperty', where: 'productId=?', whereArgs: [id]);
    if (result != null && result.isNotEmpty) {
      return Map.fromEntries(result.map((resultItem) =>
          MapEntry(resultItem['propertyName'], resultItem['propertyValue'])));
    } else {
      return {};
    }
  }

  @override
  Future<List<Product>> getSimilarProducts(int categoryId,
      {int pageIndex = 0, int pageSize = AppConsts.page_size}) {
    // TODO: implement getSimilarProducts
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProducts(
      {int pageIndex = 0,
      int pageSize = AppConsts.page_size,
      int categoryId = 0,
      SortRules sortRules = const SortRules(),
      FilterRules filterRules}) async {
    final String whereFilter =
        QueryUtils.formWherePart(categoryId, false, filterRules);
    final String order = QueryUtils.formOrderPart(sortRules);

    final List<Map<String, dynamic>> queryResult =
        await localDatabase.database.rawQuery('''
SELECT a.id AS id, 
  a.title AS title, 
  a.shortDescription AS shortDescription, 
  a.description AS description, 
  a.isFavorite AS isFavorite, 
  a.price AS price, 
  a.discountPercent AS discountPercent, 
  a.amountAvailable AS amountAvailable, 
  a.created AS created, 
  a.averageRating AS averageRating, 
  a.ratingCount AS ratingCount, 
  b.address AS address, 
  b.altText AS altText, 
  b.isLocal AS isLocal 
FROM 
  (
    SELECT * 
    FROM product 
    $whereFilter 
    $order 
    LIMIT ${pageIndex * pageSize}, $pageSize
  ) AS a 
  LEFT JOIN 
  (
    SELECT * 
    FROM commerceImage 
    WHERE product.id = commerceImage.productId 
    LIMIT 1
  ) AS b 
  ON a.id = b.productId
        ''');
    return queryResult
        .map((productInMap) => LocalProduct.fromMap(productInMap,
            [LocalCommerceImage.fromMap(productInMap)], null, null))
        .toList(growable: false);
  }

  @override
  Future<FilterRules> getPossibleFilterOptions(int categoryId) async {
    return FilterRules(
        categories: Map.fromIterable(
            await getCategories(parentCategoryId: categoryId),
            value: (_) => false),
        selectedPriceRange: await _getPricesForCategory(categoryId),
        selectedAttributes: await _getPossibleOptions(categoryId));
  }

  Future<Map<ProductAttribute, List<String>>> _getPossibleOptions(
      int categoryId) async {
    return Map.fromIterable(
        await _getPossibleAttributesInCategory(categoryId) +
            await _getPossiblePropertiesInCategory(categoryId),
        value: (_) => <String>[]);
  }

  Future<List<ProductAttribute>> _getPossibleAttributesInCategory(
      int categoryId) async {}

  Future<List<ProductAttribute>> _getPossiblePropertiesInCategory(
      int categoryId) async {}

  Future<PriceRange> _getPricesForCategory(int categoryId) async {
    final queryResult = await localDatabase.database.rawQuery('''
SELECT 
  MIN(product.price) AS minPrice,
  MAX(product.price) AS maxPrice
FROM 
  product 
  INNER JOIN 
  (
    SELECT * 
    FROM productCategoryLink 
    WHERE categoryId = $categoryId
  ) 
  ON product.id = productCategoryLink.productId
        ''');
    return queryResult.isEmpty
        ? null
        : PriceRange(
            queryResult.first['minPrice'], queryResult.first['maxPrice']);
  }

  @override
  Future<List<Category>> getCategories({int parentCategoryId = 0}) async {
    final queryResult = await localDatabase.database.query('category',
        where: 'parentId = ?', whereArgs: [parentCategoryId]);
    return queryResult
        .map((map) => LocalCategory.fromMap(map))
        .toList(growable: false);
  }

  @override
  Future<Category> getCategoryDetails(int categoryId) async {
    final queryResult = await localDatabase.database
        .query('category', where: 'id = ?', whereArgs: [categoryId]);
    return queryResult == null
        ? null
        : LocalCategory.fromMap(queryResult.first);
  }
}
