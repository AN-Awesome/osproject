# Functions
GCC32 = x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding
LD32 = x86-_64-pc-linux-ld.exe -melf_i386 -T ../elf_i386.x -nostdlib -e main -Ttext 0x10200
OBJCOPY32 = x86_64-pc-linux-objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

# File search macro
CSRC = $(wildcard ./src/*.c)
ASMSRC = $(wildcard ./src/*.asm)

COBJ = $(subst Main.o, , $(notdir $(patsubst %.c, %.o, $(CSRC))))
ASMOBJ = $(notdir $(patsubst %.asm, %.o, $(ASMSRC)))

all: prepare ./tmp/EntryPoint.bin dep

prepare: 
	mkdir -p tmp

./tmp/EntryPoint.bin: ./src/EntryPoint.s
	@echo ========= EntryPoint.bin ========= 
	nasm -o $@ $<
	@echo ========= EntryPoint.bin =========

dep:
	@echo ========= Make Dependency =========
	make -C tmp -f ../makefile InternalDependency
	@echo ========= Dependency Search Complete =========

InternalDependency:
	$(GCC32) -MM $(CSRC) > Dependency.dep