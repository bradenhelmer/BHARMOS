/* 
	* init_vector_table.S
	*
	* Exception vector table and initialization code.
*/
.section ".evt.text", "ax"

#define GP_SAVE_PAIR_OFFSET -16
#define FP_SAVE_PAIR_OFFSET -32
#define GP_RESTORE_PAIR_OFFSET 16
#define FP_RESTORE_PAIR_OFFSET 32

.macro save_corruptible_registers
	/* Save GP Integer Registers */
	stp x0,  x1,  [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x2,  x3,  [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x4,  x5,  [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x6,  x7,  [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x8,  x9,  [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x10, x11, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x12, x13, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x14, x15, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x16, x17, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x18, x19, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x20, x21, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x22, x23, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x24, x25, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x26, x27, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x28, x29, [sp, #GP_SAVE_PAIR_OFFSET]!
	stp x30, xzr, [sp, #GP_SAVE_PAIR_OFFSET]!

	/* Save FP/SIMD Registers */
	stp q0, q1, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q2, q3, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q4, q5, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q6, q7, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q8, q9, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q10, q11, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q12, q13, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q14, q15, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q16, q17, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q18, q19, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q20, q21, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q22, q23, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q24, q25, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q26, q27, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q28, q29, [sp, #FP_SAVE_PAIR_OFFSET]!
	stp q30, q31, [sp, #FP_SAVE_PAIR_OFFSET]!
.endm

.macro restore_corruptible_registers
	/* Restore FP/SIMD Registers */
	ldp q30, q31, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q28, q29, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q26, q27, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q24, q25, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q22, q23, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q20, q21, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q18, q19, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q16, q17, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q14, q15, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q12, q13, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q10, q11, [sp], #FP_RESTORE_PAIR_OFFSET	
	ldp q8, q9, [sp],   #FP_RESTORE_PAIR_OFFSET	
	ldp q6, q7, [sp],   #FP_RESTORE_PAIR_OFFSET	
	ldp q4, q5, [sp],   #FP_RESTORE_PAIR_OFFSET	
	ldp q2, q3, [sp],   #FP_RESTORE_PAIR_OFFSET	
	ldp q0, q1, [sp],   #FP_RESTORE_PAIR_OFFSET	

	/* Restore GP Registers */
	ldr x30, [sp], #8
	ldp x28, x29, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x26, x27, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x24, x25, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x22, x23, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x20, x21, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x18, x19, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x16, x17, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x14, x15, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x12, x13, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x10, x11, [sp], #GP_RESTORE_PAIR_OFFSET
	ldp x8, x9, [sp],   #GP_RESTORE_PAIR_OFFSET
	ldp x6, x7, [sp],   #GP_RESTORE_PAIR_OFFSET
	ldp x4, x5, [sp],   #GP_RESTORE_PAIR_OFFSET
	ldp x2, x3, [sp],   #GP_RESTORE_PAIR_OFFSET
	ldp x0, x1, [sp],   #GP_RESTORE_PAIR_OFFSET
.endm

.global init_vector_table
init_vector_table:
	ldr x1, =el1_vector_table
	msr VBAR_EL1, x1
	ret

/* EL1 VECTOR TABLE */
.global el1_vector_table
.balign 0x800
el1_vector_table:

/* CurrentEL with SP0 */
curr_el_sp0_sync:
	b handle_sync

.balign 0x80
curr_el_sp0_irq:
	b handle_async

.balign 0x80
curr_el_sp0_frq:
	b handle_async

.balign 0x80
curr_el_sp0_serror:
	b handle_async

/* CurrentEL with SPx */
.balign 0x80
curr_el_spx_sync:
	b handle_sync

.balign 0x80
curr_el_spx_irq:
	b handle_async

.balign 0x80
curr_el_spx_frq:
	b handle_async

.balign 0x80
curr_el_spx_serror:
	b handle_async

/*  Lower EL using AArch64 */
.balign 0x80
lower_el_aarch64_sync:
	b handle_sync

.balign 0x80
lower_el_aarch64_irq:
	b handle_async

.balign 0x80
lower_el_aarch64_frq:
	b handle_async

.balign 0x80
lower_el_aarch64_serror:
	b handle_async

/*  Lower EL using AArch32 */
.balign 0x80
lower_el_aarch32_sync:
	b aarch32_unimplemented

.balign 0x80
lower_el_aarch32_irq:
	b aarch32_unimplemented

.balign 0x80
lower_el_aarch32_frq:
	b aarch32_unimplemented

.balign 0x80
lower_el_aarch32_serror:
	b aarch32_unimplemented


/* Halt the core if exception generated here */
aarch32_unimplemented:
	wfi
	b aarch32_unimplemented

/* Handler for asynchronous exceptions. */
handle_async:
	save_corruptible_registers	
	nop
	restore_corruptible_registers	
	eret

/* Handler for synchronous exceptions. */
handle_sync:
	save_corruptible_registers	
	nop
	restore_corruptible_registers	
	eret
