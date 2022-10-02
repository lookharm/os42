[org 0x7c00]
    ; print R (real-mode)
    mov bx, 0x1000
    call load_disk ; load kernel_entry form disk to memory address 0x1000
    call switch_pm
    jmp $

; https://stanislavs.org/helppc/int_13-2.html
load_disk:
    mov ah, 0x2
    mov al, 0x2
    mov ch, 0x0
    mov cl, 0x2
    mov dh, 0x0
    ; dl = set by BIOS, qemu -fda bootsector.bin
    int 0x13
    jc load_disk_err
    jmp load_disk_done

load_disk_err:
    jmp $

load_disk_done:
    ret

; Volume 3 - 3.4.3. Segment Descriptors
gdt_start:

; 0x0
gdt_null:
    dq 0x00

; 0x8
gdt_code:
    dw 0xffff ; limit 15:0
    dw 0x0 ; base 15:0
    
    db 0x0 ; base 23:16
    db 10011010b ; present, hightest priviledge, code/data | code, execute/read
    db 11001111b ; 
    db 0x0 ; base 31:24

; 0x10
gdt_data:
    dw 0xffff ; limit 15:0
    dw 0x0 ; base 15:0
    
    db 0x0 ; base 23:16
    db 10010010b ; present, hightest priviledge, code/data | data, read/write
    db 11001111b ; 
    db 0x0 ; base 31:24

gdt_end:

; Volume 3 - 2.4.1. Global Descriptor Table Register (GDTR)
gdt_desc:
    dw gdt_end - gdt_start
    dd gdt_start

; Volume 3 - 8.8.1. Switching to Protected Mode
[bits 16]
switch_pm:
    ; Volume 2 - CLI—Clear Interrupt Flag
    cli

    ; Volume 2 - LGDT/LIDT—Load Global/Interrupt Descriptor Table Register
    lgdt [gdt_desc]
    
    ; Vloume 3 - 2.5. CONTROL REGISTERS
    ; set only PE flag to enable protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; far jump to selector 08h which is code segment.
    jmp 0x8:main_pm

[bits 32]
main_pm:
    ; reload the rest segment registers
    ; cs register is restets by jmp 0x8:main_pm
    mov ax, 0x10 ; data segment
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; print P (protected-mode)
    
    call 0x1000 ; call kernel_entry
    jmp $

times 510-($-$$) db 0x00
dw 0xaa55