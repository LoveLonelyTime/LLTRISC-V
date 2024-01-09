#include <core_test.h>

#define bool unsigned char

bool add_test()
{
    volatile int a = 56;
    volatile int b = 44;
    return a + b == 100;
}

bool sub_test()
{
    volatile int a = 32;
    volatile int b = 23423;
    return a - b == -23391;
}

bool shift_left_logical_test()
{
    volatile int a = 18;
    a = a << 4;
    return a == 288;
}

bool shift_right_logical_test()
{
    volatile unsigned char a = 128;
    a = a >> 4;
    return a == 8;
}

bool shift_right_arithmetic_test()
{
    volatile signed char a = -128;
    a = a >> 4;
    return a == -8;
}

bool or_test()
{
    volatile short a = 1255;
    volatile short b = 12555;
    return (a | b) == 13807;
}

bool and_test()
{
    volatile short a = 1255;
    volatile short b = 12555;
    return (a & b) == 3;
}

bool xor_test()
{
    volatile short a = 1255;
    volatile short b = 12555;
    return (a ^ b) == 13804;
}

bool multi_test()
{
    volatile int a = 34;
    volatile int b = 23;
    return a * b == 782;
}

bool div_test()
{
    volatile int a = 432;
    volatile int b = 23;
    return a / b == 18 && a % b == 18;
}

int main()
{
    bool res = 1;
    res &= add_test();
    res &= sub_test();
    res &= shift_left_logical_test();
    res &= shift_right_logical_test();
    res &= shift_right_arithmetic_test();
    res &= or_test();
    res &= and_test();
    res &= xor_test();
    res &= multi_test();
    res &= div_test();
    core_assert(res);
    return 0;
}