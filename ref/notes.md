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

### SIMD & Floating-Point Scalar Registers
| Register Name | Size    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| Bn            | 8 bits  | Byte-sized sub-register of SIMD/FP register (0–31).                        |
| Hn            | 16 bits | Halfword-sized sub-register of SIMD/FP register (0–31).                    |
| Sn            | 32 bits | Word-sized sub-register of SIMD/FP register (0–31).                       |
| Dn            | 64 bits | Doubleword-sized sub-register of SIMD/FP register (0–31).                 |
| Qn            | 128 bits| Full SIMD/FP register (0–31), used for 128-bit vector operations.          |
| Vn            | Variable| General-purpose SIMD/FP register (0–31), supports scalar and vector views. |

#### Examples of using the `V` register as a vector
| Syntax      | Description                                        |
|-------------|----------------------------------------------------|
| `Vn.16B`    | Access the vector as 16 bytes (8 bits each).       |
| `Vn.8H`     | Access the vector as 8 halfwords (16 bits each).   |
| `Vn.4S`     | Access the vector as 4 single-precision words (32 bits each). |
| `Vn.2D`     | Access the vector as 2 double-precision words (64 bits each). |
| `Vn.8B`     | Access the lower half of the vector as 8 bytes.    |
| `Vn.4H`     | Access the lower half of the vector as 4 halfwords.|
| `Vn.2S`     | Access the lower half of the vector as 2 single-precision words. |
| `Vn.D`      | Access the lower half of the vector as 1 double-precision word. |


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

## System Level Programming Information (See Part D of Manual)

### Exception Levels
 - 4 levels from EL0 to EL3:

| Level | Supports                 | Use Case       |
|-------|--------------------------|----------------|
| EL0   | _Unprivileged_ execution | Applications   |
| EL1   | _Privileged_ execution   | OS Kernel      |
| EL2   | Virtualization           | Hypervisor     |
| EL3   | Security State           | Secure Monitor |

- All implementations **must** include EL0 and EL1.
#### Moving between exception levels
- On taking an exception, the EL may only increase or remain the same.
- On returning from an exception, the EL may only decrease or remain the same.
- The inteneded EL the execution remains or changes to is called the _target exception level_.
    - No exception can target EL0.
    - The target is implicit by nature or defined by configuration bits in sys regs.
#### Precise Exceptions
- Exceptions are described as precise when the handler receieves PE state and memory system
  state that is consistent with the PE having executed all instructions up to but not including
  the point at which the exception was taken.
- All exceptions in AArch64 are required to be precise except _SError Interrupt_.
#### Synchronous & Asynchronous Exceptions
##### Synchronous Exceptions:
- Exception is generated from direct/attempted execution of an instruction.
- Return address given to handler is guaranteed to indicate the instruction that
  caused the exception.
- It is precise.
##### Asynchronous Exceptions:
- Opposite of all criteria in synchronous exceptions.

### Execution State
- AArch64 or AArch32
- Exception levels operate in execution states.
- PE can only change execution state at reset or on change of exception level.

### Registers for Instruction Processing and Exception Handling

#### [General Purpose Registers](1#general-purpose-registers-(gprs))

#### Stack Pointer
- Each exception level has its own dedicated stack pointer register:
    - `SP_EL0` | `SP_EL1` | `SP_EL2` | `SP_EL3`
#### [SIMD & Floating-Point Registers](1#simd-%26-floating-point-scalar-registers)

#### Saved Program Status Regsiters (SPSRs)
- Used to save PE state when taking exceptions, one register per level:
    - `SPSR_EL0` | `SPSR_EL1` | `SPSR_EL2` | `SPSR_EL3`
- When an exception is taken, the PE state is saved from PSTATE in the SPSR at the EL
  the exception is taken to. This means:
    - On return, restore the PE state to the state stored in the SPSR at the level
      the exception is returning from.
- All SPSRs are unknown on reset.

#### Exception Link Registers (ELRs)
- Hold preferred exception return addresses, on register per level:
    - `ELR_EL0` | `ELR_EL1` | `ELR_EL2` | `ELR_EL3`
- When a PE takes an exception, the preferred return address is saved in the ELR at
  the exeption level the exception is taken to.
- On exception return, the program counter is restored to the address stored in the
  ELR.

### Process State - PSTATE
- Abstraction of process information.

#### PSTATE Fields

| **Field**       | **Description**                                                                                       | **Reset Value**                  |
|------------------|-------------------------------------------------------------------------------------------------------|-----------------------------------|
| **Condition Flags**                                                                                                      |                                   |
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
| **Exception Mask Bits**                                                                                                  |                                   |
| `D`             | Debug exception mask bit. Set to `1` on reset or exception to AArch64.                                | `1`                               |
| `A`             | SError interrupt mask bit.                                                                            | `1`                               |
| `I`             | IRQ interrupt mask bit.                                                                               | `1`                               |
| `F`             | FIQ interrupt mask bit.                                                                               | `1`                               |
| **Access Control Bits**                                                                                                  |                                   |
| `PAN`           | Privileged Access Never bit. Requires `FEAT_PAN` to be implemented.                                   |                                   |
| `UAO`           | User Access Override bit. Requires `FEAT_UAO` to be implemented.                                      |                                   |
| `TCO`           | Tag Check Override bit. Requires `FEAT_MTE` to be implemented.                                        |                                   |
| **Branch Control Bits**                                                                                                  |                                   |
| `BTYPE`         | Branch target identification bit. Requires `FEAT_BTI` to be implemented.                              |                                   |
| **Timing Control Bits**                                                                                                  |                                   |
| `DIT`           | Data Independent Timing bit. Requires `FEAT_DIT` to be implemented. Set to `0` on reset to AArch64.   | `0`                               |
| **Speculation Control Bits**                                                                                            |                                   |
| `SSBS`          | Speculative Store Bypass Safe bit. Requires `FEAT_SSBS` to be implemented.                            | IMPLEMENTATION DEFINED value      |

#### Accessing PSTATE Fields
