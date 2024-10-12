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