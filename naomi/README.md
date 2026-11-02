# Cannonball for SEGA NAOMI / NAOMI 2

Port of [dreamcast-cannonball](https://github.com/LimitZer0/dreamcast-cannonball)
(the CannonBall OutRun engine) to the SEGA NAOMI arcade board, loaded by
netboot onto a NetDIMM. Built with KallistiOS (`KOS_SUBARCH=naomi`).

Target cabinet: Crazy Taxi upright (NAOMI 2 multi-BIOS, NetDIMM 512 MB,
Raspberry Pi 3 netbooter), wheel + accelerator + brake + Drive/Reverse shifter.

## Build

Everything builds in GitHub Actions (`.github/workflows/naomi.yml`). The first
run builds the SH-4 toolchain (about an hour) and caches it; later runs take a
few minutes. Download the `naomi-bins` artifact from the run and copy the
`.bin` files to the netbooter.

No ROMs are stored in this repository. Never commit them.

## Plan

1. **JVS test** (`naomi/jvstest`): netboot, read wheel/pedals/shifter/START
   through the MIE (KOS `dc/maple/mie.h`), calibrate. Proves the whole chain.
2. **Cannonball boots**: NAOMI build of the game, ROMs and resources in a
   romdisk (`/rd/`) instead of `/cd/`; VMU, CD custom music and dcload paths
   disabled.
3. **Audio**: the Dreamcast build streams pre-rendered music (Yamaha ADPCM)
   from the CD. The NAOMI has no CD: first approach, smaller audio packed in
   the romdisk; later, stream from the NetDIMM (ROM board reads).
4. **Controls**: KOS maps the JVS wheel to `joyx` and the pedals to the
   triggers by default, the same as the Dreamcast pad. Map the shifter to
   high/low gear, START to start/coin.
5. **Saves**: hiscores/settings in the MIE EEPROM (128 bytes) or not at all.
