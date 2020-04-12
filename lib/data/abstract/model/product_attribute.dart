import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class ProductAttribute extends Equatable {
  final int id;
  final String name;
  final Map<String, double> optionsWithPriceChanges;
  final String info;

  const ProductAttribute(
      {this.id, @required this.name, this.optionsWithPriceChanges, this.info});

  @override
  List<Object> get props => [id, name, optionsWithPriceChanges, info];
}
