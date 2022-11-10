all: _kernel disk.img

_kernel:
	@echo 
	@echo ============== Kernel Source Build =============
	@echo 
	make -C kernel
	@echo 
	@echo ================================================
	@echo 

disk.img: ./kernel/bin/BootLoader.bin
	@echo 
	@echo =============== Disk Image Build ===============
	@echo 
	cp kernel/bin/BootLoader.bin disk.img
	@echo 
	@echo ================================================
	@echo 

clean:
	make -C kernel clean
	rm -f disk.img