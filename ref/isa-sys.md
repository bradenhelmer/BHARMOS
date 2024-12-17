# ArmV8-A Architecture Notes - ISA & System Level Programming
**CPU:** Cortex-A72

[**Reference Manual**](https://developer.arm.com/documentation/ddi0487/fc/)

## Table of Contents
- [General Notes](#1.-general-notes-(see-part-a-of-the-manual))
    - [Execution State](#execution-state%3A-aarch64)
    - [System Registers](#system-registers)
    - [Data Types](#data-types)
    - [Memory Model](#memory-model)
- [Instruction Set](#2.-instruction-set-(see-part-c-of-the-manual))
    - [General-Purpose Regsiters](#general-purpose-registers-(gprs))
    - [SIMD & Floating-Point Scalar Registers](#simd-%26-floating-point-scalar-registers)
      - [`V` Register Use Examples](#examples-of-using-the-v-register-as-a-vector)
    - [Condition Codes](#condition-codes)
    - [Addressing Modes](#addressing-modes)
- [System Level Programming Information](#system-level-programming-information-(see-part-d-of-manual))
  - [Exception Levels](#exception-levels)
    - [Moving Between Exception Levels](#moving-between-exception-levels)
    - [Precise Exceptions](#precise-exceptions)
    - [Synchronous & Asynchronous Exceptions](#synchronous-%26-asynchronous-exceptions)
      - [Synchronous Exceptions](#synchronous-exceptions%3A)
      - [Asynchronous Exceptions](#asynchronous-exceptions%3A)
  - [Excecution State](#execution-state)
  - [Registers for Instruction Processing and Exception Handling](#registers-for-instruction-processing-and-exception-handling)
    - [General Purpose Registers](#general-purpose-registers)
    - [SIMD & Floating-Point Regsiers](#simd-%26-floating-point-registers)
    - [Stack Pointer](#stack-pointer)
    - [Saved Program Status Registers (SPSRs)](#saved-program-status-regsiters-(spsrs))
    - [Exception Link Regsiters](#exception-link-registers-(elrs))
  - [Process State (PSTATE)](#process-state---pstate)
  - [Reset](#reset)
    - [AArch64 Reset PE State](#pe-state-on-reset-to-aarch64-state-(see-d1.9.1-in-manual))
  - [Exception Entry](#exception-entry)
    - [Preferred Exception Return Address](#preferred-exception-return-address)
    - [Exception Vectors](#exception-vectors)
    - [Exception Classes and `ESR_ELx` Registers](#exception-classes-and-esr_elx-registers)
  - [Exception Return](#exception-return)
  - [Synchronous Exception Types](#synchronous-exception-types)
    - [Floating-Point Exceptions](#floating-point-exceptions)
  - [Asynchronous Exception Types (Interrupts)](#asynchronous-exception-types-(interrupts))
  - [System Calls](#system-calls)

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
| Name | Size      | Encoding | Description                           |
|------|-----------|----------|---------------------------------------|
| Wn   | 32 bits   | 0–30     | General-purpose register W0–W30       |
| Xn   | 64 bits   | 0–30     | General-purpose register X0–X30       |
| WZR  | 32 bits   | 31       | Zero register (write ignored, read 0) |
| XZR  | 64 bits   | 31       | Zero register (write ignored, read 0) |
| WSP  | 32 bits   | 31       | Current stack pointer (32-bit view)   |
| SP   | 64 bits   | 31       | Current stack pointer (64-bit view)   |

**Note:** `X30/W30` is used as the link register for procedure calls.

### SIMD & Floating-Point Scalar Registers
| Register Name | Size    | Description                                                                 |
|---------------|---------|-----------------------------------------------------------------------------|
| Bn            | 8 bits  | Byte-sized sub-register of SIMD/FP register (0–31).                         |
| Hn            | 16 bits | Halfword-sized sub-register of SIMD/FP register (0–31).                     |
| Sn            | 32 bits | Word-sized sub-register of SIMD/FP register (0–31).                         |
| Dn            | 64 bits | Doubleword-sized sub-register of SIMD/FP register (0–31).                   |
| Qn            | 128 bits| Full SIMD/FP register (0–31), used for 128-bit vector operations.           |
| Vn            | Variable| General-purpose SIMD/FP register (0–31), supports scalar and vector views.  |

#### Examples of using the `V` register as a vector
| Syntax      | Description                                                      |
|-------------|------------------------------------------------------------------|
| `Vn.16B`    | Access the vector as 16 bytes (8 bits each).                     |
| `Vn.8H`     | Access the vector as 8 halfwords (16 bits each).                 |
| `Vn.4S`     | Access the vector as 4 single-precision words (32 bits each).    |
| `Vn.2D`     | Access the vector as 2 double-precision words (64 bits each).    |
| `Vn.8B`     | Access the lower half of the vector as 8 bytes.                  |
| `Vn.4H`     | Access the lower half of the vector as 4 halfwords.              |
| `Vn.2S`     | Access the lower half of the vector as 2 single-precision words. |
| `Vn.D`      | Access the lower half of the vector as 1 double-precision word.  |


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
    - These registers may have the 't' or 'h' suffix from the 'thread' or 'handler' terminology
        - 't' Indicates the use of the `SP_EL0` stack pointer.
        - 'h' Indicates the use of the `SP_ELx` stack pointer.
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

### [Process State - PSTATE](./pstate.md)

### Reset
- **Cold Reset**: Resets all logic on which PE executes.
- **Warm Reset**: Resets _some_ logic on which PE executes. Some state is left unchanged.
- On a reset, the PE enters the **highest** implemented exception level.
- AArch64:
    - The stack pointer for the highest implemented exception level is selected.
    - Execution starts at a **IMPLEMENTATION DEFINED** address. **ANYWHERE** in the
      physical address range.
    - The reset vector base address register (`RVBAR_ELx`) in the highest implemented
      exception level holds this address.:
        - `RVBAR_EL1` | `RVBAR_EL2` | `RVBAR_EL3`

#### PE State on reset to AArch64 state (See D1.9.1 in manual)

### Exception Entry
- Exceptions will **never** cause execution to move to a lower exception level.
- PE State is saved in `SPSR_ELx` at target exception level.
- Preferred return address is saved in `ELR_ELx` at target exception level.
- Selected SP register is the dedicated `SP_ELx` register at the target exception level.
- Execution moves to the target exception level, starting at the address defined by the exception vector.
  - This vector is used to indicate whether the exception came from a lower level or the current level.

#### Preferred Exception Return Address
- **Asynchronous exceptions**: The address is the first instruction that was not executed or completed due to the interrupt.  
- **Synchronous exceptions (non-system calls)**: The address is the instruction causing the exception.  
- **Exception-generating instructions**: The address is the instruction immediately following the one causing the exception.

#### Exception Vectors
- On PE exception, execution is forced to the address that is the _exception vector_ for the given exception.
  - This exception vector lives in the _vector table_:
    - The table occupies word-aligned (32-bit) memory addresses, starting at the _vector table base address_ (VBAR).
    - Each exception level has its own VBAR.
    - The table indicates if the exception is one of the following:
      - Synchronous exception
      - SError
      - IRQ
      - FRQ
    - The vector table offsets can be found at table **D1-5** in the manual.

#### Exception Classes and `ESR_ELx` Registers
- `ESR_ELx` registers hold information about the reasoning for the exception if the exception is
  either a synchronous exception or an SError interrupt.
- The 32-bit ESR_ELx registers are formatted as follows:

| Bit Field | Bit Range | Description                                                                   |
|-----------|-----------|-------------------------------------------------------------------------------|
| `EC`      | `[31:26]` | Cause of exception                                                            |
| `IL`      | `[25]`    | Indicates 16 or 32-bit instruction length                                     |
| `ISS`     | `[24:0]`  | Instruction specific syndrome field, can be independently defiend for each EC |

- Each exception class and code can be found in table **D1-6** in the manual.

### Exception Return
- An exception return will **always** be to the same or lower exception level.
- Returns are used for:
  - Returning to a previously executing thread.
  - Entry to a new execution thhread.
- Requires the simultaneous restoration of the PC & PSTATE to values consistent with the desired
  state of execution returning from the exception. The processor coordinates this synchronization.
  - The PC is restored from `ELR_ELx`.
  - PSTATE is restored from `SPSR_ELx`
- Sets event register for PE executing the exception return instruction.
- The exception return instruction is undefined in `EL0`. 
- For illegal and legal return events, see section **D1.11.2** & **D1.11.3** in the manual.

### Synchronous Exception Types
- Any exception generated in the attempt to execute an UNDEFINED instruction:
  - Instructions at an inappropriate exception level.
  - Disabled instructions.
  - Instruction bit patterns that have not been allocated.
- Illegal execution state exceptions (`PSTATE.IL == 1`).
- Use of misaligned SP.
- Attempted to execute instruction with misaligned PC.
- Exception generating instructions `SVC`, `HVC`, or `SMC`.
- Traps on attempts to execute instructions that are trapped to higher exception levels
  according to system registers.
- Instruction aborts from attempted instruction execution from memory areas that generated faults
- Data aborts from attemped reads or writes of memory that generate faults.
- All debug exceptions.
- For instructions that generate multiple synchronous exceptions, the priority numbering hierarchy
  can be found in section **D1.12.4** of the manual

#### Floating-Point Exceptions
- Input Denormal.
- Inexact.
- Underflow.
- Overflow.
- Divide by zero.
- Invalid Operation.

### Asynchronous Exception Types (Interrupts)
- Two types of interrupts:
  - **Physical Interrupts** - Signals sent to the PE from the outside:
    - SError (System Error)
    - IRQ (Interrupt Request)
    - FRQ (Fast Interrupt Request)
  - **Virtual interrupts** - Only at EL2

### System Calls
- Generated by execution of instructions `SVC`, `HVC`, or `SMC`.
  - `SVC` generates a supervisor call by default that targets EL1.
