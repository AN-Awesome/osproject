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
	make -C bin clean
	make -C ProtectedMode clean