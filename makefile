all: clean _kernel_ _tools_ os.img

clean:
	rm -f os..img

	rm -f build/*.*

	rm -f kernel/bits32/data/*.o
	rm -f kernel/bits32/data/*.elf
	rm -f kernel/bits32/data/*.dep
	rm -f kernel/bits32/data/*.bin

_kernel_:
	make -C kernel

_tools_:
	make -C tools

os.img:	build/boot.bin build/kernel32.bin
	tools/ImageMaker/ImageMaker.exe $^