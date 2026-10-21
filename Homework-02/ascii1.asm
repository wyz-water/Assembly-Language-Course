.model small
.stack 100h

.code
main proc
    mov ax, @data
    mov ds, ax

    mov bl, 'a'        ; BL保存当前要输出的字符
    mov cx, 2          ; 外层循环：共输出2行

row_loop:
    push cx            ; 保存外层循环的CX
    mov cx, 13         ; 内层循环：每行输出13个字符

char_loop:
    mov dl, bl         ; DL = 当前字符
    mov ah, 02h        ; DOS功能02H：输出DL中的字符
    int 21h

    mov dl, ' '        ; 输出一个空格
    mov ah, 02h
    int 21h

    inc bl             ; 下一个ASCII字符

    loop char_loop     ; CX--，不为0则继续输出

    ; 一行输出结束，换行
    mov dl, 0dh        ; CR，回车
    mov ah, 02h
    int 21h

    mov dl, 0ah        ; LF，换行
    mov ah, 02h
    int 21h

    pop cx             ; 恢复外层循环的CX
    loop row_loop      ; 外层循环

    mov ax, 4c00h      ; 返回DOS
    int 21h

main endp
end main