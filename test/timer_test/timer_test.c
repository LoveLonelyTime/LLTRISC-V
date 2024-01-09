#include <core_test.h>

#define esp 0.00001

int timer_interrupt_cnt = 0;

float myfabs(float a)
{
    return a < 0 ? -a : a;
}

void set_mtime(unsigned long val)
{
    *((unsigned long *)0x20000000) = val;
}

void set_mtimecmp(unsigned long val)
{
    *((unsigned long *)0x20000008) = val;
}

void trapHandler()
{
    timer_interrupt_cnt++;
    // Reset system timer
    set_mtime(0);

    if (timer_interrupt_cnt == 5)
    {
        // Disable system timer interrupt
        __asm__(
            "li a5, 128\n"
            "csrrc zero, mie, a5"
            :
            :);
    }
}

int main()
{
    set_mtime(0);
    set_mtimecmp(100);
    // Enable system timer interrupt and global interrupt
    __asm__(
        "li a5, 128\n"
        "csrrs zero, mie, a5\n"
        "csrrsi zero, mstatus, 8"
        :
        :);
    float pi = 3.1415926;
    float radius = 5.23;
    float area = pi * radius * radius;
    float res = 85.93166822;
    core_assert(timer_interrupt_cnt == 5);
    return 0;
}