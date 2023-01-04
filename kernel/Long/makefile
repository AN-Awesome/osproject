# IA-32e 모드 커널을 빌드하기 위한 make 파일

#################################################################
# 빌드 환경 및 규칙 설정
#################################################################
# 컴파일러 링커 및 정의
NASM64 = nasm -f elf64
GCC64 = x86_64-pc-linux-gcc.exe -c -m64 -ffreestanding 
LD64 = x86_64-pc-linux-ld.exe -melf_x86_64 -T ../elf_x86_64.x -nostdlib -e Main -Ttext 0x200000

# 바이너리 이미지 생성을 위한 OBJCOPY 옵션 정의
OBJCOPY64 = x86_64-pc-linux-objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

# 디렉터리 정의
OBJECTDIRECTORY = Temp
SOURCEDIRECTORY = Src

#################################################################
# 빌드 항목 및 빌드 방법 설정
#################################################################
# 기본적으로 빌드를 수행할 목록
all: prepare Kernel64.bin

# 오브젝트 파일이 위치할 디렉터리를 생성
prepare:
	mkdir -p $(OBJECTDIRECTORY)


# 커널의 C 소스 파일에 대한 의존성 정보 생성 
dep:
	@echo === Make Dependency File ===
	make -C $(OBJECTDIRECTORY) -f ../makefile InternalDepency
	@echo === Dependency Search Complete ===

# 디렉토리를 오브젝트 파일 디렉터리로 이동해서 의존성 파일 및 실행 파일을 생성
ExecuteInternalBuild: dep
	make -C $(OBJECTDIRECTORY) -f ../makefile Kernel64.elf64

# 커널 이미지를 바이너리 파일로 변환하여 IA-32e 모드 바이너리 생성
Kernel64.bin: ExecuteInternalBuild
	$( OBJCOPY64 ) $( OBJECTDIRECTORY )/Kernel64.elf $@

# 소스 파일을 제외한 나머지 파일 정리
clean:
	rm -f *.bin
	rm -f $(OBJECTDIRECTORY)/*.*

#################################################################
# Maked에 의해 다시 호출되는 부분, Temp 디렉토리 기준으로 수행됨
#################################################################
# 빌드할 어셈블리어 엔트리 포인트 소스 파일 정의, Temp 디렉토리를 기준으로 설정

ENTRYPOINTSOURCEFILE = ../$(SOURCEDIRECTORY)/EntryPoint.s
ENTRYPOINTSOURCEFILE = EntryPoint.o
# 빌드할 C 소스 파일 정의, Temp 디렉토리를 기준으로 설정
CSOURCEFILES = $(wildcard ../$(SOURCEDIRECTORY)/*.c)
ASSEMBLYSOURCEFILES = $(wild ../$(SOURCEDIRECTORY)/*.asm)
COBJECTFILES = $(notdir $(patsubst %.c, %.o, $(CSOURCEFILES)))
ASSEMBLYOBJECTFILES = $(notdir $(patsubst %.asm, %.o, $(ASSEMBLYSOURCEFILES)))

# 어셈블리어 엔트리 포인트 빌드
$(ENTRYPOINTOBJECTFILE) : $(ENTRYPOINTSOURCEFILE)
	$(NASM64) -o $@ $<

# .c 파일을 .o 파일로 바꾸는 규칙 정의
%.o: ../$(SOURCEDIRECTORY)/%.c
	$(GCC64) -c $<

# .asm 파일을 .o 파일로 바꾸는 규칙 정의
%.o: ../$(SOURCEDIRECTORY)/%.c
	$(GCC64) -c $<

# 실제 의존성에 관련된 파일을 생성
InternalDepency:
	$(GCC64) -NM $(CSOURCEFILES) > Dependency.dep

# 실제 커널 이미지를 빌드
Kernel64.elf: $(ENTRYPOINTOBJECTFILE) $(COBJECTFILES) $(ASSEMBLYOBJECTFILES)
	$(LD64) -o $@ $^