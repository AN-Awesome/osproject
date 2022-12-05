all: BootLoader ProtectedMode

BootLoader:
	@echo == BUILD BOOTLOADER ===
	make -C Boot
	@echo == COMPLETE BUILD BOOTLOADER ===

ProtectedMode:
	@echo == BUILD 32 KERNEL ===
	make -C ProtectedMode
	@echo == COMPLETE BUILD 32 KERNEL ===
	
clean:
	make -C bin clean