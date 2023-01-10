%.o: ../src/%.c
	gcc -c -m32 -ffreestanding -c $<

%.o: ../src/%.asm
	nasm -f elf32 -o $@ $<

kernel32.elf: Main.o $(subst Main.o, , $(notdir $(patsubst %.c, %.o, $(wildcard ../src/*.c))))
	ld -melf_i386 -T ../elf_i386.x -nostdlib -e Main -Ttext 0x10200 -o $@ $^

ifeq (Dependency.dep, $(Dependency.dep))
include Dependency.dep
endif