all: EntryPoint Main.c

EntryPoint: src/EntryPoint.s
	nasm -o ../bin/EntryPoint.bin $<

Main.c:

CSOURCEFILES = $(wildcard src/*.c)		#이름 = $(wildcard 파일이름/.c)

%.o : %.c								#.o의 확장자로 생성.
	gcc -c $<