#include <stdio.h>
typedef unsigned int uint32_t;

static inline int clz_beta(uint32_t x) {
    return __builtin_clz(x);
}

int main(){
    printf("%d\n",clz_beta(1));
    printf("%d\n",clz_beta(-1));
    printf("%d\n",clz_beta(666666));
    printf("%d\n",clz_beta(2147483647));
    printf("%d\n",clz_beta(123));
    return 1;
}