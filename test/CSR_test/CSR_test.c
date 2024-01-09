#include <core_test.h>

#define bool unsigned char

bool read_misa_test()
{
    int result = 0;
    int input = 0;
    __asm__(
        "csrrw %0,misa,%1"
        : "=r"(result)
        : "r"(input));

    return result == 0b01000000000000000000000100000000;
}

bool write_swap_mtval_test()
{
    int result = 0;
    __asm__(
        "csrrwi %0,mtval,17"
        : "=r"(result)
        :);
    __asm__(
        "csrrwi %0,mtval,0"
        : "=r"(result)
        :);
    return result == 17;
}

bool write_set_reset_mtval_test()
{
    int result = 0;
    __asm__(
        "csrrsi %0,mtval,17"
        : "=r"(result)
        :);
    __asm__(
        "csrrci %0,mtval,16"
        : "=r"(result)
        :);
    __asm__(
        "csrrwi %0,mtval,0"
        : "=r"(result)
        :);
    return result == 1;
}

bool read_mcycle_test()
{
    static int mcycle = 0;
    static int mcycleh = 0;
    static int minstret = 0;
    static int minstreth = 0;
    __asm__(
        "csrrci %0,mcycle,0"
        : "=r"(mcycle)
        :);
    __asm__(
        "csrrci %0,mcycleh,0"
        : "=r"(mcycleh)
        :);
    __asm__(
        "csrrci %0,minstret,0"
        : "=r"(minstret)
        :);
    __asm__(
        "csrrci %0,minstreth,0"
        : "=r"(minstreth)
        :);
    return 1;
}

int main()
{
    bool res = 1;
    res &= read_misa_test();
    res &= write_swap_mtval_test();
    res &= write_set_reset_mtval_test();
    res &= read_mcycle_test();
    core_assert(res);
    return 0;
}