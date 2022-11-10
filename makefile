all: Kernal disk.img

Kernal:
	make -C kernal

disk.img:

clean:
	make -C kernal clean
	rm -f disk.img