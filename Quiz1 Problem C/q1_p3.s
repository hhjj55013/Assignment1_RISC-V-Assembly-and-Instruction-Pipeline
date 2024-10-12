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