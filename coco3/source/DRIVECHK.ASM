        assume cs:prog,ds:prog
prog    segment 'code'
        org 100h
start:  mov ax,cs
        mov ds,ax
        mov si,128
skip:   inc si
        mov al,es:[si]
        cmp al,32
        jz skip
        and al,223
        sub al,'A'
        jb bad_drive_spec
        mov bl,al
        mov bh,0
        inc bx
        mov cx,860h
        mov dx,offset buffer
        mov ax,440dh
        int 21h
        jb read_error
        mov al,buffer[1]
        cmp al,10
        jnb unknown
        mov ah,0
        mov bx,ax
        add bx,bx
        mov dx,offset first_part
        mov ah,9
        int 21h
        mov dx,descriptor[bx]
display:
        mov ah,9
        int 21h
        mov ax,4c00h
        int 21h
bad_drive_spec:
        mov dx,offset baddrive_msg
        jmp display
read_error:
        mov dx,offset read_msg
        jmp display
unknown:
        mov ah,al
        mov cl,4
        ror al,cl
        and ax,0f0fh
        or ax,3030h
        cmp al,3ah
        jb lower_ok
        add al,7
lower_ok:
        cmp ah,3ah
        jb upper_ok
        add ah,7
upper_ok:
        mov drive_code,ax
        mov dx,offset unknown_msg
        jmp display

baddrive_msg db 'Bad drive specification',13,10,'$'
read_msg db 'Service error',13,10,'$'
first_part db 'BIOS identifies drive as $'
unknown_msg db 'BIOS ID code '
drive_code dw 0
        db ' unknown',13,10,'$'
descriptor dw desc0
        dw desc1
        dw desc2
        dw desc3
        dw desc4
        dw desc5
        dw desc6
        dw desc7
        dw desc8
        dw desc9
desc0   db '320/360K floppy',13,10,'$'
desc1   db '1.2MB floppy',13,10,'$'
desc2   db '720K floppy',13,10,'$'
desc3   db '8" single density floppy',13,10,'$'
desc4   db '8" double density floppy',13,10,'$'
desc5   db 'hard disk',13,10,'$'
desc6   db 'tape drive',13,10,'$'
desc7   db '1.44MB floppy',13,10,'$'
desc8   db 'read/write optical',13,10,'$'
desc9   db '2.88MB floppy',13,10,'$'

buffer  db 0

prog    ends

        end start

