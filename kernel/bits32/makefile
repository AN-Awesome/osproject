all: _entry_ _c_dep_ _bin_link_ data/kernel32.elf.bin ../../build/kernel32.bin

_entry_: ./src/Entry.s
	nasm -o data/entry.bin $<

_c_dep_:
	gcc -c -m32 -ffreestanding -MM $(wildcard ./src/*.c) > data/Dependency.dep

_bin_link_:
	make -C data

data/kernel32.elf.bin:
	objcopy -j .text -j .data -j .rodata -j .bss -S -O binary data/kernel32.elf $@

../../build/kernel32.bin: ./data/entry.bin ./data/kernel32.elf.bin
	cat $^ > $@