.model small
.stack 100h

.code
main proc
    mov ax, @data
    mov ds, ax

    mov bl, 'a'        ; BL保存当前字符
    mov bh, 2          ; BH作为外层计数器，共2行

row_loop:
    mov cx, 13         ; 每行输出13个字符

char_loop:
    mov dl, bl         ; 输出当前字符
    mov ah, 02h
    int 21h

    mov dl, ' '        ; 输出空格
    mov ah, 02h
    int 21h

    inc bl             ; 指向下一个字母

    dec cx             ; 内层计数器减1
    jnz char_loop      ; CX不等于0，继续内层循环

    ; 输出回车换行
    mov dl, 0dh
    mov ah, 02h
    int 21h

    mov dl, 0ah
    mov ah, 02h
    int 21h

    dec bh             ; 外层计数器减1
    jnz row_loop       ; BH不等于0，再输出一行

    mov ax, 4c00h
    int 21h

main endp
end main