include ../../config.mk

defalut : test

TESTCASE = CSR_test

INC = -I../include

../obj_dir/Vlltriscv :
	$(MAKE) -C ../ Vlltriscv

$(TESTCASE).out : $(TESTCASE).c startup.S
	$(RISCV_CC) $(CORE_SECTION) -march=$(ARCH) $(INC) -nostdlib --entry=_lltriscv_startup startup.S $(TESTCASE).c -lgcc -o $(TESTCASE).out

.PHONY : clean test
clean :
	-$(RM) $(TESTCASE).out test.vcd log.txt

test : $(TESTCASE).out ../obj_dir/Vlltriscv
	../obj_dir/Vlltriscv $(TESTCASE).out
