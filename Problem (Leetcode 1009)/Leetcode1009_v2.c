#include <stdio.h>

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

int main(){
    // Testcases are in test[] array
    int test[] = {0, 5, 7, 10};
    int test_size = sizeof(test) / sizeof(test[0]);

    // Start translating every testcases
    for (int i = 0; i < test_size; i++){
        printf("Binary of %d \n", test[i]);
        int ans = bitwiseComplement(test[i]);
        printf("Inverted Binary Decimal Output: %d\n", ans);
    }
    return 0;
}