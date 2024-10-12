#include <stdio.h>
#include <limits.h>  // For CHAR_BIT

int bitwiseComplement_clz(int n) {
    // Use the leading zero count to create the mask
    int mask = (1U << (32 - __builtin_clz(n))) - 1;

    // XOR with mask to get the complement
    return n ^ mask;
}

int main() {
    int test[] = {0, 5, 7, 10};
    int test_size = sizeof(test) / sizeof(test[0]);

    for (int i = 0; i < test_size; i++) {
        printf("Binary complement of %d: %d\n", test[i], bitwiseComplement_clz(test[i]));
    }

    return 0;
}