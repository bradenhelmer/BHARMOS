/*
 * exceptions.h
 *
 * Definitions related to exception handling.
 */
#ifndef BHARMOS_EXCEPTIONS_H
#define BHARMOS_EXCEPTIONS_H
#include <bharmos/registers.h>

static u8 get_current_el() {
  CurrentEL EL;
  READ_SYS_REG(CurrentEL, EL);
  return (EL.EL);
}

#endif // BHARMOS_EXCEPTIONS_H
