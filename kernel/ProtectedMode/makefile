all: EntryPoint Main.c

EntryPoint: src/EntryPoint.s
<<<<<<< HEAD
	nasm -o ../bin/EntryPoint.bin $<
=======
	nasm -o ../bin/EntryPoint.bin $<

Main.c:

CENTRYPOINTOBJECTFILE = Main.o
COBJECTFILES = $(patsubst %.c,%.o,$(CSOURCEFILES))



CSOURCEFILES = $(wildcard src/*.c)		#이름 = $(wildcard 파일이름/.c)

%.o : %.c								#.o의 확장자로 생성.
	gcc -c $<
>>>>>>> 88dd55f41df05eb1c122b6ebf49388655d084dff
