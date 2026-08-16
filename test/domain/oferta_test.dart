import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/json.dart';
import 'package:mi_primera_app/features/ofertas/domain/estado_oferta.dart';
import 'package:mi_primera_app/features/ofertas/domain/oferta.dart';
import 'package:mi_primera_app/features/ofertas/domain/precio.dart';

Oferta ejemplo({EstadoOferta? estado, List<String>? fotos}) => Oferta(
  id: 'ofr-001',
  negocioId: 'neg-panaderia-san-jose',
  titulo: 'Combo de pan del día',
  descripcion: '8 panes variados que no se vendieron hoy.',
  precio: const Precio(original: 15000, descuento: 8000),
  estado:
      estado ??
      Publicada(
        cantidadDisponible: 3,
        publicadaEn: DateTime.utc(2026, 8, 15, 23, 30),
      ),
  fotos: fotos ?? const <String>[],
);

void main() {
  group('serialización', () {
    test('una oferta sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Reservada(
          reservadaPor: 'usr-077',
          codigoRetiro: 'R-3391',
          reservadaEn: DateTime.utc(2026, 8, 15, 23, 45),
        ),
        fotos: const ['https://ejemplo.co/f/pan1.jpg'],
      );

      // Pasa por TEXTO, no solo por Map: así también se prueba que las fechas
      // y las listas sobreviven a jsonEncode.
      final texto = jsonEncode(original.toJson());
      final vuelta = Oferta.fromJson(jsonDecode(texto) as Map<String, dynamic>);

      expect(vuelta, equals(original));
    });

    test('una oferta sin la clave fotos se lee con la lista vacía', () {
      final json = ejemplo().toJson()..remove('fotos');
      expect(Oferta.fromJson(json).fotos, isEmpty);
    });

    test('una oferta sin título dice QUÉ campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('titulo');

      expect(
        () => Oferta.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'titulo')),
      );
    });

    test('una fecha inválida dentro del estado se rechaza', () {
      final json = ejemplo().toJson();
      (json['estado'] as Map<String, dynamic>)['publicadaEn'] = '15 de agosto';

      expect(() => Oferta.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['estado']['publicadaEn'], '2026-08-15T23:30:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos ofertas con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos ofertas con los mismos datos comparten hashCode', () {
      // Sin esto, meterlas en un Set daría dos elementos donde debería haber uno.
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos ofertas con fotos distintas NO son iguales', () {
      expect(
        ejemplo(fotos: const ['a']),
        isNot(equals(ejemplo(fotos: const ['b']))),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(titulo: 'Otro título');

      expect(copia.titulo, 'Otro título');
      expect(copia.id, original.id);
      expect(copia.negocioId, original.negocioId);
    });
  });

  group('reglas de negocio', () {
    test('una oferta publicada con cupo se puede reservar', () {
      expect(ejemplo().sePuedeReservar, isTrue);
    });

    test('una oferta reservada no se puede volver a reservar', () {
      final oferta = ejemplo(
        estado: Reservada(
          reservadaPor: 'usr-077',
          codigoRetiro: 'R-3391',
          reservadaEn: DateTime.utc(2026, 8, 15),
        ),
      );
      expect(oferta.sePuedeReservar, isFalse);
    });

    test('una oferta publicada hace más de 12 horas debe vencer', () {
      final oferta = ejemplo(
        estado: Publicada(
          cantidadDisponible: 2,
          publicadaEn: DateTime.utc(2026, 8, 15, 8),
        ),
      );
      final ahora = DateTime.utc(2026, 8, 15, 21); // 13 horas después
      expect(oferta.debeVencer(ahora), isTrue);
    });
  });
}
