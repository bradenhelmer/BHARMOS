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

	fmov d0, xzr
	fmov d1, xzr
	fmov d2, xzr
	fmov d3, xzr
	fmov d4, xzr
	fmov d5, xzr
	fmov d6, xzr
	fmov d7, xzr
	fmov d8, xzr
	fmov d9, xzr
	fmov d10, xzr
	fmov d11, xzr
	fmov d12, xzr
	fmov d13, xzr
	fmov d14, xzr
	fmov d15, xzr
	fmov d16, xzr
	fmov d17, xzr
	fmov d18, xzr
	fmov d19, xzr
	fmov d20, xzr
	fmov d21, xzr
	fmov d22, xzr
	fmov d23, xzr
	fmov d24, xzr
	fmov d25, xzr
	fmov d26, xzr
	fmov d27, xzr
	fmov d28, xzr
	fmov d29, xzr
	fmov d30, xzr
	fmov d31, xzr

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
	lsr x1, x1, #2
	and x1, x1, #0x3
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
