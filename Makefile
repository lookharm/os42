build: 
	i386-elf-gcc -o kernel/kernel.o -ffreestanding -c kernel/kernel.c
	i386-elf-gcc -o driver/port.o -ffreestanding -c driver/port.c
	i386-elf-gcc -o driver/screen.o -ffreestanding -c driver/screen.c

	nasm -f elf -o boot/kernel_entry.o boot/kernel_entry.asm
	i386-elf-ld -o boot/kernel.bin -Ttext 0x1000 --oformat binary \
		boot/kernel_entry.o \
		kernel/kernel.o \
		driver/port.o \
		driver/screen.o
	
	nasm -f bin -o boot/bootsector.bin boot/bootsector.asm 
	cat boot/bootsector.bin boot/kernel.bin > os-image.bin

run: build
	qemu-system-x86_64 -fda os-image.bin

rm:
	rm *.bin
	rm boot/*.bin
	rm boot/*.o
	rm kernel/*.o
	rm driver/*.o