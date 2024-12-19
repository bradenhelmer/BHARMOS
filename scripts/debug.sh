#!/bin/bash

# Start Qemu
qemu-system-aarch64 \
	-machine virt \
	-cpu cortex-a72 \
	-kernel bharmos.elf \
	-nographic \
	-S -gdb tcp::1234 &

# Keep track of process to kill later
QEMU_PID=$!

sleep 1

# Start up GDB and attach
gdb-multiarch bharmos.elf \
	-ex "set architecture aarch64" \
	-ex "target remote localhost:1234"

# Kill Qemu process after done debugging, if still running...
if ps -p $QEMU_PID > /dev/null
then
	kill $QEMU_PID
fi
