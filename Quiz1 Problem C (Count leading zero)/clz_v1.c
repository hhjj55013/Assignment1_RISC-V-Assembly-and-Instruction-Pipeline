#include <stdio.h>
typedef unsigned int uint32_t;

static inline int clz_v1(uint32_t x) {
    int count = 0;
    for (int i = 31; i >= 0; --i) {
        if (x & (1U << i))
            break;
        count++;
    }
    return count;
}

int main(){
    printf("%d",clz_v1(666666));
    return 1;
}