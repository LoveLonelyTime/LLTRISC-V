defalut : test

VERILATOR = verilator

VSRC = $(wildcard ../hw/core/*.sv ../hw/core/stages/*.sv ../hw/soc/*.sv)
CSRC = $(wildcard framework/*.cpp)

TESTCASE = $(wildcard ./*_test/test.mk)

VFLAGS = --top-module lltriscv --cc -Wall -Wno-fatal --exe --trace
CFLAGS = -I../include

obj_dir/Vlltriscv.mk : $(VSRC) $(CSRC)
	$(VERILATOR) $(VFLAGS) -CFLAGS "$(CFLAGS)" $(VSRC) $(CSRC)

Vlltriscv : obj_dir/Vlltriscv.mk
	$(MAKE) -f Vlltriscv.mk -C obj_dir

.PHONY : clean test
clean :
	-$(RM) -r obj_dir
	$(foreach var,$(TESTCASE),$(MAKE) -f test.mk clean -C $(patsubst ./%/test.mk,./%,$(var));)

test : Vlltriscv
	$(foreach var,$(TESTCASE),$(MAKE) -f test.mk -C $(patsubst ./%/test.mk,./%,$(var));)
