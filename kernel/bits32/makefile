all: _entry_ dep BuildCode ./data/kernel32.elf.bin ../../build/kernel32.bin

_entry_:
	nasm -o data/entry.bin src/entry.s

dep:
	x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding -MM $(wildcard ./src/*.c) > ./data/dependency.dep

BuildCode:
	make -C data

./data/kernel32.elf.bin:
	x86_64-pc-linux-objcopy.exe -j .text -j .data -j .rodata -j .bss -S -O binary ./data/kernel32.elf $@

../../build/kernel32.bin: ./data/entry.bin ./data/kernel32.elf.bin
	cat $^ > $@