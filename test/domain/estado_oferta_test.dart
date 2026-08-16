import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/json.dart';
import 'package:mi_primera_app/features/ofertas/domain/estado_oferta.dart';

void main() {
  group('transiciones', () {
    test('una oferta publicada con cupo se puede reservar', () {
      final estado = Publicada(
        cantidadDisponible: 2,
        publicadaEn: DateTime.utc(2026, 8, 15),
      );
      expect(estado.sePuedeReservar, isTrue);
    });

    test('una oferta publicada sin cupo NO se puede reservar', () {
      final estado = Publicada(
        cantidadDisponible: 0,
        publicadaEn: DateTime.utc(2026, 8, 15),
      );
      expect(estado.sePuedeReservar, isFalse);
    });

    test('una oferta reservada no se puede volver a reservar', () {
      final estado = Reservada(
        reservadaPor: 'usr-1',
        codigoRetiro: 'R-1',
        reservadaEn: DateTime.utc(2026, 8, 15),
      );
      expect(estado.sePuedeReservar, isFalse);
    });

    test('una oferta recogida no se puede cancelar', () {
      final estado = Recogida(recogidaEn: DateTime.utc(2026, 8, 15));
      expect(estado.sePuedeCancelar, isFalse);
    });

    test('una oferta vencida está finalizada', () {
      final estado = Vencida(venceEn: DateTime.utc(2026, 8, 15));
      expect(estado.estaFinalizada, isTrue);
    });

    test('cancelar sin motivo no se puede ni escribir', () {
      expect(() => Cancelada(motivo: ''), throwsA(isA<AssertionError>()));
    });
  });

  group('serialización', () {
    test('un estado Reservada sobrevive la ida y vuelta a JSON', () {
      final original = Reservada(
        reservadaPor: 'usr-1',
        codigoRetiro: 'R-1',
        reservadaEn: DateTime.utc(2026, 8, 15, 22, 10),
      );
      final texto = jsonEncode(original.toJson());
      final vuelta = EstadoOferta.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );
      expect(vuelta, equals(original));
    });

    test('un tipo de estado desconocido lanza CampoInvalido', () {
      expect(
        () => EstadoOferta.fromJson({'tipo': 'inventado'}),
        throwsA(
          isA<CampoInvalido>().having((e) => e.campo, 'campo', 'estado.tipo'),
        ),
      );
    });
  });
}
