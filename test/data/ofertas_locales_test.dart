import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/json.dart';
import 'package:mi_primera_app/features/ofertas/data/ofertas_locales.dart';

const _json = '''
[
  {
    "id": "ofr-001",
    "negocioId": "neg-panaderia-san-jose",
    "titulo": "Combo de pan del día",
    "descripcion": "8 panes variados que no se vendieron hoy.",
    "precio": { "original": 15000, "descuento": 8000 },
    "estado": {
      "tipo": "publicada",
      "cantidadDisponible": 3,
      "publicadaEn": "2026-08-15T23:30:00Z"
    }
  },
  {
    "id": "ofr-002",
    "negocioId": "neg-carniceria-el-buen-corte",
    "titulo": "Bandeja de cortes surtidos",
    "descripcion": "Carne de res y cerdo, apta para hoy y mañana.",
    "precio": { "original": 45000, "descuento": 25000 },
    "estado": {
      "tipo": "reservada",
      "reservadaPor": "usr-077",
      "codigoRetiro": "R-3391",
      "reservadaEn": "2026-08-15T23:45:00Z"
    }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = OfertasLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodas()).length, 2);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = OfertasLocales(lector: (_) async => _json);

    expect(
      (await repo.obtenerPorId('ofr-001'))?.titulo,
      'Combo de pan del día',
    );
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = OfertasLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodas(), throwsA(isA<CampoInvalido>()));
  });

  test('obtenerDisponibles filtra las que ya no se pueden reservar', () async {
    final repo = OfertasLocales(lector: (_) async => _json);

    final disponibles = await repo.obtenerDisponibles();

    expect(disponibles.length, 1);
    expect(disponibles.single.id, 'ofr-001'); // la reservada queda afuera
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      // Esta SÍ toca el bundle: es la única que caza "olvidé el pubspec".
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = OfertasLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodas()).length, greaterThanOrEqualTo(3));
    },
  );
}
