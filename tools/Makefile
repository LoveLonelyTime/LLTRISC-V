default : all

all : dump

dump : dump.cpp
	$(CXX) -I../test/include dump.cpp ../test/framework/lltriscv_elf_image.cpp -o dump

.PHONY : clean

clean :
	-$(RM) dump
