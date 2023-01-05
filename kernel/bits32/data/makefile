%.o: ../src/%.c
	x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding -c $<

%.o: ../src/%.asm
	nasm -f elf32 -o $@ $<

kernel32.elf: Main.o $(subst Main.o, , $(notdir $(patsubst %.c, %.o, $(wildcard ../src/*.c)))) $(notdir $(patsubst %.asm, %.o, $(wildcard ../src/*.asm)))
	@echo ===elf build===
	x86_64-pc-linux-ld.exe -melf_i386 -T ../linkscript.x -nostdlib -e Main -Ttext 0x10200 -o $@ $^
	@echo ======

ifeq (Dependency.dep, $(wildcard dependency.dep))
include Dependency.dep
endif