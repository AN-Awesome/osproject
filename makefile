all: kernel

kernel:
	make -C kernel

clean:
	rm -f disk.img