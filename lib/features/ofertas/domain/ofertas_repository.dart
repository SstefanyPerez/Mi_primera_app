import 'package:mi_primera_app/features/ofertas/domain/oferta.dart';

/// Lo que la aplicación necesita saber de las ofertas.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo. Es la declaración de intenciones más explícita que hay.
abstract interface class OfertasRepository {
  Future<List<Oferta>> obtenerTodas();

  Future<Oferta?> obtenerPorId(String id);
}
