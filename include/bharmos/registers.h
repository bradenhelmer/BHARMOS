/*
 * registers.h
 *
 * AArch64 register definitions.
 *
 * Descriptions here are from taken from the ARMV8-A Reference manual.
 */
// clang-format off
#ifndef BHARMOS_REGISTERS_H
#define BHARMOS_REGISTERS_H
#include <bharmos/sizes.h>

// CurrentEL - Current Exception Level
typedef struct {
  u64 RES1 : 2;    // Reserved.
  u64 EL : 2;      // Current exception level.
  u64 RES0 : 60;   // Reserved. 
} CurrentEL;

// ESR_EL1 - Exception Syndrome Register
typedef struct {
  u64 ISS : 25;    // Instruction specific syndrome.
  u64 IL : 1;      // Instruction length for synchronous execptions.
  u64 EC : 6;      // Exception class.
  u64 RES : 32;    // Reserved.
} ESR_EL1;

// ELR_EL1 - Exception Link Register
typedef struct {
  u64 RA : 64;     // Return address
} ELR_EL1;

// FAR_EL1 - Fault Address Register
typedef struct {
  u64 FVA : 64;    // Faulting VA for synchronous exceptions taken to EL1.
} FAR_EL1;

// SCTLR_EL1 - System Control Register for EL1 & EL0
typedef struct {
  u64 M : 1;       // MMU enable for EL1/EL0 stage 1 address translation.
  u64 A : 1;       // Alignment check enable. Enable EL1/EL0 fault checking.
  u64 C : 1;       // Stage 1 data access cacheability control.
  u64 SA : 1;      // SP alignment check enable EL1.
  u64 SA0 : 1;     // SP alignment check enable EL0.
  u64 CP15BEN : 1; // Reserved in EL0 AArch64.
  u64 nAA : 1;     // Non-aligned access. (FEAT_LSE2)
  u64 IDT : 1;     // Reserved in EL0 AArch64.
  u64 SED : 1;     // SETEND instruction disable.
  u64 UMA : 1;     // User mask access. Traps EL0 execution of MSR and MRS
                   // instructions that access the PSTATE.{D, A, I, F} masks to
                   // EL1.
  u64 EnRCTX : 1;  // Enable EL0 access to CFP RCTX, DVP RCT, and CPP RCTX
                   // instructions. (FEAT_SPECRES)
  u64 EOS : 1;     // Exception exit is context synchronizing. (FEAT_ExS)
  u64 I : 1;       // Stage 1 instruction access cacheability control.
  u64 EnDB : 1;    // Enabling of pointer authentication with APDBKey_EL1.
                   // (FEAT_PAuth)
  u64 DZE : 1;     // Traps execution of EL0 DCZVA instructions to EL1.
  u64 UCT : 1;     // Traps EL0 accesses to CTR_EL0 to EL1.
  u64 nTWI : 1;    // Traps execution of EL0 WFI instructions to EL1.
  u64 nTWE : 1;    // Traps execution of EL0 WFE instructions to EL1.
  u64 WXN : 1;     // Write permission implies 'execute-never'. In EL1 & EL0
                   // translation regimes, this can force all memory regions that
                   // are writeable to be treated as XN.
  u64 TSCXT : 1;   // Trap EL0 accesst ot SCXTNUM_EL0 register when EL0 is using
                   // AArch64. (FEAT_CSV2)
  u64 IESB : 1;    // Implicit error synchronization event enable. (FEAT_IESB)
  u64 EIS : 1;     // Exception entry is context synchronizing. (FEAT_ExS)
  u64 SPAN : 1;    // Set privileged access never, on taking an exception to
                   // EL1. (FEAT_PAN)
  u64 EE0 : 1;     // Endianness of data accesses at EL0.
  u64 EE : 1;      // Endianness of data accesses at EL1, and stage 1 translation
                   // table walks.
  u64 UCI : 1;     // Traps EL0 cache maintenance instructions to EL1.
  u64 EnDA : 1;    // Enabling of pointer authentication with APDAKey_EL1.
                   // (FEAT_PAuth)
  u64 nTLSMD : 1;  // No trap load multiple and store multiple to
                   // Device-nG{n}R{n}E. (FEAT_LSMAOC)
  u64 LSMAOE : 1;  // Enable load multiple and store multiple atomicity and
                   // ordering. (FEAT_LSMAOC)
  u64 EnIB : 1;    // Enabling of pointer authentication with APIBKey_EL1.
                   // (FEAT_PAuth)
  u64 EnIA : 1;    // Enabling of pointer authentication with APIAKey_EL1.
                   // (FEAT_PAuth)
  u64 RES1 : 3;    // Reserved.
  u64 BT0 : 1;     // PAC branch type compatibility for EL0. (FEAT_BTI)
  u64 BT1 : 1;     // PAC branch type compatibility for EL1. (FEAT_BTI)
  u64 ITFSB : 1;   // Controls auto-synchronization of tag check faults into
                   // TFSRE0_EL1/TFSR_EL1. (FEAT_MTE)
  u64 TCF0 : 2;    // Tag check fault for EL0. (FEAT_MTE)
  u64 TCF : 2;     // Tag check fault for EL1. (FEAT_MTE)
  u64 ATA0 : 1;    // Allocation tag access for EL0. (FEAT_MTE)
  u64 ATA : 1;     // Allocation tag access for EL1. (FEAT_MTE)
  u64 DSSBS : 1;   // Default PSTATE.SSBS on exeception entry.
  u64 TWEDEn : 1;  // TWE delay enable. (FEAT_TWED)
  u64 TWEDEL : 4;  // TWE delay. (FEAT_TWED)
  u64 RES0 : 14;   // Reserved.
} SCTLR_EL1;

// SPSR_EL1 - Saved Program Status Register
typedef struct {
  u64 M3 : 4;      // AArch32 mode only.
  u64 M4 : 1;      // Execution state.
  u64 T : 1;       // T32 instruction set state.
  u64 F : 1;       // FIQ interrupt mask.
  u64 I : 1;       // IRQ interrupt mask.
  u64 A : 1;       // SError interrupt mask.
  u64 E : 1;       // Endianness.
  u64 IT1 : 6;     // If-Then.
  u64 GE : 4;      // Greater than or equal flags.
  u64 IL : 1;      // Illegal execution state.
  u64 SS : 1;      // Software step.
  u64 PAN : 1;     // Privileged access never. (FEAT_PAN)
  u64 SSBS : 1;    // Speculative store bypass. (FEAT_SBSS)
  u64 DIT : 1;     // Data independent timing. (FEAT_DIT)
  u64 IT2 : 2;     // If-Then
  u64 Q : 1;       // Overflow | saturation flag.
  u64 V : 1;       // Overflow condition flag.
  u64 C : 1;       // Carry condition flag.
  u64 Z : 1;       // Zero condition flag.
  u64 N : 1;       // Negative condition flag.
  u64 RES : 32;    // Reserved
} SPSR_EL1;

// VBAR_EL1 - Vector Base Address Register
typedef struct {
  u64 RES0 : 11;   // Reserved.
  u64 VBA : 53;    // Vector base address.
} VBAR_EL1;

// clang-format on

#define READ_SYS_REG(REG_TYPE, OUTPUT)                                         \
  __asm__ __volatile__("mrs %0, " #REG_TYPE : "=r"(OUTPUT) :);

#define WRITE_SYS_REG(REG_TYPE, INPUT)                                         \
  __asm__ __volatile__("msr " #REG_TYPE ", %0" ::"r"(INPUT));

#endif // BHARMOS_REGISTERS_H
