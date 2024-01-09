#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "/usr/include/elf.h"
#include "lltriscv_elf_image.h"
lltriscv_elf_image mem_image;

#define TEXT_SECTION_MAX 30720
#define DATA_SECTION_MAX 1024
#define RODATA_SECTION_MAX 8192
#define RAM_MAX 12288
#define Core_Memory_Copy_Start 0x00021C00

void dump_mem(const char *f_name, uint32_t addr, int block_size, int cnt)
{

    FILE *fpw = fopen(f_name, "wb");
    fprintf(fpw, "#File_format=Bin\n");
    fprintf(fpw, "#Address_depth=%d\n", cnt);
    fprintf(fpw, "#Data_width=%d\n", block_size * 8);
    uint8_t *ptr = (uint8_t *)mem_image.memv(addr);

    for (int i = 0; i < cnt; i++)
    {
        for (int j = block_size - 1; j >= 0; j--)
        {
            for (int k = 7; k >= 0; k--)
            {
                fprintf(fpw, "%d", (ptr[j] >> k) & 1);
            }
        }
        ptr += block_size;
        fprintf(fpw, "\n");
    }

    fclose(fpw);
}

int main(int argc, char **argv)
{
    // Load ELF file
    if (argc <= 1)
    {
        fprintf(stderr, "Error: No test input file.\n");
        return -1;
    }

    // Create IMEM 64KiB
    mem_image.mmap(0x00010000, 65536);
    // Create RODMEM 64KiB
    mem_image.mmap(0x00020000, 65536);
    // Create DMEM 64KiB
    mem_image.mmap(0x80000000, 65536);
    SectionSummary sectionSummary = mem_image.loadELF(argv[1]);

    // Memory security detection
    if (sectionSummary.section_text_size > TEXT_SECTION_MAX)
    {
        fprintf(stderr, "Text section exceeding size!\n");
        return -1;
    }

    if (sectionSummary.section_rodata_size > RODATA_SECTION_MAX - DATA_SECTION_MAX)
    {
        fprintf(stderr, "ROData section exceeding size!\n");
        return -1;
    }

    if (sectionSummary.section_data_size > DATA_SECTION_MAX)
    {
        fprintf(stderr, "Data section exceeding size! Unable to copy!\n");
        return -1;
    }

    if (sectionSummary.section_data_size + sectionSummary.section_bss_size > RAM_MAX)
    {
        fprintf(stderr, "Data + BSS section exceeding size!\n");
        return -1;
    }

    printf("Stack + Heap Remaining size: %d\n", RAM_MAX - sectionSummary.section_data_size - sectionSummary.section_bss_size);

    // Copy area
    memcpy(mem_image.memv(Core_Memory_Copy_Start), mem_image.memv(0x80000000), DATA_SECTION_MAX);

    // Dump memory
    dump_mem("program_text.mi", 0x00010000, 4, TEXT_SECTION_MAX / 4);
    dump_mem("program_rodata.mi", 0x00020000, 1, RODATA_SECTION_MAX);
    return 0;
}
