# Functions
GCC32 = x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding
LD32 = x86-_64-pc-linux-ld.exe -melf_i386 -T ../elf_i386.x -nostdlib -e main -Ttext 0x10200
OBJCOPY32 = x86_64-pc-linux-objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

# File search macro
CSRC = $(wildcard ./src/*.c)
ASMSRC = $(wildcard ./src/*.asm)

COBJ = $(subst Main.o, , $(notdir $(patsubst %.c, %.o, $(CSRC))))
ASMOBJ = $(notdir $(patsubst %.asm, %.o, $(ASMSRC)))

all: prepare ProtectedMode.bin # EntryPoint Main.c

prepare: # mkdir : make directory
	mkdir -p tmp

tmp/EntryPoint.bin: ./src/EntryPoint.s
	nasm -o $@ $<

dep:
	@echo === Make Dependency ===
	make -C tmp -f ../makefile InternalDependency
	@echo === Dependency Search Complete ===

ExecuteInternelBuild : dep
	make -C tmp -f ../makefile ProtectedMode.elf

tmp/ProtectedMode.elf.bin: ExecuteInternelBuild
	$(OBJCOPY32) tmp/ProtectedMode.elf $@

ProtectedMode.bin: tmp/EntryPoint.bin tmp/ProtectedMode.elf.bin
	cat $^ > $@

clean:
	rm -f tmp/*.*

# .c 파일을 .o 파일로 바꾸는 규칙 정의 
%.o: ./src/%.c
	$(GCC32) -c %<

# .asm 파일을 .o 파일로 바꾸는 규칙 정의
%.o: ./src/%.asm
	nasm -f elf32 -o $@ $<

InternalDependency:
	$(GCC32) -MM $(CSRC) > Dependency.dep

ProtectedMode.elf: Main.o $(COBJ) $(ASMOBJ)
	$(LD32) -o $@ $^

ifeq (Dependency.dep, $(wildcard Dependency.dep))
include Dependency.dep
endif