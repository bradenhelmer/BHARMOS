/* BHARMOS Linker Script*/

ENTRY(_start)

SECTIONS {

	/* Device Tree Blob Start */
	. = 0x40000000;
	DTB_ADDR = .;
	. += 0x8000;	

	KERNEL_START = .;
	
	.boot.text ALIGN(4K) : AT(ADDR(.boot.text)) {
		*(.boot.text)
	}

	.text ALIGN(4K) : AT(ADDR(.text)) {
		*(.text)
	}

	.data ALIGN(4K) : AT(ADDR(.data)) {
		*(.data)
	}

	.bss ALIGN(4K) : AT(ADDR(.bss)) {
		*(.bss COMMON)
	}
	
	. = ALIGN(4K);
	stack_top = .;

}
