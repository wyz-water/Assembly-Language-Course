.model small
.stack 400h
.data
prompt db 'n=$'
buf db 6 dup(0),'$'
.code
main proc
    mov ax,@data
    mov ds,ax

    mov ah,9
    lea dx,prompt
    int 21h            ; 提示输入 n

    xor bx,bx
read_loop:
    mov ah,1
    int 21h            ; 读一个字符
    cmp al,0dh         ; 回车?
    je read_done
    sub al,'0'
    xor ah,ah
    mov cx,ax
    mov ax,bx
    mov dx,10
    mul dx
    add ax,cx
    mov bx,ax          ; n = n*10 + 数字
    jmp read_loop
read_done:

    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah
    mov ah,2
    int 21h            ; 换行

    mov ax,bx          ; ax = n
    call fib           ; ax = F(n)

    ; 先把 AX 转成十进制存到 buf(打印字符会破坏 AL)
    lea si,buf
    mov bx,10
    xor cx,cx
c1:
    xor dx,dx
    div bx
    push dx
    inc cx
    test ax,ax
    jnz c1
c2:
    pop dx
    add dl,'0'
    mov [si],dl
    inc si
    loop c2
    mov byte ptr [si],'$'

    mov ah,9
    lea dx,buf
    int 21h            ; 打印 F(n)

    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah
    mov ah,2
    int 21h

    mov ax,4c00h
    int 21h
main endp

; ------------------------------------------------------
; 递归求斐波那契数 fib(n)
; 输入: AX = n, 输出: AX = F(n), F(0)=0, F(1)=1
; 参数和中间结果都用寄存器 (BX 存 n, DX 存 F(n-1))
; 栈空间: 每层递归在栈上占用约 6 字节
;   (返回地址 2 + push bx 2 + push ax 保存F(n-1) 2),
;   递归深度约 n 层, n=100 约需 600 字节,
;   所以 .stack 400h(1024字节) 足够, 不会 stack overflow。
; 结果范围: 16 位最大 65535, F(24)=46368 还放得下,
;   n>=25 时结果会溢出。
; ------------------------------------------------------
fib proc
    cmp ax,1
    jbe f_ret          ; n=0 -> 0, n=1 -> 1, 直接返回
    push bx            ; 保存调用者的 bx
    mov bx,ax          ; bx = n
    dec ax
    call fib           ; ax = F(n-1)
    push ax            ; 保存 F(n-1)
    mov ax,bx
    sub ax,2
    call fib           ; ax = F(n-2)
    pop dx             ; dx = F(n-1)
    add ax,dx          ; ax = F(n-1)+F(n-2)
    pop bx             ; 恢复 bx
f_ret:
    ret
fib endp
end main