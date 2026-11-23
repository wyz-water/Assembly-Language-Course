; ============================================================
; caldata.asm : 数据段(全局变量/表) + 栈段
; 模块 1/3, 供 calmain / calproc 通过 EXTRN 引用
; ============================================================
dseg segment public 'DATA'
    public year, month, days, weekday
    public prompt_y, prompt_m, month_names, day_names, mdays, ttab
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
end