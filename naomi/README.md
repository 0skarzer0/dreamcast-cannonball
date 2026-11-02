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

### The game, with your ROMs (local build)

The `naomi-latest` release also holds `kos-naomi-sdk.tar.zst`: the SH-4
toolchain, KallistiOS for NAOMI, GLdc and SDL2, built by the workflow.

```sh
sudo mkdir -p /opt/toolchains/dc && sudo chown $USER /opt/toolchains/dc
tar -C /opt/toolchains/dc -I zstd -xf kos-naomi-sdk.tar.zst
source naomi/env.sh
naomi/make_romdisk.sh /path/to/outrun.zip build-naomi/rd
kos-cmake -S cmake -B build-naomi -DTARGET=dreamcast.cmake -DCMAKE_BUILD_TYPE=Release \
  -DSDL2_DIR="$KOS_BASE/addons/lib/dreamcast/cmake/SDL2" \
  -DNAOMI_ROMDISK_OBJ=$PWD/build-naomi/rd/romdisk.o
cmake --build build-naomi
$KOS_BASE/utils/naomibintool/naomibintool build build-naomi/cannonball_naomi.bin \
  -t "CANNONBALL OUTRUN" -d "0SKARZER0" -e build-naomi/cannonball.elf
```

`cannonball_naomi.bin` contains your ROMs: keep it to yourself.

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
