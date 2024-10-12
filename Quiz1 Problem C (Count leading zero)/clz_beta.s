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