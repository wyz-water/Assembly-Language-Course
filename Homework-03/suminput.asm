.model small
.stack 100h
.data
prompt db 'Enter n (1-100): $'
buf db 6 dup(0),'$'
.code
main proc
    mov ax,@data
    mov ds,ax

    mov ah,9
    lea dx,prompt
    int 21h            ; 提示输入

    xor bx,bx          ; bx = n
read_loop:
    mov ah,1
    int 21h            ; 读一个字符
    cmp al,0dh         ; 回车?
    je read_done
    sub al,'0'
    xor ah,ah
    mov cx,ax          ; cx = 这位数字
    mov ax,bx
    mov dx,10
    mul dx             ; ax = n*10
    add ax,cx
    mov bx,ax          ; n = n*10 + 数字
    jmp read_loop
read_done:

    xor ax,ax          ; 和 = 0
    mov cx,bx          ; cx = n
    cmp cx,0
    je done_sum
    mov bx,1
sum_loop:
    add ax,bx
    inc bx
    loop sum_loop
done_sum:

    ; 先把 AX 转成十进制存到 buf（后面打印会破坏 AX）
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

    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h            ; 补一个换行

    mov ah,9
    lea dx,buf
    int 21h            ; 打印和

    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h

    mov ax,4c00h
    int 21h
main endp
end main