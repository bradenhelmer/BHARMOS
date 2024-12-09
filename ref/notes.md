# Architecture Notes: Armv8-A  
**CPU:** Cortex-A72

## 1. General Notes (See Part A of the Manual)

### Execution State: AArch64
- **General-Purpose Registers (GPRs):** 31 64-bit GP registers (`X0`–`X30`, where `X30` is the link register).  
- **Program Counter (PC), Stack Pointer (SP), and Exception Link Registers (ELR):** All are 64-bit.  
- **SIMD / Floating-Point Registers:** 32 128-bit registers for SIMD and scalar FP operations.  
- **Instruction Set:** A64 (with fixed 32-bit instruction encodings).  
- **Exception Model:** Four levels: `EL0`–`EL3`.  
- **Addressing:** 64-bit virtual addressing.  
- **Program State (PSTATE):** Holds Processor Element (PE) state.  
- **System Registers:** Each system register name is suffixed with the lowest exception level it can be accessed at (e.g., `_EL0`, `_EL1`, `_EL2`, `_EL3`).

### System Registers
- Contain control and status information.  
- Format: `<register_name>_ELx.<bit_field_name>` indicates the specific register and its bit fields.  
- Categories include:
  - General system/control registers
  - Debug registers
  - Generic timer registers
  - (Optionally) Performance/activity monitor registers
  - Generic Interrupt Controller (GIC) system registers

### Data Types
- **Integers:**
  - Byte: 8 bits
  - Halfword: 16 bits
  - Word: 32 bits
  - Doubleword: 64 bits
  - Quadword: 128 bits
- **Floating-Point:**
  - Half-precision (16-bit)
  - Single-precision (32-bit)
  - Double-precision (64-bit)
  - BFloat16

### Memory Model
- Can generate exceptions on unaligned memory access.  
- Can restrict access to certain memory areas.  
- Translates Virtual Addresses (VAs) to Physical Addresses (PAs).  
- Supports both big-endian and little-endian data interpretation.  
- Controls memory access ordering, caching, and address translation structures.  
- Synchronizes access to shared memory among multiple PEs.  
- Provides barriers to control/prevent speculative memory access.

---

## 2. Instruction Set (See Part C of the Manual)

### General Information
- Instructions are **32-bit wide**.  
- Instruction encodings are grouped by functionality:
  - Miscellaneous (branching, exceptions, system instructions)
  - Data-processing (with register and immediate operands)
  - Load/Store (GP and SIMD/FP registers)
  - SIMD/FP operations

### General-Purpose Registers (GPRs)
| Name | Size     | Encoding | Description                             |
|------|-----------|----------|-----------------------------------------|
| Wn   | 32 bits   | 0–30     | General-purpose register W0–W30         |
| Xn   | 64 bits   | 0–30     | General-purpose register X0–X30         |
| WZR  | 32 bits   | 31       | Zero register (write ignored, read 0)  |
| XZR  | 64 bits   | 31       | Zero register (write ignored, read 0)  |
| WSP  | 32 bits   | 31       | Current stack pointer (32-bit view)     |
| SP   | 64 bits   | 31       | Current stack pointer (64-bit view)     |

**Note:** `X30/W30` is used as the link register for procedure calls.

### SIMD / FP Registers
- `Bn` (8 bits), `Hn` (16 bits), `Sn` (32 bits), `Dn` (64 bits), `Qn` (128 bits) are sub-register names for the SIMD/FP register file (0–31).

### Condition Codes
- Refer to Section C1.2.4 in the manual for details on condition flags and their usage.

### Addressing Modes

1. **Base Register Only (No Offset)**: `[base{, #0}]`
   ```asm
   LDR X0, [X1] ; Load from address in X1 into X0
   ```

2. **Base + Offset**
   - **Immediate Offset:** `[base, #imm]`
     ```asm
     LDR X0, [X1, #8] ; Load from (X1 + 8) into X0
     ```
   - **Register Offset:** `[base, Xm {, LSL #imm}]`
     ```asm
     LDR X0, [X1, X2, LSL #2] ; Load from (X1 + (X2 << 2)) into X0
     ```
   - **Scaled Offset:** `[base, Wm, (S|U)XT(X|W){#imm}]`
     ```asm
     LDR X0, [X1, W2, SXTW] ; Load from (X1 + sign-extended W2) into X0
     ```

3. **Pre-Indexed Addressing:** `[base, #imm]!`
   - The base register is updated *before* the memory access.
   ```asm
   LDR X0, [X1, #4]! ; Load from (X1 + 4) into X0, then X1 = X1 + 4
   ```

4. **Post-Indexed Addressing:** `[base], #imm`
   - The base register is updated *after* the memory access.
   ```asm
   LDR X0, [X1], #4 ; Load from X1 into X0, then X1 = X1 + 4
   ```

5. **Literal (PC-Relative Addressing):** `label`
   - Address is computed relative to the PC.  
   - Used for accessing constants/data stored near the instruction.
   ```asm
   LDR X0, =value ; Load address of 'value' into X0
   ```
