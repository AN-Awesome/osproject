all: KERNEL IMG

KERNEL:
	@echo 
	@echo =========== Kernal Build ===========
	@echo 
	make -C kernal
	@echo 
	@echo ====================================
	@echo 

IMG: 
	@echo 
	@echo =========== Image Build ===========
	@echo 
	cp kernal/bin/BootLoader.bin disk.img
	@echo 
	@echo ===================================
	@echo 

clean:
	make -C kernal clean
	rm -f disk.img