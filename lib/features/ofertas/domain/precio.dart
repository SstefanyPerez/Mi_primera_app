import 'package:mi_primera_app/core/json.dart';

/// Precio de lista y precio con descuento de una oferta.
///
/// Es un objeto de valor: dos precios con los mismos montos son el mismo
/// precio, así que no lleva `id` y se compara por contenido.
class Precio {
  const Precio({required this.original, required this.descuento})
    : assert(descuento > 0, 'el descuento debe ser mayor a cero'),
      assert(
        descuento < original,
        'el descuento debe ser menor al precio original',
      );

  factory Precio.fromJson(Map<String, dynamic> json) => Precio(
    original: leerDecimal(json, 'original'),
    descuento: leerDecimal(json, 'descuento'),
  );

  final double original;
  final double descuento;

  Map<String, dynamic> toJson() => {
    'original': original,
    'descuento': descuento,
  };

  double get ahorro => original - descuento;

  double get porcentajeDescuento => original == 0 ? 0 : ahorro / original;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Precio &&
          other.original == original &&
          other.descuento == descuento;

  @override
  int get hashCode => Object.hash(original, descuento);

  @override
  String toString() => 'Precio(original: $original, descuento: $descuento)';
}
