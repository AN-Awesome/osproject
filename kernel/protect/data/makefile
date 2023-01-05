GCCCP = x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding
BUILDER = x86_64-pc-linux-ld.exe -melf_i386 -T ../link.x -nostdlib -e Main -Ttext 0x10200

%.o: ../src/%.c
	$(GCCCP) -c $<

%.o: ../src/%.asm
	nasm -f elf32 -o $@ $<

kernel32.elf: ./c_entry.o $(subst c_cenry.o, '', $(notdir $(patsubst %.c, %.o, $(wildcard ../src/*.c)))) $(notdir $(patsubst %.asm, %.o, $(wildcard ../src/*.asm)))
	@echo ===elf build===
	$(BUILDER) -o $@ $^
	@echo ======

ifeq (Dependency.dep, $(wildcard ./data/Dependency.dep))
include Dependency.dep
endif