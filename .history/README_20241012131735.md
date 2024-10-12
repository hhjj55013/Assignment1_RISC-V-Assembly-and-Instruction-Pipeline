---
title: 'Assignment1: RISC-V Assembly and Instruction Pipeline'

---

# Assignment1: RISC-V Assembly and Instruction Pipeline
2024/10/10 Contributed by < [Huckle_H](https://github.com/hhjj55013/Assignment1_RISC-V-Assembly-and-Instruction-Pipeline) > 
###### tags: `RISC-V` `Computer architure 2024`



## Quiz1 Problem C
You will need to implement the ```fp16_to_fp32``` function, which converts a 16-bit floating-point number in IEEE half-precision format (bit representation) to a 32-bit floating-point number in IEEE single-precision format (bit representation). This implementation will avoid using any floating-point arithmetic and will utilize the ```clz``` function discussed earlier.

### C code
```c
static inline float fabsf(float x) {
    uint32_t i = *(uint32_t *)&x;
    i &= 0x7FFFFFFF;
    x = *(float *)&i;
    return x;
}
```
```c
static inline int my_clz(uint32_t x) {
    int count = 0;
    for (int i = 31; i >= 0; --i) {
        if (x & (1U << i))
            break;
        count++;
    }
    return count;
}
```
```c
static inline uint32_t fp16_to_fp32(uint16_t h) {

    const uint32_t w = (uint32_t) h << 16;
    const uint32_t sign = w & UINT32_C(0x80000000);
    const uint32_t nonsign = w & UINT32_C(0x7FFFFFFF);
    uint32_t renorm_shift = my_clz(nonsign);
    renorm_shift = renorm_shift > 5 ? renorm_shift - 5 : 0;
    const int32_t inf_nan_mask = ((int32_t)(nonsign + 0x04000000) >> 8) & INT32_C(0x7F800000);
    const int32_t zero_mask = (int32_t)(nonsign - 1) >> 31;
    return sign | ((((nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23)) | inf_nan_mask) & ~zero_mask);
}
```

### Test datas
#### Example 1
Input: ```0x3C00``` (half-precision 1.0)
Expected Output: ```0x3F800000``` (single-precision 1.0)

#### Example 2
Input: ```0xC000``` (half-precision -2.0)
Expected Output: ```0xC0000000``` (single-precision -2.0)

#### Example 3
Input: ```0x7BFF``` (half-precision largest finite positive value, approx 0.65504)
Expected Output: ```0x477FE000``` (single-precision 0.65504)

#### Example 4
Input: ```0x3555``` (half-precision positive value, approx 0.333251953)
Expected Output: ```0x3EAAA000``` (single-precision approx 0.333251953)

#### Example 5
Input: ```0x0400``` (half-precision smallest positive normalized value, approx. 0.00006103516)
Expected Output: ```0x38800000``` (single-precision approx. 0.00006103516)

#### Example 6
Input: ```0xFC00``` (half-precision -infinity)
Expected Output: ```0xFF800000``` (single-precision -infinity)

### RISC-V assembly
```bash=
.data
num_test:   .word 6
test:       .word 0x3C00, 0xC000, 0x7BFF, 0x3555, 0x0400, 0xFC00
answer:     .word 0x3F800000, 0xC0000000, 0x477FE000, 0x3EAAA000, 0x38800000, 0xFF800000
store:      .word 0x10000000
feedback1:  .string "Pass"
feedback2:  .string "Error"

.text
main:
    la      s0, num_test    # s0 = Addr(num_test)
    lw      s0, 0(s0)       # s0 = num_test
    la      s1, test        # s1 = Addr(test)
    la      s2, store       # s2 = Addr(store)
    lw      s2, 0(s2)       # s2 = 0x10000000
    la      s3, answer      # s3 = Addr(answer)
    addi    s0, s0, -1      # num_test--

#######################################################
# < Function >
#    Converts a 16-bit floating-point number in IEEE half-precision format 
#    to a 32-bit floating-point number in IEEE single-precision format.
#
# < Parameters >
#    a0 : unsigned short x (16-bit floating-point number)
#
# < Return Value >
#    a1 : unsigned int
#######################################################
# < Local Variable >
#    a2 : sign
#    a3 : nonsign
#    a4 : renorm_shift
#    a5 : inf_nan_mask
#    a6 : zero_mask
#######################################################

fp16_to_fp32:
    lhu     a0, 0(s1)       # a0 = (uint32_t) h
    slli    a0, a0, 16      # a0 = w = (uint32_t) h << 16
    li      a2, -2147483648 # a2 = UINT32_C(0x80000000)
    and     a2, a2, a0      # a2 = sign
    li      a3, 2147483647  # a3 = UINT32_C(0x7FFFFFFF)
    and     a3, a3, a0      # a3 = nonsign

# clz()
    mv      a0, a3          # a0 = nonsign
    li      t0, 32          # int n = 32 (zero count)
    srli    t1, a0, 16      # t1 = x >> 16
    beqz    t1, IF1         # if (x >> 16) == 0 branch
    addi    t0, t0, -16     # if t1 != 0, n-=16
    srli    a0, a0, 16      # If t1 != 0, x>>16
IF1:
    srli    t1, a0, 8       # t1 = x >> 8
    beqz    t1, IF2         # t1 = 1 if (x >> 8) == 0 branch
    addi    t0, t0, -8      # if t1 != 0, n-=8
    srli    a0, a0, 8       # If t1 != 0, x>>8
IF2:
    srli    t1, a0, 4       # t1 = x >> 4
    beqz    t1, IF3         # t1 = 1 if (x >> 4) == 0 branch
    addi    t0, t0, -4      # if t1 != 0, n-=4
    srli    a0, a0, 4       # If t1 != 0, x>>4
IF3:
    srli    t1, a0, 2       # t1 = x >> 2
    beqz    t1, IF4         # t1 = 1 if (x >> 2) == 0 branch
    addi    t0, t0, -2      # if t1 != 0, n-=2
    srli    a0, a0, 2       # If t1 != 0, x>>2
IF4:
    srli    t1, a0, 1       # t1 = x >> 1
    beqz    t1, IF5         # t1 = 1 if (x >> 1) == 0 branch
    addi    t0, t0, -1      # if t1 != 0, n--
    srli    a0, a0, 1       # If t1 != 0, x>>1
IF5:   
    andi    t1, a0, 1       # Check the last bit (x & 1)
    sub     a4, t0, t1      # a4 = renorm_shift = n - (x & 1)
    li      t0, 6           # t0 = 5
    bgeu    a4, t0, f_if1   # if (renorm_shift >= 6) branch
    mv      a4, zero        # if (renorm_shift <= 5) renorm_shift = 0
    j       f_if2           # jump to f_if2
f_if1:
    addi    a4, a4, -5      # if (renorm_shift >= 6) renorm_shift -= 5
f_if2:
    li      t0, 67108864
    add     t0, t0, a3      # t0 = (int32_t)(nonsign + 0x04000000)
    srai    t0, t0, 8       # t0 = (int32_t)(nonsign + 0x04000000) >> 8
    li      t1, 2139095040  # t1 = INT32_C(0x7F800000)
    and     a5, t0, t1      # a5 = inf_nan_mask
    addi    t0, a3, -1      # t0 = (int32_t)(nonsign - 1)
    srai    a6, t0, 31      # a6 = zero_mask

    sll     t0, a3, a4      # t0 = nonsign << renorm_shift
    srli    t0, t0, 3       # t0 = nonsign << renorm_shift >> 3
    li      t1, 112         # t1 = 0x70
    sub     t1, t1, a4      # t1 = 0x70 - renorm_shift
    slli    t1, t1, 23      # t1 = (0x70 - renorm_shift) << 23
    add     t0, t0, t1      # t0 = (nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23)
    or      t0, t0, a5      # t0 = t0 | inf_nan_mask
    not     t1, a6          # t1 = ~zero_mask
    and     t0, t0, t1      # t0 = t0 | ~zero_mask
    or      a1, t0, a2      # t0 = sign | t0
# Compare the result
    sw      a1, 0(s2)       # MEM[Addr(answer)] = return value
    lw      t0, 0(s3)       # t0 = answer
    bne     a1, t0, Error
# Preparing next test
    addi    s0, s0, -1      # num_test--
    addi    s1, s1, 4       # Addr(test) += 4
    addi    s2, s2, 4       # Addr(store) += 4
    addi    s3, s3, 4       # Addr(answer) += 4
    bge     s0, x0, fp16_to_fp32 # if(num_test >= 0) continue fp16_to_fp32
    la      a0, feedback1   # Print "Pass"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
Error:
    la      a0, feedback2   # Print "Error"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
```



## Quiz1 Problem C (Count leading zero)
In quiz1 problem c, it apply a GCC built in function ```int __builtin_clz (unsigned int x)``` , which returns the number of leading 0-bits in x, starting at the most significant bit position. If ```x``` is 0, the result is undefined.

### C programing solution
#### clz_beta.c
Built-in Function: int __builtin_clz (unsigned int x)
Returns the number of leading 0-bits in x, starting at the most significant bit position. If x is 0, the result is undefined.

Data from ["Other Built-in Functions Provided by GCC"](https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html).

```c=
static inline int clz_beta(uint32_t x) {
    return __builtin_clz(x);
}
```

#### clz_v1.c
The implement of ```int __builtin_clz (unsigned int x)``` is given by the problem, which is the first version of clz_v1().

```c=
static inline int clz_v1(uint32_t x) {
    int count = 0;
    for (int i = 31; i >= 0; --i) {
        if (x & (1U << i))
            break;
        count++;
    }
    return count;
}
```

#### clz_v2.c
The improved version use a thought of 2-based counting. It starts with assuming there is 32 zeros in the unsigned interger. Then detects whether half of the interger is zero. Repeat the step 5 times from 16, 8, 4, 2, 1. Finally return the result back to the caller.

```c=
static inline int clz_v2(uint32_t x) {
    int n = 32; // Start with 32 leading zeroes
    
    n -= (x >> 16) ? 16 : 0;
    x = (x >> 16) ? (x >> 16) : x;
    
    n -= (x >> 8) ? 8 : 0;
    x = (x >> 8) ? (x >> 8) : x;
    
    n -= (x >> 4) ? 4 : 0;
    x = (x >> 4) ? (x >> 4) : x;
    
    n -= (x >> 2) ? 2 : 0;
    x = (x >> 2) ? (x >> 2) : x;
    
    n -= (x >> 1) ? 1 : 0;
    return n - (x & 1);
}
```


### RISC-V assembly solutions

#### clz_beta.s
Using RISC-V rv32gc clang 18.1.0 compiler compile clz_beta.c, we get the code below.
```bash=
.data
num_test:   .word 5
test:       .word 1, -1, 666666, 2147483647, 123
answer:     .word 31, 0, 12, 1, 25
store:      .word 0x10000000
feedback1:  .string "Pass"
feedback2:  .string "Error"

.text
main:
    la      s0, num_test    # s0 = Addr(num_test)
    lw      s0, 0(s0)       # s0 = num_test
    la      s1, test        # s1 = Addr(test)
    la      s2, store       # s2 = Addr(store)
    lw      s2, 0(s2)       # s2 = 0x10000000
    la      s3, answer      # s3 = Addr(answer)
    addi    s0, s0, -1      # num_test--

#######################################################
# < Function >
#    Count leading zeros
#
# < Parameters >
#    a0 : unsigned int x
#
# < Return Value >
#    a0 : unsigned int x
#######################################################
clz_beta:
    lw      a0, 0(s1)       # a0 = uint32_t x
    srli    a1, a0, 1
    or      a0, a0, a1
    srli    a1, a0, 2
    or      a0, a0, a1
    srli    a1, a0, 4
    or      a0, a0, a1
    srli    a1, a0, 8
    or      a0, a0, a1
    srli    a1, a0, 16
    or      a0, a0, a1
    not     a0, a0
    srli    a1, a0, 1
    lui     a2, 349525
    addi    a2, a2, 1365
    and     a1, a1, a2
    sub     a1, a0, a1
    lui     a0, 209715
    addi    a2, a0, 819
    and     a0, a1, a2
    srli    a1, a1, 2
    and     a1, a1, a2
    add     a0, a0, a1
    srli    a1, a0, 4
    add     a0, a0, a1
    lui     a1, 61681
    addi    a1, a1, -241
    and     a0, a0, a1
    lui     a1, 4112
    addi    a1, a1, 257
    mul     a0, a0, a1
    srli    a0, a0, 24
    sw      a0, 0(s2)       # MEM[Addr(answer)] = Final result
    # Preparing next test
    addi    s0, s0, -1      # num_test--
    addi    s1, s1, 4       # Addr(test) += 4
    addi    s2, s2, 4       # Addr(store) += 4
    addi    s3, s3, 4       # Addr(answer) += 4
    bge     s0, x0, clz_beta # if(num_test >= 0) continue fp16_to_fp32
    la      a0, feedback1   # Print "Pass"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
Error:
    la      a0, feedback2   # Print "Error"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
```

#### clz_v1.s
Try to transform the code from clz_v1.c to clz_v1.s which is RISC-V assembly.
```bash=
.data
num_test:   .word 5
test:       .word 1, -1, 666666, 2147483647, 123
answer:     .word 31, 0, 12, 1, 25
store:      .word 0x10000000
feedback1:  .string "Pass"
feedback2:  .string "Error"

.text
main:
    la      s0, num_test    # s0 = Addr(num_test)
    lw      s0, 0(s0)       # s0 = num_test
    la      s1, test        # s1 = Addr(test)
    la      s2, store       # s2 = Addr(store)
    lw      s2, 0(s2)       # s2 = 0x10000000
    la      s3, answer      # s3 = Addr(answer)
    addi    s0, s0, -1      # num_test--

#######################################################
# < Function >
#    Count leading zeros
#
# < Parameters >
#    a0 : unsigned int x
#
# < Return Value >
#    a1 : int count
#######################################################
# < Local Variable >
#    s0 : num_test
#    s1 : Addr(test)
#    s2 : Addr(answer)
#    t0 : i
#######################################################
clz:
    lw      a0, 0(s1)       # a0 = uint32_t x
    mv      a1, x0          # int count = 0;
    li      t0, 31          # int i = 31; 

Loop:
    addi    t1, x0, 1       # t1 = 1U
    sll     t1, t1, t0      # t1 = 1U << i
    and     t1, a0, t1      # t1 = x & (1U << i)
    bne     t1, x0, End_Loop # if (x & (1U << i)) break
    addi    a1, a1, 1       # count++;
    addi    t0, t0, -1      # --i
    bge     t0, x0, Loop    # if(i>=0) continue loop

End_Loop:
    sw      a1, 0(s2)       # MEM[Addr(answer)] = count

    # Preparing next test
    addi    s0, s0, -1      # num_test--
    addi    s1, s1, 4       # Addr(test) += 4
    addi    s2, s2, 4       # Addr(store) += 4
    addi    s3, s3, 4       # Addr(answer) += 4
    bge     s0, x0, clz     # if(num_test >= 0) continue fp16_to_fp32
    la      a0, feedback1   # Print "Pass"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
Error:
    la      a0, feedback2   # Print "Error"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
```

#### clz_v2.s
In this improved version of counting leading zeros, I minimized the need of branch. Which can save a lot of time doing real caculation and prevent branch prediction loss. Additionally, using shift instead of addition or substraction can save a lot of time and increase CPU efficiency.
```bash=
.data
num_test:   .word 5
test:       .word 1, -1, 666666, 2147483647, 123
answer:     .word 31, 0, 12, 1, 25
store:      .word 0x10000000
feedback1:  .string "Pass"
feedback2:  .string "Error"

.text
main:
    la      s0, num_test    # s0 = Addr(num_test)
    lw      s0, 0(s0)       # s0 = num_test
    la      s1, test        # s1 = Addr(test)
    la      s2, store       # s2 = Addr(store)
    lw      s2, 0(s2)       # s2 = 0x10000000
    la      s3, answer      # s3 = Addr(answer)
    addi    s0, s0, -1      # num_test--

#######################################################
# < Function >
#    Count leading zeros
#
# < Parameters >
#    a0 : unsigned int x
#
# < Return Value >
#    a1 : n - (x & 1)
#######################################################
# < Local Variable >
#    s0 : num_test
#    s1 : Addr(test)
#    s2 : Addr(answer)
#    t0 : n
#######################################################
clz:
    lw      a0, 0(s1)       # a0 = uint32_t x
    li      t0, 32          # int n = 32 (zero count)
    
    srli    t1, a0, 16      # t1 = x >> 16
    beqz    t1, IF1         # if (x >> 16) == 0 branch
    addi    t0, t0, -16     # if t1 != 0, n-=16
    srli    a0, a0, 16      # If t1 != 0, x>>16
IF1:
    srli    t1, a0, 8       # t1 = x >> 8
    beqz    t1, IF2         # t1 = 1 if (x >> 8) == 0 branch
    addi    t0, t0, -8      # if t1 != 0, n-=8
    srli    a0, a0, 8       # If t1 != 0, x>>8
IF2:
    srli    t1, a0, 4       # t1 = x >> 4
    beqz    t1, IF3         # t1 = 1 if (x >> 4) == 0 branch
    addi    t0, t0, -4      # if t1 != 0, n-=4
    srli    a0, a0, 4       # If t1 != 0, x>>4
IF3:
    srli    t1, a0, 2       # t1 = x >> 2
    beqz    t1, IF4         # t1 = 1 if (x >> 2) == 0 branch
    addi    t0, t0, -2      # if t1 != 0, n-=2
    srli    a0, a0, 2       # If t1 != 0, x>>2
IF4:
    srli    t1, a0, 1       # t1 = x >> 1
    beqz    t1, IF5         # t1 = 1 if (x >> 1) == 0 branch
    addi    t0, t0, -1      # if t1 != 0, n--
    srli    a0, a0, 1       # If t1 != 0, x>>1
IF5:   
    andi    t1, a0, 1       # Check the last bit (x & 1)
    sub     a1, t0, t1      # Final result = n - (x & 1)
    sw      a1, 0(s2)       # MEM[Addr(answer)] = Final result

    # Preparing next test
    addi    s0, s0, -1      # num_test--
    addi    s1, s1, 4       # Addr(test) += 4
    addi    s2, s2, 4       # Addr(store) += 4
    addi    s3, s3, 4       # Addr(answer) += 4
    bge     s0, x0, clz     # if(num_test >= 0) continue fp16_to_fp32
    la      a0, feedback1   # Print "Pass"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
Error:
    la      a0, feedback2   # Print "Error"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
```
---
### Result
By using Ripes v2.2.6-win-x86_64 with 5-stage processor here are some execution info that we can compare the result between different versions.
1. Cycles: This represents the total number of clock cycles taken to execute the program or specific code segment. A lower cycle count generally indicates faster execution.
2. Instrs. Retired: This refers to the total number of instructions that were completed and retired by the CPU. An instruction is "retired" when it has completed execution and its results are written back. This is an indicator of the instruction count the CPU processed.
3. CPI (Cycles Per Instruction): This is calculated as CPI = Cycles / Instrs. Retired. It represents the average number of cycles required to execute each instruction. Lower CPI values are generally better, as they indicate more efficient instruction execution.
4. IPC (Instructions Per Cycle): This is calculated as IPC = Instrs. Retired / Cycles. IPC indicates the average number of instructions completed per cycle. Higher IPC values mean the CPU is handling more work per cycle, indicating better utilization.
5. Clock Rate: This is the speed of the CPU in hertz (Hz). In this case, it is very low (123.46 Hz), likely due to a simulation environment or power-saving mode. Higher clock rates allow more cycles per second, which typically increases performance.


| Version | Cycles | Instrs. Retired | CPI | IPC |
| :--------: | :--------: | :--------: | :--------: | :--------: |
| clz_beta.s | 215 | 196 | 1.10🏆 | 0.912 |
| clz_v1.s | 716 | 554 | 1.29 | 0.774🏆 |
| clz_v2.s | 170🏆 | 134🏆 | 1.27 | 0.788 |

As the result shows that the version of my_clz( ) shown on Quiz1 problem C needs a great number of cycles to finish the task. At the same time, the improved version (clz_v2.s) has the best performance which only requires 170 cycle to complete.

---

## Problem (Leetcode 1009)

#### [Leetcode 1009 Complement of Base 10 Integer](https://leetcode.com/problems/complement-of-base-10-integer)

The complement of an integer is the integer you get when you flip all the 0's to 1's and all the 1's to 0's in its binary representation.

For example, The integer 5 is "101" in binary and its complement is "010" which is the integer 2. Given an integer $n$, return its complement.

Constraints: 0 <= $n$ < 109

### Test datas
#### Example 1
Input: $n$ = 5
Output: 2
5 is "101" in binary, with complement "010" in binary, which is 2 in base-10.

#### Example 2
Input: $n$ = 7
Output: 0
7 is "111" in binary, with complement "000" in binary, which is 0 in base-10.
Example 3:

#### Example 3
Input: $n$ = 10
Output: 5
10 is "1010" in binary, with complement "0101" in binary, which is 5 in base-10.



### C programing solution
#### Leetcode1009_v1.c
The first version trys to solve the problem how human calculate it, but the method seemed too complicate which requires too much steps for the computer. Multipile ```for``` loops and function calling resulting in poor efficiency.

Here is the proceedure in Leetcode1009_v1.c:
1. Input testcase using interger.
2. Transform the testcase from interger to binary.
3. Do binary complement.
4. Transform the complement testcase from binary back to interger.
5. Print the result.

```c=
bool *dec_to_bin(int input, int *size){
    bool *output = calloc(1, sizeof(bool));
    *size = 0;
    while (input > 0){
        output = realloc(output, (*size + 1) * sizeof(bool));
        output[*size] = input % 2;
        input /= 2;
        (*size)++;
    }
    return output;
}

int bin_to_dec(bool* input, int size){
    int output = 0;
    for (int i = 0; i < size; i++){
        output += input[i] * pow(2, i);
    }
    return output;
}

int bitwiseComplement(int n){
    if(n==0){
        // Deal with special case
        return 1;
    }else{
        int bin_size;

        // Transform the testcase fron decimal to binary
        bool* test_bin = dec_to_bin(n, &bin_size);

        // Invert binary digits
        for (int j = 0; j < bin_size; j++){
            test_bin[j] = !test_bin[j];
        }

        // Convert back to decimal and print the result
        int ans = bin_to_dec(test_bin, bin_size);

        // Free the memory
        free(test_bin);
        return ans;
    }
}
```

#### Leetcode1009_v2.c
As Leetcode1009_v1.c is written by human thoughts, it is quite unefficient for computers to run. So I use the idea of bitwise operations to compute the complement of a number.

Here's how it work:
1. Handling the special case when ```n``` equals zero using ```if(n == 0)```.
2. Creat a mask to prevent the computer computing the meaningless zeros in the binary form number.
3. Using bitwise NOT```~``` to compute the complement of a number.
4. Using bitwise AND```&``` to trigger the mask.
5. Print the result.

```c=
int bitwiseComplement(int n){
    if(n == 0)
        // Deal with special case
        return 1;
    int temp = n;
    int mask = 0;
    while(temp){
        mask = (mask << 1) | 1;
        temp = temp >> 1;
    }
    return (~n) & mask;
}
```

#### Leetcode1009_v3.c
Although Leetcode1009_v2.c is written by bitwise operations, but it still requires a lot of while loop procedure. Instead I create a more efficient mask, using log2(n) to determine the number of bits required to represent ```n```. This is more efficient than using a loop to count the bits.

For an input ```n``` = 5:
1. log2(5) evaluates to 2.
2. ((1 << (2 + 1)) - 1) becomes ((1 << 3) - 1) which is 111 in binary, or 7 in decimal.
3. n ^ mask becomes 5 ^ 7, which is 2 (binary 010), the bitwise complement within the bit-length of 5.

```c=
int bitwiseComplement_log2(int n) {
    if (n == 0) return 1;  // Special case for 0
    
    // Find the number of bits required to represent n
    int mask = (1 << ((int)log2(n) + 1)) - 1;
    
    // XOR with mask to get the complement
    return n ^ mask;
}
```

#### Leetcode1009_v4.c
As a result, Leetcode1009_v3.c is very efficiency but it needs math.h to support the function of ```(int)log2(n)```. Which is quite difficult to modify at assembly code. By replacing it with the fuction "Count leading zero" in front of the note I just mentioned. Can easy the RISC-V assembly code which computes it.

```c=
int bitwiseComplement_clz(int n) {
    // Use the leading zero count to create the mask
    int mask = (1U << (32 - __builtin_clz(n))) - 1;

    // XOR with mask to get the complement
    return n ^ mask;
}
```


### RISC-V assembly solutions
#### Leetcode1009_v4.s
```bash=
.data
num_test:   .word 4
test:       .word 5, 7, 10, 0
answer:     .word 2, 0, 5, 1
store:      .word 0x10000000
feedback1:  .string "Pass"
feedback2:  .string "Error"

.text
main:
    la      s0, num_test    # s0 = Addr(num_test)
    lw      s0, 0(s0)       # s0 = num_test
    la      s1, test        # s1 = Addr(test)
    la      s2, store       # s2 = Addr(store)
    lw      s2, 0(s2)       # s2 = 0x10000000
    la      s3, answer      # s3 = Addr(answer)
    addi    s0, s0, -1      # num_test--

#######################################################
# < Function >
#    Complement of Base 10 Integer
#
# < Parameters >
#    a0 : int x
#
# < Return Value >
#    a1 : int
#######################################################
# < Local Variable >
#    s0 : num_test
#    s1 : Addr(test)
#    s2 : Addr(answer)
#    t0 : n
#######################################################
COB:
    lw      a0, 0(s1)       # a0 = uint32_t x
# clz:
    mv      a2, a0
    li      t0, 32          # int n = 32 (zero count)
    srli    t1, a2, 16      # t1 = x >> 16
    beqz    t1, IF1         # if (x >> 16) == 0 branch
    addi    t0, t0, -16     # if t1 != 0, n-=16
    srli    a2, a2, 16      # If t1 != 0, x>>16
IF1:
    srli    t1, a2, 8       # t1 = x >> 8
    beqz    t1, IF2         # t1 = 1 if (x >> 8) == 0 branch
    addi    t0, t0, -8      # if t1 != 0, n-=8
    srli    a2, a2, 8       # If t1 != 0, x>>8
IF2:
    srli    t1, a2, 4       # t1 = x >> 4
    beqz    t1, IF3         # t1 = 1 if (x >> 4) == 0 branch
    addi    t0, t0, -4      # if t1 != 0, n-=4
    srli    a2, a2, 4       # If t1 != 0, x>>4
IF3:
    srli    t1, a2, 2       # t1 = x >> 2
    beqz    t1, IF4         # t1 = 1 if (x >> 2) == 0 branch
    addi    t0, t0, -2      # if t1 != 0, n-=2
    srli    a2, a2, 2       # If t1 != 0, x>>2
IF4:
    srli    t1, a2, 1       # t1 = x >> 1
    beqz    t1, IF5         # t1 = 1 if (x >> 1) == 0 branch
    addi    t0, t0, -1      # if t1 != 0, n--
    srli    a2, a2, 1       # If t1 != 0, x>>1
IF5:   
    andi    t1, a2, 1       # Check the last bit (x & 1)
    sub     a2, t0, t1      # Final result = n - (x & 1)
# out
    li      t0, 32          # t0 = 32
    sub     t0, t0, a2      # t0 = 32 - __builtin_clz(n)
    li      t1, 1           # t1 = 1U
    sll     t0, t1, t0      # 1U << 1U << (32 - __builtin_clz(n))
    addi    t0, t0, -1      # t0 = mask = (1U << (32 - __builtin_clz(n))) - 1
    xor     a1, t0, a0      # Final result = n ^ mask
    sw      a1, 0(s2)       # MEM[Addr(answer)] = Final result
# Preparing next test
    addi    s0, s0, -1      # num_test--
    addi    s1, s1, 4       # Addr(test) += 4
    addi    s2, s2, 4       # Addr(store) += 4
    addi    s3, s3, 4       # Addr(answer) += 4
    bge     s0, x0, COB     # if(num_test >= 0) continue fp16_to_fp32
    la      a0, feedback1   # Print "Pass"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
Error:
    la      a0, feedback2   # Print "Error"
    li      a7, 4           # Ripes system call "PrintString"
    ecall                   # retrun
    li      a7, 10          # Ripes system call "Exit"
    ecall                   # retrun
```

## 5 Stages Pipeline CPU Analysis
The 5-stage RISC-V pipeline is a classic CPU pipeline architecture commonly used in RISC (Reduced Instruction Set Computer) processors, like the RISC-V architecture. This type of pipeline divides the processing of each instruction into five distinct stages, allowing the processor to execute multiple instructions simultaneously by overlapping stages. Each stage completes a part of the instruction in a single clock cycle, thereby improving throughput and overall performance

![image](https://hackmd.io/_uploads/S1ynayDykg.png)

Besides, I will use the code below as example to demostrate the functions of each stage in the 5 stage pipeline CPU.

```bash=
add x10, x11, x12  # x10 = x11 + x12
sub x12, x10, x11  # x12 = x10 - x11
lw  x11, 0(x10)    # x11 = Memory[x10 + 0]
```
![image](https://hackmd.io/_uploads/BkyBFJvJkx.png)

### 1. Instruction Fetch (IF)
In this stage, the instruction is fetched from the instruction memory. The program counter (PC) provides the address for the instruction memory, and the instruction is retrieved based on this address. The PC is shown connected to the instruction memory. It’s incremented by 4 for the next instruction or by an offset if a branch is taken. The compressed decoder may decode compressed instructions if supported by the CPU.

Control Signals:
1. PC enable: Controls whether the PC updates for the next cycle.
2. Multiplexers: Choose between sequential or branch addresses.

Examples:
1. Cycle 1: The ```add x10, x11, x12``` instruction is fetched from instruction memory. The PC is incremented to point to the next instruction.
1. Cycle 2: While the add instruction moves to the next stage, the ```sub x12, x10, x11``` instruction is fetched.
1. Cycle 3: While the add and sub instructions are in subsequent stages, the ```lw x11, 0(x10)``` instruction is fetched.

![image](https://hackmd.io/_uploads/H1Lv4FD1Jx.png)


### 2. Instruction Decode (ID)
The fetched instruction is decoded to understand which operation to perform. During this stage, the control signals are generated, and the necessary registers are read. The instruction from IF is passed to the decode unit, which interprets the opcode and sets control signals. Register file reads (for Reg1 and Reg2) are also done here, and the immediate value is extracted if needed.

Control Signals:
1. Decode enable/clear: Clears or enables the decode pipeline register based on pipeline control signals.
2. Register enable: Controls register read and write operations.

Examples:
1. Cycle 2: The ```add x10, x11, x12``` instruction enters the decode stage. The control unit decodes the instruction, and the register file reads the values of x11 and x12, which are needed for the addition.
1. Cycle 3: The ```sub x12, x10, x11``` instruction is decoded, and x10 and x11 are read from the register file.
1. Cycle 4: The ```lw x11, 0(x10)``` instruction is decoded. The value in x10 is read to calculate the memory address for loading, and the control signals are set for a load operation.

![image](https://hackmd.io/_uploads/B1PdVtvyJx.png)


### 3. Execute (EX)
In this stage, the ALU performs arithmetic and logical operations. If it’s a branch instruction, the branch condition is evaluated here. The ALU takes two operands (Op1 and Op2) and performs operations as specified by the instruction. There is also a branch module that determines if a branch should be taken.

Control Signals:
1. ALU operation select: Specifies the operation type (add, subtract, etc.).
2. Branch taken: Indicates if the branch condition is met.

Examples:
1. Cycle 3: The add x10, x11, x12 instruction enters the execute stage. The ALU performs x11+x12, and the result is prepared for the next stage.
2. Cycle 4: The sub x12, x10, x11 instruction enters the execute stage. The ALU performs x10−x11, and the result is prepared to be written back to x12.
3. Cycle 5: The lw x11, 0(x10) instruction enters the execute stage. The ALU computes the memory address by adding x10+0 to prepare for the memory access.

![image](https://hackmd.io/_uploads/H17KVtDyye.png)


### 4. Memory Access (MEM)
For load and store instructions, this stage accesses data memory. Load instructions read data from memory, and store instructions write data to memory. The EX/MEM pipeline register holds the data required for the memory stage. The data memory unit performs read or write operations.

Control Signals:
1. Wr en: Controls if the memory write is enabled.
2. Address and Data In: Specifies the memory address for the operation and the data for store instructions.

Examples:
1. Cycle 4: The add x10, x11, x12 instruction moves to the memory stage. Since this is a register operation, no memory access is required, and it immediately prepares to write back the result to x10.
2. Cycle 5: The sub x12, x10, x11 instruction moves to the memory stage. Like the add instruction, this is also a register operation, so no memory access is needed.
3. Cycle 6: The lw x11, 0(x10) instruction accesses memory. The computed address x10+0 is used to read a word from data memory, and the result is sent to the next stage.

![image](https://hackmd.io/_uploads/r1DcEYDJyg.png)


### 5. Write Back (WB)
In this final stage, the result from either the ALU (for arithmetic operations) or memory (for load operations) is written back to the register file. The MEM/WB pipeline register holds the data to be written back to the register file. A multiplexer selects between ALU results and data memory output.

Control Signals:
1. Register Write Enable: Controls whether data is written back to the registers.

Examples:
1. Cycle 5: The add x10, x11, x12 instruction enters the write-back stage. The result of x11+x12 is written back to register x10.
2. Cycle 6: The sub x12, x10, x11 instruction enters the write-back stage. The result of x10−x11 is written back to register x12.
3. Cycle 7: The lw x11, 0(x10) instruction enters the write-back stage. The data loaded from memory is written back to x11.

![image](https://hackmd.io/_uploads/HJJsNYwykg.png)

### Pipeline Overview
|Cycle|	IF|	ID|	EX|	MEM|WB|
|:----|:--|:--|:--|:---|:-|
|1	|add				
|2	|sub	|add			
|3	|lw	|sub	|add		
|4	|next instruction	|lw	|sub	|add	
|5	|	|next instruction	|lw	|sub	|add
|6	|	|	|next instruction	|lw	|sub
|7	|	|	|	|next instruction	|lw

![image](https://hackmd.io/_uploads/ByosVYv1kx.png)
![image](https://hackmd.io/_uploads/SJ73NFwkyx.png)
