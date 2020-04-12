import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:openflutterecommerce/domain/entities/category.dart';

main() {
  test('category is correctly taken from json', () {
    final json = '''
    {
        "id": 1,
        "name": "Роллы"
    }''';
    LocalCategory category = LocalCategory.fromJson(jsonDecode(json));
    expect(category.id, equals(1));
    expect(category.name, equals('Роллы'));
    expect(category.parentId, equals(0));
  });
}
