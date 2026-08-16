import 'package:mi_primera_app/core/comparaciones.dart';
import 'package:mi_primera_app/core/json.dart';
import 'package:mi_primera_app/features/ofertas/domain/estado_oferta.dart';
import 'package:mi_primera_app/features/ofertas/domain/precio.dart';

/// Un lote de comida excedente que un negocio publica con descuento.
///
/// Es una entidad: tiene identidad propia. Dos ofertas con el mismo texto
/// son dos ofertas distintas si tienen `id` distinto.
class Oferta {
  const Oferta({
    required this.id,
    required this.negocioId,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.estado,
    this.fotos = const <String>[],
  });

  factory Oferta.fromJson(Map<String, dynamic> json) => Oferta(
    id: leerTexto(json, 'id'),
    negocioId: leerTexto(json, 'negocioId'),
    titulo: leerTexto(json, 'titulo'),
    descripcion: leerTexto(json, 'descripcion'),
    precio: Precio.fromJson(leerMapa(json, 'precio')),
    estado: EstadoOferta.fromJson(leerMapa(json, 'estado')),
    fotos: leerTextos(json, 'fotos'),
  );

  final String id;
  final String negocioId;
  final String titulo;
  final String descripcion;
  final Precio precio;
  final EstadoOferta estado;
  final List<String> fotos;

  Map<String, dynamic> toJson() => {
    'id': id,
    'negocioId': negocioId,
    'titulo': titulo,
    'descripcion': descripcion,
    'precio': precio.toJson(),
    'estado': estado.toJson(),
    'fotos': fotos,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────

  bool get sePuedeReservar => estado.sePuedeReservar;

  bool get sePuedeCancelar => estado.sePuedeCancelar;

  bool get estaFinalizada => estado.estaFinalizada;

  bool get tieneFotos => fotos.isNotEmpty;

  Duration tiempoDesdePublicada(DateTime ahora) {
    final actual = estado;
    if (actual is! Publicada) return Duration.zero;
    return ahora.difference(actual.publicadaEn);
  }

  bool debeVencer(DateTime ahora) =>
      estado is Publicada &&
      tiempoDesdePublicada(ahora) > const Duration(hours: 12);

  // ── Copia ──────────────────────────────────────────────────────────

  Oferta copyWith({
    String? titulo,
    String? descripcion,
    Precio? precio,
    EstadoOferta? estado,
    List<String>? fotos,
  }) => Oferta(
    id: id,
    negocioId: negocioId,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion ?? this.descripcion,
    precio: precio ?? this.precio,
    estado: estado ?? this.estado,
    fotos: fotos ?? this.fotos,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Oferta &&
          other.id == id &&
          other.negocioId == negocioId &&
          other.titulo == titulo &&
          other.descripcion == descripcion &&
          other.precio == precio &&
          other.estado == estado &&
          listasIguales(other.fotos, fotos);

  @override
  int get hashCode => Object.hash(
    id,
    negocioId,
    titulo,
    descripcion,
    precio,
    estado,
    Object.hashAll(fotos),
  );

  @override
  String toString() => 'Oferta($id, $titulo, ${estado.runtimeType})';
}
