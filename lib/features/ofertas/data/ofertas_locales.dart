import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mi_primera_app/core/json.dart';
import 'package:mi_primera_app/features/ofertas/domain/oferta.dart';
import 'package:mi_primera_app/features/ofertas/domain/ofertas_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class OfertasLocales implements OfertasRepository {
  /// El lector entra por el constructor. En producción es `rootBundle`; en las
  /// pruebas, una función que devuelve una cadena. Esa costura de dos líneas
  /// es lo que hace que las pruebas no necesiten ni Flutter ni el bundle.
  OfertasLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/ofertas.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  /// El archivo no cambia mientras la app corre: leerlo y parsearlo en cada
  /// pantalla sería tirar trabajo a la basura.
  List<Oferta>? _cache;

  @override
  Future<List<Oferta>> obtenerTodas() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => Oferta.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Oferta?> obtenerPorId(String id) async {
    // firstWhere sin orElse lanza `Bad state: No element` cuando no encuentra.
    // Un bucle explícito devuelve null y se lee mejor que el orElse con truco.
    for (final oferta in await obtenerTodas()) {
      if (oferta.id == id) return oferta;
    }
    return null;
  }

  /// Propio de este dominio: solo las que un usuario todavía puede reservar.
  /// Es lo que va a llenar la pantalla principal de la app.
  Future<List<Oferta>> obtenerDisponibles() async {
    final todas = await obtenerTodas();
    return todas
        .where((oferta) => oferta.sePuedeReservar)
        .toList(growable: false);
  }
}
