; ============================================================
; calproc.asm : 计算 + 打印过程 (代码段 CSEG2)
; 模块 3/3, 过程全部 public 供 calmain 远调用
; 段内的近调用 call xxx 机器码是 E8(相对16位偏移, 只压 IP),
; 跨段的远调用 call far ptr xxx 机器码是 9A(段:偏移, 压 CS 和 IP)。
; ============================================================
include cal.inc

dseg segment public 'DATA'
    extrn year:word, month:byte, days:byte, weekday:byte
    extrn month_names:byte, day_names:byte, mdays:byte, ttab:byte
dseg ends

cseg2 segment public 'CODE'
    assume cs:cseg2, ds:dseg
    public day_of_week, print_calendar

is_leap proc near
    push bx
    push cx
    push dx
    mov ax,bx
    xor dx,dx
    mov cx,400
    div cx
    cmp dx,0
    je leap_yes
    mov ax,bx
    xor dx,dx
    mov cx,4
    div cx
    cmp dx,0
    jne leap_no
    mov ax,bx
    xor dx,dx
    mov cx,100
    div cx
    cmp dx,0
    je leap_no
leap_yes:
    mov al,1
    jmp leap_ret
leap_no:
    mov al,0
leap_ret:
    pop dx
    pop cx
    pop bx
    ret
is_leap endp

days_in_month proc near
    push bx
    push cx
    push si
    mov al,cl
    xor ah,ah
    dec ax
    mov si,offset mdays
    add si,ax
    mov al,[si]
    cmp cl,2
    jne dim_done
    call is_leap
    cmp al,1
    jne dim_done
    mov al,29
dim_done:
    pop si
    pop cx
    pop bx
    ret
days_in_month endp

day_of_week proc far
    push bp
    mov bp,sp
    push bx
    push cx
    push dx
    push si
    push di
    mov al,byte ptr [bp-4]
    cmp al,3
    jae dow_noadj
    dec bx
dow_noadj:
    mov ax,bx
    mov di,ax
    xor dx,dx
    mov cx,4
    div cx
    add di,ax
    mov ax,bx
    xor dx,dx
    mov cx,100
    div cx
    sub di,ax
    mov ax,bx
    xor dx,dx
    mov cx,400
    div cx
    add di,ax
    mov al,byte ptr [bp-4]
    xor ah,ah
    dec ax
    mov si,offset ttab
    add si,ax
    mov al,[si]
    xor ah,ah
    add di,ax
    inc di
    mov ax,di
    xor dx,dx
    mov cx,7
    div cx
    mov al,dl
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret
day_of_week endp

print_month_name proc far
    push bp
    mov bp,sp
    push bx
    push si
    mov ax,[bp+6]
    xor ah,ah
    dec ax
    mov bx,10
    mul bx
    mov si,offset month_names
    add si,ax
    mov ah,9
    mov dx,si
    int 21h
    pop si
    pop bx
    pop bp
    ret
print_month_name endp

print_num proc near
    push bx
    push cx
    push dx
    mov bx,10
    xor cx,cx
pn1:
    xor dx,dx
    div bx
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

print_day proc near
    push bp
    mov bp,sp
    push dx
    push bx
    mov dl,[bp-2]
    cmp dl,10
    jae pd_two
    printc ' '
    printc ' '
    mov dl,[bp-2]
    add dl,'0'
    mov ah,2
    int 21h
    jmp pd_ret
pd_two:
    printc ' '
    mov al,[bp-2]
    xor ah,ah
    mov bl,10
    div bl
    push ax
    mov dl,al
    add dl,'0'
    mov ah,2
    int 21h
    pop ax
    mov dl,ah
    add dl,'0'
    mov ah,2
    int 21h
pd_ret:
    pop bx
    pop dx
    pop bp
    ret
print_day endp

print_nl proc near
    newline
    ret
print_nl endp

print_calendar proc far
    push bp
    mov bp,sp
    push bx
    push cx
    push dx
    push si
    push di
    printc ' '
    printc ' '
    printc ' '
    mov ax,0
    mov al,month
    push ax
    call far ptr print_month_name
    add sp,2
    mov ax,year
    call print_num
    call print_nl
    mov ah,9
    mov dx,offset day_names
    int 21h
    mov bx,year
    mov cl,month
    call days_in_month
    mov days,al
    mov al,weekday
    mov bl,3
    mul bl
    mov cx,ax
    jcxz lead_skip
lead_lp:
    printc ' '
    loop lead_lp
lead_skip:
    mov dl,1
    mov al,weekday
    xor ah,ah
    mov si,ax
    xor ch,ch
    mov cl,days
    jcxz cal_done
day_lp:
    call print_day
    inc dl
    inc si
    cmp si,7
    jne day_nobr
    mov si,0
    call print_nl
day_nobr:
    loop day_lp
cal_done:
    call print_nl
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret
print_calendar endp
cseg2 ends
end