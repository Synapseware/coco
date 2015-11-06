        TITLE TRS-80 Colour Computer File Import/Export Utility

        ASSUME CS:PROG,DS:PROG

PROG    SEGMENT PUBLIC 'CODE'

        PUBLIC FDC_TRACK,FDC_SECTOR,DRIVE_SEL,DTA,HANDLE,DOUBLE_STEP

        EXTRN PHYS_READ:NEAR,PHYS_WRITE:NEAR,INITIALIZE:NEAR,SPINUP:NEAR
        EXTRN DRIVE_STATUS:NEAR,DRIVE_TYPE:BYTE
        EXTRN FRAME:BYTE,VIDEO_SEGMENT:WORD

;Macros

;Keyscan:  Return scancode in AH, ASCII in AL.

KEYSTROKE MACRO
        MOV AH,0
        INT 16H
        ENDM
 
;Subroutines

;Read a sector from the CoCo disk to the Disk Transfer Address

READ:
        CMP BYTE PTR HANDLE[1],-2
        JZ READ1
        MOV AL,18
        MUL BYTE PTR FDC_TRACK
        MOV CH,0
        MOV CL,FDC_SECTOR
        ADD AX,CX
        DEC AX
        MOV CL,AH               ;Determine offset in virtual disk
        MOV DH,AL
        MOV DL,CH
        MOV AX,4200H
        MOV BX,HANDLE
        INT 21H
        MOV AH,3FH
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        JB READ2
        RET
READ1:  CALL PHYS_READ          ;Read physical disk sector
        AND AL,9CH
        JNZ READ2
        RET
READ2:  MOV AL,FDC_TRACK        ;Display error window
        MOV AH,0
        MOV BL,10
        DIV BL
        OR AX,3030H
        MOV WORD PTR MSG10A,AX
        MOV AL,FDC_SECTOR
        MOV AH,0
        MOV BL,10
        DIV BL
        OR AX,3030H
        MOV WORD PTR MSG10B,AX
        MOV DI,OFFSET MSG10
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        JNB READ3                ;Carry set if retry
        PUSH WORD PTR FDC_TRACK ;Recalibrate if error
        MOV FDC_TRACK,0
        CALL READ
        POP WORD PTR FDC_TRACK
        JMP READ
READ3:  RET

;Write a sector from the CoCo disk to the Disk Transfer Address

WRITE:
        CMP BYTE PTR HANDLE[1],-2
        JZ WRITE1
        MOV AL,18
        MUL BYTE PTR FDC_TRACK
        MOV CH,0
        MOV CL,FDC_SECTOR
        ADD AX,CX
        DEC AX
        MOV CL,AH               ;Determine offset in virtual disk
        MOV DH,AL
        MOV DL,CH
        MOV AX,4200H
        MOV BX,HANDLE
        INT 21H
        MOV AH,40H
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        JB WRITE2
        RET
WRITE1: MOV AL,0                ;Write physical disk sector
        CALL PHYS_WRITE
        AND AL,0BCH
        JNZ WRITE2
        RET
WRITE2: MOV AL,FDC_TRACK        ;Display error window
        MOV AH,0
        MOV BL,10
        DIV BL
        OR AX,3030H
        MOV WORD PTR MSG19A,AX
        MOV AL,FDC_SECTOR
        MOV AH,0
        MOV BL,10
        DIV BL
        OR AX,3030H
        MOV WORD PTR MSG19B,AX
        MOV DI,OFFSET MSG19
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        JB WRITE                ;Carry set if retry
        RET

;Update the status display on the settings of the various switches

SETTINGS:
        MOV DX,711H             ;Move from
        MOV CX,14
        MOV BX,0B07H
        MOV SI,OFFSET MSG3A
        CMP BYTE PTR TO_COCO,0
        JNZ SETTINGS1
        MOV SI,OFFSET MSG3B
SETTINGS1:
        CALL ITEM
        MOV BX,0B0BH            ;Also display it before "file to move:"
        MOV CX,4
        MOV DX,1600H
        CALL ITEM
        MOV DX,819H             ;Drive head
        MOV BX,0B07H
        CMP HANDLE,0
        JL SETTINGS2
        MOV BX,808H             ;Shadow it if virtual disk being selected
SETTINGS2:
        CALL SHADOW
        MOV CX,6
        MOV SI,OFFSET MSG4A
        CMP BYTE PTR DRIVE_SEL,80H
        JZ SETTINGS3
        MOV SI,OFFSET MSG4B
SETTINGS3:
        CALL ITEM
        MOV DX,91DH             ;Maximum tracks
        MOV SI,OFFSET MSG5C
        MOV AL,MAX_TRACK
        CMP AL,80
        JZ SETTINGS3A
        SUB SI,2
        CMP AL,40
        JZ SETTINGS3A
        SUB SI,2
SETTINGS3A:
        MOV BX,0B07H
        MOV CX,2
        CALL ITEM
        MOV DX,0D15H            ;File type
        MOV BX,0B07H
        CMP INPUT_LENGTH,8
        JZ SETTINGS3B
        CMP BYTE PTR TO_COCO,0
        JNZ SETTINGS7
        CMP BYTE PTR DIR_PTR,-1
        JNZ SETTINGS7
SETTINGS3B:
        MOV BX,808H             ;Shadow if from CoCo and no file selected
SETTINGS7:
        CALL SHADOW
        MOV AL,10
        MUL BYTE PTR FTYPE
        ADD AX,OFFSET MSG7A
        MOV SI,AX
        MOV CX,10
        CALL ITEM
        MOV DX,0E19H            ;File format
        CALL SHADOW
        MOV CX,6
        MOV SI,OFFSET MSG8A
        CMP BYTE PTR FFORMAT,0
        JZ SETTINGS8
        MOV SI,OFFSET MSG8B
SETTINGS8:
        CALL ITEM
        MOV DX,0A1CH            ;Add/strip LFs
        CMP BYTE PTR FFORMAT,0
        MOV BX,0B07H
        JNZ SETTINGS4
        MOV BX,808H             ;Shadow if moving binaries, or in VNAME
SETTINGS4:
        CALL SHADOW
        MOV CX,3
        MOV SI,OFFSET MSG6A
        CMP BYTE PTR ADDLF,0
        JNZ SETTINGS5
        MOV SI,OFFSET MSG6B
SETTINGS5:
        CALL ITEM
        MOV DX,0B1CH            ;Add/strip EOFs
        CALL SHADOW
        MOV CX,3
        MOV SI,OFFSET MSG6A
        CMP BYTE PTR ADDEOF,0
        JNZ SETTINGS6
        MOV SI,OFFSET MSG6B
SETTINGS6:
        CALL ITEM
        RET

ITEM:               ;Display string length CX in SI at DX
        PUSH BX
        PUSH CX
        MOV CX,1
        LODSB
        CMP AL,'.'
        JNZ ITEM1
        MOV BL,BH               ;Periods are the same colour as the descriptor
ITEM1:  MOV BH,0
        CALL PC_CHAR
        POP CX
        POP BX
        INC DL
        LOOP ITEM
        RET

SHADOW:               ;Change colour of line depending on whether
        PUSH DS                 ;it means anything
        MOV DS,VIDEO_SEGMENT
        MOV AL,160
        MUL DH
        ADD AX,3
        MOV DI,AX
        MOV CX,29
SHADOW1:
        MOV [DI],BH
        ADD DI,2
        LOOP SHADOW1
        POP DS
        RET

;Handle function keys pressed during GET_FILE

FUNCTIONS:
        CMP AH,0FH
        JNZ FUNCTIONS_0
        MOV AX,3C00H
FUNCTIONS_0:
        CMP AX,3B00H            ;Below F1
        JB FUNCTIONS_1
        CMP AX,4300H            ;or above F8, then ignore
        JNB FUNCTIONS_1
        XCHG AH,AL
        MOV BX,AX
        ADD BX,BX
        CALL SWITCH[BX-118]
        PUSH DX
        CALL SETTINGS
        POP DX
        STC                     ;Carry set indicates function key handled
        RET
FUNCTIONS_1:
        CLC                     ;Carry clear indicates not a function key
        RET

SWITCH  DW OPTION1,OPTION2,OPTION3,OPTION4,OPTION5,OPTION6,OPTION7,OPTION8

MOUSE   DW NULL,NULL,NULL,NULL,NULL,OPTION1,NULL
        DW OPTION2,OPTION3,OPTION4,OPTION5,OPTION6,NULL
        DW OPTION7,OPTION8,NULL,EXIT,NULL,NULL,NULL,NULL,NULL,ACCEPT

OPTION1:                        ;Change virtual disk
        MOV SP,ENTRY_STACK
        MOV AL,COCO_DISK
        AND AL,0DFH
        MOV SI,OFFSET MSG1      ;Display help according to whether a name
        JZ OPTION1_A            ;has already been set
        MOV SI,OFFSET MSG2
OPTION1_A:
        CALL DISPLAY
        CALL HILITE             ;Remove any highlighted files
        MOV DIR_PTR,-1
        JMP VNAME
OPTION2:                        ;Move direction
        NOT BYTE PTR TO_COCO
        CMP BYTE PTR INPUT_LENGTH,8
        JZ OPTION2_C
        CMP BYTE PTR DIR_PTR,-1
        JZ OPTION2_A
        CALL HILITE             ;Remove highlighting if column switched
OPTION2_A:
        MOV DIR_PTR,-1          ;Turn off highlight flag
        CMP BYTE PTR TO_COCO,0
        JZ OPTION2_B            ;If moving from MS-DOS to CoCo
        MOV CUR_DIR,OFFSET PC_DIR
        MOV DIR_COLUMN,58       ;select MS-DOS directory for cursor
        MOV AL,PC_PAGE          ;Set current PC page, store current CoCo page
        XCHG AL,BYTE PTR DIR_PAGE
        MOV COCO_PAGE,AL
        RET
OPTION2_B:
        MOV CUR_DIR,OFFSET COCO_DIR
        MOV DIR_COLUMN,34       ;Otherwise select CoCo directory
        MOV AL,COCO_PAGE
        XCHG AL,BYTE PTR DIR_PAGE
        MOV PC_PAGE,AL
OPTION2_C:
        RET
OPTION3:                        ;Drive head
        XOR BYTE PTR DRIVE_SEL,10H
        CMP BYTE PTR HANDLE[1],-2
        JZ OPTION3_A
        RET
OPTION3_A:                      ;New CoCo disk
        MOV SP,ENTRY_STACK
        JMP FLIP_COCO_DISK
OPTION4:                        ;Change track maximum
        MOV AL,MAX_TRACK
        CMP AL,35
        MOV AH,40
        JZ OPTION4_A
        CMP AL,AH
        MOV AH,80
        JZ OPTION4_A
        MOV AH,35
OPTION4_A:
        MOV MAX_TRACK,AH
        PUSH DX                 ;Recalculate free space
        CALL CFREE
        POP DX
        RET
OPTION5:                        ;Change LF filter status
        NOT BYTE PTR ADDLF
        RET
OPTION6:                        ;Change EOF filter status
        NOT BYTE PTR ADDEOF
        RET
OPTION7:                        ;Change file type
        CMP BYTE PTR TO_COCO,0
        JNZ OPTION7_A
        CMP DIR_PTR,-1
        JZ OPTION7_A
        RET                     ;but only if no CoCo file highlighted
OPTION7_A:
        INC BYTE PTR FTYPE
        AND BYTE PTR FTYPE,3
        RET
OPTION8:                        ;Change file format
        CMP BYTE PTR TO_COCO,0
        JNZ OPTION8_A
        CMP DIR_PTR,-1
        JZ OPTION8_A
        RET
OPTION8_A:
        NOT BYTE PTR FFORMAT
        RET

ACCEPT: CMP BYTE PTR INPUT_LENGTH,8
        JZ NULL                 ;Forces return if clicked on filename input
        CMP CL,19
        JB NULL
        CMP CL,31
        JNB NULL
        POP AX
        JMP GETF5C
NULL:   RET

;Display CX copies of PC character AL at DX, foreground BL, background BH
;bit 7 of BL = 1 => reverse character

PC_CHAR:
        PUSH BX
        PUSH CX
        PUSH DI
        PUSH ES
        TEST BL,128
        JZ PC1
        XCHG BH,BL
PC1:    SHL BH,1
        SHL BH,1
        SHL BH,1
        SHL BH,1
        AND BX,700FH
        OR BL,BH
        PUSH AX
        MOV AL,160
        MUL DH
        ADD AL,DL
        ADC AH,0
        ADD AL,DL
        ADC AH,0
        MOV DI,AX
        MOV AX,0B800H
        MOV ES,AX
        POP AX
        MOV AH,BL
        REP STOSW
        POP ES
        POP DI
        POP CX
        POP BX
        RET

;Display an overlay menu in [DI] (with shadow) at video coord DX, with 
;height BH, width BL.  Menu framework is light cyan on dark blue.
;BH bit 7=1 => draw shadow

MENU:       
        PUSH BX
MENU1:  PUSH BX
        MOV AL,[DI]
        INC DI
        MOV CX,1
        MOV BH,MENU_BACK
        MOV BL,BH
        XOR BL,10
        CALL PC_CHAR
        INC DL
        POP BX
        DEC BL
        JNZ MENU1
        POP AX
        PUSH AX
        MOV BL,AL
        SUB DL,AL
        INC DH
        DEC BH
        TEST BH,127
        JNZ MENU1
        POP BX
        SUB DH,BH
        ADD DH,128
        TEST BH,128
        JNZ MENU2
        RET
MENU2:  ADD DL,BL               ;Create shadow
        INC DH
        MOV AL,160
        MUL DH
        ADD AL,DL
        ADC AH,0
        ADD AL,DL
        ADC AH,0
        MOV DI,AX
        INC DI
        AND BH,127
        PUSH DS
        MOV AX,0B800H
        MOV DS,AX
MENU3:  AND BYTE PTR [DI],07H
        ADD DI,160
        DEC BH
        JNZ MENU3
        SUB DI,160
        MOV CX,BX
        DEC BX
        SHL BX,1
        SUB DI,BX
MENU4:  AND BYTE PTR [DI],07H
        ADD DI,2
        LOOP MENU4
        POP DS
        RET

MENU_BACK DB 4                  ;Window background colour is red

;Read current directory.  Search path name is in DX, table to store directory
;is at SI (21 bytes per entry), CX is number of free entries in table,
;BL=10h for a list of subdirectories, BL=0 for files.

;On return, DI=first empty entry in directory, CX=number of remaining free
;entries.  Directory is sorted alphabetically.

SEARCH:
        MOV DI,SI
        MOV AH,4EH
        PUSH CX
        MOV CL,BL
        MOV CH,0
        INT 21H
        POP CX
        JNB SEARCH0
        RET
SEARCH0:
        MOV AL,DTA[21]
        XOR AL,BL
        AND AL,16
        JZ SEARCH1
        JMP SEARCH9
SEARCH1:                        ;Find DTA's entry's position in alphabetic
        PUSH SI                 ;list
        PUSH BX
SEARCH2:
        MOV BX,0
        CMP SI,DI
        JNB SEARCH6
SEARCH3:
        MOV AL,DTA[BX+30]
        CMP AL,[SI+BX]
        JB SEARCH5
        JA SEARCH4
        INC BX
        CMP BX,12
        JB SEARCH3
SEARCH4:
        ADD SI,21
        JMP SEARCH2
SEARCH5:                        ;Shift entire directory list up one entry
        PUSH CX
        PUSH SI
        PUSH DI
        MOV CX,DI
        SUB CX,SI
        DEC DI
        MOV SI,DI
        ADD DI,21
        STD
        REP MOVSB
        MOV CX,21               ;Clear the newly created space
        MOV AL,32
        REP STOSB
        CLD
        POP DI
        POP SI
        POP CX
        MOV BX,0
SEARCH6:                        ;Move filename
        MOV AL,DTA[BX+30]
        MOV [SI],AL
        INC SI
        INC BL
        CMP AL,0
        JNZ SEARCH6
        SUB SI,BX               ;Position SI to last byte in entry
        ADD SI,20
        POP BX
        PUSH DX
        CMP DX,OFFSET ALL_SEARCH
        JNZ SEARCH8             ;Only include file sizes if *.*
        CMP BL,0
        JNZ SEARCH8             ;and not looking for directories
        MOV DX,WORD PTR DTA[28]
        MOV AX,WORD PTR DTA[26]
        PUSH BX
        CMP DX,1024             ;If file size exceeds 64MB (!), display "MB"
        JNB SEARCH6A            ;rather than bytes
        CMP DX,10               ;If file larger than 640K, display "K" rather
        JB SEARCH7              ;than bytes
        MOV BX,1024
        DIV BX
        MOV DX,0
        MOV BYTE PTR [SI],'K'
        DEC SI
        JMP SEARCH7
SEARCH6A:
        DEC SI                  ;Add "MB" extension
        MOV WORD PTR [SI],424DH
        DEC SI
        MOV AX,DX               ;Effectively divide by 64K
        MOV DX,0
        MOV BX,16               ;Divide by 16 (16*64K=1MB)
        DIV BX
        MOV DX,0
SEARCH7:                        ;Work out digits
        MOV BX,10
        DIV BX
        OR DL,'0'
        MOV [SI],DL
        DEC SI
        MOV DL,0
        CMP AX,DX
        JNZ SEARCH7
        POP BX
SEARCH8:
        ADD DI,21
        POP DX
        POP SI
        LOOP SEARCH9
        RET
SEARCH9:
        MOV AH,4FH
        INT 21H
        JNB SEARCH10
        RET
SEARCH10:
        JMP SEARCH0

;Read current CoCo disk's directory.  Table to store directory is COCO_DIR.

;On return, DI=first empty entry in directory.
;Directory is sorted alphabetically.

CSEARCH:
        MOV SI,OFFSET MSG11
        CALL DISPLAY
        MOV BYTE PTR FDC_TRACK,17       
        MOV BYTE PTR FDC_SECTOR,2
        CALL READ
        MOV SI,OFFSET DTA       ;Read GAT sector and store it
        MOV DI,OFFSET GAT
        MOV CX,256
        REP MOVSB
        MOV SI,OFFSET COCO_DIR
        MOV DI,SI
        MOV CX,16
CSEARCH0:
        PUSH CX
        PUSH DI
        INC BYTE PTR FDC_SECTOR
        CALL READ
        MOV BX,OFFSET DTA
CSEARCH1:
        MOV DI,OFFSET FILE_BFR
        MOV CX,8
        CMP BYTE PTR [BX],0     ;If entry deleted, skip it
        JZ CSEARCH2
        CMP BYTE PTR [BX],-1    ;If end of directory, exit
        JNZ CSEARCH3
        POP DI
        POP CX
        RET
CSEARCH2:                       ;Find next entry
        ADD BX,32
        CMP BX,OFFSET DTA+256
        JB CSEARCH1
        POP DI
        POP CX
        LOOP CSEARCH0
        RET
CSEARCH3:                       ;Construct name in FILE_BFR
        PUSH BX
        ADD BX,8
CSEARCH3A:
        DEC BX
        CMP BYTE PTR [BX],' '
        LOOPZ CSEARCH3A
        POP BX
        JCXZ CSEARCH2
        INC CX
        PUSH BX
CSEARCH3B:
        MOV AL,[BX]
        STOSB
        INC BX
        LOOP CSEARCH3B
        POP BX
        ADD BX,8
        ADD BX,CX               ;Set to start of extension
        MOV AH,[BX]
        CMP AH,' '
        JNZ CSEARCH4
        CMP word ptr [BX+1],2020H
        JZ CSEARCH5
CSEARCH4:
        MOV AL,'.'              ;If there's an extension, include it
        STOSW
        MOV AX,[BX+1]
        CMP AX,2020H
        JZ CSEARCH5
        STOSB
        MOV AL,AH
        CMP AL,' '
        JZ CSEARCH5
        STOSB
CSEARCH5:                       ;Add terminator
        MOV AL,0
        STOSB
        POP DI                  ;Restore end-of-list pointer
        PUSH DI
        MOV SI,OFFSET COCO_DIR  ;Find file's position in alphabetical order
        PUSH BX
CSEARCH6:
        MOV BX,0
        CMP SI,DI
        JNB CSEARCH10
CSEARCH7:
        MOV AL,FILE_BFR[BX]
        CMP AL,[SI+BX]
        JB CSEARCH9
        JA CSEARCH8
        INC BX
        CMP BX,12
        JB CSEARCH7
CSEARCH8:
        ADD SI,21
        JMP CSEARCH6
CSEARCH9:                       ;Shift entire directory list up one entry
        PUSH SI
        MOV CX,DI
        SUB CX,SI
        DEC DI
        MOV SI,DI
        ADD DI,21
        STD
        REP MOVSB
        MOV CX,21               ;Clear the newly created space
        MOV AL,32
        REP STOSB
        CLD
        POP SI
        MOV BX,0
CSEARCH10:                      ;Move filename
        MOV AL,FILE_BFR[BX]
        MOV [SI],AL
        INC SI
        INC BL
        CMP AL,0
        JNZ CSEARCH10
        SUB SI,BX               ;Position SI to last byte in entry
        ADD SI,20
        POP BX
        PUSH BX
        MOV AX,[BX+3]           ;Load type/format flags
        CMP AH,1
        MOV AH,'A'
        ADC AH,0
        OR AL,'0'
        MOV [SI-7],AX
        MOV DX,0                ;Determine length of file
        MOV AX,[BX+6]
        XCHG AH,AL
        MOV BL,[BX+5]           ;Get first granule number
        MOV BH,0
CSEARCH11:
        MOV BL,GAT[BX]
        CMP BL,192
        JA CSEARCH11A
        ADD AH,9                ;9 sectors per every full granule
        ADC DL,0
        CMP DL,9                ;Reality check: 576K is just too large
        JB CSEARCH11
        JMP CSEARCH11B
CSEARCH11A:
        AND BL,63               ;Add on number of sectors occupied in last
        DEC BL
        ADD AH,BL               ;granule
        ADC DX,0
        CMP DL,1                ;If above 100000, display in "K" format
        JB CSEARCH12
        JA CSEARCH11B
        CMP AX,34464            ;34464=100000-65536
        JB CSEARCH12
CSEARCH11B:
        MOV BX,1024
        DIV BX
        MOV DX,0
        MOV BYTE PTR [SI],'K'
        DEC SI
CSEARCH12:
        MOV BX,10               ;Work out digits
        DIV BX
        OR DL,'0'
        MOV [SI],DL
        DEC SI
        MOV DL,0
        CMP AX,DX
        JNZ CSEARCH12
        POP BX
        POP DI
        ADD DI,21
        PUSH DI
        SUB BX,8                ;Position to beginning of entry
        JMP CSEARCH2

;Build directory list and display first 18 entries in the directory window
;Specific file extension is given by FCB at DX.

TOTAL_DRIVES DB 0                       ;Total number of logical drives

DIR:
        MOV LAST_DIR,DX
        MOV DI,OFFSET PC_DIR
        MOV CX,10500
        MOV AL,' '
        REP STOSB
        MOV CL,TOTAL_DRIVES
        MOV CH,0
        MOV SI,OFFSET PC_DIR
        MOV AX,3A41H                    ;Drive list, starting with A:
DIR1A:  MOV BYTE PTR [SI],'['
        MOV [SI+1],AX
        MOV BYTE PTR [SI+3],']'
        INC AL
        ADD SI,21
        LOOP DIR1A
        PUSH DX
        MOV CX,498
        MOV AL,TOTAL_DRIVES
        MOV AH,0
        SUB CX,AX
        INC SI
        MOV DX,OFFSET ALL_SEARCH
        MOV BL,16
        CALL SEARCH
        INC CX
        DEC SI
        DEC DI
DIR2:   CMP SI,DI               ;Put brackets around directory names
        JNB DIR3
        MOV BYTE PTR [SI],'['
        ADD SI,21
        JMP DIR2
DIR3:   DEC SI
        CMP BYTE PTR [SI],0
        JNZ DIR4
        MOV BYTE PTR [SI],']'
DIR4:   CMP SI,OFFSET PC_DIR
        JNB DIR3
        POP DX
        MOV SI,DI
        MOV BL,0
        CALL SEARCH
        MOV DIR_PAGE,0
        MOV PC_PAGE,0
        MOV DIR_COLUMN,58
        MOV CUR_DIR,OFFSET PC_DIR
        CALL SHOWDIR
        RET

;Build CoCo file list and display first 18 entries in the directory window

CDIR:
        MOV DI,OFFSET COCO_DIR
        MOV CX,2709
        MOV AL,' '
        REP STOSB
        MOV SI,OFFSET COCO_DIR
        CALL CSEARCH
        MOV DI,OFFSET FILE_BFR  ;Clear buffer after construction
        MOV CX,32
        MOV AL,' '
        REP STOSB
        MOV DIR_PAGE,0
        MOV COCO_PAGE,0
        MOV DIR_COLUMN,34
        MOV CUR_DIR,OFFSET COCO_DIR
        CALL SHOWDIR
        RET

;Calculate and display new free space on CoCo disk

CFREE:
        MOV DI,OFFSET GAT
        MOV CL,MAX_TRACK        ;2 granules per allowed track
        MOV CH,0
        DEC CL                  ;One track is allocated to the directory
        ADD CX,CX
        MOV BX,0
        MOV AL,-1
CFREE1: REPNZ SCASB
        JNZ CFREE2
        ADD BX,9                ;If GAT byte is $FF, add 9 sectors free
        JCXZ CFREE2
        JMP CFREE1
CFREE2: MOV AL,0                ;DWORD of bytes free
        MOV AH,BL
        MOV DL,BH
        MOV DH,AL
        MOV CX,1305H            ;Display coordinates
CFREE3:
        MOV BX,10
        DIV BX
        OR DL,'0'
        PUSH CX
        PUSH AX
        MOV AL,DL
        INC BL
        MOV DX,CX
        MOV CX,1
        CALL PC_CHAR
        POP AX
        POP CX
        DEC CL
        MOV DX,0
        CMP CL,-1
        JG CFREE3
        RET

;Display the 18th*(DIR_PAGE) entry of the directory listing.

DIR_PAGE DW 0

SHOWDIR:
        MOV DIR_PTR,-1
        MOV AX,378              ;18*21
        MUL DIR_PAGE
        ADD AX,CUR_DIR
        MOV DL,DIR_COLUMN
        MOV SI,AX
        MOV DH,5
SHOWDIR1:
        MOV AL,[SI]
        MOV BX,107H
        MOV CX,1
        CALL PC_CHAR
        INC SI
        INC DL
        MOV AL,DIR_COLUMN
        ADD AL,21
        CMP DL,AL
        JB SHOWDIR1
        MOV DL,DIR_COLUMN
        INC DH
        CMP DH,23
        JB SHOWDIR1
        RET

;Display message pointed to by SI on last line of video.  Must be terminated
;by a 0.  Character code 01 is skipped.

DISPLAY:
        MOV DX,1800H        
        MOV AH,2
        MOV BX,14
        INT 10H
        MOV AX,920H
        MOV BX,14
        MOV CX,80
        INT 10H
DISPLAY1:
        LODSB
        DEC AL
        JZ DISPLAY1
        INC AL
        JZ DISPLAY2
        MOV AH,14
        INT 10H
        JMP DISPLAY1
DISPLAY2:                       ;Home cursor in case errors occur
        MOV AH,2
        MOV DX,1613H
        INT 10H
        RET

;Subroutine to force error fail so that internal routines can take over

ERROR_FAIL:
        MOV AL,3
        IRET

;Start of program

START:  MOV DI,129              ;Check for /H switch in command line in
        MOV CL,ES:[80H]         ;case there is no GENERAL.CFG available
        MOV CH,0
        JCXZ PARAM_LINE_DONE
PARAM_LINE:
        CMP WORD PTR [DI],482FH ;"/H"
        JZ HIGH_DENSITY
        CMP WORD PTR [DI],682FH ;"/h"
        JZ HIGH_DENSITY
        INC DI
        LOOP PARAM_LINE
        JMP PARAM_LINE_DONE
HIGH_DENSITY:
        MOV BYTE PTR CS:DOUBLE_STEP,0
PARAM_LINE_DONE:
        MOV AX,CS
        MOV DS,AX
        MOV ES,AX
        MOV ENTRY_STACK,SP
        MOV AH,1AH              ;Set disk transfer address
        MOV DX,OFFSET DTA
        INT 21H
        MOV AX,0                ;Test for presence of mouse
        INT 33H
        MOV MOUSE_HERE,AL
        MOV SI,OFFSET CUR_PATH  ;Save power-up path
        CALL SAVE_PATH
        MOV DX,OFFSET DTA+256
        CALL INITIALIZE
        MOV AX,3D00H
        MOV DX,OFFSET PORT_NAME
        INT 21H
        MOV BX,AX               ;Read configurations file
        JB NO_CONFIG
        MOV AH,3FH
        MOV CX,OFFSET CFGEND-OFFSET CFGTOP
        MOV DX,OFFSET CFGTOP
        INT 21H
NO_CONFIG:
        MOV AH,3EH
        INT 21H
        MOV AX,3D00H
        MOV DX,OFFSET GENERAL_NAME
        INT 21H
        MOV BX,AX               ;Read DOUBLE_STEP from emulator's GENERAL.CFG
        JB NO_GENERAL_CONFIG
        MOV AH,3FH
        MOV CX,94
        MOV DX,OFFSET DTA
        INT 21H
        MOV AL,DTA[93]
        MOV DOUBLE_STEP,AL
NO_GENERAL_CONFIG:        
        MOV AH,3EH
        INT 21H
        MOV AX,3
        INT 10H
        MOV AX,2524H
        MOV DX,OFFSET ERROR_FAIL
        INT 21H
NEW_SCREEN:                     ;Display main screen
        PUSH ES
        MOV AX,VIDEO_SEGMENT
        MOV ES,AX
        MOV SI,OFFSET FRAME
        MOV DI,0
        MOV CX,4000
        REP MOVSB
        POP ES
        CALL SETTINGS
        MOV AL,COCO_DISK        ;Set CoCo disk if none specified
        AND AL,0DFH
        JNZ SHOW_DIRECTORIES
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        JMP VNAME               ;Get the CoCo disk name
EXIT:   MOV AX,3                ;Clear screen
        INT 10H
        MOV AH,3CH              ;Create configurations file
        MOV CX,0
        MOV DX,OFFSET PORT_NAME
        INT 21H
        MOV BX,AX
        JB EXIT1
        MOV AH,40H
        MOV CX,OFFSET CFGEND-OFFSET CFGTOP
        MOV DX,OFFSET CFGTOP
        INT 21H
EXIT1:  MOV AH,3EH
        INT 21H
        MOV AX,4C00H            ;Exit utility
        INT 21H
SHOW_DIRECTORIES:
        MOV AL,COCO_DISK        ;If no CoCo disk name given at prompt, exit
        AND AL,0DFH
        JZ EXIT
        MOV DX,32CH             ;Display virtual disk name in proper colour
        MOV CX,8
        MOV BX,107H
        MOV AL,' '
        CALL PC_CHAR
        MOV SI,OFFSET COCO_DISK
        MOV CX,1
COCO_NAME:
        LODSB
        CMP AL,'.'
        JZ COCO_NAME_DONE
        CMP AL,' '
        JZ COCO_NAME_DONE
        CMP AL,0
        JZ COCO_NAME_DONE
        CMP AL,'a'
        JB NOT_LOWERCASE
        CMP AL,'z'
        JA NOT_LOWERCASE
        AND AL,0DFH
NOT_LOWERCASE:
        CALL PC_CHAR
        INC DL
        JMP COCO_NAME
COCO_NAME_DONE:
        MOV DX,OFFSET ALL_SEARCH
        CALL DIR                ;Display complete file directory now
FLIP_COCO_DISK:
        CALL CDIR               ;Also display CoCo directory
        CALL CFREE              ;and free space on disk
        MOV INPUT_LENGTH,12
        CALL SETTINGS
        JMP MAIN
EXITA:  JMP EXIT
MAIN:   MOV SI,OFFSET MSG9
TRY_AGAIN:
        CALL DISPLAY
        MOV INPUT_LENGTH,12
        CALL OPTION2            ;Switch move direction over and back so 
        CALL OPTION2            ;directory data is correct
        MOV BYTE PTR TERMINATOR,0
        MOV DX,1613H
        CALL GET_FILE
        JB EXITA
        CMP TO_COCO,0
        JZ RECV
        JMP SEND

;Read files from the CoCo disk

COMPARE DB 11 DUP(?)            ;11 byte filename in CoCo format for comparing
FCB     DB 16 DUP(?)            ;Copy of directory entry currently open
FCB_SECTOR DB 0                 ;Directory sector containing FCB
FCB_OFFSET DB 0                 ;Offset within directory sector of open FCB
FILE_FOUND DB 0                 ;Non-zero if a file was found
FHANDLE DW -1                   ;Handle of file being created

RECV:   MOV DI,OFFSET COMPARE   ;Clear file name comparison field
        MOV CX,11
        MOV AL,32
        REP STOSB
        MOV SI,OFFSET FILE_BFR+12
        MOV CX,12
RECV0:  DEC SI
        CMP BYTE PTR [SI],' '
        LOOPZ RECV0
        MOV BYTE PTR [SI+1],0
        MOV DI,OFFSET COMPARE   ;Load specified file name into compare field
        MOV SI,OFFSET FILE_BFR
        MOV BX,OFFSET COMPARE+8 ;End of current segment of file name
RECV1:  LODSB
        CMP AL,0
        JZ RECV4
        CMP AL,'.'
        JNZ RECV2
        CMP BX,OFFSET COMPARE+8
        JNZ RECV4               ;If first "." start at EXT (offset 8) in FCB
        MOV DI,OFFSET COMPARE+8
        MOV BX,OFFSET COMPARE+11
        JMP RECV1
RECV2:  ;CMP AL,'a'
        ;JB RECV3
        ;CMP AL,'z'
        ;JA RECV3
        ;AND AL,223
RECV3:  CMP AL,'*'              ;Substitute "?" for "*" wildcarding
        JNZ RECV3B
RECV3A: CMP DI,BX
        JNB RECV1
        MOV AL,'?'
        STOSB
        JMP RECV3A
RECV3B: CMP DI,BX               ;If at end of subfield, don't allow any more
        JNB RECV1               ;characters
        STOSB
        JMP RECV1
RECV4:  MOV BYTE PTR FDC_TRACK,17
        MOV BYTE PTR FDC_SECTOR,2
        CALL READ               ;Read GAT in case disk changed since last CDIR
        MOV SI,OFFSET DTA
        MOV DI,OFFSET GAT
        MOV CX,160
        REP MOVSB
        MOV FILE_FOUND,0        ;Reset file found indicator
RECV5:  INC BYTE PTR FDC_SECTOR
        CALL READ
        MOV BX,0
        MOV DI,0                ;See if this directory entry matches our file
RECV6:  MOV AL,COMPARE[DI]
        MOV AH,DTA[DI+BX]
        CMP AH,-1               ;Entry starts with -1 if end of directory
        JZ RECV8
        CMP AL,'?'              ;Skip wildcarded characters
        JZ RECV9
        CMP AL,AH
        JZ RECV9
RECV7:  MOV DI,0                ;If compare failed, go to next field
        ADD BL,32
        JNZ RECV6
        CMP BYTE PTR FDC_SECTOR,18
        JB RECV5
RECV8:  CMP FILE_FOUND,0        ;If done but a file not found, display error
        JNZ MAIN_A
        MOV AH,2
        MOV DL,7
        INT 21H
        MOV SI,OFFSET MSG12
        JMP TRY_AGAIN
MAIN_A: MOV DI,OFFSET FILE_BFR  ;If successful, erase input line
        MOV CX,32
        MOV AL,32
        REP STOSB
        CALL OPTION2            ;Update MS-DOS directory
        MOV DX,OFFSET ALL_SEARCH
        CALL DIR
        CALL OPTION2
        JMP MAIN
RECV9:  INC DI                  ;Loop for all characters in name
        CMP DI,11
        JB RECV6
        MOV FILE_FOUND,-1       ;File found!
        MOV SI,OFFSET DTA
        ADD SI,BX
        MOV DI,OFFSET FCB
        MOV CX,16
        REP MOVSB
        MOV FCB_OFFSET,BL       ;Store directory location so we can continue
        MOV AL,FDC_SECTOR       ;wildcard search after
        MOV FCB_SECTOR,AL
        MOV DI,OFFSET MSG13A    ;Clear field in MSG13A containing file name
        MOV CX,12
        MOV AL,1
        REP STOSB
        MOV SI,OFFSET FCB+8     ;Construct ASCIIZ name in DTA
        MOV DI,OFFSET DTA
        MOV CX,8
RECV9A: DEC SI
        CMP BYTE PTR [SI],' '
        LOOPZ RECV9A
        MOV SI,OFFSET FCB
        INC CX
        MOV BX,OFFSET CHRXLAT
RECV10: LODSB
        XLAT
        STOSB
        LOOP RECV10
        MOV SI,OFFSET FCB+8     ;Check for extension
        LODSB
        CMP word ptr [SI],2020H
        JNZ RECV11
        CMP AL,' '
        JZ RECV13
RECV11: MOV BYTE PTR [DI],'.'
        INC DI
        XLAT
        STOSB
        LODSW
        CMP AX,2020H
        JZ RECV13
        XLAT
        STOSB
        MOV AL,AH
        CMP AL,20H
        JZ RECV13
        XLAT
        STOSB
RECV13: MOV BYTE PTR [DI],0
        MOV SI,OFFSET DTA       ;Duplicate in "moving" message
        MOV DI,OFFSET MSG13A
RECV14: LODSB
        CMP AL,0
        JZ RECV15
        STOSB
        JMP RECV14
PC_CREATE_ERROR:
        MOV DI,OFFSET MSG14
        MOV BH,12
        MOV DH,6
        CALL CONFIRM
        JB RECV15               ;Retry if selected, ignore not an option
        JMP RECV25
RECV15: MOV SI,OFFSET MSG13     ;Announce file being moved
        CALL DISPLAY
        MOV AH,3CH              ;Open it as an output
        MOV CX,0
        MOV DX,OFFSET DTA
        INT 21H
        JB PC_CREATE_ERROR
        MOV FHANDLE,AX
        MOV FCB,1               ;Indicates sector loaded in current granule
RECV16: MOV DH,FCB[13]          ;Calculate position in file
        MOV DL,FCB
        CALL POSITION
        CALL READ               ;Read that sector
        MOV DI,OFFSET DTA+256   ;Determine length of actual data in sector
        MOV BL,FCB[13]
        MOV BH,0
        MOV AL,GAT[BX]
        CMP AL,192              ;Is this last granule?
        JB RECV17
        AND AL,63               ;Is this last sector in granule?
        CMP AL,FCB
        JA RECV17
        MOV AX,WORD PTR FCB[14] ;If so, use EOF offset as length
        XCHG AH,AL
        ADD AX,OFFSET DTA
        MOV DI,AX
        MOV FCB,-1              ;Set flag indicating end of file
        CMP FCB[12],0           ;If binary leave it at that
        JZ RECV17
        CMP BYTE PTR ADDEOF,0   ;Otherwise add EOF byte if option selected
        JZ RECV17
        MOV AL,26
        STOSB
RECV17: 
        MOV BX,OFFSET DTA
        CMP FCB[12],0           ;If not binary...
        JZ RECV20
        CMP BYTE PTR ADDLF,0    ;and add LFs requested, do so
        JZ RECV20
RECV18: CMP BX,DI               ;Terminate when sector end reached
        JNB RECV20
        CMP BYTE PTR [BX],13
        JNZ RECV19
        MOV SI,DI               ;If a CR found, shift remainder by one byte
        INC DI
        MOV CX,SI
        SUB CX,BX
        STD
        PUSH DI
        REP MOVSB
        POP DI
        CLD
        MOV BYTE PTR [BX+1],10  ;and add a LF after it
RECV19: INC BX
        JMP RECV18
RECV20: MOV CX,DI               ;Determine number of bytes to write
        MOV DX,OFFSET DTA
        SUB CX,DX
RECV21: MOV AH,40H              ;Write sector to file, with error retry loop
        MOV BX,FHANDLE
        INT 21H
        JNB RECV22
        MOV DI,OFFSET MSG15
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        JB RECV21
RECV22: CMP FCB,-1              ;If EOF reached, done
        JZ RECV24
        INC FCB                 ;Loop for remaining sectors in granule
        CMP FCB,10
        JB RECV23
        MOV FCB,1               ;Get next granule
        MOV BH,0
        MOV BL,FCB[13]
        MOV AL,GAT[BX]
        MOV FCB[13],AL
RECV23: JMP RECV16
RECV24: MOV BX,FHANDLE          ;File completed, close it
        MOV AH,3EH
        INT 21H
        JNB RECV25
        MOV DI,OFFSET MSG15     ;Error retry loop
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        JB RECV24
RECV25: MOV AL,FCB_SECTOR       ;Reload last directory sector and continue
        MOV FDC_SECTOR,AL       ;wildcard search
        MOV BYTE PTR FDC_TRACK,17
        MOV BH,0
        MOV BL,FCB_OFFSET
        CMP BL,0E0H             ;Don't bother reloading the sector if this
        JZ RECV26               ;was its last entry
        PUSH BX
        CALL READ
        POP BX
RECV26: JMP RECV7

;Move files to the CoCo disk    

SEARCH_TEMP DB 21 DUP(?)        ;Important bytes from DTA used in FindNext
NEW_GAT DB 160 DUP(?)           ;GAT for revisions before updating directory

SEND:   MOV DI,OFFSET FILE_BFR-1
SEND0:  INC DI                  ;Make sure file name is in ASCIIZ format
        CMP BYTE PTR [DI],0
        JZ SEND0A
        CMP BYTE PTR [DI],32
        JNZ SEND0
        MOV BYTE PTR [DI],0
SEND0A: MOV AH,4EH              ;Search MS-DOS directory for matching file
        MOV CX,0
        MOV DX,OFFSET FILE_BFR
        INT 21H
        JNB SEND1
        MOV AH,2                ;Beep if no file found
        MOV DL,7
        INT 21H
        MOV SI,OFFSET MSG16     ;Display error
        JMP TRY_AGAIN
SEND1:  MOV SI,OFFSET DTA       ;Store search information for next PC file
        MOV DI,OFFSET SEARCH_TEMP
        MOV CX,21
        REP MOVSB
        MOV AX,WORD PTR DTA[26] ;Put file length somewhere safe
        MOV DX,WORD PTR DTA[28]
        MOV WORD PTR DTA[258],DX
        OR DX,AX
        CMP DX,1                ;Files never occupy zero bytes in CoCo scheme
        ADC AX,0
        MOV WORD PTR DTA[256],AX
        MOV DI,OFFSET MSG21A    ;Place file name in moving announcement
        MOV CX,12
        MOV AL,1
        REP STOSB
        MOV SI,OFFSET DTA+30
        MOV DI,OFFSET MSG21A
        MOV CX,12
SEND1A: MOVSB
        CMP BYTE PTR [SI],0
        LOOPNZ SEND1A
        MOV SI,OFFSET MSG21
        CALL DISPLAY
        MOV DI,OFFSET FCB       ;Clean CoCo's FCB area
        MOV CX,11
        MOV AL,' '
        REP STOSB
        MOV CX,5
        MOV AL,0
        REP STOSB
        MOV AX,WORD PTR FTYPE   ;Set file type/format
        MOV WORD PTR FCB[11],AX
        MOV DI,OFFSET FCB       ;Construct file name in CoCo directory format
        MOV SI,OFFSET DTA+30
SEND2:  LODSB                   ;FILENAME
        CMP AL,0
        JZ SEND4
        STOSB
        CMP AL,'.'
        JNZ SEND2
        MOV BYTE PTR [DI-1],' '
        MOV DI,OFFSET FCB+8
SEND3:  LODSB                   ;EXT
        CMP AL,0
        JZ SEND4
        STOSB
        JMP SEND3
PC_OPEN_RETRY:
        MOV DI,OFFSET MSG20
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        JB SEND4
        JMP SEND26              ;Ignore=skip to next file
SEND4:  MOV AX,3D00H            ;Open file for reading
        MOV DX,OFFSET DTA+30
        INT 21H
        MOV FHANDLE,AX
        JB PC_OPEN_RETRY
        MOV PC_EOF,0
        MOV PC_POS,0
        CMP BYTE PTR HANDLE[1],-2;If real disk...
        JNZ SEND6
SEND5:  CALL SPINUP
        CALL DRIVE_STATUS       ;Check write protect status
        TEST AL,40H
        JZ SEND6
        MOV BYTE PTR SET_RIA,0
        MOV BYTE PTR SKIP_IGNORE,-1
        MOV DI,OFFSET MSG18
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        MOV BYTE PTR SKIP_IGNORE,0
        JMP SEND5
COCO_CREATE_RETRY:
        MOV DI,OFFSET MSG17
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        JB SEND6
        JMP SEND26              ;Ignore=skip to next file
SEND6:  MOV BYTE PTR FDC_TRACK,17
        MOV BYTE PTR FDC_SECTOR,2
        CALL READ               ;Read CoCo's GAT sector
        MOV SI,OFFSET DTA
        MOV DI,OFFSET NEW_GAT
        MOV CX,160
        REP MOVSB
SEND7:  INC BYTE PTR FDC_SECTOR ;Search CoCo directory to see if file exists
        CALL READ
        MOV BX,0
SEND8:  MOV DI,OFFSET FCB
        MOV SI,OFFSET DTA
        ADD SI,BX
        CMP BYTE PTR [SI],-1    ;If end of directory reached, file didn't
        JZ SEND12               ;already exist
        MOV CX,11
        REPZ CMPSB
        JZ SEND9                ;File exists, branch to KILL routine
        ADD BL,32
        JNZ SEND8
        CMP BYTE PTR FDC_SECTOR,18
        JB SEND7
        JMP SEND12              ;Not found, branch to CREATE routine
SEND9:  PUSH BX                 ;Save this directory pointer, we'll reuse it
        MOV BL,DTA[BX+13]       ;Get first granule (FCB offset 13)
        MOV CX,192              ;Length limit to prevent infinite loops
SEND10: MOV AL,-1               ;Free granule
        XCHG AL,NEW_GAT[BX]
        MOV BL,AL
        CMP AL,192
        JNB SEND11
        LOOP SEND10
SEND11: POP BX
        JMP SEND14              ;Branch to open routine
SEND12: MOV BYTE PTR FDC_SECTOR,3
SEND12A:
        CALL READ               ;If creating, look for empty entry.
        MOV BX,0
SEND13: MOV AL,DTA[BX]
        INC AL
        JZ SEND14
        DEC AL
        JZ SEND14
        ADD BL,32
        JNZ SEND13
        INC BYTE PTR FDC_SECTOR
        CMP BYTE PTR FDC_SECTOR,19
        JB SEND12A              ;If reached end of directory track, disk full
        JMP COCO_CREATE_RETRY
SEND14: MOV FCB_OFFSET,BL       ;Here, an empty entry has been found and 
        MOV AL,FDC_SECTOR       ;the file has been freed if needed in NEW_GAT
        MOV FCB_SECTOR,AL
        MOV DI,OFFSET NEW_GAT
        MOV CL,MAX_TRACK        ;Determine maximum number of granules allowed
        MOV CH,0
        DEC CX
        ADD CX,CX
        MOV BX,0
        MOV AL,-1
SEND15: REPNZ SCASB             ;Find empty granules
        JNZ SEND16
        ADD BX,9                ;9 sectors free per granule
        JCXZ SEND16
        JMP SEND15
SEND16: INC AL                  ;Put this in terms of bytes in DX:AX DWORD
        MOV AH,BL
        MOV DL,BH
        MOV DH,0
        CMP DX,WORD PTR DTA[258]
        JA SEND18               ;Make sure it's larger than the size of the
        JB SEND17               ;file being moved
        CMP AX,WORD PTR DTA[256]
        JNB SEND18
SEND17: JMP COCO_CREATE_RETRY
;PC_READ_ERROR_0:
;        MOV DI,OFFSET MSG20
;        MOV DH,7
;        MOV BH,10
;        CALL CONFIRM
;        JB SEND18
;        JMP SEND26
SEND18: MOV DI,OFFSET NEW_GAT   ;Size checks out.  Allocate a granule
        MOV AL,-1
        MOV CX,160
        REPNZ SCASB
        MOV AX,DI
        SUB AX,OFFSET NEW_GAT+1
        MOV FCB[13],AL          ;Store it as start granule in FCB
        MOV DTA[258],AL         ;Store also as current granule
        MOV BH,0
        MOV BL,AL
        MOV NEW_GAT[BX],0C1H    ;Allocate granule
        MOV DTA[257],1          ;Sector offset within granule
SEND19: 
;        MOV AH,3FH              ;Read a byte from the PC file
;        MOV BX,FHANDLE
;        MOV CX,1
        MOV DX,WORD PTR FCB[14]
        XCHG DH,DL
        ADD DX,OFFSET DTA
        MOV DI,DX
;        INT 21H
        CALL GET_BYTE
;        JB PC_READ_ERROR_0
        CMP AX,0
        JNZ SEND20
        JMP SEND24
SEND20: CMP BYTE PTR FFORMAT,0  ;No filtering for binary files
        JZ SEND22
        CMP BYTE PTR ADDLF,0    ;LF filter
        JZ SEND21
        CMP BYTE PTR [DI],10
        JZ SEND19
SEND21: CMP BYTE PTR ADDEOF,0   ;EOF filter
        JZ SEND22
        CMP BYTE PTR [DI],26    ;Automatically closes file
        JZ SEND24
SEND22: CMP FCB[14],0           ;If a new sector should now be started, find
        JNZ SEND23              ;it
        INC FCB[15]             ;Otherwise go to next byte
        JNZ SEND19
        MOV DX,WORD PTR DTA[257];If that was the last byte in the sector...
        CALL POSITION
        CALL WRITE              ;write it
        INC FCB[14]
        JMP SEND19
SEND23: MOV FCB[14],0           ;Next sector started, allocate it
        MOV AL,DTA[256]         ;Move current byte to beginning of new sector
        MOV DTA,AL              ;buffer 
        INC FCB[15]             ;Go to next byte
        INC BYTE PTR DTA[257]
        CMP BYTE PTR DTA[257],10
        JB SEND19
        MOV DI,OFFSET NEW_GAT   ;End of granule, find next free one
        MOV CX,160
        MOV AL,-1
        REPNZ SCASB
        MOV AX,DI
        SUB AX,OFFSET NEW_GAT+1
        MOV BL,DTA[258]
        MOV BH,0
        MOV NEW_GAT[BX],AL      ;Write next granule to current granule pointer
        MOV DTA[258],AL         ;Update "current granule" byte
        MOV BL,AL
        MOV NEW_GAT[BX],0C1H    ;Allocate next granule
        MOV BYTE PTR DTA[257],1 ;Reset current sector in granule
        JMP SEND19
SEND24: CMP FCB[14],0           ;Close file
        JNZ SEND25
        MOV DX,WORD PTR DTA[257]
        CALL POSITION           ;If a sector was only partially constructed,
        CALL WRITE              ;write it now
SEND25: MOV BYTE PTR FDC_TRACK,17
        MOV AL,FCB_SECTOR       ;Update directory entry's sector
        MOV FDC_SECTOR,AL
        CALL READ
        MOV BH,0
        MOV BL,FCB_OFFSET
        MOV DI,BX
        ADD DI,OFFSET DTA
        MOV SI,OFFSET FCB
        MOV CX,16
        REP MOVSB
        CALL WRITE
        MOV AX,WORD PTR DTA[257];Put in terminating GAT entry
        MOV BH,0
        MOV BL,AH
        OR AL,192
        MOV NEW_GAT[BX],AL
        MOV FDC_SECTOR,2        ;Update GAT sector
        CALL READ
        MOV SI,OFFSET NEW_GAT
        MOV DI,OFFSET DTA
        MOV CX,160
        REP MOVSB
        CALL WRITE
SEND26: MOV AH,3EH              ;File completed, close and go to next entry
        MOV BX,FHANDLE
        INT 21H
        MOV SI,OFFSET SEARCH_TEMP
        MOV DI,OFFSET DTA
        MOV CX,21
        REP MOVSB
        MOV AH,4FH
        INT 21H
        JB SEND27
        JMP SEND1
SEND27: MOV DI,OFFSET FILE_BFR  ;All done, erase input line
        MOV CX,32
        MOV AL,32
        REP STOSB
        CALL OPTION2            ;Update CoCo directory
        CALL CDIR
        CALL CFREE
        CALL OPTION2
        JMP MAIN

;Reads 254 bytes of PC file into buffer to feed one at a time

PC_EOF  DW 0                    ;Number of bytes in record
PC_POS  DW 0                    ;Current pointer position in file

GET_BYTE:
        PUSH DX
        MOV BX,PC_POS
        CMP BX,PC_EOF
        JB GET_BYTE_2
PC_READ_RETRY:
        MOV PC_POS,0
        MOV AH,3FH
        MOV BX,FHANDLE
        MOV CX,254
        MOV DX,OFFSET DTA+259
        INT 21H
        JNB GET_BYTE_1
        MOV DI,OFFSET MSG20
        MOV DH,7
        MOV BH,10
        CALL CONFIRM
        JB PC_READ_RETRY
GET_BYTE_1:
        MOV PC_EOF,AX
        MOV BX,0
        CMP AX,BX
        JNZ GET_BYTE_2
        POP DX
        RET
GET_BYTE_2:
        MOV AL,DTA[BX+259]
        INC PC_POS
        POP DX
        MOV BX,DX
        MOV [BX],AL
        MOV AX,1
        RET

;Translate granule/offset into track/sector

POSITION:
        SHR DH,1                ;Odd granules start 9 sectors in
        JNB POSITION_1
        ADD DL,9
POSITION_1:
        CMP DH,17               ;Skip track 17
        CMC
        ADC DH,0
        MOV BYTE PTR FDC_TRACK,DH
        MOV BYTE PTR FDC_SECTOR,DL
        RET

;Specify new CoCo disk name

SET_YN  DB 0                    ;Create default 0=Yes, 1=No

VNAME:  MOV DX,OFFSET DSK_SEARCH
        CALL DIR                ;Show directory of all .DSK files
        MOV DI,OFFSET FILE_BFR  ;Clear old name
        MOV CX,32
        MOV AL,CL
        REP STOSB
        MOV DX,32CH             ;Coordinate of CoCo disk name field
        MOV INPUT_LENGTH,8      ;Maximum 8 characters allowed for this field
        MOV BYTE PTR TERMINATOR,'.'
        CALL GET_FILE
        MOV BYTE PTR TERMINATOR,0
        JB VNAME1
        MOV BX,5344H            ;The extension, "DSK"
        MOV CH,4BH
        MOV DI,OFFSET COCO_DISK
        SUB CURSOR,44
        CALL NEW_FILE
        MOV AL,[DI]             ;Blank names are not allowed
        AND AL,0DFH
        JZ VNAME
        MOV AX,[DI+1]           ;Ignore ones which are drive designations
        AND AH,0DFH
        CMP AX,3AH
        JZ VNAME1A
        MOV DX,DI               ;Check to see if file exists
        MOV AX,3D02H
        INT 21H
        JB VNAME2
        PUSH AX
        MOV AH,3EH              ;Close old file
        MOV BX,HANDLE
        INT 21H
        POP AX
        MOV HANDLE,AX           ;Save handle of the new file
VNAME1: JMP SHOW_DIRECTORIES
VNAME1A:                        ;Set handle correctly for real disk access
        MOV AH,3EH              ;But first, close old file
        MOV BX,HANDLE
        INT 21H
        MOV AL,COCO_DISK
        DEC AL
        AND AL,3
        MOV AH,-2
        MOV HANDLE,AX
        JMP SHOW_DIRECTORIES
VNAME2: PUSH DI                 ;File does not exist:  User must confirm
        MOV SI,DI               ;file create
        MOV CX,12
        MOV DI,OFFSET MSG26A    ;Include diskname in message
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        REP MOVSB
        POP ES
        CALL SAVE_SCREEN
        MOV DX,81BH
        MOV BX,8A1AH
        MOV DI,OFFSET MSG26
        CALL MENU
VNAME2A:
        MOV DX,0F1FH
        MOV AL,14
        MUL SET_YN
        ADD DL,AL
        MOV AH,2                ;Place cursor on default
        INT 10H
        MOV DX,120
        MOV CX,248
        MOV AL,112
        MUL SET_YN
        ADD CX,AX
        MOV AX,4                ;Set mouse cursor position as well
        INT 33H
VNAME3: MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
VNAME3A:                        ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ VNAME5
        CMP MOUSE_HERE,0
        JZ VNAME3A
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ VNAME3A
        SHR CX,1
        SHR CX,1
        SHR CX,1
        SHR DX,1
        SHR DX,1
        SHR DX,1
        MOV DH,DL               ;Put mouse coordinates in INT 10H form
        MOV DL,CL
VNAME4: PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ VNAME4
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        CMP DH,16               ;Dead space of mouse
        JA VNAME3
        CMP DH,14
        JB VNAME3
        CMP DL,29               ;"Yes" zone
        JB VNAME3
        CMP DL,37
        JB VNAME6
        CMP DL,43               ;"No" zone
        JB VNAME3
        CMP DL,51
        JNB VNAME3
        JMP VNAME8
VNAME4A:                        ;TAB key handler
        XOR SET_YN,1
        JMP VNAME2A
VNAME4B:                        ;ENTER key handler
        CMP SET_YN,0
        JZ VNAME6
        JMP VNAME8
VNAME5: MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        CMP AL,9
        JZ VNAME4A
        CMP AL,13
        JZ VNAME4B
        AND AL,223
        CMP AL,'Y'
        JZ VNAME6
        CMP AL,'N'
        JZ VNAME8
        JMP VNAME3
VNAME6: POP DX                  ;"Yes" handler.  Create file.
        PUSH DX
        MOV AH,3CH
        MOV CX,0
        INT 21H
        JB VNAME7
        MOV BX,AX               ;Create directory structure
        MOV CX,1                ;Skip to "track 17, sector 2"
        MOV DX,3300H
        MOV AX,4200H
        INT 21H
        MOV DI,OFFSET DTA
        MOV AL,-1
        MOV CX,256
        REP STOSB
        MOV CX,17
VNAME6A:
        PUSH CX
        MOV AH,40H
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        POP CX
        JB VNAME7
        LOOP VNAME6A
        PUSH BX
        MOV AH,3EH              ;Close old file
        MOV BX,HANDLE
        INT 21H
        POP BX
        MOV HANDLE,BX
        JMP VNAME9
VNAME7: MOV AH,3EH              ;Error abort.  Ensure file closed
        INT 21H
        MOV AH,2                ;Beep
        MOV DL,7
        INT 21H
VNAME8: POP DI                  ;"No" handler
        PUSH ES                 ;Clear diskname field
        MOV AX,DS
        MOV ES,AX
        MOV AL,32
        MOV CX,32
        REP STOSB
        POP ES
        PUSH DI
VNAME9: POP DI                  ;General return from warning window
        JMP NEW_SCREEN

NEW_FILE:              ;Copy file name from buffer to DI
        MOV SI,OFFSET FILE_BFR
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        PUSH CX
        MOV CX,32
        REP MOVSB
        POP CX
        POP ES
        SUB DI,32
        MOV CL,0
        MOV AL,FILE_BFR         ;Don't add extensions to null file names
        AND AL,0DFH
        JZ NEW_FILE0
        MOV AX,WORD PTR FILE_BFR[1]
        AND AH,0DFH             ;or ones which are drive designations
        CMP AX,3AH
        MOV AH,-1
        JNZ NEW_FILE1
NEW_FILE0:
        RET
NEW_FILE1:                      ;Check to see if extension already there
        CMP BYTE PTR [DI],'\'
        JNZ NEW_FILE2
        MOV AH,-1
NEW_FILE2:
        CMP BYTE PTR [DI],'.'
        JNZ NEW_FILE3
        MOV AH,CL
NEW_FILE3:
        INC DI
        INC CL
        CMP CL,31
        JB NEW_FILE1
        SUB DI,31
        INC AH
        JZ NEW_FILE4
        DEC AH
        MOV CURSOR,AH
NEW_FILE4:
        PUSH DI
        ADD DI,31
        MOV AL,CURSOR
        CMP AL,27
        JA NEW_FILE5
        POP DI
        PUSH DI
        MOV AH,0                ;Add extension if there is room
        ADD DI,AX
        MOV BYTE PTR [DI],'.'
        MOV [DI+1],BX
        MOV [DI+3],CH
        ADD DI,4
NEW_FILE5:                      ;Add terminator byte
        MOV BYTE PTR [DI],0
        POP DI
        RET

DIR_CMD:               ;Directory window keyboard handler
        CMP AX,4900H
        JNZ DIR_CMD1
        JMP DIR_UP
DIR_CMD1:
        CMP AX,5100H
        JNZ DIR_CMD2
        JMP DIR_DOWN
DIR_CMD2:
        CMP AX,5000H
        JNZ DIR_CMD4
        CMP DIR_PTR,-1
        JZ DIR_CMD2A
        CALL HILITE
        MOV AL,21
        MUL DIR_PTR
        MOV SI,AX
        MOV AX,378
        MUL DIR_PAGE
        ADD SI,AX
        MOV BX,CUR_DIR
        CMP BYTE PTR [BX+SI+21],' '
        JZ DIR_CMD3
        INC DIR_PTR
        MOV AL,DIR_PTR
        CMP AL,18
        JB DIR_CMD3
        CALL DIR_DOWN
DIR_CMD2A:        
        MOV DIR_PTR,0
DIR_CMD3:
        CALL HILITE
        PUSH DX
        CALL SETTINGS
        POP DX
        RET
DIR_CMD4:
        CMP AX,4800H
        JNZ DIR_CMD5
        CMP DIR_PTR,-1
        JZ DIR_CMD2A
        CALL HILITE
        SUB DIR_PTR,1
        JNS DIR_CMD3
        INC DIR_PTR
        CMP DIR_PAGE,0
        JZ DIR_CMD3
        CALL DIR_UP
        MOV DIR_PTR,17
        CALL HILITE
        PUSH DX
        CALL SETTINGS
        POP DX
        RET
DIR_CMD5:
        RET

DIR_WDW:               ;Directory window mouse handler
        CMP BYTE PTR INPUT_LENGTH,8
        JZ DIR_WDW0             ;Following only occurs if not in VNAME
        CMP DL,57               ;Which directory is mouse on?
        MOV AL,34
        JB WINDOW_SELECT
        MOV AL,58
WINDOW_SELECT:                  ;If same one as currently selected, proceed
        CMP AL,DIR_COLUMN       ;normally
        JZ DIR_WDW0
        CALL OPTION2            ;Otherwise exchange selected directories
DIR_WDW0:
        CMP DH,3                ;Dead space of directory window
        JB DIR_WDW1
        CMP DH,4
        JZ DIR_WDW1
        CMP DH,23
        JNB DIR_WDW1
        CMP DH,3                ;File name zone
        JNZ DIR_WDW4
        SUB DL,DIR_COLUMN
        JB  DIR_WDW1
        CMP DL,3                ;Up arrow
        JB DIR_WDW2
        CMP DL,21
        JNB DIR_WDW1
        CMP DL,18               ;Down arrow
        JNB DIR_WDW3
DIR_WDW1:
        RET
DIR_WDW2:
        CALL HILITE             ;Dehighlight last selected file
        MOV DIR_PTR,-1          ;Clear directory file pointer
        CALL DIR_UP
        RET
DIR_WDW3:
        CALL HILITE             ;Dehighlight last selected file
        MOV DIR_PTR,-1          ;Clear directory file pointer
        CALL DIR_DOWN
        RET
DIR_WDW4:
        SUB DL,DIR_COLUMN       ;Make sure we're on the selected window
        JB DIR_WDW1
        CMP DL,21
        JNB DIR_WDW1
        CALL HILITE             ;Dehighlight last selected file
        MOV DIR_PTR,-1          ;Clear directory file pointer
        SUB DH,5
        MOV DIR_PTR,DH
        CALL HILITE
        PUSH DS
        MOV DS,VIDEO_SEGMENT
        MOV AL,[DI-43]
        POP DS
        AND AL,0DFH
        JZ DIR_WDW5
        PUSH DX
        CALL SETTINGS
        POP DX
        CALL CHANGE_DIR
        RET
DIR_WDW5:                       ;Branches here if clicked on a blank line
        CALL HILITE             ;Remove highlight
        MOV DIR_PTR,-1
        PUSH DX
        CALL SETTINGS
        POP DX
        RET

DIR_PTR DB -1                   ;Line of file pointer within dir window

CHANGE_DIR:            ;Change to directory highlighted        
        MOV DH,DIR_PTR
        INC DH
        JNZ CHANGE_DIR0
        RET
CHANGE_DIR0:
        DEC DH
        MOV AL,21
        MUL DH
        MOV SI,AX
        MOV AX,378
        MUL DIR_PAGE
        ADD SI,AX
        ADD SI,CUR_DIR
        MOV DX,SI
        INC DX
        CMP BYTE PTR SS:[SI],'['
        JZ CHANGE_DIR1
        RET
CHANGE_DIR1:
        CMP BYTE PTR SS:[SI+2],':'
        JZ CHANGE_DIR2
        INC SI
        CMP BYTE PTR SS:[SI],']'
        JNZ CHANGE_DIR1
        MOV NEW_DIR,-1
        MOV DIR_PTR,-1
        PUSH DS
        MOV AX,SS
        MOV DS,AX
        MOV BYTE PTR [SI],0
        MOV AH,3BH
        INT 21H
        MOV BYTE PTR [SI],']'
        POP DS
        MOV DIR_PAGE,0
        MOV DX,LAST_DIR
        CALL DIR
        RET
CHANGE_DIR2:
        MOV NEW_DIR,-1
        MOV DIR_PTR,-1
        MOV DL,SS:[SI+1]
        SUB DL,'A'
        CMP DL,2
        JNB HARD_DRIVE
        MOV AX,201H             ;Verify that sector is readable by MS-DOS
        MOV DH,0                ;before allowing this disk to become the
        MOV CX,1                ;default directory
        MOV BX,OFFSET DTA
        INT 13H
        JB NOT_MSDOS
HARD_DRIVE:
        MOV AH,0EH
        INT 21H
NOT_MSDOS:
        MOV DIR_PAGE,0
        MOV DX,LAST_DIR
        CALL DIR
        RET

RESTORE_DIR:           ;Restore path to that at SI
        PUSH DX
        MOV AH,0EH
        MOV DL,[SI]
        INT 21H
        MOV DX,SI
        INC DX
        MOV AH,3BH
        INT 21H
        POP DX
        RET

SAVE_PATH:             ;Save path to SI
        PUSH DX
        MOV AH,19H              ;Save default drive
        INT 21H
        MOV [SI],AL
        MOV AH,0EH              ;Save total number of drives
        MOV DL,AL
        INT 21H
        MOV TOTAL_DRIVES,AL
        MOV BYTE PTR [SI+1],'\' ;Leading "\" for path
        ADD SI,2
        PUSH DI         
        INC DL
        MOV AH,47H              ;Retrieve path
        INT 21H
        POP DI
        SUB SI,2
        POP DX
        RET

NEW_DIR DB 0                    ;Non-zero if dir changed since last reset
LAST_DIR DW 0                   ;Offset to last directory search's mask

HILITE:                ;Toggle highlight from file DIR_PTR
        INC DIR_PTR
        JNZ HILITE1
        DEC DIR_PTR
        RET
HILITE1:
        MOV NEW_HILITE,-1
        DEC DIR_PTR
        PUSH AX
        PUSH CX
        PUSH DX
        PUSH DS
        MOV DH,DIR_PTR
        ADD DH,5
        MOV AL,160
        MUL DH
        MOV DL,DIR_COLUMN
        MOV DH,0
        ADD AX,DX
        ADD AX,DX
        MOV DI,AX
        INC DI
        MOV DS,VIDEO_SEGMENT
        MOV CX,21
HILITE2:
        XOR BYTE PTR [DI],58H
        ADD DI,2
        LOOP HILITE2
        CMP DL,34
        JNZ HILITE3
        MOV AX,[DI-17]          ;If in the CoCo directory
        TEST AH,40H             ;and a name is highlighted
        JZ HILITE3
        AND AX,3                ;Update file type/format fields
        CMP BYTE PTR [DI-15],'B'
        SBB AH,0
        MOV WORD PTR CS:FTYPE,AX
HILITE3:
        POP DS
        POP DX
        POP CX
        POP AX
        RET

NEW_HILITE DB 0                 ;Indicates hilight changed since last reset

DIR_UP:               ;Scroll directory page back one
        CMP DIR_PAGE,0
        JZ DIR_UP1
        DEC DIR_PAGE
        CALL SHOWDIR
DIR_UP1:
        PUSH DX
        CALL SETTINGS
        POP DX
        RET

DIR_DOWN:              ;Scroll directory page down one
        MOV AX,378
        MUL DIR_PAGE
        ADD AX,CUR_DIR
        ADD AX,378
        MOV SI,AX
        CMP BYTE PTR [SI],0
        JZ DIR_DOWN1
        CMP BYTE PTR [SI],32
        JZ DIR_DOWN1
        MOV AX,DIR_PAGE
        CMP AL,22
        JNB DIR_DOWN1
        INC DIR_PAGE
        CALL SHOWDIR
DIR_DOWN1:
        PUSH DX
        CALL SETTINGS
        POP DX
        RET

;File name input routine.  Display FILE_BFR 31-byte field (plus terminator)
;at cursor location DX.  Returns upon ENTER/LEFT button second click (NC)
;or ESC/RIGHT button first click (C)

CURSOR  DB 0                    ;Current column position of cursor

GET_FILE:
        CALL HILITE
        MOV DIR_PTR,-1
GETF1:  PUSH DX
        MOV SI,OFFSET FILE_BFR
        MOV CURSOR,DL
GETF2:  MOV AL,[SI]             ;Display name
        MOV BX,10EH
        MOV CX,1
        CALL PC_CHAR
        INC SI
        INC DL
        MOV AL,[SI-1]
        CMP AL,' '
        JZ GETF3
        CMP AL,0
        JZ GETF3
        MOV CURSOR,DL
GETF3:  MOV BX,INPUT_LENGTH
        ADD BX,OFFSET FILE_BFR
        CMP SI,BX
        JB GETF2
        POP DX
GETF3A: MOV AX,1                ;Mouse pointer on
        INT 33H
        PUSH DX
        MOV AH,2                ;Set cursor position
        MOV BH,0
        MOV DL,CURSOR
        INT 10H
        POP DX
GETF4:  MOV AH,1                ;Scan keyboard
        INT 16H
        JZ GETF8A
        MOV AX,2
        INT 33H
        JMP GETF8
GETF8A: TEST BYTE PTR MOUSE_HERE,-1
        JZ GETF4
        PUSH DX
        MOV AX,3
        INT 33H
        SHR CX,1
        SHR CX,1
        SHR CX,1
        SHR DX,1
        SHR DX,1
        SHR DX,1
        MOV CH,DL
        POP DX
        TEST BL,3
        JZ GETF4
        TEST BL,2
        JZ GETF5
GETF4A: MOV AX,3                ;Wait for right button to be released
        INT 33H
        TEST BL,2
        JNZ GETF4A
        MOV AX,2                ;Right button aborts.  Turn off mouse pointer
        INT 33H         
        STC                     ;and set abort flag
        RET
GETF5:  MOV AX,3                ;Wait for button to be released
        PUSH CX
        PUSH DX
        INT 33H
        POP DX
        POP CX
        TEST BL,1
        JNZ GETF5
        MOV AX,2
        INT 33H
        CMP CL,31               ;Branch if not on directory windows
        JB GETF7
        CMP CL,56               ;Dead space between two windows
        JZ GETF3A
        PUSH WORD PTR TO_COCO
        PUSH DIR_PAGE
        PUSH WORD PTR DIR_PTR
        PUSH DX
        MOV NEW_DIR,0
        MOV NEW_HILITE,0
        MOV DX,CX
        CALL DIR_WDW            ;If mouse if directory window, handle it
        POP DX
        POP AX
        POP BX
        POP CX
        CMP NEW_HILITE,0
        JZ GETF5D
        CMP NEW_DIR,-1          ;If directory changed, set name appropriately
        JZ GETF5B
        CMP AL,DIR_PTR          ;If same highlight clicked a second time,
        JNZ GETF5B
        CMP AL,-1
        JZ GETF5B
        CMP BX,DIR_PAGE
        JNZ GETF5B
        CMP CL,TO_COCO
        JNZ GETF5B
GETF5C: CLC                     ;flag as "accept".
        RET
GETF5D: JMP GETF3A
GETF5B: PUSH DX
        CALL SET_NAME           ;If highlight changed, load new hilighted
        POP DX
        JMP GETF1               ;file into buffer.
GETF6A: STC
        RET
GETF7:  MOV BL,CH               ;Execute mouse function on left-hand side
        MOV BH,0                ;of screen
        ADD BX,BX
        CMP CH,23
        JNB GETF7A
        CALL MOUSE[BX]
        PUSH DX
        CALL SETTINGS
        POP DX
GETF7A: JMP GETF3A
GETF8:  KEYSTROKE               ;Keyboard read routine
        CALL FUNCTIONS
        JB GETF8B
        CMP AL,13
        JNZ GETF9
        MOV NEW_DIR,0           ;ENTER: If directory highlighted, change it
        PUSH DX
        CALL CHANGE_DIR
        POP DX
        CMP NEW_DIR,0
        JNZ GETF8C
        JMP GETF5C              ;else return file name with NC
GETF8C: PUSH DX
        CALL SET_NAME
        POP DX
        JMP GETF1
GETF8B: JMP GETF3A
GETF9:  CMP AL,27               ;ESC: If buffer not empty, clear it
        JNZ GETF9A
        CMP FILE_BFR,32         ;else return with C set
        JZ GETF6A
        CMP FILE_BFR,0
        JZ GETF6A
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV DI,OFFSET FILE_BFR
        MOV AL,32
        MOV CX,32
        REP STOSB
        POP ES
        MOV CURSOR,DL
        JMP GETF1
GETF9A: CMP AL,8                ;Backspace
        JNZ GETF10
        CMP CURSOR,DL
        JNA GETF8B
        DEC CURSOR
        MOV AL,CURSOR
        MOV AH,0
        SUB AL,DL
        MOV SI,AX
        MOV FILE_BFR[SI],32
        PUSH DX
        MOV AH,2                ;Set new cursor position
        MOV BH,0
        MOV DL,CURSOR
        INT 10H
        MOV AL,' '              ;Clear character under cursor
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        POP DX
        JMP GETF8B
GETF10: CMP AL,32               ;ASCII character input (spaces suppressed)
        JNA GETF11
        MOV AH,CURSOR
        SUB AH,DL
        CMP AH,BYTE PTR INPUT_LENGTH
        JNB GETF8B
        PUSH AX
        MOV AL,CURSOR
        MOV AH,0
        SUB AL,DL
        MOV SI,AX
        POP AX
        MOV FILE_BFR[SI],AL
        PUSH DX
        MOV DL,CURSOR           ;Display byte
        MOV BX,10EH
        MOV CX,1
        MOV AL,FILE_BFR[SI]
        CALL PC_CHAR
        INC DL
        MOV AH,2                ;Move cursor
        MOV BH,0
        INT 10H
        POP DX
        INC CURSOR
        JMP GETF8B
GETF11: MOV NEW_HILITE,0        ;Check for directory commands
        PUSH DX
        CALL DIR_CMD
        POP DX
        CMP NEW_HILITE,0        ;If highlight changed, retrieve that file name
        JNZ GETF12
        JMP GETF8B
GETF12: PUSH DX
        CALL SET_NAME
        POP DX
        JMP GETF1

CUR_DIR DW PC_DIR               ;Tells which directory we're using
TERMINATOR DB 0                 ;Character to stop on for SET_NAME
                                ;"." if selecting CoCo disk, 0 otherwise

SET_NAME:              ;Set FILE_BFR to current hilighted path
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH ES
        MOV AX,DS               ;Clear current buffer
        MOV ES,AX
        MOV AL,CL
        REP STOSB
        POP ES
        CMP DIR_PTR,-1
        JNZ SET_NAME6
        RET
SET_NAME6:
        MOV AL,21
        MUL DIR_PTR
        MOV DI,AX
        MOV AX,378
        MUL DIR_PAGE
        ADD DI,AX
        ADD DI,CUR_DIR
        CMP BYTE PTR [DI],'['
        MOV BX,0
        JZ SET_NAME8
        MOV SI,OFFSET FILE_BFR
SET_NAME7:
        MOV AL,[DI+BX]
        CMP AL,TERMINATOR
        JZ SET_NAME8
        MOV [SI],AL
        INC SI
        INC BX
        MOV AX,INPUT_LENGTH
        ADD AX,OFFSET FILE_BFR
        CMP SI,AX
        JNB SET_NAME8
        CMP BX,21
        JB SET_NAME7
SET_NAME8:
        RET

;Displays error window and gives three options: Abort, Retry, or Ignore
;Abort branches to file prompt, retry returns a carry set, ignore returns
;a carry clear

SKIP_IGNORE DB 0                ;If non-zero, ignore not allowed
SET_RIA DB 0                    ;Default mouse position, 0=retry, 1=ignore,
                                ;2=abort

CONFIRM:               ;Display confirmation window in DI
        PUSH DI
        CALL SAVE_SCREEN
        POP DI
        MOV BL,28
        MOV DL,26
        OR BH,128
        PUSH BX
        PUSH DX
        CALL MENU
        POP DX
        POP BX
        AND BH,127
        ADD DH,BH               ;Calculate line containing abort/retry/ignore
        SUB DH,3
CONFIRM0:
        MOV AL,8                ;Position mouse pointer according to SET_RIA
        MUL SET_RIA
        ADD AL,29
        MOV DL,AL
        MOV CL,8
        MUL CL
        MOV CX,AX
        PUSH DX
        MOV AL,8
        MUL DH
        MOV DX,AX
        MOV AX,4
        INT 33H
        POP DX
        MOV AH,2                ;Position cursor there too
        MOV BH,0
        INT 10H
CONFIRM1: 
        MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
CONFIRM2:                       ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ CONFIRM4
        CMP MOUSE_HERE,0
        JZ CONFIRM2
        PUSH DX
        MOV AX,3
        INT 33H
        MOV AX,DX
        POP DX
        TEST BL,1
        JZ CONFIRM2
        SHR CX,1
        SHR CX,1
        SHR CX,1
        SHR AX,1
        SHR AX,1
        SHR AX,1
        MOV CH,AL
CONFIRM3:
        PUSH CX
        PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        POP CX
        TEST BL,1
        JNZ CONFIRM3
CONFIRM3A:        
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        INC CH
        CMP CH,DH               ;Dead space of mouse
        JB CONFIRM1
        SUB CH,2
        CMP CH,DH
        JA CONFIRM1
        CMP CL,28
        JB CONFIRM1
        CMP CL,36               ;"Retry" zone
        JB CONFIRMR
        CMP CL,44               ;"Ignore" zone
        JB CONFIRMI
        CMP CL,52               ;"Abort" zone
        JB CONFIRMA
        JMP CONFIRM1
CONFIRM4:
        MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        CMP AL,9
        JZ CONFIRMT             ;Tab key
        CMP AL,13
        JZ CONFIRMD             ;Default
        AND AL,223
        CMP AL,'R'
        JZ CONFIRMR
        CMP AL,'I'
        JZ CONFIRMI
        CMP AL,'A'
        JZ CONFIRMA
CONFIRM1A:
        JMP CONFIRM1
CONFIRMR:
        CALL RESTORE_SCREEN
        STC
        RET
CONFIRMI:
        CMP SKIP_IGNORE,0
        JNZ CONFIRM1A
        CALL RESTORE_SCREEN
        CLC
        RET
CONFIRMA:
        CALL RESTORE_SCREEN
        MOV SP,ENTRY_STACK
        CALL HILITE
        MOV DIR_PTR,-1
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        MOV AL,CL
        REP STOSB
        MOV AH,3EH
        MOV BX,FHANDLE
        INT 21H
        CALL SETTINGS
        JMP MAIN
CONFIRMT:                       ;Tab cycles through options
        INC SET_RIA
        CMP SET_RIA,3
        JB CONFIRMT1
        MOV SET_RIA,0
CONFIRMT1:
        CMP SKIP_IGNORE,0
        JNZ CONFIRMT2
        JMP CONFIRM0
CONFIRMT2:                      ;Skip ignore option if flag says so
        CMP SET_RIA,1
        JNZ CONFIRMT3
        MOV SET_RIA,2
CONFIRMT3:
        JMP CONFIRM0
CONFIRMD:                       ;This only works if the mouse is on
        CMP SET_RIA,0
        JZ CONFIRMR
        CMP SET_RIA,1
        JZ CONFIRMI
        JMP CONFIRMA

;Save screen in the "frame" storage area

SAVE_SCREEN:
        MOV SI,0
        MOV DI,OFFSET FRAME
        PUSH DS
        MOV DS,VIDEO_SEGMENT
        MOV CX,2000
        REP MOVSW
        POP DS
        RET

;Restore screen from frame save

RESTORE_SCREEN:
        MOV SI,OFFSET FRAME
        MOV DI,0
        PUSH ES
        MOV ES,VIDEO_SEGMENT
        MOV CX,2000
        REP MOVSW
        POP ES
        RET

;Messages, etc.

MSG1    DB 'Select the drive or virtual disk for the CoCo files, or press '
        DB 'ESC to exit.',0
MSG2    DB 'Select a new CoCo drive or virtual disk, or press '
        DB 'ESC to cancel change.',0

MSG3A   DB 'MS-DOS to CoCoPC  '
MSG3B   DB 'CoCo to MS-DOSCoCo'
MSG4A   DB 'Side 0'
MSG4B   DB 'Side 1'
MSG5A   DB '35'
MSG5B   DB '40'
MSG5C   DB '80'
MSG6A   DB 'Yes'
MSG6B   DB '.No'
MSG7A   DB '.BASIC (0)'
MSG7B   DB '..Data (1)'
MSG7C   DB '..EXEC (2)'
MSG7D   DB 'Editor (3)'
MSG8A   DB 'Binary'
MSG8B   DB '.ASCII'

MSG9    DB 'Select file(s) to move, press function keys to change options, '
        DB 'or ESC to exit.',0
MSG10   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º ERROR READING COCO DISK! º'
        DB 'º                          º'
        DB 'º Read error on track '
MSG10A  DB '00,  º'
        DB 'º sector '
MSG10B  DB '00.               º'
        DB 'º                          º'
        DB 'º ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³Retry ³³Ignore³³Abort ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG11   DB 'Reading CoCo disk',27H,'s directory...',0
MSG12   DB 'No CoCo files matching that name.  Enter a new file name or '
        DB 'ESC to exit.',0
MSG13   DB 'Moving '
MSG13A  DB 'FILENAME.EXT from CoCo disk to MS-DOS... ',0
MSG14   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º ERROR CREATING PC FILE!  º'
        DB 'º                          º'
        DB 'º Disk may be full or      º'
        DB 'º write protected, or file º'
        DB 'º name may not be valid in º'
        DB 'º MS-DOS.                  º'
        DB 'º                          º'
        DB 'º ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³Retry ³³Ignore³³Abort ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG15   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º WRITE ERROR IN PC FILE!  º'
        DB 'º                          º'
        DB 'º Disk may be full or      º'
        DB 'º write protected.         º'
        DB 'º                          º'
        DB 'º ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³Retry ³³Ignore³³Abort ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG16   DB 'No MS-DOS files matching that name.  Enter a new file name or '
        DB 'ESC to exit.',0
MSG17   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º COCO DISK FULL!          º'
        DB 'º                          º'
        DB 'º There is not enough room º'
        DB 'º for the current file.    º'
        DB 'º                          º'
        DB 'º ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³Retry ³³Ignore³³Abort ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG18   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º DISK WRITE PROTECTED!    º'
        DB 'º                          º'
        DB 'º The CoCo disk is write   º'
        DB 'º protected.  Check drive. º'
        DB 'º                          º'
        DB 'º ÚÄÄÄÄÄÄ¿        ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³Retry ³        ³Abort ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ        ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG19   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º ERROR WRITING COCO DISK! º'
        DB 'º                          º'
        DB 'º Write error on track '
MSG19A  DB '00, º'
        DB 'º sector '
MSG19B  DB '00.               º'
        DB 'º                          º'
        DB 'º ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³Retry ³³Ignore³³Abort ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG20   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º ERROR READING PC FILE!   º'
        DB 'º                          º'
        DB 'º Unable to read PC file.  º'
        DB 'º Check for data errors.   º'
        DB 'º                          º'
        DB 'º ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³Retry ³³Ignore³³Abort ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG21   DB 'Moving '
MSG21A  DB 'FILENAME.EXT from MS-DOS to CoCo disk... ',0
MSG26   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º WARNING!  Virtual disk º'
        DB 'º '
MSG26A  DB '                       º'
        DB 'º does not exist!        º'
        DB 'º                        º'
        DB 'º Create it now?  Reply: º'
        DB 'º ÚÄÄÄÄÄÄ¿      ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³      ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ      ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'

;Filename translation for CoCo characters
CHRXLAT DB '@ABCDEFGHIJKLMNOPQRSTUVWXYZ(_)^_'
        DB '_!_#$%&',27H,'()___-__0123456789______'
        DB '@ABCDEFGHIJKLMNOPQRSTUVWXYZ(_)^_'
        DB '`ABCDEFGHIJKLMNOPQRSTUVWXYZ{_}~',7FH

PORT_NAME DB 'PORT.CFG',0
GENERAL_NAME DB 'GENERAL.CC3',0
DSK_SEARCH DB '*.DSK',0
ALL_SEARCH DB '*.*',0

;Work space -- not to be saved

INPUT_LENGTH DW 8               ;Number of characters allowed at a prompt
DTA     DB 513 DUP(?)           ;Disk transfer address 
FILE_BFR DB 32 DUP(?)           ;File name input field
COCO_DISK DB 32 DUP(?)          ;CoCo disk name
HANDLE  DW -1                   ;Handle of currently open virtual drive file
CUR_PATH DB 0,'\',64 DUP(0)     ;Power-up default directory
PC_DIR  DB 10500 DUP(0)         ;PC directory listing (max. 500 entries)
COCO_DIR DB 2709 DUP(0)         ;CoCo directory listing (max. 129 entries)
FDC_TRACK DB 0
FDC_SECTOR DB 0
MOUSE_HERE DB 0                 ;Indicates presence of mouse
DIR_COLUMN DB 58
ENTRY_STACK DW 0                ;Stack to restore in case of error
DOUBLE_STEP DB 1                ;Set to 1 unless MAX_TRACK is 80
GAT DB 256 DUP(?)               ;CoCo's GAT sector storage area
PC_PAGE DB 0                    ;Page of the PC directory currently shown
COCO_PAGE DB 0                  ;Page of the CoCo directory currently shown

;Configuration data -- to be saved

CFGTOP  EQU $

VIR_DIR DB 0,'\',64 DUP(0)
TO_COCO DB -1                   ;0=CoCo to MS-DOS, -1=MS-DOS to CoCo
DRIVE_SEL DB 80H                ;80H=head 0 (front), 90H=head 1 (back)
MAX_TRACK DB 35                 ;Maximum tracks
ADDLF   DB -1                   ;0=no action, -1=add/strip LFs
ADDEOF  DB -1                   ;0=no action, -1=add/strip EOFs
FTYPE   DB 0                    ;0=BASIC, 1=Data, 2=EXEC, 3=Editor
FFORMAT DB -1                   ;0=Binary, -1=ASCII

CFGEND  EQU $

PROG    ENDS
        END START
