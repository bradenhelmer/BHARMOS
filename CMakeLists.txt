cmake_minimum_required(VERSION 3.13)

project(bharmos LANGUAGES C ASM)

# Directories
set(KERNEL_DIR ${CMAKE_SOURCE_DIR}/kernel)
set(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)

# General Compilation
set(CMAKE_C_COMPILER clang)
set(CMAKE_ASM_COMPILER clang)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Cross Compilation Flags
add_compile_options(
	-g
    --target=aarch64-none-elf
    -mcpu=cortex-a72
    -nostdlib
    -ffreestanding
)

# Gather all source files
file(GLOB C_SOURCES "${KERNEL_DIR}/*.c")
file(GLOB ASM_SOURCES "${KERNEL_DIR}/*.S")
set(LINKER_SCRIPT "${KERNEL_DIR}/bharmos-link.ld")

# Create the ELF target
add_executable(bharmos.elf ${C_SOURCES} ${ASM_SOURCES})
target_include_directories(bharmos.elf PRIVATE ${INCLUDE_DIR})
#
# Linker flags
target_link_options(bharmos.elf PRIVATE
    --target=aarch64-none-elf
    -fuse-ld=lld
    -nostdlib
	-T${LINKER_SCRIPT}
)

# Running with QEMU
set(QEMU_AARCH64 qemu-system-aarch64)
set(QEMU_CPU "cortex-a72")
set(QEMU_FLAGS "-nographic")
set(QEMU_MACHINE "virt")

add_custom_target(run
    COMMAND ${QEMU_AARCH64}
            -machine ${QEMU_MACHINE}
            -cpu ${QEMU_CPU}
            -kernel $<TARGET_FILE:bharmos.elf>
            ${QEMU_FLAGS}
    DEPENDS bharmos.elf
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running bharmos.elf in QEMU"
)

add_custom_target(debug-script
	COMMAND ${CMAKE_COMMAND}
			-E copy
			${CMAKE_SOURCE_DIR}/scripts/debug.sh
			${CMAKE_BINARY_DIR}
	DEPENDS
	${CMAKE_SOURCE_DIR}/scripts/debug.sh
)

add_custom_target(debug
	COMMAND 
	${CMAKE_BINARY_DIR}/debug.sh
    DEPENDS
	bharmos.elf
	debug-script
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_custom_target(dump
    COMMAND
	llvm-objdump -D $<TARGET_FILE:bharmos.elf>
	> be.dump && nvim be.dump
	DEPENDS
	bharmos.elf
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
