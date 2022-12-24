all: BootLoader Kernel32

BootLoader:
	@echo ==================== BUILD BOOTLOADER ====================
	make -C Boot
	@echo ==================== COMPLETE BUILD BOOTLOADER ====================

Kernel32:
	@echo ==================== BUILD 32 KERNEL ====================
	make -C ProtectedMode
	@echo ==================== COMPLETE BUILD 32 KERNEL ====================
	
clean:
	rm -f bin/*.*
	make -C ProtectedMode clean