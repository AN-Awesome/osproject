all: clean _kernel_ os.img

clean:
	rm -f os.img
	rm -f Disk.img

	rm -f build/*.*
	rm -f kernel/bits32/data/*.elf
	rm -f kernel/bits32/data/*.o
	rm -f kernel/bits32/data/*.bin
	rm -f kernel/bits32/data/*.def

_kernel_:
	make -C kernel

os.img: build/boot.bin build/kernel32.bin
	./ImageMaker $^
	sudo qemu-system-x86_64 -m 64 -fda ./Disk.img -rtc base=localtime -M pc