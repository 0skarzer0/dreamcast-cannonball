# Source this for the NAOMI build of the game and its libraries (GLdc, SDL2):
#   source naomi/env.sh
# KallistiOS's NAOMI environment defines __NAOMI__ but not __DREAMCAST__, which
# SDL2's Dreamcast port and the game test for. KallistiOS does not use
# __DREAMCAST__ itself, so adding it is safe.
: "${DC:=/opt/toolchains/dc}"
source "$DC/kos/environ.sh"
export KOS_CFLAGS="${KOS_CFLAGS} -D__DREAMCAST__"
