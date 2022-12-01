NASM32 = nasm
GCC32 = x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding
LD32 = x86-_64-pc-linux-ld.exe -melf_i386 -T ../elf_i386.x -nostdlib -e main -Ttext 0x10200
OBJCOPY32 = x86_64-pc-linux-objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

OBJECTDIRECTORY = obj
SOURCEDIRECTORY = src

all: prepare ProtectedMode.bin # EntryPoint Main.c

prepare: # mkdir : make directory
	mkdir -p $(OBJECTDIRECTORY)

$(OBJECTDIRECTORY)/EntryPoint.bin: $(SOURCEDIRECTORY)/EntryPoint.s
	$(NASM32) -o $@ $<

dep:
	@echo === Make Dependency ===
	make -C $(OBJECTDIRECTORY) -f ../makefile InternalDependency
	@echo === Dependency Search Complete ===

ExecuteInternelBuild : dep
	make -C $(OBJECTDIRECTORY) -f ../makefile ProtectedMode.elf

$(OBJECTDIRECTORY)/ProtectedMode.elf.bin: ExecuteInternelBuild
	$(OBJCOPY32) $(OBJECTDIRECTORY)/ProtectedMode.elf $@

ProtectedMode.bin: $(OBJECTDIRECTORY)/EntryPoint.bin $(OBJECTDIRECTORY)/ProtectedMode.elf.bin
	cat $^ > $@

clean:
	rm -f $(OBJECTDIRECTORY)/*.*

CENTRYMAIN = Main.o
CSRC = $(wildcard ../$(SOURCEDIRECTORY)/*.c)
ASMSRC = $(wildcard ../$(SOURCEDIRECTORY)/*.asm)
COBJ = $(subst Main.o, , $(notdir $(patsubst %.c, %.o, $(CSRC))))
ASMOBJ = $(notdir $(patsubst %.asm, %.o, $(ASMSRC)))

# .c 파일을 .o 파일로 바꾸는 규칙 정의 
%.o: ../$(SOURCEDIRECTORY)/%.C
		$(GCC32) -c %<

# .asm 파일을 .o 파일로 바꾸는 규칙 정의
%.o: ../$(SOURCEDIRECTORY)/%.asm
		$(NASM32) -f elf32 -o $@ $<

InternalDependency:
	$(GCC32) -MM $(CSRC) > Dependency.dep

ProtectedMode.elf: $(CENTRYMAIN) $(COBJ) $(ASMOBJ)
	$(LD32) -o $@ $^

ifeq (Dependency.dep, $(wildcard Dependency.dep))
include Dependency.dep
endif