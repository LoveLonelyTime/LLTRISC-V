#include <core_test.h>

void set_cmp(unsigned int val)
{
    *((unsigned int *)0x20000100) = val;
}

unsigned int read_status()
{
    return *((unsigned int *)0x20000108);
}

unsigned int set_status(unsigned int val)
{
    (*((unsigned int *)0x20000108)) |= val;
}

void set_data(unsigned int data)
{
    while ((read_status() & 1) != 0)
        ;
    *((unsigned int *)0x20000104) = data;
    set_status(1);
    while ((read_status() & 1) != 0)
        ;
}

void trapHandler()
{
}

int main()
{
    // Init cmp
    set_cmp(10);
    // Send data
    set_data(0x18);
    set_data(0x25);
    set_data(0x34);
    core_assert(1);
    return 0;
}