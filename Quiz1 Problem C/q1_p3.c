#include <stdio.h>
#include <stdint.h>
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

static inline uint32_t fp16_to_fp32(uint16_t h) {
    const uint32_t w = (uint32_t) h << 16;
    printf("%x\n", w);
    const uint32_t sign = w & UINT32_C(0x80000000);
    printf("%x\n", sign);
    const uint32_t nonsign = w & UINT32_C(0x7FFFFFFF);
    printf("%x\n", nonsign);
    uint32_t renorm_shift = __builtin_clz(nonsign);
    renorm_shift = renorm_shift > 5 ? renorm_shift - 5 : 0;
    printf("%x\n", renorm_shift);
    const int32_t inf_nan_mask = ((int32_t)(nonsign + 0x04000000) >> 8) & INT32_C(0x7F800000);
    printf("%x\n", inf_nan_mask);
    const int32_t zero_mask = (int32_t)(nonsign - 1) >> 31;
    printf("%x\n", zero_mask );
    return sign | ((((nonsign << renorm_shift >> 3) + ((0x70 - renorm_shift) << 23)) | inf_nan_mask) & ~zero_mask);
}

int main(){
    // printf("%x\n",fp16_to_fp32(0x3C00));
    // printf("%x\n",fp16_to_fp32(0xC000));
    // printf("%x\n",fp16_to_fp32(0x7BFF));
    printf("%x\n",fp16_to_fp32(0x3555));
    // printf("%x\n",fp16_to_fp32(0x0400));
    return 1;
}