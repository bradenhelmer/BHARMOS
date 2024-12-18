#include "kernel.h"
volatile u8 *uart = (u8 *)0x09000000;

void putchar(char c) {
  *uart = c;
}

void print(const char *s) {
  while (*s != '\0') {
	putchar(*s);
	s++;
  }
}

void kmain(void) {
  print("BHARMOS Kernel\n");
}
