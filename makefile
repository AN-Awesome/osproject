all: _kernel Disk.img
_kernel:
	@echo 
	@echo ==================== Kernel Source Build ====================
	@echo 
	make -C kernel
	@echo 
	@echo ============================================================
	@echo 

Disk.img: kernel/bin/BootLoader.bin kernel/bin/Kernel32.bin
	@echo 
	@echo ==================== Disk Image Build ====================
	@echo 
	cat $^ > $@
	@echo 
	@echo ============================================================
	@echo 

clean:
	make -C kernel clean
	rm -f disk.img