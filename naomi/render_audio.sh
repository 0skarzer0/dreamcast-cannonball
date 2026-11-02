#!/bin/bash
# Record the original music and FM sound effects from your ROMs for the NAOMI
# romdisk (same recordings as the Dreamcast disc, see build-dc/make_cdi.sh).
#
#   tools/render_audio.sh <render-tool-build-dir>          (once, host build)
#   naomi/render_audio.sh <render-tool> <outrun.zip> <out-dir>
#
# Writes <out-dir>/music/orig/1-4.wav(.loop) and <out-dir>/sfx/*.wav. Give
# that folder to naomi/pack_bin.py (/dimm, read from the NetDIMM: full
# quality), or put it in <romdisk-dir>/extra for naomi/make_romdisk.sh
# (in RAM: use NAOMI_AUDIO_RATE=22050 NAOMI_AUDIO_CHANNELS=1 to fit). With these the game plays the
# recordings instead of emulating the YM2151 FM chip: correct sound and less
# CPU. Contains data from your ROMs: never commit or share it.
set -euo pipefail

TOOL=$(cd "$(dirname "${1:?render tool}")" && pwd)/$(basename "$1")
SRC=${2:?outrun.zip or ROM folder}
OUT=${3:?romdisk output folder}
REPO=$(cd "$(dirname "$0")/.." && pwd)

# Default: as on the Dreamcast disc (recorder's rate, stereo, ~37 MB)
RATE=${NAOMI_AUDIO_RATE:-}
CH=${NAOMI_AUDIO_CHANNELS:-2}

mkdir -p "$OUT"
OUT=$(cd "$OUT" && pwd)
R="$OUT/render"
rm -rf "$R" "$OUT/music/orig" "$OUT/sfx"
mkdir -p "$R/roms" "$R/res" "$OUT/music/orig" "$OUT/sfx"

if [ -f "$SRC" ]; then unzip -q -o -j "$SRC" -d "$R/roms"; else cp "$SRC"/* "$R/roms/"; fi
cp "$REPO/build-dc/res/tilemap.bin" "$REPO/build-dc/res/tilepatch.bin" "$R/res/"
sed -e "s#/cd/roms/#$R/roms/#g" -e "s#/cd/res/#$R/res/#g" "$REPO/build-dc/cd/config.xml" > "$R/config.xml"
FIX=$(sed -n 's#.*<fix_samples>\([0-9]\)</fix_samples>.*#\1#p' "$R/config.xml" | head -1)

render() { # mode cmd out
    ( cd "$R" && CB_RENDER=$1 CB_CMD=$2 CB_OUT=$3 CB_FIX=${FIX:-0} SDL_AUDIODRIVER=dummy \
      "$TOOL" -cfgfile "$R/config.xml" 2>/dev/null | grep -a "cmd 0x" || true )
}

n=1
for cmd in 0x85 0x81 0x82 0xA5; do
    render music $cmd "$R/$n.wav"
    SRC_RATE=$(python3 -c "import wave;print(wave.open('$R/$n.wav').getframerate())")
    DST_RATE=${RATE:-$SRC_RATE}
    ffmpeg -loglevel error -y -i "$R/$n.wav" -ar "$DST_RATE" -ac "$CH" -c:a adpcm_yamaha "$OUT/music/orig/$n.wav"
    # The .loop file holds the loop start as a BYTE offset into the ADPCM
    # data (4 bits per sample per channel); the recorder gives it in frames
    # at its own rate
    if [ -f "$R/$n.wav.loop" ]; then
        python3 -c "f=int(open('$R/$n.wav.loop').read());b=(f*$DST_RATE//$SRC_RATE)*$CH//2;print(b&~1)" \
            > "$OUT/music/orig/$n.wav.loop"
    fi
    n=$((n + 1))
done
for cmd in 84 86 94 95 99 9B; do
    render sfx 0x$cmd "$OUT/sfx/$cmd.wav"
done
rm -rf "$R"
du -sh "$OUT/music" "$OUT/sfx"
