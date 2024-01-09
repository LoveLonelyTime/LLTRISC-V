#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string.h>

#include "/usr/include/elf.h"
#include "lltriscv_elf_image.h"

#define RT_THREAD_SECTION_NAME ".rti_fn"

static bool is_rt_thread_section(const char *s_name)
{
    char tmp[15];
    memset(tmp, 0, sizeof(tmp));
    if (strlen(s_name) < strlen(RT_THREAD_SECTION_NAME))
        return false;
    memcpy(tmp, s_name, strlen(RT_THREAD_SECTION_NAME));
    return strcmp(tmp, RT_THREAD_SECTION_NAME) == 0;
}

SectionSummary lltriscv_elf_image::loadELF(const char *path)
{
    FILE *fp = fopen(path, "rb");

    // Read elf_head
    Elf32_Ehdr elf_head;
    fread(&elf_head, sizeof(Elf32_Ehdr), 1, fp);

    // Read section table
    Elf32_Shdr *shdrs = (Elf32_Shdr *)malloc(sizeof(Elf32_Shdr) * elf_head.e_shnum);
    fseek(fp, elf_head.e_shoff, SEEK_SET);
    fread(shdrs, sizeof(Elf32_Shdr) * elf_head.e_shnum, 1, fp);

    // Read string section
    char *string_section = (char *)malloc(shdrs[elf_head.e_shstrndx].sh_size);
    fseek(fp, shdrs[elf_head.e_shstrndx].sh_offset, SEEK_SET);
    fread(string_section, shdrs[elf_head.e_shstrndx].sh_size, 1, fp);
    SectionSummary sectionSummary;
    // Load segments to memory
    for (int i = 0; i < elf_head.e_shnum; i++)
    {
        if (strcmp(".text", &string_section[shdrs[i].sh_name]) == 0)
        {
            uint8_t *segment_ptr = memv(shdrs[i].sh_addr);
            sectionSummary.section_text_size = shdrs[i].sh_size;
            fseek(fp, shdrs[i].sh_offset, SEEK_SET);
            fread(segment_ptr, shdrs[i].sh_size, 1, fp);
        }
        else if (strcmp(".data", &string_section[shdrs[i].sh_name]) == 0)
        {
            uint8_t *segment_ptr = memv(shdrs[i].sh_addr);
            sectionSummary.section_data_size = shdrs[i].sh_size;
            fseek(fp, shdrs[i].sh_offset, SEEK_SET);
            fread(segment_ptr, shdrs[i].sh_size, 1, fp);
        }
        else if (strcmp(".bss", &string_section[shdrs[i].sh_name]) == 0)
        {
            uint8_t *segment_ptr = memv(shdrs[i].sh_addr);
            sectionSummary.section_bss_size = shdrs[i].sh_size;
            memset(segment_ptr, 0, shdrs[i].sh_size);
        }
        else if (strcmp(".rodata", &string_section[shdrs[i].sh_name]) == 0)
        {
            uint8_t *segment_ptr = memv(shdrs[i].sh_addr);
            sectionSummary.section_rodata_size = shdrs[i].sh_size;
            fseek(fp, shdrs[i].sh_offset, SEEK_SET);
            fread(segment_ptr, shdrs[i].sh_size, 1, fp);
        }
    }

    // Free
    free(shdrs);
    free(string_section);
    fclose(fp);
    return sectionSummary;
}

uint8_t *lltriscv_elf_image::mmap(uint32_t start, size_t length)
{
    uint8_t *ptr = (uint8_t *)malloc(length);
    memset(ptr, 0, length);
    mem_flag flag;
    flag.mem_sp = start;
    flag.mem_ep = start + length - 1;
    mem[flag] = ptr;
    return ptr;
}

uint8_t *lltriscv_elf_image::memv(uint32_t addr)
{
    mem_flag flag;
    flag.mem_ep = addr;
    auto it = mem.lower_bound(flag);
    if (it != mem.end() && it->first.mem_sp <= addr)
    {
        return it->second + (addr - it->first.mem_sp);
    }
    return NULL;
}

lltriscv_elf_image::~lltriscv_elf_image()
{
    // Free memory
    for (const std::pair<mem_flag, uint8_t *> &item : mem)
    {
        free(item.second);
    }
}
