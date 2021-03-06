C_SOURCES = $(shell find . -name "*.c")
C_OBJECTS = $(patsubst %.c, %.o, $(C_SOURCES))
S_SOURCES = $(shell find . -name "*.S")
S_OBJECTS = $(patsubst %.S, %.o, $(S_SOURCES))

CC = gcc
LD = ld
ASM = nasm

C_FLAGS = -c -Wall -m32 -ggdb -gstabs+ -nostdinc -fno-builtin -fno-stack-protector
LD_FLAGS = -T tools/kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f elf -g -F stabs

C_INCLUDE = libs/         \
			kern/debug/   \
			kern/driver/  \
			kern/mm/      \
			kern/trap/    \
			kern/process  \
			kern/schedule \

C_FLAGS += $(addprefix -I,$(C_INCLUDE))

all: $(S_OBJECTS) $(C_OBJECTS) link update_image

.c.o:
	@echo gcc $<
	$(CC) $(C_FLAGS) $< -o $@

.S.o:
	@echo nasm $<
	$(ASM) $(ASM_FLAGS) $<

link:
	@echo ld
	$(LD) $(LD_FLAGS) $(S_OBJECTS) $(C_OBJECTS) -o kernel

.PHONY:clean
clean:
	$(RM) $(S_OBJECTS) $(C_OBJECTS) kernel

.PHONY:update_image
update_image:
	sudo mount floppy.img /mnt/floppy
	sudo cp kernel /mnt/floppy
	sleep 1
	sudo umount /mnt/floppy

.PHONY:mount_image
mount_image:
	sudo mount floppy.img /mnt/floppy

.PHONY:umount_image
umount_image:
	sudo umount /mnt/floppy

.PHONY:qemu
qemu:
	qemu -fda floppy.img -boot a -m 256

.PHONY:debug
debug:
	qemu -S -s -fda floppy.img -boot a -m 256 &
	sleep 1
	cgdb -x tools/gdbinit

