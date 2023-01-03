all: _kernel disk.img tools
_kernel:
	@echo 
	@echo ==================== Kernel Source Build ====================
	@echo 
	make -C kernel
	@echo 
	@echo ============================================================
	@echo 

disk.img: ./kernel/bin/BootLoader.bin ./kernel/bin/Kernel32.bin
	@echo 
	@echo ==================== Disk Image Build ====================
	@echo 
	cat $^ > disk.img
	@echo 
	@echo ============================================================
	@echo 

tools:
	@echo 
	@echo ==================== Utility Build ====================
	@echo 
	make -C tools
	@echo 
	@echo ============================================================
	@echo 

clean:
	make -C kernel clean
	rm -f disk.img