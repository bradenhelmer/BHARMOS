# bharmos Makefile

# QEMU
QEMU         = qemu-system-aarch64
QEMU_MACHINE = -machine virt
QEMU_CPU     = -cpu cortex-a72
QEMU_FLAGS   = -nographic
QEMU_A72     = $(QEMU) $(QEMU_MACHINE) $(QEMU_CPU)

# clang cross compilation
CC         = clang
C_FLAGS    = -nostdlib
CPU_FLAGS  = -mcpu=cortex-a72
ARCH_FLAGS = --target=aarch64-none-elf
ARMCC      = $(CC) $(ARCH_FLAGS) $(CPU_FLAGS) $(C_FLAGS)

# link flags
LD_FLAGS = -fuse-ld=lld -T../linker.ld

# Kernel Image
BHARMOS = bharmos.elf

all: $(BHARMOS)

bharmos.elf: kernel.o boot.o
	$(ARMCC) $^ $(LD_FLAGS) -o $@

boot.o: ../boot.S
	$(ARMCC) $< -c -o $@

kernel.o: ../kernel.c ../kernel.h
	$(ARMCC) $< -c -o $@

run: $(BHARMOS)
	$(QEMU_A72) -kernel $(BHARMOS) $(QEMU_FLAGS)

clean:
	rm bharmos.elf *.o
