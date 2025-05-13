import 'package:price_pk/beans/unit_class.dart';
import 'package:price_pk/beans/volume_unit.dart';
import 'package:price_pk/beans/weight_unit.dart';

class InputBoxState {
  String name;
  double? price;
  UnitClass unit;
  late int id;

  static int _id = 0;

  UnitClass get prePrice => unit.prePrice(price);

  InputBoxState(
      {this.price = 0.0, required this.unit, this.name = "", int? id}) {
    this.id = id ?? ++_id;
  }

  /// Convert the InputBoxState to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'unit': unit.toJson(),
      'id': id,
    };
  }

  /// Create an InputBoxState from a JSON map
  factory InputBoxState.fromJson(Map<String, dynamic> json) {
    final unitData = json['unit'] as Map<String, dynamic>;
    final unitType = unitData['type'] as String;
    final unitValue = unitData['value'] as double;

    UnitClass unit;

    // Handle different unit types
    switch (unitType) {
      case 'Milligram':
        unit = Milligram(unitValue);
        break;
      case 'Gram':
        unit = Gram(unitValue);
        break;
      case 'Kilogram':
        unit = Kilogram(unitValue);
        break;
      case 'Ton':
        unit = Ton(unitValue);
        break;
      case 'Liter':
        unit = Liter(unitValue);
        break;
      case 'Milliliter':
        unit = Milliliter(unitValue);
        break;
      default:
        throw UnsupportedError('Unsupported unit type: $unitType');
    }

    return InputBoxState(
      name: json['name'] as String? ?? '',
      price: json['price'] as double?,
      unit: unit,
      id: json['id'] as int? ?? 0,
    );
  }

  InputBoxState copyWith(
      {double? price, UnitClass? unit, String? name, int? id}) {
    return InputBoxState(
      price: price ?? this.price,
      unit: unit ?? this.unit,
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }
}
