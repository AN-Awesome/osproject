all: _kernel disk.img

_kernel:
	make -C kernel

disk.img:
	cp kernel/bin/BootLoader.bin disk.img

clean:
	make -C kernel clean
	rm -f disk.img