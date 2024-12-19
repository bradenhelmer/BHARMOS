/*
 * kernel.c
 *
 * Main kernel entry point.
 */
#include <bharmos/exceptions.h>
#include <bharmos/sizes.h>
volatile u8 *uart = (u8 *)0x09000000;

void putchar(char c) { *uart = c; }

void print(const char *s) {
  while (*s != '\0') {
    putchar(*s);
    s++;
  }
}

void kmain(void) {
  print("Starting BHARMOS Kernel...\n");
  u8 EL = get_current_el();
  print("The current exception level is: ");
  putchar(EL + 48);
  putchar('\n');
}
