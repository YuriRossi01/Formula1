GCC = gcc
AS_FLAGS = --32 
LD_FLAGS = -m elf_i386
FLAGS = -m32 -g -c
GSTABS = -gstabs 


all: bin/telemetry

bin/telemetry: obj/telemetry.o obj/main.o
	$(GCC) -m32 obj/*.o -o bin/telemetry

obj/telemetry.o: src/telemetry.s
	$(GCC) $(FLAGS) src/telemetry.s -o obj/telemetry.o

obj/main.o: src/main.c
	$(GCC) $(FLAGS) src/main.c -o obj/main.o




clean:
	rm -rf obj/*
	rm -rf bin/telemetry bin/out_1.txt


# PER DEBUGGARE
#as -gstabs -o miofile.o miofile.s
#ld -o miofile miofile.o



# ASM 32 SU MACCHINE 64
# as --32 -o miofile.o miofile.s
#ld -m elf_i386 -o miofile miofile.o

