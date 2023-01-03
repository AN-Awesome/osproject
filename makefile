all: _kernel _tools _buildimg
_kernel:
	@echo 
	@echo ==================== Kernel Source Build ====================
	@echo 
	make -C kernel
	@echo 
	@echo ============================================================
	@echo 

_tools:
	@echo 
	@echo ==================== Tools Build ====================
	@echo 
	make -C tools
	@echo 
	@echo ============================================================
	@echo 

_buildimg: kernel/bin/BootLoader.bin kernel/bin/Kernel32.bin
	@echo 
	@echo ==================== Disk Image Build ====================
	@echo 
	./tools/imgbuild_.exe $^
	@echo 
	@echo ============================================================
	@echo 

clean:
	make -C kernel clean
	rm -f disk.img