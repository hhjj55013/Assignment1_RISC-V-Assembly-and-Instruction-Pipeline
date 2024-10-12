#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

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