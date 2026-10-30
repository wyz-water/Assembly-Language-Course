.model small
.stack 100h
.data
buf db 6 dup(0),'$'
.code
main proc
    mov ax,@data
    mov ds,ax

    xor ax,ax          ; 和放在寄存器 AX 里
    mov cx,100
    mov bx,1
L1:
    add ax,bx
    inc bx
    loop L1            ; AX = 1+2+...+100 = 5050

    ; 把 AX 转成十进制字符串
    lea si,buf
    mov bx,10
    xor cx,cx
C1:
    xor dx,dx
    div bx             ; DX=余数, AX=商
    push dx
    inc cx
    test ax,ax
    jnz C1
C2:
    pop dx
    add dl,'0'
    mov [si],dl
    inc si
    loop C2
    mov byte ptr [si],'$'

    mov ah,9
    lea dx,buf
    int 21h            ; 打印结果

    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h            ; 换行

    mov ax,4c00h
    int 21h
main endp
end main