/* 
	* init_vector_table.S
	*
	* Exception vector table and initialization code.
*/

.global init_vector_table
init_vector_table:
	ldr x1, =el1_vector_table
	msr VBAR_EL1, x1
	ret

.global el1_vector_table
.balign 0x800
el1_vector_table:

/* CurrentEL with SP0 */
curr_el_sp0_sync:
.balign 0x80
curr_el_sp0_irq:
.balign 0x80
curr_el_sp0_frq:
.balign 0x80
curr_el_sp0_serror:

/* CurrentEL with SPx */
.balign 0x80
curr_el_spx_sync:
.balign 0x80
curr_el_spx_irq:
.balign 0x80
curr_el_spx_frq:
.balign 0x80
curr_el_spx_serror:

/*  Lower EL using AArch64 */
.balign 0x80
lower_el_aarch64_sync:
.balign 0x80
lower_el_aarch64_irq:
.balign 0x80
lower_el_aarch64_frq:
.balign 0x80
lower_el_aarch64_serror:

/*  Lower EL using AArch32 */
.balign 0x80
lower_el_aarch32_sync:
.balign 0x80
lower_el_aarch32_irq:
.balign 0x80
lower_el_aarch32_frq:
.balign 0x80
lower_el_aarch32_serror:
