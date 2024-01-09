#include <core_test.h>

#define esp 0.00001

float myfabs(float a)
{
    return a < 0 ? -a : a;
}

int main()
{
    float pi = 3.1415926;
    float radius = 5.23;
    float area = pi * radius * radius;
    float res = 85.93166822;
    core_assert(myfabs(area - res) < esp);
    return 0;
}