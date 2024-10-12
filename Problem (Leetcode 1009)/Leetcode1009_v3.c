#include <math.h>
#include <stdio.h>

int bitwiseComplement_log2(int n) {
    if (n == 0) return 1;  // Special case for 0
    
    // Find the number of bits required to represent n
    int mask = (1 << ((int)log2(n) + 1)) - 1;
    
    // XOR with mask to get the complement
    return n ^ mask;
}

int main() {
    int test[] = {0, 5, 7, 10};
    int test_size = sizeof(test) / sizeof(test[0]);

    for (int i = 0; i < test_size; i++) {
        printf("Binary complement of %d: %d\n", test[i], bitwiseComplement_log2(test[i]));
    }

    return 0;
}