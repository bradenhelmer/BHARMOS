# AArch64 PSTATE
- Abstraction of process information
- On exception, the PSTATE is kept in the SPSR of the exception level the exception is taken to.

## PSTATE Fields:

| **Field**       | **Description**                                                                                       | **Reset Value**                   |
|-----------------|-------------------------------------------------------------------------------------------------------|-----------------------------------|
| **Condition Flags**                                                                                                     |                                   |
| `N`             | Negative Condition flag.                                                                              |                                   |
| `Z`             | Zero Condition flag.                                                                                  |                                   |
| `C`             | Carry Condition flag.                                                                                 |                                   |
| `V`             | Overflow Condition flag.                                                                              |                                   |
| **Execution State Controls**                                                                                            |                                   |
| `SS`            | Software Step bit. Set to `0` on reset or exception to AArch64.                                       | `0`                               |
| `IL`            | Illegal Execution state bit. Set to `0` on reset or exception to AArch64.                             | `0`                               |
| `nRW`           | Current Execution state. `0` for AArch64. Set to `0` on reset or exception to AArch64.                | `0`                               |
| `EL`            | Current Exception level. Encodes the highest implemented Exception level on reset to AArch64.         | Highest Exception Level           |
| `SP`            | Stack pointer register selection. Set to `1` (selects `SP_ELx`) on reset or exception to AArch64.     | `1`                               |
| **Exception Mask Bits**                                                                                                 |                                   |
| `D`             | Debug exception mask bit. Set to `1` on reset or exception to AArch64.                                | `1`                               |
| `A`             | SError interrupt mask bit.                                                                            | `1`                               |
| `I`             | IRQ interrupt mask bit.                                                                               | `1`                               |
| `F`             | FIQ interrupt mask bit.                                                                               | `1`                               |
| **Access Control Bits**                                                                                                 |                                   |
| `PAN`           | Privileged Access Never bit. Requires `FEAT_PAN` to be implemented.                                   |                                   |
| `UAO`           | User Access Override bit. Requires `FEAT_UAO` to be implemented.                                      |                                   |
| `TCO`           | Tag Check Override bit. Requires `FEAT_MTE` to be implemented.                                        |                                   |
| **Branch Control Bits**                                                                                                 |                                   |
| `BTYPE`         | Branch target identification bit. Requires `FEAT_BTI` to be implemented.                              |                                   |
| **Timing Control Bits**                                                                                                 |                                   |
| `DIT`           | Data Independent Timing bit. Requires `FEAT_DIT` to be implemented. Set to `0` on reset to AArch64.   | `0`                               |
| **Speculation Control Bits**                                                                                            |                                   |
| `SSBS`          | Speculative Store Bypass Safe bit. Requires `FEAT_SSBS` to be implemented.                            | IMPLEMENTATION DEFINED value      |

## Accessing PSTATE Fields
- Fields are accessed using special purpose registers (SPRs):
    - Reads with `MRS` instruction
    - Writes with `MSR` instruction

### Directly Readable and Writeable PSTATE SPRs (`MRS` & `MSR`)
| **Field**        | **Description**                                                                                     | **Reset Value**                   |
|------------------|-----------------------------------------------------------------------------------------------------|-----------------------------------|
| `NZCV`           | Condition flags: Negative (`N`), Zero (`Z`), Carry (`C`), Overflow (`V`).                           |                                   |
| `DAIF`           | Exception mask bits: Debug (`D`), SError (`A`), IRQ (`I`), FIQ (`F`).                               |                                   |
| `CurrentEL`      | Current Exception Level (`EL`). Encodes the highest implemented exception level on reset to AArch64.| Highest Exception Level           |
| `SPSel`          | Stack Pointer Selection (`SP`). Determines which stack pointer is in use.                           | `1` (Selects `SP_ELx`)            |
| `PAN`            | Privileged Access Never (`PAN`).                                                                    |                                   |
| `UAO`            | User Access Override (`UAO`).                                                                       |                                   |
| `DIT`            | Data Independent Timing (`DIT`).                                                                    | `0` (on reset)                    |
| `SSBS`           | Speculative Store Bypass Safe (`SSBS`).                                                             | IMPLEMENTATION DEFINED value      |
| `TCO`            | Tag Check Override (`TCO`). 

### Directly Writeable PSTATE SPRs (`MSR`)
| **Operand**   | **PSTATE Field**         | **Description**                                                                                 |
|---------------|--------------------------|-------------------------------------------------------------------------------------------------|
| `DAIFSet`     | `D`, `A`, `I`, `F`       | Directly sets any of the `PSTATE.{D, A, I, F}` bits to `1`.                                     |
| `DAIFClr`     | `D`, `A`, `I`, `F`       | Directly clears any of the `PSTATE.{D, A, I, F}` bits to `0`.                                   |
| `SPSel`       | `SP`                     | Directly sets `PSTATE.SP` to either `1` or `0`.                                                 |
| `PAN`         | `PAN`                    | Directly sets `PSTATE.PAN` to either `1` or `0`.                                                |
| `UAO`         | `UAO`                    | Directly sets `PSTATE.UAO` to either `1` or `0`.                                                |
| `DIT`         | `DIT`                    | Directly sets `PSTATE.DIT` to either `1` or `0`.                                                |
| `SSBS`        | `SSBS`                   | Directly sets `PSTATE.SSBS` to either `1` or `0`.                                               |
| `TCO`         | `TCO`                    | Directly sets `PSTATE.TCO` to either `1` or `0`. `PSTATE.TCO` can also be accessed by an `MSR Xt` instruction. |
