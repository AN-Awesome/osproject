GCC32 = x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding
LD32 = x86_64-pc-linux-ld.exe -melf_i386 -T ../elf_i386.x -nostdlib -e Main -Ttext 0x10200
OBJCOPY32 = x86_64-pc-linux-objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

all: prepare ../bin/Kernel32.bin

# Create dir. tmp folder
prepare:
	mkdir -p tmp

# Build EntryPoint.s -> EntryPoint.bin
tmp/EntryPoint.bin: src/EntryPoint.s
	nasm -o $@ $<

# Create dependency files
dep:
	@echo ==================== Make Dependancy File ====================
	make -C tmp -f ../makefile InternalDependency
	@echo ==================== Dependancy Search Complete ====================

# Build dependency + execute files
ExecuteInternalBuild: dep
	make -C tmp -f ../makefile Kernel32.elf

# Transform Kernel Image(Kernel32.elf) -> *.bin
tmp/Kernel32.elf.bin: ExecuteInternalBuild
	$(OBJCOPY32) tmp/Kernel32.elf $@

# Protected Mode Image Build :: EntryPoint + Kernel sources..
../bin/Kernel32.bin: tmp/EntryPoint.bin tmp/Kernel32.elf.bin
	cat $^ > $@d
			
clean:
	rm -f *.bin
	rm -f tmp/*.*

# Configure C source code files
CENTRYPOINTOBJECTFILE = Main.o
CSOURCEFILES = $(wildcard ../src/*.c)
ASSEMBLYSOURCEFILES = $(wildcard ../src/*.asm)
COBJECTFILES = $(subst Main.o, , $(notdir $(patsubst %.c,%.o,$(CSOURCEFILES))))
ASSEMBLYOBJECTFILES = $(notdir $(patsubst %.asm,%.o,$(ASSEMBLYSOURCEFILES)))

# Transform file name extentions(*.c, *.asm -> *.obj)
%.o: ./src/%.c
	$(GCC32) -c $<

%.o: ../src/%.asm
	nasm -f elf32 -o $@ $<

# Create dependency file(*.dep)
InternalDependency:
	$(GCC32) -MM $(CSOURCEFILES) > Dependency.dep

# Build Kernel Image
Kernel32.elf: $(CENTRYPOINTOBJECTFILE) $(COBJECTFILES) $(ASSEMBLYOBJECTFILES)
	$(LD32) -o $@ $^

# include *.dep
ifeq (Dependency.dep, $(wildcard Dependency.dep))
include Dependency.dep
endif
