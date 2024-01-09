#ifndef __LLTRISCV_ELF_IMAGE_H__
#define __LLTRISCV_ELF_IMAGE_H__

#include <map>
#include <stdint.h>
#include <stdlib.h>

struct mem_flag
{
    uint32_t mem_sp;
    uint32_t mem_ep;

    bool operator<(const mem_flag &o) const
    {
        return mem_ep < o.mem_ep;
    }
};

struct SectionSummary
{
    size_t section_text_size;
    size_t section_data_size;
    size_t section_rodata_size;
    size_t section_bss_size;
};

class lltriscv_elf_image
{
private:
    std::map<mem_flag, uint8_t *> mem;

public:
    SectionSummary loadELF(const char *path);
    uint8_t *mmap(uint32_t start, size_t length);
    uint8_t *memv(uint32_t addr);
    ~lltriscv_elf_image();
};

#endif