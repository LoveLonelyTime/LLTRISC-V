#include <core_test.h>

int C[100];
int n;

int lowbit(int x)
{
    return x & -x;
}

int sum(int x)
{
    int ret = 0;
    while (x > 0)
    {
        ret += C[x];
        x -= lowbit(x);
    }
    return ret;
}

void add(int x, int d)
{
    while (x <= n)
    {
        C[x] += d;
        x += lowbit(x);
    }
}

int main()
{
    n = 5;
    for (int i = 0; i < 100; i++)
        C[i] = 0;
    add(1, 1);
    add(2, 5);
    add(3, 4);
    add(4, 2);
    add(5, 3);

    add(1, 3);
    int t1 = sum(5) - sum(1);
    add(3, -1);
    add(4, 2);
    int t2 = sum(4) - sum(0);
    core_assert(t1 == 14 && t2 == 16);
    return 0;
}