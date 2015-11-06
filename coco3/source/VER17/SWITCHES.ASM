        ENABLE_DRAGON = 0               ;0 = disable Dragon keyboard layout
        ENABLE_RS232 = 1                ;0 = disable RS-232 support
        ENABLE_SNAPSHOTS = 1            ;0 = disables snapshot features
        ENABLE_NATIVE_VIDEO = 1         ;0 = disable extended video
        ENABLE_MATH = 1                 ;0 = disable hex calculator functions
        NEW_ACCESS_METHOD = 1           ;Method wherein CPU accesses native
                                        ;video. 0 = bit 7 of $FF88
                                        ;       1 = bit 7 of MMU2
        CLEAR_RAM = 1                   ;1 = zero all RAM on power-up/restart
        VIDEO_ACCESS_MASK = 128         ;Bit 7 of $FF88/MMU2 sets access
        IF NEW_ACCESS_METHOD
        PAGE_MASK = 128                 ;Bit 7 of $FF88 specifies mode 1 page
        ELSE
        PAGE_MASK = 64                  ;Bit 6 of $FF88 specifies mode 1 page
        ENDIF
        VIDEO_MODE_BITMASK = 3          ;Bits 0 and 1 of $FF88 represent
                                        ;native video mode.  0 = emulated,
                                        ;1 = 320x200, 2=320x480, 3=640x480
        JV = 564AH                      ;"JV" signature to enable native mode
