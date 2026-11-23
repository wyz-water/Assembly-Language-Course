; ============================================================
; 作业6: 输出月历 (1900-2099)
; 两个代码段: cseg1(主程序+输入), cseg2(计算+打印),
; 段间用远调用 call far ptr, 体会短/近/远跳转的区别。
; 参数传递三种方式都用到了:
;   寄存器传参: day_of_week(BX=年, CL=月)
;   数据段传参: print_calendar 读全局变量 year/month/weekday
;   栈传参:     print_month_name (参数压在栈上, far调用后 [bp+6] 取)
; ============================================================

dseg segment
    year   dw 0
    month  db 0
    days   db 0
    weekday db 0
    prompt_y db 'year(1900-2099):$'
    prompt_m db 'month(1-12):$'
    month_names db 'January  $','February $','March    $','April    $'
                db 'May      $','June     $','July     $','August   $'
                db 'September$','October  $','November $','December $'
    day_names db 'Su Mo Tu We Th Fr Sa',0dh,0ah,'$'
    mdays db 31,28,31,30,31,30,31,31,30,31,30,31
    ttab  db 0,3,2,5,0,3,5,1,4,6,2,4
dseg ends

sseg segment stack
    db 400h dup(?)
sseg ends

; ================= 代码段 1: 主程序 + 输入 =================
cseg1 segment para public 'CODE'
    assume cs:cseg1, ds:dseg, ss:sseg
main proc far
    mov ax,dseg
    mov ds,ax

    mov ah,9
    mov dx,offset prompt_y
    int 21h
    call read_number      ; ax = 年
    mov year,ax

    mov ah,9
    mov dx,offset prompt_m
    int 21h
    call read_number      ; ax = 月
    mov month,al

    ; 寄存器传参: bx=年, cl=月, 返回 al=星期
    mov bx,year
    mov cl,month
    call far ptr day_of_week
    mov weekday,al

    ; 数据段传参: 读全局变量
    call far ptr print_calendar

    mov ax,4c00h
    int 21h
main endp

; 读一个十进制数(最大4位), 返回 AX
read_number proc near
    xor bx,bx
rn_loop:
    mov ah,1
    int 21h
    cmp al,0dh
    je rn_done
    cmp al,0ah
    je rn_loop
    sub al,'0'
    xor ah,ah
    mov cx,ax
    mov ax,bx
    mov dx,10
    mul dx
    add ax,cx
    mov bx,ax
    jmp rn_loop
rn_done:
    mov ax,bx
    ret
read_number endp
cseg1 ends

; ================= 代码段 2: 计算 + 打印 =================
cseg2 segment para public 'CODE'
    assume cs:cseg2, ds:dseg

; 判闰年: bx=年 -> al=1闰 0平
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

; 某月天数: bx=年, cl=月 -> al=天数
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
    call is_leap        ; bx 还是年
    cmp al,1
    jne dim_done
    mov al,29
dim_done:
    pop si
    pop cx
    pop bx
    ret
days_in_month endp

; 算 1 号的星期: bx=年, cl=月 -> al=0..6 (0=周日)
; 公式: t={0,3,2,5,0,3,5,1,4,6,2,4}
;       m<3 时 y 减 1
;       w=(y+y/4-y/100+y/400+t[m-1]+1) mod 7
day_of_week proc far
    push bp
    mov bp,sp
    push bx             ; [bp-2]=bx
    push cx             ; [bp-4]=cx (低字节是月)
    push dx
    push si
    push di
    ; 1/2 月按上一年算
    mov al,byte ptr [bp-4]
    cmp al,3
    jae dow_noadj
    dec bx
dow_noadj:
    mov ax,bx
    mov di,ax           ; sum = y
    xor dx,dx
    mov cx,4
    div cx
    add di,ax           ; + y/4
    mov ax,bx
    xor dx,dx
    mov cx,100
    div cx
    sub di,ax           ; - y/100
    mov ax,bx
    xor dx,dx
    mov cx,400
    div cx
    add di,ax           ; + y/400
    mov al,byte ptr [bp-4]
    xor ah,ah
    dec ax
    mov si,offset ttab
    add si,ax
    mov al,[si]
    xor ah,ah
    add di,ax           ; + t[m-1]
    inc di              ; + 1
    mov ax,di
    xor dx,dx
    mov cx,7
    div cx              ; dx = w
    mov al,dl           ; al = 星期
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret
day_of_week endp

; 打印月名: 参数在栈上(far调用, [bp+6]=月)
print_month_name proc far
    push bp
    mov bp,sp
    push bx
    push si
    mov ax,[bp+6]
    xor ah,ah
    dec ax
    mov bx,10
    mul bx              ; (月-1)*10
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

; 打印 AX (1900..2099)
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

; 打印一天的 3 字符格子(右对齐), dl=日(1..31), 不破坏调用者的寄存器
print_day proc near
    push bp
    mov bp,sp
    push dx             ; [bp-2] = 日
    push bx
    mov dl,[bp-2]
    cmp dl,10
    jae pd_two
    mov dl,' '
    mov ah,2
    int 21h
    mov dl,' '
    mov ah,2
    int 21h
    mov dl,[bp-2]
    add dl,'0'
    mov ah,2
    int 21h
    jmp pd_ret
pd_two:
    mov dl,' '
    mov ah,2
    int 21h
    mov al,[bp-2]
    xor ah,ah
    mov bl,10
    div bl              ; al=十位 ah=个位
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

; 换行
print_nl proc near
    push dx
    mov dl,0dh
    mov ah,2
    int 21h
    mov dl,0ah
    mov ah,2
    int 21h
    pop dx
    ret
print_nl endp

; 打印整张月历(数据段传参: year/month/weekday 全局变量)
print_calendar proc far
    push bp
    mov bp,sp
    push bx
    push cx
    push dx
    push si
    push di
    ; 标题: 3空格 + 月名 + 空格 + 年
    mov dl,' '
    mov ah,2
    int 21h
    mov dl,' '
    mov ah,2
    int 21h
    mov dl,' '
    mov ah,2
    int 21h
    mov ax,0
    mov al,month
    push ax
    call far ptr print_month_name   ; 栈传参
    add sp,2
    mov ax,year
    call print_num
    call print_nl
    ; 星期行
    mov ah,9
    mov dx,offset day_names
    int 21h
    ; 天数
    mov bx,year
    mov cl,month
    call days_in_month
    mov days,al
    ; 前导空格 weekday*3
    mov al,weekday
    mov bl,3
    mul bl
    mov cx,ax
    jcxz lead_skip
lead_lp:
    mov dl,' '
    mov ah,2
    int 21h
    loop lead_lp
lead_skip:
    ; 日循环: dl=日, si=列(0..6), cx=剩余天数
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
end main