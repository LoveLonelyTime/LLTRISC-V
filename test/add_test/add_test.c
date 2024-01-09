#include <core_test.h>

int arr_data[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
const int arr_rodata[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int arr_bss[11];
int main()
{
    int arr_len = sizeof(arr_data) / sizeof(int);
    for (int i = 1; i < arr_len; i++)
    {
        arr_bss[i] = arr_bss[i - 1] + arr_data[i] + arr_rodata[i];
    }
    core_assert(arr_bss[10] == 110);
    return 0;
}
