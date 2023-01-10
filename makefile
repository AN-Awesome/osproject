all: _kernel_ _tools_ Disk.img

_kernel_:
	make -C kernel

_tools_:
	make -C tools

Disk.img: build/boot.bin build/kernel32.bin
	./ImageMaker $^
	sudo qemu-system-x86_64 -m 64 -fda ./Disk.img -rtc base=localtime -M pc

clean:
	rm -f build/*.*
	rm -f Disk.img
	rm -f ImageMaker

	rm -f kernel/bits32/data/*.o
	rm -f kernel/bits32/data/*.elf
	rm -f kernel/bits32/data/*.dep
	rm -f kernel/bits32/data/*.bin