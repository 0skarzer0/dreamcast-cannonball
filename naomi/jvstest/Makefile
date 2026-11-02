# Cannonball Naomi - JVS test
# Builds jvstest.bin, ready to netboot on a NAOMI / NAOMI 2 NetDIMM.
# Needs the KallistiOS environment with KOS_SUBARCH=naomi.

TARGET = jvstest.elf
OBJS = jvstest.o
NAOMIBINTOOL ?= $(KOS_BASE)/utils/naomibintool/naomibintool

all: jvstest.bin

include $(KOS_BASE)/Makefile.rules

$(TARGET): $(OBJS)
	kos-cc -o $(TARGET) $(OBJS)

jvstest.bin: $(TARGET)
	$(NAOMIBINTOOL) build $@ -t "CANNONBALL JVS TEST" -d "0SKARZER0" -e $(TARGET)

clean:
	-rm -f $(OBJS) $(TARGET) jvstest.bin
