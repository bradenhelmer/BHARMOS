/* 
	* boot.S
	*
	* CPU startup and initialization code.
*/

.section ".boot.text","ax"

.macro init_registers

	/* Init GP registers */
	mov x0, xzr
	mov x1, xzr
	mov x2, xzr
	mov x3, xzr
	mov x4, xzr
	mov x5, xzr
	mov x6, xzr
	mov x7, xzr
	mov x8, xzr
	mov x9, xzr
	mov x10, xzr
	mov x11, xzr
	mov x12, xzr
	mov x13, xzr
	mov x14, xzr
	mov x15, xzr
	mov x16, xzr
	mov x17, xzr
	mov x18, xzr
	mov x19, xzr
	mov x20, xzr
	mov x21, xzr
	mov x22, xzr
	mov x23, xzr
	mov x24, xzr
	mov x25, xzr
	mov x26, xzr
	mov x27, xzr
	mov x28, xzr
	mov x29, xzr
	mov x30, xzr
	
	/* Init FP registers */

	/* Disable access trapping for EL1/EL0 */
	mov x1, #(0x3 << 20)
	msr CPACR_EL1, x1
	isb

	movi v0.16b,  #0
	movi v1.16b,  #0
	movi v2.16b,  #0
	movi v3.16b,  #0
	movi v4.16b,  #0
	movi v5.16b,  #0
	movi v6.16b,  #0
	movi v7.16b,  #0
	movi v8.16b,  #0
	movi v9.16b,  #0
	movi v10.16b, #0
	movi v11.16b, #0
	movi v12.16b, #0
	movi v13.16b, #0
	movi v14.16b, #0
	movi v15.16b, #0
	movi v16.16b, #0
	movi v17.16b, #0
	movi v18.16b, #0
	movi v19.16b, #0
	movi v20.16b, #0
	movi v21.16b, #0
	movi v22.16b, #0
	movi v23.16b, #0
	movi v24.16b, #0
	movi v25.16b, #0
	movi v26.16b, #0
	movi v27.16b, #0
	movi v28.16b, #0
	movi v29.16b, #0
	movi v30.16b, #0
	movi v31.16b, #0

	/* Init stack pointer registers */
	adr x1, stack_top
	mov sp, x1
	mov x1, xzr

	/* Init system control registers */
	# ldr x1, =0x30C50838
	# msr SCTLR_EL1, x1

.endm

/* Cores the arent 0 will be sent here to sleep */
core_sleep:
	wfi
	b core_sleep

.global _start
_start:

	/* Only continue with core 0 */
	mrs x1, MPIDR_EL1
	and x1, x1, #0xFF
	cbnz x1, core_sleep

	init_registers

	/* Ensure we aren't in any exception level higher than 1 */
	mrs x1, CurrentEL
	ubfx x1, x1, #2, #2
	cmp x1, #1
	b.ne high_exception_halt

	/* Setup vector table */
	bl init_vector_table

	mov x2, #10
	bl kmain
	b .
	
high_exception_halt:
	wfi
	b high_exception_halt
