; ============================================================
; calmain.asm : 主程序 + 输入 (代码段 CSEG1)
; 模块 2/3
; 段间调用: call far ptr 跳进 calproc 的 CSEG2,
; 远调用会同时压入 CS 和 IP, 返回用 retf 一起恢复。
; ============================================================
include cal.inc

dseg segment public 'DATA'
    extrn year:word, month:byte, days:byte, weekday:byte
    extrn prompt_y:byte, prompt_m:byte
dseg ends

sseg segment stack
sseg ends

cseg1 segment public 'CODE'
    assume cs:cseg1, ds:dseg, ss:sseg
    extrn day_of_week:far, print_calendar:far
main proc far
    mov ax,dseg
    mov ds,ax

    mov ah,9
    mov dx,offset prompt_y
    int 21h
    call read_number
    mov year,ax

    mov ah,9
    mov dx,offset prompt_m
    int 21h
    call read_number
    mov month,al

    mov bx,year
    mov cl,month
    call far ptr day_of_week   ; 远调用(跨段), 机器码 9A
    mov weekday,al

    call far ptr print_calendar ; 远调用(跨段), 机器码 9A

    mov ax,4c00h
    int 21h
main endp

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
end main