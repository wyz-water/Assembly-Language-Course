.model small
.stack 100h
.data
sum dw 0              ; 用来放结果的数据段变量
buf db 6 dup(0),'$'
.code
main proc
    mov ax,@data
    mov ds,ax

    xor ax,ax
    mov cx,100
    mov bx,1
L1:
    add ax,bx
    inc bx
    loop L1
    mov sum,ax         ; 结果放到数据段

    mov ax,sum         ; 再取回来
    lea si,buf
    mov bx,10
    xor cx,cx
C1:
    xor dx,dx
    div bx
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
    int 21h

    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h

    mov ax,4c00h
    int 21h
main endp
end main