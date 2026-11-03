#!/bin/bash
# Pack the NAOMI romdisk: config.xml, res/ and your OutRun revision B ROMs.
#
#   naomi/make_romdisk.sh <dir-with-the-31-rom-files-or-outrun.zip> <out-dir>
#
# Writes <out-dir>/romdisk.o (symbol "romdisk"), linked into the NAOMI build
# with -DNAOMI_ROMDISK_OBJ=<out-dir>/romdisk.o. The result contains the ROMs:
# never commit or share it.
#
# Optional: put recorded audio in <out-dir>/extra/music/orig and
# <out-dir>/extra/sfx (same layout as the Dreamcast disc) and it is packed too.
set -euo pipefail

SRC=${1:?ROM folder or outrun.zip}
OUT=${2:?output folder}
REPO=$(cd "$(dirname "$0")/.." && pwd)
: "${KOS_BASE:?source the KallistiOS environ.sh first}"

mkdir -p "$OUT"
OUT=$(cd "$OUT" && pwd)
RD="$OUT/romdisk"
rm -rf "$RD"
mkdir -p "$RD/roms" "$RD/res"

if [ -f "$SRC" ]; then
    unzip -q -o -j "$SRC" -d "$RD/roms"
else
    cp "$SRC"/* "$RD/roms/"
fi
rm -f "$RD/roms/"*.txt
N=$(ls "$RD/roms" | wc -l)
if [ "$N" -lt 31 ]; then
    echo "Expected the 31 OutRun revision B ROM files, found $N" >&2
    exit 1
fi

# The disc's settings, with NAOMI defaults: no FPS counter, no VMU animation,
# timing fixes off, new attract mode off, enhanced level objects
sed -e 's#<fps_counter>[0-9]*</fps_counter>#<fps_counter>0</fps_counter>#' \
    -e 's#<vmu_animation>[0-9]*</vmu_animation>#<vmu_animation>0</vmu_animation>#' \
    -e 's#<fix_timer>[0-9]*</fix_timer>#<fix_timer>0</fix_timer>#' \
    -e 's#<new_attract>[0-9]*</new_attract>#<new_attract>0</new_attract>#' \
    -e 's#<levelobjects>[0-9]*</levelobjects>#<levelobjects>1</levelobjects>#' \
    "$REPO/build-dc/cd/config.xml" > "$RD/config.xml"
cp "$REPO/build-dc/res/tilemap.bin" "$REPO/build-dc/res/tilepatch.bin" "$RD/res/"
# SDL's controller database is not needed on the NAOMI (no SDL controllers)

if [ -d "$OUT/extra" ]; then
    cp -r "$OUT/extra/." "$RD/"
fi

"$KOS_BASE/utils/genromfs/genromfs" -f "$OUT/romdisk.img" -d "$RD" -V CANNONBALL
"$KOS_BASE/utils/bin2o/bin2o" "$OUT/romdisk.img" romdisk "$OUT/romdisk.o"
echo "romdisk: $(du -h "$OUT/romdisk.img" | cut -f1) -> $OUT/romdisk.o"
