#include <stdio.h>
typedef unsigned int uint32_t;

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
    x = (x >> 1) ? (x >> 1) : x;

    return n - (x & 1);
}

int main(){
    printf("%d",clz_v2(-1));
    return 1;
}