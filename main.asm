org 0x7C00          ; bootloader starts at memory address 0x7C00

mov ax, 0x0013
int 0x10

mov ax, 0xA000
mov es, ax

xor di, di
mov cx, 320*200
mov al, 1            ; initial color
mov bx, 0           ; row counter
mov dx, 0           ; column counter

draw_loop:
    push di
    push dx
    push cx
    push bx
    call set_color
    pop bx
    pop cx
    pop dx
    pop di
    stosb            ; write AL to ES:[DI] and increment DI
    inc bx
    cmp bx, 320
    jne skip_reset
    xor bx, bx
    inc dx
skip_reset:
    loop draw_loop




jmp skip_functions

set_color:
    call circle_fractal
    call cmap_mono
    ret

top_black_bottom_white:
    mov al, 15
    cmp dx, 100
    jge skip_black
    mov al, 0
    skip_black:
    ret
circle:
    mov eax, ebx ;x
    sub eax, 160 ;x - 160
    imul eax, eax ;(x - 160)^2
    mov ebx, edx ;y
    sub ebx, 100 ;y - 100
    imul ebx, ebx ;(y - 100)^2
    add ebx, eax ;(x - 160)^2 + (y - 100)^2
    mov eax, ebx
    cmp ebx, 50*50
    mov al, 15
    jg skip_black1
    mov al, 0
    skip_black1:
    ret
circle_fractal:
    mov eax, ebx ;x
    sub eax, 160 ;x - 160
    imul eax, eax ;(x - 160)^2
    mov ebx, edx ;y
    sub ebx, 100 ;y - 100
    imul ebx, ebx ;(y - 100)^2
    add ebx, eax ;(x - 160)^2 + (y - 100)^2
    mov eax, ebx
    cmp ebx, 50*50
    ret
checkerboard:
    mov al, 255
    xor dx, bx
    and dx, 0x10
    jz skip_black2
    mov al, 0
    skip_black2:
    ret
checkerboard_fractal:
    xor al, al
    xor al, bl
    xor al, dl
    ret
plasma_fractal:
    ; Calculate color using a plasma-like effect
    mov ax, dx          ; ax = y
    imul bx             ; ax = x * y
    shr ax, 8           ; Scale down by shifting right
    add al, bl          ; Add x-coordinate to mix the effect
    ret
lava:
    ; 128 + 128 * sin(x / 16.0) + 
    ; 128 + 128 * sin(y / 16.0) +
    ; 128 + 128 * sin((x + y) / 32.0) +
    ; 128 + 128 * sin((x**2 + y**2) / 10000.0)
    ; wip
    ret

; color maps
cmap_mono:
    ; al : 0-255 -> 16-31
    shr al, 4
    add al, 16
    ret
cmap_rainbow:
    ; al : 0-255 -> 64-79
    shr al, 4
    add al, 64
    ret
cmap_red_blue:
    ; al : 0-255 -> 104-112
    shr al, 5
    add al, 104
    ret




skip_functions:
mov ah, 0x00
int 0x16 ; wait for keypress

; text mode
mov ax, 0x0003
int 0x10

; Hang the CPU
cli
hlt

times 510-($-$$) db 0
dw 0xAA55