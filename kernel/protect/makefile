all: clean data/entry.bin _dep BuildCode ./data/kernel32.elf.bin ../../build/kernel32.bin

clean:
	rm -f data/*.bin
	rm -f data/*.dep
	rm -f data/*.o
	rm -f data/*.elf

data/entry.bin: src/entry.s
	nasm -o $@ $^

_dep:
	x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding -MM $(wildcard ./src/*.c) > ./data/dependency.dep

BuildCode:
	make -C data

./data/kernel32.elf.bin:
	x86_64-pc-linux-objcopy.exe -j .text -j .data -j .rodata -j .bss -S -O binary ./data/kernel32.elf $@

../../build/kernel32.bin: ./data/entry.bin ./data/kernel32.elf.bin
	cat $^ > $@