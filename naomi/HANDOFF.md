# HANDOFF — Cannonball (OutRun) en NAOMI

Documento de traspaso entre sesiones (personas o IAs). **Actualízalo en cada sesión.**
Para compilar y empaquetar, ver [README.md](README.md).

## Estado (2026-11-04)

- **Funciona en la placa real** (NAOMI 2, NetDIMM 512 MB, mueble Crazy Taxi): arranca directo al juego,
  controles calibrados, música original grabada y efectos FM servidos desde la NetDIMM, ajustes y
  récords en la SRAM con batería.
- Compila en GitHub Actions (`.github/workflows/naomi.yml`, KallistiOS `d81aa3f`); la release
  `naomi-latest` incluye el SDK (`kos-naomi-sdk.tar.zst`) para compilar en local.
- Último cambio: sin textos fijos en las pantallas de demo; nuevos valores por defecto.

## Arquitectura

| Parte | Dónde | Detalle |
|---|---|---|
| Plataforma | `cmake/dreamcast.cmake`, `__NAOMI__` | Build de Dreamcast con `KOS_SUBARCH=naomi` |
| ROMs y recursos | `naomi/make_romdisk.sh` → romdisk en `/rd/` | No hay CD; se enlaza en el programa |
| Música/efectos | `naomi/render_audio.sh`, `naomi/pack_bin.py`, `src/main/naomi/dimmfs.c` | Grabados de las ROMs del usuario en ADPCM Yamaha, añadidos al final de la imagen netboot y leídos bajo demanda desde la NetDIMM por el puerto de cartucho (`/dimm`) |
| Música extra | `dimm/music/extra/*.wav` + `tracks.txt` | Pantalla de selección de música; nivelar a ~-17,5 LUFS |
| Controles | `src/main/sdl2/input.cpp` (`poll_naomi`) | Driver MIE de KOS: volante → `joyx`, acelerador → `rtrig`, freno → `ltrig` |
| Guardado | SRAM con batería | Ajustes y récords |
| Stubs | `src/main/naomi/naomi_stubs.c` | Flashrom, VMU, etc. |
| Prueba JVS | `naomi/jvstest/` | Programa para leer y calibrar los controles del mueble |

## Controles

| Control | Función |
|---|---|
| Volante | Dirección (y izquierda/derecha en menús) |
| Acelerador / freno | Pedales analógicos |
| Palanca adelante / atrás | Marcha corta / larga (arriba/abajo en menús) |
| START | Empezar / seleccionar / pausa; actúa al **soltarlo**, así que funciona aunque el acelerador esté pisado (la luz parpadea en el título) |
| **Freno + START** | Menú principal (también TEST del panel de servicio) |
| START mantenido + R (palanca atrás) | Cambiar la cámara (con START pulsado la palanca no cambia de marcha) |

Calibración (valores JVS medidos en el mueble, 2026-11-02; se amplían solos si un control llega más lejos):
volante 8448 / 33792 / 60160, acelerador 11776–47104, freno 14080–47360, margen de pedales 6 %.

## Notas y trampas

- **WiPi Netbooter:** subir siempre `.bin.gz`; con `.bin` sin comprimir falla (lee los últimos 4 bytes
  como tamaño gzip).
- La imagen netboot contiene las ROMs y grabaciones del usuario: **no publicarla**.
- La VRAM real no admite escrituras de byte (Flycast sí). La DMA del PVR se cuelga en NAOMI.
- Revertido: "scanlines como un único quad + L/H + START para menú/vista" (`331325f`).

## Pendiente / ideas

1. **Unificar combinaciones con los otros ports:** en `mame4all-naomi`, freno + START = meter crédito;
   aquí freno + START = menú. Decidir un estándar común para todos los juegos del mueble.
2. Revisar `NEXT_TASK.md` (optimización heredada del port de Dreamcast: tabla de zoom horizontal de sprites).
