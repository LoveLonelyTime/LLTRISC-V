#define Core_Debug_Assert_Port 0x00000010
#define Core_Debug_Assert_OK 0x7F
#define Core_Debug_Assert_Unexpected 0x7C

void core_assert(int cond)
{
    *((int *)Core_Debug_Assert_Port) = cond ? Core_Debug_Assert_OK : Core_Debug_Assert_Unexpected;
}
