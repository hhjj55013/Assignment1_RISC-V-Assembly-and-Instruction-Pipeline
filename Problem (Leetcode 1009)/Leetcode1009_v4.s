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