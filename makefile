all: Kernal disk.img

Kernal:
	make -C kernal

disk.img:

clean:
	rm -f disk.img