#include <cstdio>
#include <map>
#include <string>
#include <verilated_vcd_c.h>
#include "Vlltriscv.h"
#include "lltriscv_elf_image.h"

// const uint64_t MAX_TIME = 640000000LL;
const uint64_t MAX_TIME = 10000000;
lltriscv_elf_image mem_image;

int main(int argc, char **argv)
{

    // Load ELF file
    if (argc <= 1)
    {
        fprintf(stderr, "Error: No test input file.\n");
        return -1;
    }
    std::string debug_str;
    // Create IMEM 64KiB
    mem_image.mmap(0x00010000, 65536);
    // Create RODMEM 64KiB
    mem_image.mmap(0x00020000, 65536);
    // Create DMEM 64KiB
    mem_image.mmap(0x80000000, 65536);

    mem_image.loadELF(argv[1]);

    // Copy area
    memcpy(mem_image.memv(0x00020C00), mem_image.memv(0x80000000), 1024);

    // Create VerilatedContext
    VerilatedContext *contextp = new VerilatedContext();
    VerilatedVcdC *tracep = new VerilatedVcdC();
    contextp->commandArgs(argc, argv);
    contextp->traceEverOn(true);
    Vlltriscv *lltriscv = new Vlltriscv(contextp);
    lltriscv->trace(tracep, 0);

    // Waveform test.vcd
    tracep->open("test.vcd");

    FILE *log_file = fopen("log.txt", "w");
    int status_code = 0;
    while (!contextp->gotFinish())
    {
        if (contextp->time() > MAX_TIME)
        {
            fprintf(log_file, "Program End: [%s]\n", "ERROR-Timeout");
            printf("\033[31m");
            printf("Result: Timeout\n");
            printf(
                " _____ _____ _____ _____ _____ \n"
                "|   __| __  | __  |     | __  |\n"
                "|   __|    -|    -|  |  |    -|\n"
                "|_____|__|__|__|__|_____|__|__|\n");
            printf("\033[0m");
            status_code = -1;
            break;
        }
        // Reset core
        if (contextp->time() >= 1 && contextp->time() <= 2)
            lltriscv->reset = 1;
        else
            lltriscv->reset = 0;

        // Clock
        lltriscv->CLK = (contextp->time() & 1);

        // IMEM
        uint32_t *iptr = (uint32_t *)mem_image.memv(lltriscv->imem_Addr);
        if (iptr == NULL)
        {
            fprintf(log_file, "Read illegal IMEM Addr: %#x\n", lltriscv->imem_Addr);
            lltriscv->imem_RD = 0;
        }
        else
        {
            lltriscv->imem_RD = *iptr;
            fprintf(log_file, "[%ld] Read IMEM in %#x: %#x\n", contextp->time(), lltriscv->imem_Addr, *iptr);
        }

        // Program End
        if (lltriscv->dmem_Addr == 0x00000010 && lltriscv->dmem_WE)
        {
            printf("[%s] Program End.\n", argv[1]);
            int res = lltriscv->dmem_WD & 0xFF;
            if (res == 0x7F)
            {
                fprintf(log_file, "Program End: [%s]\n", "ACCEPTED");
                printf("Result:\n");
                printf("\033[32m");
                printf(
                    " _____ _____ _____ _____ _____ _____ _____ ____  \n"
                    "|  _  |     |     |   __|  _  |_   _|   __|    \\ \n"
                    "|     |   --|   --|   __|   __| | | |   __|  |  |\n"
                    "|__|__|_____|_____|_____|__|    |_| |_____|____/ \n");
                printf("\033[0m");
            }
            else
            {
                fprintf(log_file, "Program End: [%s]\n", "ERROR");
                printf("\033[31m");
                printf("Result:\n");
                printf(
                    " _____ _____ _____ _____ _____ \n"
                    "|   __| __  | __  |     | __  |\n"
                    "|   __|    -|    -|  |  |    -|\n"
                    "|_____|__|__|__|__|_____|__|__|\n");
                printf("\033[0m");
                status_code = -1;
            }
            break;
        }

        // Debug port
        if (lltriscv->CLK && lltriscv->dmem_Addr == 0x00000020 && lltriscv->dmem_WE)
        {
            printf("%c", (char)lltriscv->dmem_WD);
        }

        lltriscv->dmem_sel = 0;
        // RODMEM
        if ((lltriscv->dmem_Addr >> 16) == 0x00000002)
        {
            lltriscv->dmem_sel = 1;
            uint8_t *dptr = mem_image.memv(lltriscv->dmem_Addr);
            uint32_t res = 0;
            if (lltriscv->dmem_WC == 0)
                res = *((uint8_t *)dptr);
            else if (lltriscv->dmem_WC == 1)
            {
                res = *((uint16_t *)dptr);
                if (lltriscv->dmem_Addr & 1)
                {
                    res = 0;
                    fprintf(log_file, "Misalignment Read RODMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                }
            }
            else if (lltriscv->dmem_WC == 2)
            {
                res = *((uint32_t *)dptr);
                if (lltriscv->dmem_Addr & 3)
                {
                    res = 0;
                    fprintf(log_file, "Misalignment Read RODMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                }
            }

            fprintf(log_file, "Read RODMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
            lltriscv->dmem_RD = res;
        }

        // DMEM
        if ((lltriscv->dmem_Addr >> 16) == 0x00008000)
        {
            lltriscv->dmem_sel = 1;
            uint8_t *dptr = mem_image.memv(lltriscv->dmem_Addr);
            if (lltriscv->dmem_WE)
            {
                uint32_t res = 0;
                if (lltriscv->dmem_WC == 0)
                    res = lltriscv->dmem_WD & 0x000000FF;
                else if (lltriscv->dmem_WC == 1)
                    res = lltriscv->dmem_WD & 0x0000FFFF;
                else if (lltriscv->dmem_WC == 2)
                    res = lltriscv->dmem_WD & 0xFFFFFFFF;

                if (dptr == NULL)
                {
                    fprintf(log_file, "Write illegal DMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                }
                else
                {
                    fprintf(log_file, "Write DMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                    if (lltriscv->dmem_WC == 0)
                        *((uint8_t *)dptr) = res;
                    else if (lltriscv->dmem_WC == 1)
                    {
                        if (lltriscv->dmem_Addr & 1)
                        {
                            fprintf(log_file, "Misalignment Write DMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                            res = 0;
                        }
                        *((uint16_t *)dptr) = res;
                    }
                    else if (lltriscv->dmem_WC == 2)
                    {
                        if (lltriscv->dmem_Addr & 3)
                        {
                            fprintf(log_file, "Misalignment Write DMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                            res = 0;
                        }
                        *((uint32_t *)dptr) = res;
                    }
                }
            }
            else
            {
                if (dptr == NULL)
                {
                    fprintf(log_file, "Read illegal DMEM in %#x\n", lltriscv->dmem_Addr);
                    lltriscv->dmem_RD = 0;
                }
                else
                {
                    uint32_t res = 0;
                    if (lltriscv->dmem_WC == 0)
                        res = *((uint8_t *)dptr);
                    else if (lltriscv->dmem_WC == 1)
                    {
                        res = *((uint16_t *)dptr);
                        if (lltriscv->dmem_Addr & 1)
                        {
                            fprintf(log_file, "Misalignment Read DMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                            res = 0;
                        }
                    }
                    else if (lltriscv->dmem_WC == 2)
                    {
                        res = *((uint32_t *)dptr);
                        if (lltriscv->dmem_Addr & 3)
                        {
                            fprintf(log_file, "Misalignment Read DMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                            res = 0;
                        }
                    }

                    fprintf(log_file, "Read DMEM in %#x: %#x\n", lltriscv->dmem_Addr, res);
                    lltriscv->dmem_RD = res;
                }
            }
        }

        lltriscv->eval();
        tracep->dump(contextp->time());
        contextp->timeInc(1);
    }
    tracep->close();
    delete lltriscv;
    delete contextp;

    fclose(log_file);
    return status_code;
}