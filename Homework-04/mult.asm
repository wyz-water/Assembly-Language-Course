.model small
.stack 100h
.data
head db 'The 9*9 table:',0dh,0ah,'$'
.code
main proc
    mov ax,@data
    mov ds,ax

    mov ah,9
    lea dx,head
    int 21h            ; 打印标题

    mov ch,9           ; 外层循环: 第一个因数, 9 到 1
row_loop:
    mov cl,9           ; 内层循环: 第二个因数, 9 到 1
col_loop:
    mov al,ch          ; al = 第一个因数
    mov bl,cl          ; bl = 第二个因数
    call print_item    ; 打印 "a*b=p "
    dec cl
    jnz col_loop

    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah
    mov ah,2
    int 21h            ; 换行

    dec ch
    jnz row_loop

    mov ax,4c00h
    int 21h
main endp

; ------------------------------------------------------
; 过程 print_item
; 输入: AL = 第一个因数, BL = 第二个因数
; 输出: 打印 "a*b=p " (p 是一位或两位的积)
; 说明: 过程里用到了主过程的 AX/BX/CX/DX/DI,
;       所以在入口处全部压栈保存, 返回前再恢复,
;       这样主过程的循环计数器 CH/CL 不会被破坏。
; ------------------------------------------------------
print_item proc
    push ax            ; 保存主过程的寄存器
    push bx
    push cx
    push dx
    push di

    mov ch,al          ; ch = a
    mov cl,bl          ; cl = b
    mul bl             ; AX = a*b (最大 9*9=81, 不会溢出)
    mov di,ax          ; di = 积

    mov dl,ch
    add dl,'0'
    mov ah,2
    int 21h            ; 打印 a

    mov dl,'*'
    mov ah,2
    int 21h            ; 打印 '*'

    mov dl,cl
    add dl,'0'
    mov ah,2
    int 21h            ; 打印 b

    mov dl,'='
    mov ah,2
    int 21h            ; 打印 '='

    mov ax,di          ; 取积
    mov bl,10
    div bl             ; al=十位, ah=个位
    mov ch,al
    mov cl,ah
    cmp ch,0
    je p_ones
    mov dl,ch
    add dl,'0'
    mov ah,2
    int 21h            ; 打印十位
p_ones:
    mov dl,cl
    add dl,'0'
    mov ah,2
    int 21h            ; 打印个位

    mov dl,' '
    mov ah,2
    int 21h            ; 打印空格

    pop di             ; 恢复
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_item endp
end main