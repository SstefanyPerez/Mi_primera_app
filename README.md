# App de comida excedente — Valledupar

Conecta negocios de comida (panaderías, carnicerías, asaderos) que les
sobran productos al final del día con personas que quieren comprarlos a
menor precio antes de que dejen de estar frescos.

## El dominio

- `Oferta`         — entidad principal. Identidad: `id`.
- `Precio`         — objeto de valor: precio original y precio con descuento.
- `EstadoOferta`   — sellada: Publicada · Reservada · Recogida · Vencida · Cancelada.

Decisión: modelo escrito a mano en `Precio`, `EstadoOferta` y `Oferta`.

Se probó generar `Precio` y `Oferta` con freezed + json_serializable, pero la
versión instalada (freezed 4.0.0-dev.3, un prerelease) produjo tres fallos de
generación distintos: colisión de nombres con `fromJson` personalizado,
pérdida de conversión de objetos anidados a `Map` sin `explicitToJson`, y un
error de "Cannot populate the required constructor argument" al activarlo.
Ante un toolchain inestable y el cierre de la entrega, se priorizó la versión
manual: compila limpio, pasa las pruebas sin parches, y conserva el mensaje
`CampoInvalido` que identifica exactamente qué campo del JSON falló — algo
que la versión generada pierde.

## Cómo correrlo

    flutter pub get
    flutter test
    flutter run