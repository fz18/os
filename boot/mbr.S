%include "boot.inc"
SECTION MBR vstart=0x7c00
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov sp, 0x7c00
	mov ax, 0xb800
	mov gs, ax 
;------------------------------
;   clean screen
;------------------------------
	mov ax, 0600h
	mov bx, 0700h
	mov cx, 0
	mov dx, 184fh
	int 10h
;;; get cursor
   mov byte [gs:0x00],'1'
   mov byte [gs:0x01],0xA4

   mov byte [gs:0x02],' '
   mov byte [gs:0x03],0xA4

   mov byte [gs:0x04],'M'
   mov byte [gs:0x05],0xA4	   ;A��ʾ��ɫ������˸��4��ʾǰ��ɫΪ��ɫ

   mov byte [gs:0x06],'B'
   mov byte [gs:0x07],0xA4

   mov byte [gs:0x08],'R'
   mov byte [gs:0x09],0xA4

	mov eax, LOADER_START_SECTOR
	mov bx, LOADER_BASE_ADDR
	mov cx, 4
	call rd_disk_m_16

	jmp LOADER_BASE_ADDR + 0x300

rd_disk_m_16:
	mov esi, eax
	mov di, cx
; 设置要读取的扇区
	mov dx, 0x1f2
	mov al, cl
	out dx, al
	mov eax, esi
; LBA 地址存入 0x1f3 ~ 0x1f6
	mov dx, 0x1f3
	out dx, al
	;LBA 15~8
	mov cl, 8
	shr eax, cl
	mov dx, 0x1f4
	out dx, al
	;LBA 23~16
	shr eax, cl
	mov dx, 0x1f5
	out dx, al

	shr eax, cl
	and al, 0x0f
	or al, 0xe0
	mov dx, 0x1f6
	out dx, al
; 0x1f7 读命令
	mov dx, 0x1f7
	mov al, 0x20
	out dx, al
; 检测硬盘状态
.not_ready:
	nop
	in al, dx
	and al, 0x88
	cmp al, 0x08
	jnz .not_ready

; 读数据
	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax
	mov dx, 0x1f0
.go_on_read:
	in ax, dx
	mov [bx], ax
	add bx, 2
	loop .go_on_read
	ret

	times 510-($-$$) db 0
	db 0x55, 0xaa