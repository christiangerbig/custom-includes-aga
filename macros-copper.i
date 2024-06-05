; -- Commands

COPMOVE MACRO
; \1 WORD: 16-Bit Wert
; \2 WORD CUSTOM-Registeroffset
  IFC "","\1"
    FAIL Makro COPMOVE: 16-Bit Wert fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COPMOVE: CUSTOM-Registeroffset fehlt
  ENDC
  move.w  #\2,(a0)+          ;CUSTOM-Registeroffset
  move.w  \1,(a0)+           ;Wert f�r Register
  ENDM


COPMOVEQ MACRO
; \1 WORD: 16-Bit Wert
; \2 WORD CUSTOM-Registeroffset
  IFC "","\1"
    FAIL Makro COPMOVEQ: 16-Bit Wert fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COPMOVEQ: CUSTOM-Registeroffset fehlt
  ENDC
  move.l  #((\2)<<16)|((\1)&$ffff),(a0)+ ;CUSTOM-Registeroffset + Wert f�r Register
  ENDM


COPWAIT MACRO
; \1 ... X-position (Bits 2-8)
; \2 ... Y-Position (Bits 0-7)
  IFC "","\1"
    FAIL Makro COPWAIT: X-position (Bits 2-8) fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COPWAIT: Y-Position (Bits 0-7) fehlt
  ENDC
  move.l  #((((\2)<<24)|((((\1)/4)*2)<<16))|$10000)|$fffe,(a0)+ ;Y-Pos, X-Pos, WAIT-Kennung
  ENDM


COPWAITBLIT MACRO
  move.l  #$00010000,(a0)+ ;BFD-Bit=0, auf Blitter warten
  ENDM


COPWAITBLIT2 MACRO
; \1 ... X-position (Bits 2-8)
; \2 ... Y-Position (Bits 0-7)
  IFC "","\1"
    FAIL Makro COPWAITBLIT2: X-position (Bits 2-8) fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COPWAITBLIT2: Y-Position (Bits 0-7) fehlt
  ENDC
  move.l  #((((\2)<<24)|((((\1)/4)*2)<<16))|$10000)|$7ffe,(a0)+ ;Y-Pos, X-Pos, WAIT-Kennung, BFD-Bit=0, auf Blitter warten
  ENDM


COPSKIP MACRO
; \1 ... X-position (Bits 2-8)
; \2 ... Y-Position (Bits 0-7)
  IFC "","\1"
    FAIL Makro COPSKIP: X-position (Bits 2-8) fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COPSKIP: Y-Position (Bits 0-7) fehlt
  ENDC
  move.l  #((\2)<<24)|((((\1)/4)*2)<<16)|$ffff,(a0)+ ;Y-Pos, X-Pos, SKIP-Kennung
  ENDM


COPLISTEND MACRO
  moveq   #-2,d0
  move.l  d0,(a0)
  ENDM

; -- Inits

COP_INIT_PLAYFIELD_REGISTERS MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: ["NOBITPLANES", "NOBITPLANESSPR", "BLANK", "BLANKSPR"]
; \3 Viewport-Label-Prefix: vp1,vp2..vpn (optional)
; \4 STRING "TRIGGERBITPLANES" (optional) BPLCON0 initialisieren
  IFC "","\1"
    FAIL Makro COP_INIT_PLAYFIELD_REGISTERS: Labels-Prefix fehlt
  ENDC
  IFC "","\1"
    FAIL Makro COP_INIT_PLAYFIELD_REGISTERS: Art des Displays ["NOBITPLANES", "NOBITPLANESPR", "BLANK", "BLANKSPR"] fehlt
  ENDC
  CNOP 0,4
  IFC "","\3"
\1_init_playfield_registers
    IFC "","\2"
      COPMOVEQ DIWSTRTBITS,DIWSTRT
      COPMOVEQ DIWSTOPBITS,DIWSTOP
      COPMOVEQ DDFSTRTBITS,DDFSTRT
      COPMOVEQ DDFSTOPBITS,DDFSTOP
      COPMOVEQ BPLCON0BITS,BPLCON0
      COPMOVEQ BPLCON1BITS,BPLCON1
      COPMOVEQ BPLCON2BITS,BPLCON2
      COPMOVEQ BPLCON3BITS1,BPLCON3 ;High-Bits der Farbwerte
      COPMOVEQ pf1_plane_moduli,BPL1MOD
      IFGT pf_depth-1
        IFD pf2_plane_moduli
          COPMOVEQ pf2_plane_moduli,BPL2MOD
        ELSE
          COPMOVEQ pf1_plane_moduli,BPL2MOD
        ENDC
      ENDC
      COPMOVEQ BPLCON4BITS,BPLCON4
      COPMOVEQ DIWHIGHBITS,DIWHIGH
      COPMOVEQ FMODEBITS,FMODE
      rts
    ELSE
      IFC "NOBITPLANES","\2"
        COPMOVEQ DIWSTRTBITS,DIWSTRT
        COPMOVEQ DIWSTOPBITS,DIWSTOP
        COPMOVEQ BPLCON0BITS,BPLCON0
        COPMOVEQ BPLCON3BITS1,BPLCON3
        COPMOVEQ BPLCON4BITS,BPLCON4
        COPMOVEQ DIWHIGHBITS,DIWHIGH
        rts
      ENDC
      IFC "NOBITPLANESSPR","\2"
        COPMOVEQ DIWSTRTBITS,DIWSTRT
        COPMOVEQ DIWSTOPBITS,DIWSTOP
        COPMOVEQ BPLCON0BITS,BPLCON0
        COPMOVEQ BPLCON3BITS1,BPLCON3
        COPMOVEQ BPLCON4BITS,BPLCON4
        COPMOVEQ DIWHIGHBITS,DIWHIGH
        COPMOVEQ FMODEBITS,FMODE
        rts
      ENDC
      IFC "BLANK","\2"
        COPMOVEQ BPLCON0BITS,BPLCON0
        COPMOVEQ BPLCON3BITS1,BPLCON3 ;High-Bits der Farbwerte
        rts
      ENDC
      IFC "BLANKSPR","\2"
        COPMOVEQ BPLCON0BITS,BPLCON0
        COPMOVEQ BPLCON3BITS1,BPLCON3 ;High-Bits der Farbwerte
        COPMOVEQ BPLCON4BITS,BPLCON4
        COPMOVEQ FMODEBITS,FMODE
        rts
      ENDC
    ENDC
  ELSE
\1_\3_init_playfield_registers
    COPMOVEQ \3_DDFSTRTBITS,DDFSTRT
    COPMOVEQ \3_DDFSTOPBITS,DDFSTOP
    IFC "TRIGGERBITPLANES","\4"
      COPMOVEQ \3_BPLCON0BITS,BPLCON0
    ENDC
    COPMOVEQ \3_BPLCON1BITS,BPLCON1
    COPMOVEQ \3_BPLCON2BITS,BPLCON2
    COPMOVEQ \3_BPLCON3BITS1,BPLCON3 ;High-Bits der Farbwerte
    COPMOVEQ \3_pf1_plane_moduli,BPL1MOD
    IFD \3_pf2_plane_moduli
      COPMOVEQ \3_pf2_plane_moduli,BPL2MOD
    ELSE
      COPMOVEQ \3_pf1_plane_moduli,BPL2MOD
    ENDC
    COPMOVEQ \3_BPLCON4BITS,BPLCON4
    COPMOVEQ \3_FMODEBITS,FMODE
    rts
  ENDC
  ENDM


COP_INIT_BITPLANE_POINTERS MACRO
; \1 STRING: Labels-Prefix der Routine
  IFC "","\1"
    FAIL Makro COP_INIT_BITPLANE_POINTERS: Labels-Prefix fehlt
  ENDC
  CNOP 0,4
\1_init_bitplane_pointers
  MOVEF.W  BPL1PTH,d0
  moveq   #(pf_depth*2)-1,d7 ;Anzahl der Bitplanes
\1_init_bitplane_pointers_loop
  move.w  d0,(a0)            ;BPLxPTH/L
  addq.w  #2,d0              ;n�chstes Register
  addq.w  #4,a0              ;n�chster Eintrag in CL
  dbf     d7,\1_init_bitplane_pointers_loop
  rts
  ENDM


COP_SET_BITPLANE_POINTERS MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: ["construction1", "display"]
; \3 BYTE SIGNED: Anzahl der Bitplanes Playfield 1
; \4 BYTE SIGNED: Anzahl der BitPlanes Playfield 2 (optional)
; \5 WORD: X-Offset (optional)
; \6 WORD: Y-Offset (optional)
  IFC "","\1"
    FAIL Makro COP_SET_BITPLANE_POINTERS: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COP_SET_BITPLANE_POINTERS: Name der Copperliste ["construction1", "display"] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro COP_SET_BITPLANE_POINTERS: Anzahl der Bitplanes Playfield1 fehlt
  ENDC
  CNOP 0,4
\1_set_bitplane_pointers
  IFC "","\4"
    IFC "","\5"
      move.l  \1_\2(a3),a0       
      ADDF.W  \1_BPL1PTH+2,a0
      move.l  pf1_display(a3),a1 ;Zeiger auf erste Plane
      moveq   #\3-1,d7           ;Anzahl der Bitplanes
\1_set_bitplane_pointers_loop
      move.w  (a1)+,(a0)         ;High-Wert
      addq.w  #8,a0              ;n�chter Playfieldzeiger
      move.w  (a1)+,4-8(a0)      ;Low-Wert
      dbf     d7,\1_set_bitplane_pointers_loop
    ELSE
      move.l  \1_\2(a3),a0       
      ADDF.W  \1_BPL1PTH+2,a0
      move.l  pf1_display(a3),a1 ;Zeiger auf erste Plane
      MOVEF.L (\5/8)+(\6*pf1_plane_width*pf1_depth3),d1
      moveq   #\3-1,d7           ;Anzahl der Bitplanes
\1_set_bitplane_pointers_loop
      move.l  (a1)+,d0
      add.l   d1,d0
      move.w  d0,4(a0)           ;BPLxPTL
      swap    d0                 ;High
      move.w  d0,(a0)            ;BPLxPTH
      addq.w  #8,a0
      dbf     d7,\1_set_bitplane_pointers_loop
    ENDC
  ELSE
    move.l  \1_\2(a3),a0         
    lea     \1_BPL2PTH+2(a0),a1
    ADDF.W  \1_BPL1PTH+2,a0
    move.l  pf1_display(a3),a2 ;Zeiger auf erste Plane

; ** Zeiger auf Playfield 1 eintragen **
    moveq   #\3-1,d7           ;Anzahl der Bitplanes
\1_set_bitplane_pointers_loop1
    move.w  (a2)+,(a0)         ;BPLxPTH
    ADDF.W  16,a0              ;�bern�chter Playfieldzeiger
    move.w  (a2)+,4-16(a0)     ;BPLxPTL
    dbf     d7,\1_set_bitplane_pointers_loop1

; ** Zeiger auf Playfield 2 eintragen **
    move.l  pf2_display(a3),a2 ;Zeiger auf erste Plane
    moveq   #\4-1,d7           ;Anzahl der Bitplanes
\1_set_bitplane_pointers_loop2
    move.w  (a2)+,(a1)         ;BPLxPTH
    ADDF.W  16,a1              ;�bern�chter Playfieldzeiger
    move.w  (a2)+,4-16(a1)     ;BPLxPTL
    dbf     d7,\1_set_bitplane_pointers_loop2
  ENDC
  rts
  ENDM


COP_INIT_SPRITE_POINTERS MACRO
; \1 STRING: Labels-Prefix der Routine
  IFC "","\1"
    FAIL Makro COP_INIT_SPRITE_POINTERS: Labels-Prefix fehlt
  ENDC
  CNOP 0,4
\1_init_sprite_pointers
  move.w  #SPR0PTH,d0
  moveq   #(spr_number*2)-1,d7 ;Anzahl der Sprites
\1_init_sprite_pointers_loop
  move.w  d0,(a0)          ;SPRxPTH/L
  addq.w  #2,d0            ;n�chstes Register
  addq.w  #4,a0            ;n�chster Eintrag in CL
  dbf     d7,\1_init_sprite_pointers_loop
  rts
  ENDM


COP_SET_SPRITE_POINTERS MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: ["construction1", "construction2", "display"]
; \3 BYTE SIGNED: Anzahl der Sprites
; \4 NUMBER: [1,2,3,4,5,6,7] Index ab welchem Sprite (optional)
  IFC "","\1"
    FAIL Makro COP_SET_SPRITE_POINTERS: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COP_SET_SPRITE_POINTERS: Name der Copperliste ["construction1", "construction2", "display"] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro COP_SET_SPRITE_POINTERS: Anzahl der Sprites fehlt
  ENDC
  CNOP 0,4
\1_set_sprite_pointers
  move.l  \1_\2(a3),a0       
  IFC "","\4"
    lea     spr_pointers_display(pc),a1 ;Zeiger auf Sprites
    ADDF.W  \1_SPR0PTH+2,a0
  ELSE
    lea     spr_pointers_display+(\4*4)(pc),a1 ;Zeiger auf Sprites + Index
    ADDF.W  \1_SPR\3PTH+2,a0
  ENDC
  moveq   #\3-1,d7           ;Anzahl der Sprites
\1_set_sprite_pointers_loop
  move.w  (a1)+,(a0)         ;SPRxPTH
  addq.w  #8,a0              ;n�chter Spritezeiger
  move.w  (a1)+,4-8(a0)      ;SPRxPTL
  dbf     d7,\1_set_sprite_pointers_loop
  rts
  ENDM


COP_SELECT_COLORHI_BANK MACRO
; \1 NUMBER: Color-Bank number 0..7
; \2 WORD: BPLCON3-bits (optional)
  IFC "","\1"
    FAIL Makro COP_SELECT_COLORHI_BANK MACRO: Color-Bank Nummer 0..7 fehlt
  ENDC
    COPMOVEQ BPLCON3BITS1+(BPLCON3F_BANK0*\1),BPLCON3 ;High-Bits
  IFNC "","\2"
    or.w     #\2,-2(a0)      ;High-Bits
  ENDC
  ENDM


COP_SELECT_COLORLO_BANK MACRO
; \1 NUMBER: Color-Bank 0..7
; \2 WORD: BPLCON3-bits (optional)
  IFC "","\1"
    FAIL Makro COP_SELECT_COLORLO_BANK MACRO: Color-Bank Nummer 0..7 fehlt
  ENDC
    COPMOVEQ BPLCON3BITS2+(BPLCON3F_BANK0*\1),BPLCON3 ;Low-Bits
  IFNC "","\2"
    or.w     #\2,-2(a0)      ;Low-Bits
  ENDC
  ENDM


COP_INIT_COLORHI MACRO
; \1 WORD: Erstes Farbregister-Offset
; \2 BYTE_SIGNED: Anzahl der Farbwerte
; \3 POINTER: Farbtabelle (optional)
  IFC "","\1"
    FAIL Makro COP_INIT_COLORHI: Erstes Farbregister-Offset fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COP_INIT_COLORHI: Anzahl der Farbwerte fehlt
  ENDC
  move.w  #\1,d3             ;erstes Farbregister-Offset
  moveq   #\2-1,d7           ;Anzahl der Farbwerte
  IFNC "","\3"
    lea     \3(pc),a1        ;Farbtabelle
  ENDC
  bsr     cop_init_high_colors
  ENDM


COP_INIT_COLORLO MACRO
; \1 WORD: Erstes Farbregister-Offset
; \2 BYTE_SIGNED: Anzahl der Farbwerte
; \3 POINTER: Farbtabelle (optional)
  IFC "","\1"
    FAIL Makro COP_INIT_COLORLO: Erstes Farbregister-Offset fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COP_INIT_COLORLO: Anzahl der Farbwerte fehlt
  ENDC
  move.w  #\1,d3             ;erstes Farbregister-Offset
  moveq   #\2-1,d7           ;Anzahl der Farbwerte
  IFNC "","\3"
    lea     \3(pc),a1        ;Farbtabelle
  ENDC
  bsr     cop_init_low_colors
  ENDM


COP_INIT_COLOR00_REGISTERS MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: "YWRAP" (optional)
  IFC "","\1"
    FAIL Makro COP_INIT_COLOR00_REGISTERS: Labels-Prefix fehlt
  ENDC
  CNOP 0,4
\1_init_COLOR00_registers
  move.l  #(((\1_VSTART1<<24)|(((\1_HSTART1/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.l  #(BPLCON3<<16)|BPLCON3BITS1,d1 ;High-Werte
  move.l  #(COLOR00<<16)|COLOR00HIGHBITS,d2
  move.l  #(BPLCON3<<16)|BPLCON3BITS2,d3 ;Low-RGB-Werte
  move.l  #(COLOR00<<16)|COLOR00LOWBITS,d4
  IFC "YWRAP","\2"
    move.l  #(((cl_y_wrap<<24)|(((\1_HSTART1/4)*2)<<16))|$10000)|$fffe,d5 ;WAIT-Befehl
  ENDC
  moveq   #1,d6
  ror.l   #8,d6              ;$01000000 Additionswert
  MOVEF.W \1_display_y_size-1,d7 ;Anzahl der Zeilen
\1_init_COLOR00_registers_loop
  move.l  d0,(a0)+           ;WAIT x,y
  move.l  d1,(a0)+           ;High-Werte
  move.l  d2,(a0)+           ;COLOR00
  move.l  d3,(a0)+           ;Low-Werte
  move.l  d4,(a0)+           ;COLOR00
  IFC "YWRAP","\2"
    cmp.l   d5,d0            ;Rasterzeile $ff erreicht ?
    bne.s   no_patch_copperlist2 ;Nein -> verzweige
patch_copperlist2
    COPWAIT cl_x_wrap,cl_y_wrap ;Copperliste patchen
    bra.s   \1_init_color_registers_skip
    CNOP 0,4
no_patch_copperlist2
    COPMOVEQ TRUE,NOOP
\1_init_color_registers_skip
  ENDC
  add.l   d6,d0              ;n�chste Zeile
  dbf     d7,\1_init_COLOR00_registers_loop
  rts
  ENDM


COP_RESET_COLOR00 MACRO
; \1 STRING: Label-Prefix Copperliste [cl1,cl2]
; \2 WORD: X-Position
; \3 WORD: Y-Postion
  IFC "","\1"
    FAIL Makro COP_RESET_COLOR00: Labels-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COP_RESET_COLOR00: X-Position fehlt
  ENDC
  IFC "","\3"
    FAIL Makro COP_RESET_COLOR00: Y-Position fehlt
  ENDC
  CNOP 0,4
\1_reset_COLOR00
  COPWAIT \2,(\3)&$ff
  COPMOVEQ BPLCON3BITS1,BPLCON3
  COPMOVEQ COLOR00HIGHBITS,COLOR00
  COPMOVEQ BPLCON3BITS2,BPLCON3
  COPMOVEQ COLOR00LOWBITS,COLOR00
  rts
  ENDM


COP_INIT_BPLCON4_CHUNKY_SCREEN MACRO
; \1 STRING: Label-Prefix Copperliste [cl1,cl2]
; \2 NUMBER: HSTART
; \3 NUMBER: VSTART
; \4 NUMBER: Breite in Pixeln
; \5 NUMBER: H�he in Zeilen
; \6 BOOLEAN: TRUE = open border before display window start
; \7 BOOLEAN: TRUE = quick clear
; \8 BOOLEAN: TRUE = Hintergrundeffekt
; \9 LONGWORD: CMOVE value,register / STRING: "OVERSCAN" (optional)
  IFC "","\1"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: Labels-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: HSTART fehlt
  ENDC
  IFC "","\3"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: VSTART fehlt
  ENDC
  IFC "","\4"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: Breite in Pixeln fehlt
  ENDC
  IFC "","\5"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: H�he in Zeilen fehlt
  ENDC
  IFC "","\6"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: Boolean zu open border fehlt
  ENDC
  IFC "","\7"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: Boolean zu quick clear fehlt
  ENDC
  IFC "","\8"
    FAIL Makro COP_INIT_BPLCON4_CHUNKY_SCREEN: Boolean zu Hintergrundeffekt fehlt
  ENDC
  CNOP 0,4
\1_init_BPLCON4_registers
  IFNE \8
    move.l  #(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
    move.l  #(BPLCON4<<16)+(BPLCON4BITS&$00ff),d1
    IFEQ \6
      IFNC "","\9"
        IFNC "OVERSCAN","\9"
          move.l  #\9,d2
        ELSE
          move.l  #BPL1DAT<<16,d2
        ENDC
      ELSE
        move.l  #BPL1DAT<<16,d2
      ENDC
    ENDC
    moveq   #1,d3
    ror.l   #8,d3            ;Y-Additionswert $01000000
    MOVEF.W \5-1,d7          ;Anzahl der Zeilen
\1_init_BPLCON4_registers_loop1
    move.l  d0,(a0)+         ;WAIT x,y
    IFEQ \6
      IFC "OVERSCAN","\9"
        COPMOVEQ FMODEBITS2,FMODE
        move.l  d2,(a0)+       ;BPL1DAT
        COPMOVEQ TRUE,NOOP
        COPMOVEQ FMODEBITS,FMODE
      ELSE
        move.l  d2,(a0)+       ;BPL1DAT
      ENDC
    ENDC
    moveq   #(\4/8)-1,d6     ;Anzahl der Spalten
\1_init_BPLCON4_registers_loop2
    move.l  d1,(a0)+         ;BPLCON4
    dbf     d6,\1_init_BPLCON4_registers_loop2
    add.l   d3,d0            ;n�chste Zeile
    dbf     d7,\1_init_BPLCON4_registers_loop1
    rts
  ELSE
    move.l  a4,-(a7)
    move.l  #(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
    IFEQ \7
      move.l  #(BPLCON3<<16)+BPLCON3BITS3,d1 ;High-RGB-Werte
    ELSE
      move.l  #(BPLCON3<<16)+BPLCON3BITS1,d1 ;High-RGB-Werte
    ENDC
    IFEQ \7
      move.l  #(COLOR31<<16)+COLOR00HIGHBITS,a2
    ELSE
      move.l  #(COLOR00<<16)+COLOR00HIGHBITS,a2
    ENDC
    IFEQ \7
      move.l  #(COLOR31<<16)+COLOR00LOWBITS,a4
    ELSE
      move.l  #(COLOR00<<16)+COLOR00LOWBITS,a4
    ENDC
    IFEQ \7
      move.l  #(BPLCON3<<16)+BPLCON3BITS4,d3 ;Low-RGB-Werte
    ELSE
      move.l  #(BPLCON3<<16)+BPLCON3BITS2,d3 ;Low-RGB-Werte
    ENDC
    move.l  #(BPLCON4<<16)+(BPLCON4BITS&$00ff),d4
    IFEQ \6
      IFNC "","\9"
        IFNC "OVERSCAN","\9"
          move.l  #\9,d2
        ELSE
          move.l  #BPL1DAT<<16,d2
        ENDC
      ELSE
        move.l  #BPL1DAT<<16,d2
      ENDC
    ENDC
    moveq   #1,d5
    ror.l   #8,d5            ;Y-Additionswert $01000000
    MOVEF.W \5-1,d7          ;Anzahl der Zeilen
\1_init_BPLCON4_registers_loop1
    move.l  d0,(a0)+         ;WAIT x,y
    move.l  d1,(a0)+         ;High-Werte
    move.l  a2,(a0)+         ;COLOR31/00
    move.l  d3,(a0)+         ;Low-Werte
    move.l  a4,(a0)+         ;COLOR31/00
    IFEQ \6
      IFC "OVERSCAN","\9"
        COPMOVEQ FMODEBITS2,FMODE
        move.l  d2,(a0)+       ;BPL1DAT
        COPMOVEQ TRUE,NOOP
        COPMOVEQ FMODEBITS,FMODE
      ELSE
        move.l  d2,(a0)+       ;BPL1DAT
      ENDC
    ENDC
    moveq   #(\4/8)-1,d6     ;Anzahl der Spalten
\1_init_BPLCON4_registers_loop2
    move.l  d4,(a0)+         ;BPLCON4
    dbf     d6,\1_init_BPLCON4_registers_loop2
    add.l   d5,d0            ;n�chste Zeile
    dbf     d7,\1_init_BPLCON4_registers_loop1
    move.l  (a7)+,a4
    rts
  ENDC
  ENDM


COP_INIT_BPLCON1_CHUNKY_SCREEN MACRO
; \1 STRING: Label-Prefix Copperliste [cl1,cl2]
; \2 NUMBER: HSTART
; \3 NUMBER: VSTART
; \4 NUMBER: Breite in Pixeln
; \5 NUMBER: H�he in Zeilen
; \6 WORD: alternative BPLCON1BITS
  IFC "","\1"
    FAIL Makro COP_INIT_BPLCON1_CHUNKY_SCREEN: Labels-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COP_INIT_BPLCON1_CHUNKY_SCREEN: HSTART fehlt
  ENDC
  IFC "","\3"
    FAIL Makro COP_INIT_BPLCON1_CHUNKY_SCREEN: VSTART fehlt
  ENDC
  IFC "","\4"
    FAIL Makro COP_INIT_BPLCON1_CHUNKY_SCREEN: Breite in Pixeln fehlt
  ENDC
  IFC "","\5"
    FAIL Makro COP_INIT_BPLCON1_CHUNKY_SCREEN: H�he in Zeilen fehlt
  ENDC
  CNOP 0,4
\1_init_BPLCON1_registers
  move.l  #(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  IFC "","\6"
    move.l  #(BPLCON1<<16)+BPLCON1BITS,d1
  ELSE
    move.l  #(BPLCON1<<16)+\6,d1
  ENDC
  moveq   #1,d3
  ror.l   #8,d3              ;Y-Additionswert $01000000
  MOVEF.W \5-1,d7            ;Anzahl der Zeilen
\1_init_BPLCON1_registers_loop1
  move.l  d0,(a0)+           ;WAIT x,y
  moveq   #(\4/8)-1,d6       ;Anzahl der Spalten
\1_init_BPLCON1_registers_loop2
  move.l  d1,(a0)+           ;BPLCON1
  dbf     d6,\1_init_BPLCON1_registers_loop2
  add.l   d3,d0              ;n�chste Zeile
  dbf     d7,\1_init_BPLCON1_registers_loop1
  rts
  ENDM


COP_INIT_COPINT MACRO
; \1 STRING: Label-Prefix Copperliste [cl1,cl2]
; \2 WORD: X-Position (optional)
; \3 WORD: Y-Postion  (optional)
; \4 STRING: "YWRAP" (optional)
  IFC "","\1"
    FAIL Makro COP_INIT_COPINT: Labels-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  CNOP 0,4
\1_init_copint
  IFC "YWRAP","\4"
    COPWAIT cl_x_wrap,cl_y_wrap ;Copperliste patchen
  ENDC
  IFNC "","\2"
    IFNC "","\3"
      COPWAIT \2,\3
    ENDC
  ENDC
  COPMOVEQ INTF_COPER+INTF_SETCLR,INTREQ
  rts
  ENDM


COPY_COPPERLIST MACRO
; \1 STRING: Label-Prefix Copperliste [cl1,cl2]
; \2 NUMBER: Anzahl der Copperlisten [2,3]
  IFC "","\1"
    FAIL Makro COPY_COPPERLIST: Labels-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COPY_COPPERLIST: Anzahl der Copperlisten [2,3] fehlt
  ENDC
  CNOP 0,4
  IFC "cl1","\1"
copy_first_copperlist
    IFC "","\2"
      FAIL Makro COPY_COPPERLIST: Anzahl der Copperlisten fehlt
    ENDC
    IFEQ \2-2
      move.l  \1_construction2(a3),a0 ;Quelle
      move.l  \1_display(a3),a1 ;2. Ziel
      move.w  #(copperlist1_SIZE/LONGWORDSIZE)-1,d7 ;Anzahl der Langw�rter zum kopieren
copy_first_copperlist_loop
      move.l  (a0)+,(a1)+        ;1 Langwort kopieren
      dbf     d7,copy_first_copperlist_loop
      rts
    ENDC
    IFEQ \2-3
      move.l  \1_construction1(a3),a0 ;Quelle
      move.l  \1_construction2(a3),a1 ;1. Ziel
      move.w  #(copperlist1_SIZE/LONGWORDSIZE)-1,d7 ;Anzahl der Langw�rter zum kopieren
      move.l  \1_display(a3),a2 ;2. Ziel
copy_first_copperlist_loop
      move.l  (a0),(a1)+         ;1 Langwort kopieren
      move.l  (a0)+,(a2)+
      dbf     d7,copy_first_copperlist_loop
      rts
    ENDC
  ENDC
  IFC "cl2","\1"
copy_second_copperlist
    IFC "","\2"
      FAIL Makro COPY_COPPERLIST: Anzahl der Copperlisten fehlt
    ENDC
    IFEQ \2-2
      move.l  \1_construction2(a3),a0 ;Quelle
      move.l  \1_display(a3),a1 ;2. Ziel
      move.w  #(copperlist2_SIZE/LONGWORDSIZE)-1,d7 ;Anzahl der Langw�rter zum kopieren
copy_second_copperlist_loop
      move.l  (a0)+,(a1)+        ;1 Langwort kopieren
      dbf     d7,copy_second_copperlist_loop
      rts
    ENDC
    IFEQ \2-3
      move.l  \1_construction1(a3),a0 ;Quelle
      move.l  \1_construction2(a3),a1 ;1. Ziel
      move.w  #(copperlist2_SIZE/LONGWORDSIZE)-1,d7 ;Anzahl der Langw�rter zum kopieren
      move.l  \1_display(a3),a2 ;2. Ziel
copy_second_copperlist_loop
      move.l  (a0),(a1)+         ;1 Langwort kopieren
      move.l  (a0)+,(a2)+
      dbf     d7,copy_second_copperlist_loop
      rts
    ENDC
  ENDC
  ENDM


CONVERT_IMAGE_TO_RGB4_CHUNKY MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 POINTER: Tabelle mit Switchwerten
; \3 STRING: Pointer-Base [pc,a3]
  IFC "","\1"
    FAIL Makro CONVERT_IMAGE_TO_RGB4_CHUNKY: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro CONVERT_IMAGE_TO_RGB4_CHUNKY: Tabelle mit Switchwerten fehlt
  ENDC
  IFC "","\3"
    FAIL Makro CONVERT_IMAGE_TO_RGB4_CHUNKY: Pointer-Base [pc,a3] fehlt
  ENDC
  CNOP 0,4
\1_convert_image_data
  move.l  a4,-(a7)
  lea     \1_image_data,a0 ;Quellbild
  lea     \1_image_color_table(pc),a1 ;RGB-Farbwerte des Playfieldes
  IFC "","\2"
    lea   \1_\2(\3),a2
  ELSE
    move.l \2(\3),a2
  ENDC
  move.w  #\1_image_plane_width*(\1_image_depth-1),a4
  moveq   #16,d1             ;COLOR16
  MOVEF.W \1_image_y_size-1,d7 ;H�he des Playfieldes
\1_convert_image_data_loop1
  moveq   #\1_image_plane_width-1,d6 ;Breite des Quellbildes in Bytes
\1_convert_image_data_loop2
  moveq   #8-1,d5            ;Anzahl der Bits pro Byte
\1_convert_image_data_loop3
  moveq   #TRUE,d0           ;Farbnummer
  IFGE \1_image_depth-1
    btst    d5,(a0)          ;Bit n in Bitplane0 gesetzt ?
    beq.s   \1_no_bitplane0  ;Nein -> verzweige
    addq.w  #1,d0            ;COLOR01
\1_no_bitplane0
  ENDC
  IFGE \1_image_depth-2
    btst    d5,\1_image_plane_width*1(a0) ;Bit n in Bitplane1 gesetzt ?
    beq.s   \1_no_bitplane1  ;Nein -> verzweige
    addq.w  #2,d0            ;COLOR02
\1_no_bitplane1
  ENDC
  IFGE \1_image_depth-3
    btst    d5,\1_image_plane_width*2(a0) ;Bit n in Bitplane2 gesetzt ?
    beq.s   \1_no_bitplane2  ;Nein -> verzweige
    addq.w  #4,d0            ;COLOR04
\1_no_bitplane2
  ENDC
  IFGE \1_image_depth-4
    btst    d5,\1_image_plane_width*3(a0) ;Bit n in Bitplane3 gesetzt ?
    beq.s   \1_no_bitplane3  ;Nein -> verzweige
    addq.w  #8,d0            ;COLOR08
\1_no_bitplane3
  ENDC
  IFEQ \1_image_depth-5
    btst    d5,\1_image_plane_width*4(a0) ;Bit n in Bitplane4 gesetzt ?
    beq.s   \1_no_bitplane4  ;Nein -> verzweige
    add.w   d1,d0            ;COLOR16
\1_no_bitplane4
  ENDC
  move.w  (a1,d0.l*2),(a2)+  ;RGB4-Farbwert aufgrund der ermittelten Farbnummer kopieren
  dbf     d5,\1_convert_image_data_loop3
  addq.w  #1,a0              ;N�chstes Byte in Quellbild
  dbf     d6,\1_convert_image_data_loop2
  add.l   a4,a0              ;restliche Bitplanes �berspringen
  dbf     d7,\1_convert_image_data_loop1
  move.l  (a7)+,a4
  rts
  ENDM


CONVERT_IMAGE_TO_HAM6_CHUNKY MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 POINTER: Tabelle mit Switchwerten
; \3 STRING: Pointer-Base [pc,a3]
  IFC "","\1"
    FAIL Makro CONVERT_IMAGE_TO_HAM6_CHUNKY: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro CONVERT_IMAGE_TO_HAM6_CHUNKY: Tabelle mit Switchwerten fehlt
  ENDC
  IFC "","\3"
    FAIL Makro CONVERT_IMAGE_TO_HAM6_CHUNKY: Pointer-Base [pc,a3] fehlt
  ENDC
  CNOP 0,4
\1_convert_image_data
  movem.l a4-a6,-(a7)
  lea     \1_image_data,a0   ;Quellbild
  lea     \1_image_color_table(pc),a1 ;Farbwerte des Playfieldes
  IFC "","\2"
    lea   \1_\2(\3),a2
  ELSE
    move.l \2(\3),a2
  ENDC
  move.w  #16,a4             ;COLOR16
  move.w  #32,a5             ;COLOR32
  move.w  #\1_image_plane_width*(\1_image_depth-1),a6
  moveq   #$30,d3
  moveq   #$f,d4             ;Maske f�r Farbbits
  MOVEF.W \1_image_y_size-1,d7 ;H�he des Playfieldes
\1_convert_image_data_loop1
  moveq   #TRUE,d2           ;RGB4-Wert zur�cksetzen (COLOR00)
  moveq   #\1_image_plane_width-1,d6 ;Breite des Quellbildes in Bytes
\1_convert_image_data_loop2
  moveq   #8-1,d5            ;Anzahl der Bits pro Byte
\1_convert_image_data_loop3
  moveq   #TRUE,d0           ;Farbnummer
  btst    d5,(a0)            ;Bit n in Bitplane0 gesetzt ?
  beq.s   \1_no_bitplane0    ;Nein -> verzweige
  addq.w  #1,d0              ;Farbnummer erh�hen
\1_no_bitplane0
  btst    d5,\1_image_plane_width*1(a0) ;Bit n in Bitplane1 gesetzt ?
  beq.s   \1_no_bitplane1    ;Nein -> verzweige
  addq.w  #2,d0              ;Farbnummer erh�hen
\1_no_bitplane1
  btst    d5,\1_image_plane_width*2(a0) ;Bit n in Bitplane2 gesetzt ?
  beq.s   \1_no_bitplane2    ;Nein -> verzweige
  addq.w  #4,d0              ;Farbnummer erh�hen
\1_no_bitplane2
  btst    d5,\1_image_plane_width*3(a0) ;Bit n in Bitplane3 gesetzt ?
  beq.s   \1_no_bitplane3    ;Nein -> verzweige
  addq.w  #8,d0              ;Farbnummer erh�hen
\1_no_bitplane3
  btst    d5,\1_image_plane_width*4(a0) ;Bit n in Bitplane4 gesetzt ?
  beq.s   \1_no_bitplane4    ;Nein -> verzweige
  add.w   a4,d0              ;Farbnummer erh�hen
\1_no_bitplane4
  btst    d5,\1_image_plane_width*5(a0) ;Bit n in Bitplane5 gesetzt ?
  beq.s   \1_no_bitplane5    ;Nein -> verzweige
  add.w   a5,d0              ;Farbnummer erh�hen
\1_no_bitplane5
  move.l  d0,d1              ;Farbnummer retten
  and.b   d3,d1              ;Bit 4 oder 5 gesetzt ?
  bne.s   \1_check_blue      ;Ja -> verzweige
\1_use_color_register
  move.w  (a1,d0.l*2),d2     ;Farbwert auslesen
  bra.s   \1_set_rgb
  CNOP 0,4
\1_check_blue
  cmp.b   #$10,d1            ;Blauanteil �ndern ?
  bne.s   \1_check_red       ;Nein -> verzweige
  and.w   #$ff0,d2           ;Blauanteil ausmaskieren
  and.w   d4,d0              ;Blauanteil ausmaskieren
  or.b    d0,d2              ;Neuen Blauanteil setzen
  bra.s   \1_set_rgb
  CNOP 0,4
\1_check_red
  cmp.b   #$20,d1            ;Rotanteil �ndern ?
  bne.s   \1_check_green     ;Nein -> verzweige
  and.w   #$0ff,d2           ;Rotanteil ausmaskieren
  and.w   d4,d0              ;Rotanteil ausmaskieren
  lsl.w   #8,d0              ;Bits in richtige Position bringen
  or.w    d0,d2              ;Neuen Rotanteil setzen
  bra.s   \1_set_rgb
  CNOP 0,4
\1_check_green
  cmp.b   d3,d1              ;Gr�nanteil �ndern ?
  bne.s   \1_set_rgb         ;Nein -> verzweige
  and.w   #$f0f,d2           ;Gr�nanteil ausmaskieren
  and.w   d4,d0              ;Gr�nanteil ausmaskieren
  lsl.b   #4,d0              ;Bits in richtige Position bringen
  or.b    d0,d2              ;Neuen Gr�nanteil setzen
\1_set_rgb
  move.w  d2,(a2)+           ;RGB-Wert retten
  dbf     d5,\1_convert_image_data_loop3
  addq.w  #1,a0              ;N�chstes Byte in Quellbild
  dbf     d6,\1_convert_image_data_loop2
  add.l   a6,a0              ;restliche Bitplanes �berspringen
  dbf     d7,\1_convert_image_data_loop1
  movem.l (a7)+,a4-a6
  rts
  ENDM


CONVERT_IMAGE_TO_RGB8_CHUNKY MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 POINTER: Tabelle mit Switchwerten
; \3 STRING: Pointer-Base [pc,a3]
  IFC "","\1"
    FAIL Makro CONVERT_IMAGE_TO_RGB8_CHUNKY: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro CONVERT_IMAGE_TO_RGB8_CHUNKY: Tabelle mit Switchwerten fehlt
  ENDC
  IFC "","\3"
    FAIL Makro CONVERT_IMAGE_TO_RGB8_CHUNKY: Pointer-Base [pc,a3] fehlt
  ENDC
  CNOP 0,4
\1_convert_image_data
  movem.l a4-a6,-(a7)
  moveq   #16,d3             ;COLOR16
  move.w  #$0f0f,d4          ;Maske
  lea     \1_image_data,a0  ;Quellbild
  lea     \1_image_color_table(pc),a1 ;Farbwerte des Playfieldes
  IFC "","\2"
    lea   \1_color_table(pc),a2
  ELSE
    move.l \2(\3),a2
  ENDC
  move.w  #32,a4             ;COLOR32
  move.w  #64,a5             ;COLOR64
  move.w  #128,a6            ;COLOR128
  MOVEF.W \1_image_y_size-1,d7 ;H�he des Playfieldes
\1_convert_image_loop1
  moveq   #\1_image_plane_width-1,d6 ;Breite des Quellbildes in Bytes
\1_convert_image_loop2
  moveq   #8-1,d5            ;Anzahl der Bits pro Byte
\1_convert_image_loop3
  moveq   #TRUE,d0           ;Farbnummer
  IFGE \1_image_depth-1
    btst    d5,(a0)          ;Bit n in Bitplane0 gesetzt ?
    beq.s   \1_no_bitplane0  ;Nein -> verzweige
    addq.w  #1,d0            ;Farbnummer erh�hen
\1_no_bitplane0
  ENDC
  IFGE \1_image_depth-2
    btst    d5,\1_image_plane_width*1(a0) ;Bit n in Bitplane1 gesetzt ?
    beq.s   \1_no_bitplane1  ;Nein -> verzweige
    addq.w  #2,d0            ;Farbnummer erh�hen
\1_no_bitplane1
  ENDC
  IFGE \1_image_depth-3
    btst    d5,\1_image_plane_width*2(a0) ;Bit n in Bitplane2 gesetzt ?
    beq.s   \1_no_bitplane2  ;Nein -> verzweige
    addq.w  #4,d0            ;Farbnummer erh�hen
\1_no_bitplane2
  ENDC
  IFGE \1_image_depth-4
    btst    d5,\1_image_plane_width*3(a0) ;Bit n in Bitplane3 gesetzt ?
    beq.s   \1_no_bitplane3  ;Nein -> verzweige
    addq.w  #8,d0            ;Farbnummer erh�hen
\1_no_bitplane3
  ENDC
  IFGE \1_image_depth-5
    btst    d5,\1_image_plane_width*4(a0) ;Bit n in Bitplane4 gesetzt ?
    beq.s   \1_no_bitplane4  ;Nein -> verzweige
    add.w   d3,d0            ;Farbnummer erh�hen
\1_no_bitplane4
  ENDC
  IFGE \1_image_depth-6
    btst    d5,\1_image_plane_width*5(a0) ;Bit n in Bitplane5 gesetzt ?
    beq.s   \1_no_bitplane5  ;Nein -> verzweige
    add.w   a4,d0            ;Farbnummer erh�hen
\1_no_bitplane5
  ENDC
  IFGE \1_image_depth-7
    btst    d5,\1_image_plane_width*6(a0) ;Bit n in Bitplane6 gesetzt ?
    beq.s   \1_no_bitplane6  ;Nein -> verzweige
    add.w   a5,d0            ;Farbnummer erh�hen
\1_no_bitplane6
  ENDC
  IFEQ \1_image_depth-8
    btst    d5,\1_image_plane_width*7(a0) ;Bit n in Bitplane7 gesetzt ?
    beq.s   \1_no_bitplane7  ;Nein -> verzweige
    add.w   a6,d0            Farbnummer erh�hen
\1_no_bitplane7
  ENDC
  move.l  (a1,d0.l*4),d0     ;RGB8-Farbwert lesen
  move.l  d0,d2              
  RGB8_TO_RGB4HI d0,d1,d4
  move.w  d0,(a2)+           ;High-Bits
  RGB8_TO_RGB4LO d2,d1,d4
  move.w  d2,(a2)+           ;Low-Bits
  dbf     d5,\1_convert_image_loop3
  addq.w  #1,a0              ;N�chstes Byte in Quellbild
  dbf     d6,\1_convert_image_loop2
  add.l   #\1_image_plane_width*(\1_image_depth-1),a0 ;restliche Bitplanes �berspringen
  dbf     d7,\1_convert_image_loop1
  movem.l (a7)+,a4-a6
  rts
  ENDM


CONVERT_IMAGE_TO_HAM8_CHUNKY MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 POINTER: Tabelle mit Switchwerten
; \3 STRING: Pointer-Base [pc,a3]
  IFC "","\1"
    FAIL Makro CONVERT_IMAGE_TO_HAM8_CHUNKY: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro CONVERT_IMAGE_TO_HAM8_CHUNKY: Tabelle mit Switchwerten fehlt
  ENDC
  IFC "","\3"
    FAIL Makro CONVERT_IMAGE_TO_HAM8_CHUNKY: Pointer-Base [pc,a3] fehlt
  ENDC
  CNOP 0,4
\1_convert_image_data
  movem.l a3-a6,-(a7)
  MOVEF.W $c0,d3             ;Maske f�r HAM-Bits
  move.w  #$0f0f,d4          ;Maske
  lea     \1_image_data,a0   ;Quellbild
  lea     \1_image_color_table(pc),a1 ;Farbwerte des Playfieldes
  move.l  a7,save_a7(a3)     ;Stackpointer retten
  IFC "","\2"
    lea   \1_color_table(pc),a2
  ELSE
    move.l \2(\3),a2
  ENDC
  move.w  #16,a3             ;COLOR16
  move.w  #32,a4             ;COLOR32
  move.w  #64,a5             ;COLOR64
  move.w  #128,a6            ;COLOR128
  move.w  #\1_image_plane_width*(\1_image_depth-1),a7
  MOVEF.W \1_image_y_size-1,d7 ;H�he des Playfieldes
\1_translate_image_data_loop1
  moveq   #TRUE,d2           ;RGB-Wert zur�cksetzen (COLOR00)
  moveq   #\1_image_plane_width-1,d6 ;Breite des Quellbildes in Bytes
\1_translate_image_data_loop2
  moveq   #8-1,d5            ;Anzahl der Bits pro Byte
\1_translate_image_data_loop3
  moveq   #TRUE,d0           ;Farbnummer
  btst    d5,(a0)            ;Bit n in Bitplane0 gesetzt ?
  beq.s   \1_no_bitplane0    ;Nein -> verzweige
  addq.w  #1,d0              ;Farbnummer erh�hen
\1_no_bitplane0
  btst    d5,\1_image_plane_width*1(a0) ;Bit n in Bitplane1 gesetzt ?
  beq.s   \1_no_bitplane1    ;Nein -> verzweige
  addq.w  #2,d0              ;Farbnummer erh�hen
\1_no_bitplane1
  btst    d5,\1_image_plane_width*2(a0) ;Bit n in Bitplane2 gesetzt ?
  beq.s   \1_no_bitplane2    ;Nein -> verzweige
  addq.w  #4,d0              ;Farbnummer erh�hen
\1_no_bitplane2
  btst    d5,\1_image_plane_width*3(a0) ;Bit n in Bitplane3 gesetzt ?
  beq.s   \1_no_bitplane3    ;Nein -> verzweige
  addq.w  #8,d0              ;Farbnummer erh�hen
\1_no_bitplane3
  btst    d5,\1_image_plane_width*4(a0) ;Bit n in Bitplane4 gesetzt ?
  beq.s   \1_no_bitplane4    ;Nein -> verzweige
  add.w   a3,d0              ;Farbnummer erh�hen
\1_no_bitplane4
  btst    d5,\1_image_plane_width*5(a0) ;Bit n in Bitplane5 gesetzt ?
  beq.s   \1_no_bitplane5    ;Nein -> verzweige
  add.w   a4,d0              ;Farbnummer erh�hen
\1_no_bitplane5
  btst    d5,\1_image_plane_width*6(a0) ;Bit n in Bitplane6 gesetzt ?
  beq.s   \1_no_bitplane6    ;Nein -> verzweige
  add.w   a5,d0              ;Farbnummer erh�hen
\1_no_bitplane6
  btst    d5,\1_image_plane_width*7(a0) ;Bit n in Bitplane7 gesetzt ?
  beq.s   \1_no_bitplane7    ;Nein -> verzweige
  add.w   a6,d0              ;Farbnummer erh�hen
\1_no_bitplane7
  move.l  d0,d1              ;Farbnummer retten
  and.b   d3,d1              ;Bit 6 oder 7 gesetzt ?
  bne.s   \1_check_blue      ;Ja -> verzweige
\1_use_color_register
  move.l  (a1,d0.l*4),d2     ;Farbwert auslesen
  bra.s   \1_set_rgb
  CNOP 0,4
\1_check_blue
  lsl.b   #2,d0              ;Bits in richtige Postion bringen
  cmp.b   #$40,d1            ;Blauanteil �ndern ?
  bne.s   \1_check_red       ;Nein -> verzweige
  move.b  d0,d2              ;Neuen Blauanteil setzen
  bra.s   \1_set_rgb
  CNOP 0,4
\1_check_red
  cmp.b   #$80,d1            ;Rotanteil �ndern ?
  bne.s   \1_check_green     ;Nein -> verzweige
  swap    d2
  move.w  d0,d2              ;Neuen Rotanteil setzen
  swap    d2                 ;Bits in richtige Position bringen
  bra.s   \1_set_rgb
  CNOP 0,4
\1_check_green
  cmp.b   d3,d1              ;Gr�nanteil �ndern ?
  bne.s   \1_set_rgb         ;Nein -> verzweige
  and.l   #$ff00ff,d2        ;Gr�nanteil ausmaskieren
  lsl.w   #8,d0              ;Bits in richtige Position bringen
  or.w    d0,d2              ;Neuen Gr�nanteil setzen
\1_set_rgb
  move.l  d2,d0              ;24-Bit Farbwert holen
  RGB8_TO_RGB4HI d0,d1,d4
  move.w  d0,(a2)+           ;High-Bits
  RGB8_TO_RGB4LO d0,d1,d4
  move.w  d0,(a2)+           ;Low-Bits
  dbf     d5,\1_translate_image_data_loop3
  addq.w  #1,a0              ;N�chstes Byte in Quellbild
  dbf     d6,\1_translate_image_data_loop2
  add.l   a7,a0              ;restliche Bitplanes �berspringen
  dbf     d7,\1_translate_image_data_loop1
  move.l  variables+save_a7(pc),a7 ;Stackpointer holen
  movem.l (a7)+,a3-a6
  rts
  ENDM


CONVERT_IMAGE_TO_BPLCON4_CHUNKY MACRO
; \0 STRING: Gr��enangabe ["B","W"]
; \1 STRING: Labels-Prefix der Routine
; \2 POINTER: Tabelle mit Switchwerten
; \3 STRING: Pointer-Base [pc,a3]
; \4 NUMBER: Start-Swirchwert (optional)
  IFC "","\0"
    FAIL Makro CONVERT_IMAGE_TO_BPLCON4_CHUNKY: Gr��enangabe ["B","W"] fehlt
  ENDC
  IFC "","\1"
    FAIL Makro CONVERT_IMAGE_TO_BPLCON4_CHUNKY: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro CONVERT_IMAGE_TO_BPLCON4_CHUNKY: Tabelle mit Switchwerten fehlt
  ENDC
  IFC "","\3"
    FAIL Makro CONVERT_IMAGE_TO_BPLCON4_CHUNKY: Pointer-Base [pc,a3] fehlt
  ENDC
  CNOP 0,4
\1_convert_image_data
  IFGE \1_image_depth-5
    moveq   #16,d1           ;Bit 4
  ENDC
  IFGE \1_image_depth-6
    moveq   #32,d2           ;Bit 5
  ENDC
  IFGE \1_image_depth-7
    moveq   #64,d3           ;Bit 6
  ENDC
  IFEQ \1_image_depth-8
    MOVEF.W 128,d4           ;Bit 7
  ENDC
  lea     \1_image_data,a0   ;Quellbild
  IFC "","\2"
    lea   \1_switch_table(pc),a1
  ELSE
    move.l \2(\3),a1
  ENDC
  IFGE \1_image_depth-4
    move.w  #\1_image_plane_width*(\1_image_depth-1),a2
  ENDC
  MOVEF.W \1_image_y_size-1,d7 ;H�he des Playfieldes
\1_translate_image_data_loop1
  moveq   #\1_image_plane_width-1,d6 ;Breite des Quellbildes in Bytes
\1_translate_image_data_loop2
  moveq   #8-1,d5            ;Anzahl der Bits pro Byte
\1_translate_image_data_loop3
  IFC "","\4"
    moveq   #TRUE,d0         ;Start-Switchwert = Null
  ELSE
    MOVEF.W \4,d0            ;Start-Switchwert
  ENDC
  IFGE \1_image_depth-1
    btst    d5,(a0)          ;Bit n in Bitplane0 gesetzt ?
    beq.s   \1_no_bitplane0  ;Nein -> verzweige
    addq.w  #1,d0            ;Switchwert erh�hen
\1_no_bitplane0
  ENDC
  IFGE \1_image_depth-2
    btst    d5,\1_image_plane_width*1(a0) ;Bit n in Bitplane1 gesetzt ?
    beq.s   \1_no_bitplane1  ;Nein -> verzweige
    addq.w  #2,d0            ;Switchwert erh�hen
\1_no_bitplane1
  ENDC
  IFGE \1_image_depth-3
    btst    d5,\1_image_plane_width*2(a0) ;Bit n in Bitplane2 gesetzt ?
    beq.s   \1_no_bitplane2  ;Nein -> verzweige
    addq.w  #4,d0            ;Switchwert erh�hen
\1_no_bitplane2
  ENDC
  IFGE \1_image_depth-4
    btst    d5,\1_image_plane_width*3(a0) ;Bit n in Bitplane3 gesetzt ?
    beq.s   \1_no_bitplane3  ;Nein -> verzweige
    addq.w  #8,d0            ;Switchwert erh�hen
\1_no_bitplane3
  ENDC
  IFGE \1_image_depth-5
    btst    d5,\1_image_plane_width*4(a0) ;Bit n in Bitplane4 gesetzt ?
    beq.s   \1_no_bitplane4  ;Nein -> verzweige
    add.w   d1,d0            ;Switchwert erh�hen
\1_no_bitplane4
  ENDC
  IFGE \1_image_depth-6
    btst    d5,\1_image_plane_width*5(a0) ;Bit n in Bitplane5 gesetzt ?
    beq.s   \1_no_bitplane5  ;Nein -> verzweige
    add.w   d2,d0            ;Switchwert erh�hen
\1_no_bitplane5
  ENDC
  IFGE \1_image_depth-7
    btst    d5,\1_image_plane_width*6(a0) ;Bit n in Bitplane6 gesetzt ?
    beq.s   \1_no_bitplane6  ;Nein -> verzweige
    add.w   d3,d0            ;Switchwert erh�hen
\1_no_bitplane6
  ENDC
  IFEQ \1_image_depth-8
    btst    d5,\1_image_plane_width*7(a0) ;Bit n in Bitplane7 gesetzt ?
    beq.s   \1_no_bitplane7  ;Nein -> verzweige
    add.w   d4,d0            ;Switchwert erh�hen
\1_no_bitplane7
  ENDC
  IFC "B","\0"
    move.b  d0,(a1)+         ;Switchwert eintragen
  ENDC
  IFC "W","\0"
    move.b  d0,(a1)+         ;Switchwert eintragen
    move.b  #BPLCON4BITS&FALSEB,(a1)+
  ENDC
  dbf     d5,\1_translate_image_data_loop3
  addq.w  #1,a0              ;N�chstes Byte in Quellbild
  dbf     d6,\1_translate_image_data_loop2
  add.l   a2,a0              ;restliche Bitplanes �berspringen
  dbf     d7,\1_translate_image_data_loop1
  rts
  ENDM


; -- Raster routines

SWAP_COPPERLIST MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 NUMBER: Anzahl der Copperlisten [2,3]
; \3 STRING: "NOSET" Keine Pointer setzen (optional)
  IFC "","\1"
    FAIL Makro SWAP_COPPERLIST: Labels-Prefix fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SWAP_COPPERLIST: Anzahl der Copperlisten [2,3] fehlt
  ENDC
  CNOP 0,4
  IFC "cl1","\1"
swap_first_copperlist
    IFEQ \2-2
      move.l  \1_construction2(a3),a0
      move.l  \1_display(a3),\1_construction2(a3)
      move.l  a0,\1_display(a3)
      IFNC "NOSET","\3"
        move.l  a0,COP1LC-DMACONR(a6)
      ENDC
      rts
    ENDC
    IFEQ \2-3
      move.l  \1_construction1(a3),a0
      move.l  \1_display(a3),\1_construction1(a3)
      move.l  \1_construction2(a3),a1
      move.l  a0,\1_construction2(a3)
      move.l  a1,\1_display(a3)
      IFNC "NOSET","\3"
        move.l  a1,COP1LC-DMACONR(a6)
      ENDC
      rts
    ENDC
  ENDC
  IFC "cl2","\1"
swap_second_copperlist
    IFEQ \2-2
      move.l  \1_construction2(a3),a0
      move.l  \1_display(a3),\1_construction2(a3)
      move.l  a0,\1_display(a3)
      IFNC "NOSET","\3"
        move.l  a0,COP2LC-DMACONR(a6)
      ENDC
      rts
    ENDC
    IFEQ \2-3
      move.l  \1_construction1(a3),a0
      move.l  \1_display(a3),\1_construction1(a3)
      move.l  \1_construction2(a3),a1
      move.l  a0,\1_construction2(a3)
      move.l  a1,\1_display(a3)
      IFNC "NOSET","\3"
        move.l  a1,COP2LC-DMACONR(a6)
      ENDC
      rts
    ENDC
  ENDC
  ENDM


CLEAR_COLOR00_SCREEN MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: Label-Prefix Copperliste [cl1,cl2]
; \3 STRING: Name der Copperliste [construction1,construction2]
; \4 STRING: extension[1..n]
; \5 NUMBER: Anzahl der Befehle pro Schleifendurchlauf [16,32]
  IFC "","\1"
    FAIL Makro CLEAR_COLOR00_SCREEN: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro CLEAR_COLOR00_SCREEN: Label-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro CLEAR_COLOR00_SCREEN: Name der Copperliste [construction1,construction2] fehlt
  ENDC
  IFC "","\4"
    FAIL Makro CLEAR_COLOR00_SCREEN: Angabe extension[1..n] fehlt
  ENDC
  IFC "","\5"
    FAIL Makro CLEAR_COLOR00_SCREEN: Anzahl der Befehle pro Schleifendurchlauf fehlt
  ENDC
  CNOP 0,4
  IFC "cl1","\2"
\1_clear_first_copperlist
    IFC "16","\5"
      move.w  #COLOR00HIGHBITS,d0
      move.w  #COLOR00LOWBITS,d1
      MOVEF.L \2_\4_SIZE*16,d2
      move.l  \2_\3(a3),a0 
      ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+2,a0
      moveq   #(\2_display_y_size/16)-1,d7
\1_clear_first_copperlist_loop
      move.w  d0,(a0)            ;COLOR00 high
      move.w  d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ;COLOR00 low
      move.w  d0,\2_\4_SIZE*1(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*1)(a0)
      move.w  d0,\2_\4_SIZE*2(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*2)(a0)
      move.w  d0,\2_\4_SIZE*3(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*3)(a0)
      move.w  d0,\2_\4_SIZE*4(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*4)(a0)
      move.w  d0,\2_\4_SIZE*5(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*5)(a0)
      move.w  d0,\2_\4_SIZE*6(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*6)(a0)
      move.w  d0,\2_\4_SIZE*7(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*7)(a0)
      move.w  d0,\2_\4_SIZE*8(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*8)(a0)
      move.w  d0,\2_\4_SIZE*9(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*9)(a0)
      move.w  d0,\2_\4_SIZE*10(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*10)(a0)
      move.w  d0,\2_\4_SIZE*11(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*11)(a0)
      move.w  d0,\2_\4_SIZE*12(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*12)(a0)
      move.w  d0,\2_\4_SIZE*13(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*13)(a0)
      move.w  d0,\2_\4_SIZE*14(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*14)(a0)
      move.w  d0,\2_\4_SIZE*15(a0)
      add.l   d2,a0              ;n�chste Zeile in CL
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*15)-(\2_\4_SIZE*16)(a0)
      dbf     d7,\1_clear_first_copperlist_loop
      rts
    ENDC
    IFC "32","\5"
      move.w  #COLOR00HIGHBITS,d0
      move.w  #COLOR00LOWBITS,d1
      MOVEF.L \2_\4_SIZE*32,d2
      move.l  \2_\3(a3),a0 
      ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+2,a0
      moveq   #(\2_display_y_size/32)-1,d7
\1_clear_first_copperlist_loop
      move.w  d0,(a0)            ;COLOR00 high
      move.w  d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ;COLOR00 low
      move.w  d0,\2_\4_SIZE*1(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*1)(a0)
      move.w  d0,\2_\4_SIZE*2(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*2)(a0)
      move.w  d0,\2_\4_SIZE*3(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*3)(a0)
      move.w  d0,\2_\4_SIZE*4(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*4)(a0)
      move.w  d0,\2_\4_SIZE*5(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*5)(a0)
      move.w  d0,\2_\4_SIZE*6(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*6)(a0)
      move.w  d0,\2_\4_SIZE*7(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*7)(a0)
      move.w  d0,\2_\4_SIZE*8(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*8)(a0)
      move.w  d0,\2_\4_SIZE*9(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*9)(a0)
      move.w  d0,\2_\4_SIZE*10(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*10)(a0)
      move.w  d0,\2_\4_SIZE*11(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*11)(a0)
      move.w  d0,\2_\4_SIZE*12(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*12)(a0)
      move.w  d0,\2_\4_SIZE*13(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*13)(a0)
      move.w  d0,\2_\4_SIZE*14(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*14)(a0)
      move.w  d0,\2_\4_SIZE*15(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*15)(a0)
      move.w  d0,\2_\4_SIZE*16(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*16)(a0)
      move.w  d0,\2_\4_SIZE*17(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*17)(a0)
      move.w  d0,\2_\4_SIZE*18(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*18)(a0)
      move.w  d0,\2_\4_SIZE*19(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*19)(a0)
      move.w  d0,\2_\4_SIZE*20(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*20)(a0)
      move.w  d0,\2_\4_SIZE*21(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*21)(a0)
      move.w  d0,\2_\4_SIZE*22(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*22)(a0)
      move.w  d0,\2_\4_SIZE*23(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*23)(a0)
      move.w  d0,\2_\4_SIZE*24(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*24)(a0)
      move.w  d0,\2_\4_SIZE*25(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*25)(a0)
      move.w  d0,\2_\4_SIZE*26(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*26)(a0)
      move.w  d0,\2_\4_SIZE*27(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*27)(a0)
      move.w  d0,\2_\4_SIZE*28(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*28)(a0)
      move.w  d0,\2_\4_SIZE*29(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*29)(a0)
      move.w  d0,\2_\4_SIZE*30(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*30)(a0)
      move.w  d0,\2_\4_SIZE*31(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*31)(a0)
      move.w  d0,\2_\4_SIZE*32(a0)
      add.l   d2,a0              ;n�chste Zeile in CL
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*15)-(\2_\4_SIZE*32)(a0)
      dbf     d7,\1_clear_first_copperlist_loop
      rts
    ENDC
  ENDC
  IFC "cl2","\2"
\1_clear_second_copperlist
    IFC "16","\5"
      move.w  #COLOR00HIGHBITS,d0
      move.w  #COLOR00LOWBITS,d1
      MOVEF.L \2_\4_SIZE*16,d2
      move.l  \2_\3(a3),a0 
      ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+2,a0
      moveq   #(\2_display_y_size/16)-1,d7
\1_clear_second_copperlist_loop
      move.w  d0,(a0)            ;COLOR00 high
      move.w  d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ;COLOR00 low
      move.w  d0,\2_\4_SIZE*1(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*1)(a0)
      move.w  d0,\2_\4_SIZE*2(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*2)(a0)
      move.w  d0,\2_\4_SIZE*3(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*3)(a0)
      move.w  d0,\2_\4_SIZE*4(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*4)(a0)
      move.w  d0,\2_\4_SIZE*5(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*5)(a0)
      move.w  d0,\2_\4_SIZE*6(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*6)(a0)
      move.w  d0,\2_\4_SIZE*7(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*7)(a0)
      move.w  d0,\2_\4_SIZE*8(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*8)(a0)
      move.w  d0,\2_\4_SIZE*9(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*9)(a0)
      move.w  d0,\2_\4_SIZE*10(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*10)(a0)
      move.w  d0,\2_\4_SIZE*11(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*11)(a0)
      move.w  d0,\2_\4_SIZE*12(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*12)(a0)
      move.w  d0,\2_\4_SIZE*13(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*13)(a0)
      move.w  d0,\2_\4_SIZE*14(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*14)(a0)
      move.w  d0,\2_\4_SIZE*15(a0)
      add.l   d2,a0              ;n�chste Zeile in CL
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*15)-(\2_\4_SIZE*16)(a0)
      dbf     d7,\1_clear_second_copperlist_loop
      rts
    ENDC
    IFC "32","\5"
      move.w  #COLOR00HIGHBITS,d0
      move.w  #COLOR00LOWBITS,d1
      MOVEF.L \2_\4_SIZE*32,d2
      move.l  \2_\3(a3),a0 
      ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+2,a0
      moveq   #(\2_display_y_size/32)-1,d7
\1_clear_second_copperlist_loop
      move.w  d0,(a0)            ;COLOR00 high
      move.w  d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ;COLOR00 low
      move.w  d0,\2_\4_SIZE*1(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*1)(a0)
      move.w  d0,\2_\4_SIZE*2(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*2)(a0)
      move.w  d0,\2_\4_SIZE*3(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*3)(a0)
      move.w  d0,\2_\4_SIZE*4(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*4)(a0)
      move.w  d0,\2_\4_SIZE*5(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*5)(a0)
      move.w  d0,\2_\4_SIZE*6(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*6)(a0)
      move.w  d0,\2_\4_SIZE*7(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*7)(a0)
      move.w  d0,\2_\4_SIZE*8(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*8)(a0)
      move.w  d0,\2_\4_SIZE*9(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*9)(a0)
      move.w  d0,\2_\4_SIZE*10(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*10)(a0)
      move.w  d0,\2_\4_SIZE*11(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*11)(a0)
      move.w  d0,\2_\4_SIZE*12(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*12)(a0)
      move.w  d0,\2_\4_SIZE*13(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*13)(a0)
      move.w  d0,\2_\4_SIZE*14(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*14)(a0)
      move.w  d0,\2_\4_SIZE*15(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*15)(a0)
      move.w  d0,\2_\4_SIZE*16(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*16)(a0)
      move.w  d0,\2_\4_SIZE*17(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*17)(a0)
      move.w  d0,\2_\4_SIZE*18(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*18)(a0)
      move.w  d0,\2_\4_SIZE*19(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*19)(a0)
      move.w  d0,\2_\4_SIZE*20(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*20)(a0)
      move.w  d0,\2_\4_SIZE*21(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*21)(a0)
      move.w  d0,\2_\4_SIZE*22(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*22)(a0)
      move.w  d0,\2_\4_SIZE*23(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*23)(a0)
      move.w  d0,\2_\4_SIZE*24(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*24)(a0)
      move.w  d0,\2_\4_SIZE*25(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*25)(a0)
      move.w  d0,\2_\4_SIZE*26(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*26)(a0)
      move.w  d0,\2_\4_SIZE*27(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*27)(a0)
      move.w  d0,\2_\4_SIZE*28(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*28)(a0)
      move.w  d0,\2_\4_SIZE*29(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*29)(a0)
      move.w  d0,\2_\4_SIZE*30(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*30)(a0)
      move.w  d0,\2_\4_SIZE*31(a0)
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*31)(a0)
      move.w  d0,\2_\4_SIZE*32(a0)
      add.l   d2,a0              ;n�chste Zeile in CL
      move.w  d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_SIZE*15)-(\2_\4_SIZE*32)(a0)
      dbf     d7,\1_clear_second_copperlist_loop
      rts
    ENDC
  ENDC
  ENDM


CLEAR_BPLCON4_CHUNKY_SCREEN MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: Label-Prefix Copperliste [cl1,cl2]
; \3 STRING: Name der Copperliste [construction1,construction2]
; \4 STRING: extension[1..n]
; \5 BOOLEAN: TRUE = quick_clear
  IFC "","\1"
    FAIL Makro CLEAR_CHUNKY_SCREEN: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro CLEAR_CHUNKY_SCREEN: Label-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro CLEAR_CHUNKY_SCREEN: Name der Copperliste [construction1,construction2] fehlt
  ENDC
  IFC "","\4"
    FAIL Makro CLEAR_CHUNKY_SCREEN: Angabe extension[1..n] fehlt
  ENDC
  IFC "","\5"
    FAIL Makro CLEAR_CHUNKY_SCREEN: Boolean zu quick clear fehlt
  ENDC
  CNOP 0,4
  IFC "cl1","\2"
\1_clear_first_copperlist
    move.l  \2_\3(a3),a0 
    WAITBLITTER
    move.l  #(BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
    moveq   #FALSE,d0
    move.l  d0,BLTAFWM-DMACONR(a6) ;Maske aus
    ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
    move.l  a0,BLTDPT-DMACONR(a6) ;Ziel = Copperliste
    moveq   #2,d0
    move.w  d0,BLTDMOD-DMACONR(a6) ;D-Mod
    IFEQ \1_\5
      moveq   #-2,d0 
    ELSE
      MOVEF.W BPLCON4BITS,d0
    ENDC
    move.w  d0,BLTADAT-DMACONR(a6) ;Quelle = BPLCON4-Bits
    move.l  #(\1_clear_blit_y_size<<16)+(\1_clear_blit_x_size/16),BLTSIZV-DMACONR(a6) ;Blitter starten
    rts
  ENDC
  IFC "cl2","\2"
\1_clear_second_copperlist
    move.l  \2_\3(a3),a0 
    WAITBLITTER
    move.l  #(BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
    moveq   #FALSE,d0
    move.l  d0,BLTAFWM-DMACONR(a6) ;Maske aus
    ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
    move.l  a0,BLTDPT-DMACONR(a6) ;Ziel = Copperliste
    moveq   #2,d0
    move.w  d0,BLTDMOD-DMACONR(a6) ;D-Mod
    IFEQ \1_\5
      moveq   #-2,d0 
    ELSE
      MOVEF.W BPLCON4BITS,d0
    ENDC
    move.w  d0,BLTADAT-DMACONR(a6) ;Quelle = BPLCON4-Bits
    move.l  #(\1_clear_blit_y_size<<16)+(\1_clear_blit_x_size/16),BLTSIZV-DMACONR(a6) ;Blitter starten
    rts
  ENDC
  ENDM


RESTORE_BPLCON4_CHUNKY_SCREEN MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: Label-Prefix Copperliste [cl1,cl2]
; \3 STRING: Name der Copperliste [construction1,construction2]
; \4 STRING: extension[1..n]
; \5 NUMBER: Anzahl der Befehle pro Schleifendurchlauf [16,32]
; \6 LABEL:  Sub-Routine zum L�schen durch die CPU (optional)
; \7 LABEL:  Sub-Routine zum L�schen durch den Blitter (optional)
  IFC "","\1"
    FAIL Makro RESTORE_BPLCON4_CHUNKY_SCREEN: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro RESTORE_BPLCON4_CHUNKY_SCREEN: Label-Prefix Copperliste [cl1,cl2] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro RESTORE_BPLCON4_CHUNKY_SCREEN: Name der Copperliste [construction1,construction2] fehlt
  ENDC
  IFC "","\4"
    FAIL Makro RESTORE_BPLCON4_CHUNKY_SCREEN: Angabe extension[1..n] fehlt
  ENDC
  IFC "","\5"
    FAIL Makro RESTORE_BPLCON4_CHUNKY_SCREEN: Anzahl der Befehle pro Schleifendurchlauf [16,32] fehlt
  ENDC
  CNOP 0,4
  IFC "cl1","\2"
restore_first_copperlist
    IFEQ \1_restore_cl_by_cpu
      IFC "","\6"
        IFC "16","\5"
          moveq   #-2,d0       ;2. Wort des WAIT-Befehls
          MOVEF.L \2_\4_SIZE*16,d1
          move.l  \2_\3(a3),a0 
          ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
          moveq   #(\2_display_y_size/16)-1,d7
restore_first_copperlist_loop
          move.w  d0,(a0)      ;WAIT-Befehl wieder herstellen
          move.w  d0,\2_\4_SIZE*1(a0)
          move.w  d0,\2_\4_SIZE*2(a0)
          move.w  d0,\2_\4_SIZE*3(a0)
          move.w  d0,\2_\4_SIZE*4(a0)
          move.w  d0,\2_\4_SIZE*5(a0)
          move.w  d0,\2_\4_SIZE*6(a0)
          move.w  d0,\2_\4_SIZE*7(a0)
          move.w  d0,\2_\4_SIZE*8(a0)
          move.w  d0,\2_\4_SIZE*9(a0)
          move.w  d0,\2_\4_SIZE*10(a0)
          move.w  d0,\2_\4_SIZE*11(a0)
          move.w  d0,\2_\4_SIZE*12(a0)
          move.w  d0,\2_\4_SIZE*13(a0)
          move.w  d0,\2_\4_SIZE*14(a0)
          move.w  d0,\2_\4_SIZE*15(a0)
          add.l   d1,a0              ;16 Zeilen �berspringen
          move.w  d0,(\2_\4_SIZE*15)-(\2_\4_SIZE*16)(a0)
          dbf     d7,restore_first_copperlist_loop
          rts
        ENDC
        IFC "32","\5"
          moveq   #-2,d0             ;2. Wort des WAIT-Befehls
          MOVEF.L \2_\4_SIZE*32,d1
          move.l  \2_\3(a3),a0 
          ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
          moveq   #(\2_display_y_size/32)-1,d7
restore_first_copperlist_loop
          move.w  d0,(a0)            ;WAIT-Befehl wieder herstellen
          move.w  d0,\2_\4_SIZE*1(a0)
          move.w  d0,\2_\4_SIZE*2(a0)
          move.w  d0,\2_\4_SIZE*3(a0)
          move.w  d0,\2_\4_SIZE*4(a0)
          move.w  d0,\2_\4_SIZE*5(a0)
          move.w  d0,\2_\4_SIZE*6(a0)
          move.w  d0,\2_\4_SIZE*7(a0)
          move.w  d0,\2_\4_SIZE*8(a0)
          move.w  d0,\2_\4_SIZE*9(a0)
          move.w  d0,\2_\4_SIZE*10(a0)
          move.w  d0,\2_\4_SIZE*11(a0)
          move.w  d0,\2_\4_SIZE*12(a0)
          move.w  d0,\2_\4_SIZE*13(a0)
          move.w  d0,\2_\4_SIZE*14(a0)
          move.w  d0,\2_\4_SIZE*15(a0)
          move.w  d0,\2_\4_SIZE*16(a0)
          move.w  d0,\2_\4_SIZE*17(a0)
          move.w  d0,\2_\4_SIZE*18(a0)
          move.w  d0,\2_\4_SIZE*19(a0)
          move.w  d0,\2_\4_SIZE*20(a0)
          move.w  d0,\2_\4_SIZE*21(a0)
          move.w  d0,\2_\4_SIZE*22(a0)
          move.w  d0,\2_\4_SIZE*23(a0)
          move.w  d0,\2_\4_SIZE*24(a0)
          move.w  d0,\2_\4_SIZE*25(a0)
          move.w  d0,\2_\4_SIZE*26(a0)
          move.w  d0,\2_\4_SIZE*27(a0)
          move.w  d0,\2_\4_SIZE*28(a0)
          move.w  d0,\2_\4_SIZE*29(a0)
          move.w  d0,\2_\4_SIZE*30(a0)
          add.l   d1,a0              ;32 Zeilen �berspringen
          move.w  d0,(\2_\4_SIZE*31)-(\2_\4_SIZE*32)(a0)
          dbf     d7,restore_first_copperlist_loop
          rts
        ENDC
      ENDC
    ENDC
    IFEQ \1_restore_cl_by_blitter
      IFC "","\7"
        move.l  \2_\3(a3),a0   
        WAITBLITTER
        ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
        move.l  a0,BLTDPT-DMACONR(a6) ;Ziel = Copperliste
        move.w  #\2_\4_SIZE-\1_restore_blit_width,BLTDMOD-DMACONR(a6) ;D-Mod
        moveq   #-2,d0         ;2. Wort des Wait-Befehls
        move.w  d0,BLTADAT-DMACONR(a6) ;Quelle = 2. Wort von CWAIT
        move.w  #(\1_restore_blit_y_size*64)+(\1_restore_blit_x_size/16),BLTSIZE-DMACONR(a6) ;Anzahl der Zeilen
        rts
      ENDC
    ENDC
  ENDC
  IFC "cl2","\2"
restore_second_copperlist
    IFEQ \1_restore_cl_by_cpu
      IFC "","\6"
        IFC "16","\5"
          moveq   #-2,d0       ;2. Wort des WAIT-Befehls
          MOVEF.L \2_\4_SIZE*16,d1
          move.l  \2_\3(a3),a0 
          ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
          moveq   #(\2_display_y_size/16)-1,d7
restore_second_copperlist_loop
          move.w  d0,(a0)      ;WAIT-Befehl wieder herstellen
          move.w  d0,\2_\4_SIZE*1(a0)
          move.w  d0,\2_\4_SIZE*2(a0)
          move.w  d0,\2_\4_SIZE*3(a0)
          move.w  d0,\2_\4_SIZE*4(a0)
          move.w  d0,\2_\4_SIZE*5(a0)
          move.w  d0,\2_\4_SIZE*6(a0)
          move.w  d0,\2_\4_SIZE*7(a0)
          move.w  d0,\2_\4_SIZE*8(a0)
          move.w  d0,\2_\4_SIZE*9(a0)
          move.w  d0,\2_\4_SIZE*10(a0)
          move.w  d0,\2_\4_SIZE*11(a0)
          move.w  d0,\2_\4_SIZE*12(a0)
          move.w  d0,\2_\4_SIZE*13(a0)
          move.w  d0,\2_\4_SIZE*14(a0)
          move.w  d0,\2_\4_SIZE*15(a0)
          add.l   d1,a0              ;16 Zeilen �berspringen
          move.w  d0,(\2_\4_SIZE*15)-(\2_\4_SIZE*16)(a0)
          dbf     d7,restore_second_copperlist_loop
          rts
        ENDC
        IFC "32","\5"
          moveq   #-2,d0             ;2. Wort des WAIT-Befehls
          MOVEF.L \2_\4_SIZE*32,d1
          move.l  \2_\3(a3),a0 
          ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
          moveq   #(\2_display_y_size/32)-1,d7
restore_second_copperlist_loop
          move.w  d0,(a0)            ;WAIT-Befehl wieder herstellen
          move.w  d0,\2_\4_SIZE*1(a0)
          move.w  d0,\2_\4_SIZE*2(a0)
          move.w  d0,\2_\4_SIZE*3(a0)
          move.w  d0,\2_\4_SIZE*4(a0)
          move.w  d0,\2_\4_SIZE*5(a0)
          move.w  d0,\2_\4_SIZE*6(a0)
          move.w  d0,\2_\4_SIZE*7(a0)
          move.w  d0,\2_\4_SIZE*8(a0)
          move.w  d0,\2_\4_SIZE*9(a0)
          move.w  d0,\2_\4_SIZE*10(a0)
          move.w  d0,\2_\4_SIZE*11(a0)
          move.w  d0,\2_\4_SIZE*12(a0)
          move.w  d0,\2_\4_SIZE*13(a0)
          move.w  d0,\2_\4_SIZE*14(a0)
          move.w  d0,\2_\4_SIZE*15(a0)
          move.w  d0,\2_\4_SIZE*16(a0)
          move.w  d0,\2_\4_SIZE*17(a0)
          move.w  d0,\2_\4_SIZE*18(a0)
          move.w  d0,\2_\4_SIZE*19(a0)
          move.w  d0,\2_\4_SIZE*20(a0)
          move.w  d0,\2_\4_SIZE*21(a0)
          move.w  d0,\2_\4_SIZE*22(a0)
          move.w  d0,\2_\4_SIZE*23(a0)
          move.w  d0,\2_\4_SIZE*24(a0)
          move.w  d0,\2_\4_SIZE*25(a0)
          move.w  d0,\2_\4_SIZE*26(a0)
          move.w  d0,\2_\4_SIZE*27(a0)
          move.w  d0,\2_\4_SIZE*28(a0)
          move.w  d0,\2_\4_SIZE*29(a0)
          move.w  d0,\2_\4_SIZE*30(a0)
          add.l   d1,a0              ;32 Zeilen �berspringen
          move.w  d0,(\2_\4_SIZE*31)-(\2_\4_SIZE*32)(a0)
          dbf     d7,restore_second_copperlist_loop
          rts
        ENDC
      ENDC
    ENDC
    IFEQ \1_restore_cl_by_blitter
      IFC "","\7"
        move.l  \2_\3(a3),a0   
        WAITBLITTER
        ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+2,a0
        move.l  a0,BLTDPT-DMACONR(a6) ;Ziel = Copperliste
        move.w  #\2_\4_SIZE-\1_restore_blit_width,BLTDMOD-DMACONR(a6) ;D-Mod
        moveq   #-2,d0         ;2. Wort des Wait-Befehls
        move.w  d0,BLTADAT-DMACONR(a6) ;Quelle = 2. Wort von CWAIT
        move.w  #(\1_restore_blit_y_size*64)+(\1_restore_blit_x_size/16),BLTSIZE-DMACONR(a6) ;Anzahl der Zeilen
        rts
      ENDC
    ENDC
  ENDC
  ENDM


SET_TWISTED_BACKGROUND_BARS MACRO
; \0 STRING: Gr��enangabe ["B","W"]
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: Label-Prefix Copperliste ["cl1","cl2"]
; \3 STRING: Name der Copperliste ["construction2","construction3"]
; \4 STRING: "extension[1..n]"
; \5 NUMBER: H�he der Bar [32,48]
; \6 POINTER: Tabelle mit Switchwerten
; \7 STRING: Pointer-Base [pc,a3]
; \8 WORD: Offset Tabellenanfang (optional)
; \9 STRING: "45" (optional)
  IFC "","\0"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: Gr��enangabe ["B","W"] fehlt
  ENDC
  IFC "","\1"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: Label-Prefix Copperliste ["cl1","cl2"] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: Name der Copperliste ["construction2","construction3"] fehlt
  ENDC
  IFC "","\4"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: "extension[1..n]" fehlt
  ENDC
  IFC "","\5"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: H�he der Bar [32,48] fehlt
  ENDC
  IFC "","\6"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: H�he der Bar Tabelle mit Switchwerten fehlt
  ENDC
  IFC "","\7"
    FAIL Makro SET_TWISTED_BACKGROUND_BARS: Pointer-Base [pc,a3] fehlt
  ENDC
  CNOP 0,4
\1_set_background_bars
  movem.l a4-a5,-(a7)
  IFC "B","\0"
    moveq   #\1_bar_height*BYTESIZE,d4
  ENDC
  lea     \1_yz_coordinates(pc),a0 ;Zeiger auf YZ-Koords
  move.l  \2_\3(a3),a2       
  ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_BPLCON4_1+2,a2
  IFC "pc","\7"
    lea   \1_\6(\7),a5       ;Zeiger auf Tabelle mit Switchwerten
  ENDC
  IFC "a3","\7"
    move.l \6(\7),a5         ;Zeiger auf Tabelle mit Switchwerten
  ENDC
  IFNC "","\8"
    add.l  #\8*BYTESIZE,a5   ;Offset Tabellenanfamg
  ENDC
  IFC "45","\9"
    moveq   #(\2_display_width)-1-1,d7 ;Anzahl der Spalten
  ELSE
    moveq   #\2_display_width-1,d7 ;Anzahl der Spalten
  ENDC
\1_set_background_bars_loop1
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  moveq   #\1_bars_number-1,d6 ;Anzahl der Stangen
\1_set_background_bars_loop2
  move.l  (a0)+,d0           ;Z + Y lesen
  IFC "B","\0"
    bmi     \1_skip_background_bar ;Wenn Z negativ -> verzweige
  ENDC
  IFC "W","\0"
    bmi     \1_no_background_bar ;Wenn Z negativ -> verzweige
  ENDC
\1_set_background_bar
  lea     (a2,d0.w*4),a4     ;Y-Offset
  COPY_TWISTED_BAR.\0 \1,\2,\4,\5
\1_no_background_bar
  dbf     d6,\1_set_background_bars_loop2
  addq.w  #4,a2              ;n�chste Spalte in CL
  dbf     d7,\1_set_background_bars_loop1
  movem.l (a7)+,a4-a5
  rts
  IFC "B","\0"
    CNOP 0,4
\1_skip_background_bar
    add.l   d4,a1              ;Switchwerte �berspringen
    bra.s   \1_no_background_bar
  ENDC
  ENDM


SET_TWISTED_FOREGROUND_BARS MACRO
; \0 STRING: Gr��enangabe B/W
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: [cl1,cl2]
; \3 STRING: construction[2,3]
; \4 STRING: extension[1..n]
; \5 NUMBER: H�he der Bar [32, 48]
; \6 POINTER: Tabelle mit Switchwerten
; \7 STRING: Pointer-Base [pc, a3]
; \8 WORD: Offset Tabellenanfang (optional)
; \9 STRING: "45" (optional)
  IFC "","\0"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: Gr��enangabe ["B","W"] fehlt
  ENDC
  IFC "","\1"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: Label-Prefix Copperliste ["cl1","cl2"] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: Name der Copperliste ["construction2","construction3"] fehlt
  ENDC
  IFC "","\4"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: "extension[1..n]" fehlt
  ENDC
  IFC "","\5"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: H�he der Bar [32,48] fehlt
  ENDC
  IFC "","\6"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: H�he der Bar Tabelle mit Switchwerten fehlt
  ENDC
  IFC "","\7"
    FAIL Makro SET_TWISTED_FOREGROUND_BARS: Pointer-Base [pc,a3] fehlt
  ENDC
  CNOP 0,4
\1_set_foreground_bars
  movem.l a4-a5,-(a7)
  IFC "B","\0"
    moveq   #\1_bar_height*BYTESIZE,d4
  ENDC
  lea     \1_yz_coordinates(pc),a0 ;Zeiger auf YZ-Koords
  move.l  \2_\3(a3),a2       
  ADDF.W  \2_\4_entry+\2_ext\*RIGHT(\4,1)_BPLCON4_1+2,a2
  IFC "pc","\7"
    lea   \1_\6(\7),a5       ;Zeiger auf Tabelle mit Switchwerten
  ENDC
  IFC "a3","\7"
    move.l \6(\7),a5         ;Zeiger auf Tabelle mit Switchwerten
  ENDC
  IFNC "","\8"
    add.l  #\8,a5            ;Offset Tabellenanfang
  ENDC
  IFC "45","\9"
    moveq   #(\2_display_width)-1-1,d7 ;Anzahl der Spalten
  ELSE
    moveq   #\2_display_width-1,d7 ;Anzahl der Spalten
  ENDC
\1_set_foreground_bars_loop1
  move.l  a5,a1              ;Zeiger auf Tabelle mit Switchwerten
  moveq   #\1_bars_number-1,d6 ;Anzahl der Stangen
\1_set_foreground_bars_loop2
  move.l  (a0)+,d0           ;Z + Y lesen
  IFC "B","\0"
    bpl     \1_skip_foreground_bar ;Wenn Z positiv -> verzweige
  ENDC
  IFC "W","\0"
    bpl     \1_no_foreground_bar ;Wenn Z positiv -> verzweige
  ENDC
\1_set_foreground_bar
  lea     (a2,d0.w*4),a4     ;Y-Offset
  COPY_TWISTED_BAR.\0 \1,\2,\4,\5
\1_no_foreground_bar
  dbf     d6,\1_set_foreground_bars_loop2
  addq.w  #4,a2              ;n�chste Spalte in CL
  dbf     d7,\1_set_foreground_bars_loop1
  movem.l (a7)+,a4-a5
  rts
  IFC "B","\0"
    CNOP 0,4
\1_skip_foreground_bar
    add.l   d4,a1              ;Switchwerte �berspringen
    bra.s   \1_no_foreground_bar
  ENDC
  ENDM


COPY_TWISTED_BAR MACRO
; \0 STRING: Gr��enangabe ["B","W"]
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: ["cl1","cl2"]
; \3 STRING: "extension[1..n]"
; \4 NUMBER: H�he der Bar [32,48]
  IFC "","\0"
    FAIL Makro COPY_TWISTED_BAR: Gr��enangabe B/W fehlt
  ENDC
  IFC "","\0"
    FAIL Makro COPY_TWISTED_BAR: Gr��enangabe ["B","W"] fehlt
  ENDC
  IFC "","\1"
    FAIL Makro COPY_TWISTED_BAR: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro COPY_TWISTED_BAR: Label-Prefix Copperliste ["cl1","cl2"] fehlt
  ENDC
  IFC "","\3"
    FAIL Makro COPY_TWISTED_BAR: "extension[1..n]" fehlt
  ENDC
  IFC "","\4"
    FAIL Makro COPY_TWISTED_BAR: H�he der Bar [32,48] fehlt
  ENDC
  IFC "B","\0"
    IFEQ \1_\4-15
      movem.l (a1),d0-d3         ;15 Switchwerte lesen
      move.b  d0,\2_\3_SIZE*3(a4)
      lsr.w   #8,d0
      move.b  d0,\2_\3_SIZE*2(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*1(a4)
      lsr.w   #8,d0
      move.b  d0,(a4)
      move.b  d1,\2_\3_SIZE*7(a4)
      lsr.w   #8,d1
      move.b  d1,\2_\3_SIZE*6(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*5(a4)
      lsr.w   #8,d1
      move.b  d1,\2_\3_SIZE*4(a4)
      move.b  d2,\2_\3_SIZE*11(a4)
      lsr.w   #8,d2
      move.b  d2,\2_\3_SIZE*10(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*9(a4)
      lsr.w   #8,d2
      move.b  d2,\2_\3_SIZE*8(a4)
      lsr.w   #8,d3
      move.b  d3,\2_\3_SIZE*14(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*13(a4)
      lsr.w   #8,d3
      move.b  d3,\2_\3_SIZE*12(a4)
    ENDC
    IFEQ \1_\4-32
      movem.l (a1)+,d0-d3      ;16 Switchwerte lesen
      move.b  d0,\2_\3_SIZE*3(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*1(a4)
      lsr.l   #8,d0
      move.b  d0,(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*2(a4)
      move.b  d1,\2_\3_SIZE*7(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*5(a4)
      lsr.l   #8,d1
      move.b  d1,\2_\3_SIZE*4(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*6(a4)
      move.b  d2,\2_\3_SIZE*11(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*9(a4)
      lsr.l   #8,d2
      move.b  d2,\2_\3_SIZE*8(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*10(a4)
      move.b  d3,\2_\3_SIZE*15(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*13(a4)
      lsr.l   #8,d3
      move.b  d3,\2_\3_SIZE*12(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*14(a4)
      movem.l (a1)+,d0-d3      ;weitere 16 Switchwerte lesen
      move.b  d0,\2_\3_SIZE*19(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*17(a4)
      lsr.l   #8,d0
      move.b  d0,\2_\3_SIZE*16(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*18(a4)
      move.b  d1,\2_\3_SIZE*23(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*21(a4)
      lsr.l   #8,d1
      move.b  d1,\2_\3_SIZE*20(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*22(a4)
      move.b  d2,\2_\3_SIZE*27(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*25(a4)
      lsr.l   #8,d2
      move.b  d2,\2_\3_SIZE*24(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*26(a4)
      move.b  d3,\2_\3_SIZE*31(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*29(a4)
      lsr.l   #8,d3
      move.b  d3,\2_\3_SIZE*28(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*30(a4)
    ENDC
    IFEQ \1_\4-48
      movem.l (a1)+,d0-d3        ;16 Switchwerte lesen
      move.b  d0,\2_\3_SIZE*3(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*1(a4)
      lsr.l   #8,d0
      move.b  d0,(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*2(a4)
      move.b  d1,\2_\3_SIZE*7(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*5(a4)
      lsr.l   #8,d1
      move.b  d1,\2_\3_SIZE*4(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*6(a4)
      move.b  d2,\2_\3_SIZE*11(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*9(a4)
      lsr.l   #8,d2
      move.b  d2,\2_\3_SIZE*8(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*10(a4)
      move.b  d3,\2_\3_SIZE*15(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*13(a4)
      lsr.l   #8,d3
      move.b  d3,\2_\3_SIZE*12(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*14(a4)
      movem.l (a1)+,d0-d3        ;weitere 16 Switchwerte lesen
      move.b  d0,\2_\3_SIZE*19(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*17(a4)
      lsr.l   #8,d0
      move.b  d0,\2_\3_SIZE*16(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*18(a4)
      move.b  d1,\2_\3_SIZE*23(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*21(a4)
      lsr.l   #8,d1
      move.b  d1,\2_\3_SIZE*20(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*22(a4)
      move.b  d2,\2_\3_SIZE*27(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*25(a4)
      lsr.l   #8,d2
      move.b  d2,\2_\3_SIZE*24(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*26(a4)
      move.b  d3,\2_\3_SIZE*31(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*29(a4)
      lsr.l   #8,d3
      move.b  d3,\2_\3_SIZE*28(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*30(a4)
      movem.l (a1)+,d0-d3        ;weitere 16 Switchwerte lesen
      move.b  d0,\2_\3_SIZE*35(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*33(a4)
      lsr.l   #8,d0
      move.b  d0,\2_\3_SIZE*32(a4)
      swap    d0
      move.b  d0,\2_\3_SIZE*34(a4)
      move.b  d1,\2_\3_SIZE*39(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*37(a4)
      lsr.l   #8,d1
      move.b  d1,\2_\3_SIZE*36(a4)
      swap    d1
      move.b  d1,\2_\3_SIZE*38(a4)
      move.b  d2,\2_\3_SIZE*43(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*41(a4)
      lsr.l   #8,d2
      move.b  d2,\2_\3_SIZE*40(a4)
      swap    d2
      move.b  d2,\2_\3_SIZE*42(a4)
      move.b  d3,\2_\3_SIZE*47(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*45(a4)
      lsr.l   #8,d3
      move.b  d3,\2_\3_SIZE*44(a4)
      swap    d3
      move.b  d3,\2_\3_SIZE*46(a4)
    ENDC
  ENDC
  IFC "W","\0"
    IFEQ \1_\4-14
      movem.l (a1)+,d0-d3    ;8 Switchwerte lesen
      move.w  d0,\2_\3_SIZE*1(a4)
      swap    d0
      move.w  d0,(a4)
      move.w  d1,\2_\3_SIZE*3(a4)
      swap    d1
      move.w  d1,\2_\3_SIZE*2(a4)
      move.w  d2,\2_\3_SIZE*5(a4)
      swap    d2
      move.w  d2,\2_\3_SIZE*4(a4)
      move.w  d3,\2_\3_SIZE*7(a4)
      swap    d3
      move.w  d3,\2_\3_SIZE*6(a4)
      movem.l (a1),d0-d2     ;weitere 6 Switchwerte lesen
      move.w  d0,\2_\3_SIZE*9(a4)
      swap    d0
      move.w  d0,\2_\3_SIZE*8(a4)
      move.w  d1,\2_\3_SIZE*11(a4)
      swap    d1
      move.w  d1,\2_\3_SIZE*10(a4)
      move.w  d2,\2_\3_SIZE*13(a4)
      swap    d2
      move.w  d2,\2_\3_SIZE*12(a4)
    ENDC
    IFEQ \1_\4-15
      movem.l (a1)+,d0-d3    ;8 Switchwerte lesen
      move.w  d0,\2_\3_SIZE*1(a4)
      swap    d0
      move.w  d0,(a4)
      move.w  d1,\2_\3_SIZE*3(a4)
      swap    d1
      move.w  d1,\2_\3_SIZE*2(a4)
      move.w  d2,\2_\3_SIZE*5(a4)
      swap    d2
      move.w  d2,\2_\3_SIZE*4(a4)
      move.w  d3,\2_\3_SIZE*7(a4)
      swap    d3
      move.w  d3,\2_\3_SIZE*6(a4)
      movem.l (a1),d0-d3     ;weitere 7 Switchwerte lesen
      move.w  d0,\2_\3_SIZE*9(a4)
      swap    d0
      move.w  d0,\2_\3_SIZE*8(a4)
      move.w  d1,\2_\3_SIZE*11(a4)
      swap    d1
      move.w  d1,\2_\3_SIZE*10(a4)
      move.w  d2,\2_\3_SIZE*13(a4)
      swap    d2
      move.w  d2,\2_\3_SIZE*12(a4)
      swap    d3
      move.w  d3,\2_\3_SIZE*14(a4)
    ENDC
  ENDC
  ENDM
