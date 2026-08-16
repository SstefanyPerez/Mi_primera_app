import 'package:mi_primera_app/core/json.dart';

/// En qué punto de su ciclo de vida está una oferta.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoOferta {
  const EstadoOferta();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoOferta.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'publicada' => Publicada(
        cantidadDisponible: leerEntero(json, 'cantidadDisponible'),
        publicadaEn: leerFecha(json, 'publicadaEn'),
      ),
      'reservada' => Reservada(
        reservadaPor: leerTexto(json, 'reservadaPor'),
        codigoRetiro: leerTexto(json, 'codigoRetiro'),
        reservadaEn: leerFecha(json, 'reservadaEn'),
      ),
      'recogida' => Recogida(recogidaEn: leerFecha(json, 'recogidaEn')),
      'vencida' => Vencida(venceEn: leerFecha(json, 'venceEn')),
      'cancelada' => Cancelada(motivo: leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    Publicada(:final cantidadDisponible, :final publicadaEn) => {
      'tipo': 'publicada',
      'cantidadDisponible': cantidadDisponible,
      'publicadaEn': publicadaEn.toIso8601String(),
    },
    Reservada(:final reservadaPor, :final codigoRetiro, :final reservadaEn) => {
      'tipo': 'reservada',
      'reservadaPor': reservadaPor,
      'codigoRetiro': codigoRetiro,
      'reservadaEn': reservadaEn.toIso8601String(),
    },
    Recogida(:final recogidaEn) => {
      'tipo': 'recogida',
      'recogidaEn': recogidaEn.toIso8601String(),
    },
    Vencida(:final venceEn) => {
      'tipo': 'vencida',
      'venceEn': venceEn.toIso8601String(),
    },
    Cancelada(:final motivo) => {'tipo': 'cancelada', 'motivo': motivo},
  };
}

final class Publicada extends EstadoOferta {
  const Publicada({
    required this.cantidadDisponible,
    required this.publicadaEn,
  });

  final int cantidadDisponible;
  final DateTime publicadaEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Publicada &&
          other.cantidadDisponible == cantidadDisponible &&
          other.publicadaEn == publicadaEn;

  @override
  int get hashCode => Object.hash(cantidadDisponible, publicadaEn);

  @override
  String toString() => 'Publicada($cantidadDisponible disponibles)';
}

final class Reservada extends EstadoOferta {
  const Reservada({
    required this.reservadaPor,
    required this.codigoRetiro,
    required this.reservadaEn,
  });

  final String reservadaPor;
  final String codigoRetiro;
  final DateTime reservadaEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reservada &&
          other.reservadaPor == reservadaPor &&
          other.codigoRetiro == codigoRetiro &&
          other.reservadaEn == reservadaEn;

  @override
  int get hashCode => Object.hash(reservadaPor, codigoRetiro, reservadaEn);

  @override
  String toString() => 'Reservada(por $reservadaPor, código $codigoRetiro)';
}

final class Recogida extends EstadoOferta {
  const Recogida({required this.recogidaEn});

  final DateTime recogidaEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recogida && other.recogidaEn == recogidaEn;

  @override
  int get hashCode => recogidaEn.hashCode;

  @override
  String toString() => 'Recogida($recogidaEn)';
}

final class Vencida extends EstadoOferta {
  const Vencida({required this.venceEn});

  final DateTime venceEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Vencida && other.venceEn == venceEn;

  @override
  int get hashCode => venceEn.hashCode;

  @override
  String toString() => 'Vencida($venceEn)';
}

final class Cancelada extends EstadoOferta {
  const Cancelada({required this.motivo})
    : assert(motivo != '', 'cancelar exige motivo');

  final String motivo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cancelada && other.motivo == motivo;

  @override
  int get hashCode => motivo.hashCode;

  @override
  String toString() => 'Cancelada: $motivo';
}

// ── Reglas de negocio: transiciones ─────────────────────────────────────

extension Transiciones on EstadoOferta {
  bool get sePuedeReservar => switch (this) {
    Publicada(:final cantidadDisponible) => cantidadDisponible > 0,
    Reservada() || Recogida() || Vencida() || Cancelada() => false,
  };

  bool get sePuedeCancelar => switch (this) {
    Publicada() || Reservada() => true,
    Recogida() || Vencida() || Cancelada() => false,
  };

  bool get estaFinalizada => switch (this) {
    Recogida() || Vencida() || Cancelada() => true,
    Publicada() || Reservada() => false,
  };
}
