all: _kernel tools disk.img
_kernel:
	@echo 
	@echo ==================== Kernel Source Build ====================
	@echo 
	make -C kernel
	@echo 
	@echo ============================================================
	@echo 

tools:
	@echo 
	@echo ==================== Tools Build ====================
	@echo 
	make -C tools
	@echo 
	@echo ============================================================
	@echo 

disk.img: ./kernel/bin/BootLoader.bin ./kernel/bin/Kernel32.bin
	@echo 
	@echo ==================== Disk Image Build ====================
	@echo 
	./tools/ImageBuilder.exe $^
	@echo 
	@echo ============================================================
	@echo 

clean:
	make -C kernel clean
	rm -f disk.img