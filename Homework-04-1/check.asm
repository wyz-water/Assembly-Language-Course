.model small
.stack 100h
.data
table db 1,2,3,4,5,6,7,8,9
      db 2,4,7,8,10,12,14,16,18
      db 3,6,9,12,15,18,21,24,27
      db 4,8,12,16,7,24,28,32,36
      db 5,10,15,20,25,30,35,40,45
      db 6,12,18,24,30,7,42,48,54
      db 7,14,21,28,35,42,49,56,63
      db 8,16,24,32,40,48,56,7,72
      db 9,18,27,36,45,54,63,72,81
.code
main proc
    mov ax,@data
    mov ds,ax

    mov ch,1           ; 行, 1..9
row_loop:
    mov cl,1           ; 列, 1..9
col_loop:
    ; si = (行-1)*9 + (列-1), 表按行存, 用变址寻址
    mov al,ch
    dec al
    mov bl,9
    mul bl             ; ax = (行-1)*9
    mov si,ax
    mov al,cl
    dec al
    xor ah,ah
    add si,ax          ; si = 元素偏移

    mov al,ch
    mul cl             ; ax = 行*列 = 正确值

    mov dl,table[si]   ; dl = 表里的值
    cmp al,dl
    je no_err
    mov bl,dl          ; bl = 错误值
    call report        ; 打印 "(行,列):错误值->正确值"
no_err:
    inc cl
    cmp cl,9
    jbe col_loop
    inc ch
    cmp ch,9
    jbe row_loop

    mov ax,4c00h
    int 21h
main endp

; ------------------------------------------------------
; 过程 report: 打印 "(行,列):错误值->正确值" 并换行
; 输入: CH=行, CL=列, BL=错误值, AL=正确值
; 说明: 过程里用了主过程的 AX/BX/CX/DX/SI/BP,
;       入口全部压栈保存, 返回前恢复,
;       主过程的循环计数器 CH/CL 不受影响。
; ------------------------------------------------------
report proc
    push bp
    mov bp,sp
    push ax            ; [bp-2] = 正确值(留一份在栈里备用)
    push bx
    push cx
    push dx
    push si

    mov dl,'('
    mov ah,2
    int 21h
    mov dl,ch
    add dl,'0'
    mov ah,2
    int 21h            ; 行
    mov dl,','
    mov ah,2
    int 21h
    mov dl,cl
    add dl,'0'
    mov ah,2
    int 21h            ; 列
    mov dl,')'
    mov ah,2
    int 21h
    mov dl,':'
    mov ah,2
    int 21h

    mov ax,bx
    and ax,0ffh        ; ax = 错误值
    call print_num

    mov dl,'-'
    mov ah,2
    int 21h
    mov dl,'>'
    mov ah,2
    int 21h

    mov ax,[bp-2]      ; 从栈里取回正确值 (print_num 会破坏 ax)
    call print_num

    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah
    mov ah,2
    int 21h            ; 换行

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret
report endp

; ------------------------------------------------------
; 过程 print_num: 打印 AX (0..255) 的十进制
; ------------------------------------------------------
print_num proc
    push bx
    push cx
    push dx
    mov bl,10
    xor cx,cx
pn1:
    xor dx,dx
    div bx             ; dx=余数, ax=商
    push dx
    inc cx
    test ax,ax
    jnz pn1
pn2:
    pop dx
    add dl,'0'
    mov ah,2
    int 21h
    loop pn2
    pop dx
    pop cx
    pop bx
    ret
print_num endp
end main