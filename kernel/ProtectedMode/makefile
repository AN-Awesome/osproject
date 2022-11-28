all: EntryPoint Main.c

EntryPoint: src/EntryPoint.s
	nasm -o ../bin/EntryPoint.bin $<

Main.c: