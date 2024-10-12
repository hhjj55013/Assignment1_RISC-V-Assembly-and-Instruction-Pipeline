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