; -- Inits

SET_SPRITE_POSITION MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Y-Koordinate
; \3 WORD: Höhe in Zeilen
; Rückgabewerte: [\2 WORD] SPRxPOS, [\3 WORD] SPRxCTL
  IFC "","\1"
    FAIL Makro SET_SPRITE_POSITION: X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SET_SPRITE_POSITION: Y-Koordinate fehlt
  ENDC
  IFC "","\3"
    FAIL Makro SET_SPRITE_POSITION: Höhe in Zeilen fehlt
  ENDC
  rol.w   #8,\2              ;% SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- --- SV8
  lsl.w   #5,\1              ;%SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SH2 SH1 SH0 --- --- --- --- ---
  lsl.w   #8,\3              ;% EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- --- ---
  addx.b  \2,\2              ;% --- --- --- --- --- --- SV8 EV8
  add.b   \1,\1              ;% SH1 SH0 --- --- --- --- --- ---
  addx.b  \2,\2              ;% --- --- --- --- --- SV8 EV8 SH2
  lsr.b   #3,\1              ;% --- --- --- SH1 SH0 --- --- ---
  or.b    \1,\2              ;% --- --- --- SH1 SH0 SV8 EV8 SH2
  lsr.w   #8,\1              ;% --- --- --- --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
  move.b  \2,\3              ;% EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0  --- --- --- SH1 SH0 SV8 EV8 SH2
  move.b  \1,\2              ;% SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
  ENDM


SET_SPRITE_POSITION_1X MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Y-Koordinate
; \3 WORD: Höhe in Zeilen
; Rückgabewerte: [\2 LONGWORD] Bit 31..16 SPRxPOS Bit 15..0 SPRxCTL
  IFC "","\1"
    FAIL Makro SET_SPRITE_POSITION_1X: X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SET_SPRITE_POSITION_1X: Y-Koordinate fehlt
  ENDC
  IFC "","\3"
    FAIL Makro SET_SPRITE_POSITION_1X: Höhe in Zeilen fehlt
  ENDC
  SET_SPRITE_POSITION \1,\2,\3
  swap    \2                 ;% SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
  move.w  \3,\2              ;% SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 --- --- --- SH1 SH0 SV8 EV8 SH2
  ENDM


SET_SPRITE_POSITION_V9 MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Y-Koordinate
; \3 WORD: Höhe in Zeilen
; \4 BYTE: Scratch-Register
; Rückgabewerte: [\2 WORD] SPRxPOS, [\3 WORD] SPRxCTL
  IFC "","\1"
    FAIL Makro SET_SPRITE_POSITION_V9: X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SET_SPRITE_POSITION_V9: Y-Koordinate fehlt
  ENDC
  IFC "","\3"
    FAIL Makro SET_SPRITE_POSITION_V9: Höhe in Zeilen fehlt
  ENDC
  IFC "","\4"
    FAIL Makro SET_SPRITE_POSITION_V9: Scratch-Register fehlt
  ENDC
  rol.w   #7,\2              ;% SV8 SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- SV9
  move.b  \2,\4              ;% SV0 --- --- --- --- --- --- SV9
  lsl.w   #7,\3              ;% EV8 EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- ---
  addx.b  \4,\4              ;% --- --- --- --- --- --- SV9 EV9
  ror.b   #2,\1              ;% --- --- --- --- --- SH10 SH9 SH8 SH1 SH0 SH7 SH6 SH5 SH4 SH3 SH2
  add.b   \1,\1              ;% --- --- --- --- --- SH10 SH9 SH8 SH0 
  addx.b  \4,\4              ;% --- --- --- --- --- SV9 EV9 SH1
  add.b   \1,\1              ;% --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SH2 --- ---
  addx.b  \4,\4              ;% --- --- --- --- SV9 EV9 SH1 SH0
  or.b    \4,\3              ;% EV8 EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- SV9 EV9 SH1 SH0
  add.w   \2,\2              ;% SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- SV9 ---
  addx.w  \3,\3              ;% EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- SV9 EV9 SH1 SH0 SV8
  addx.b  \3,\3              ;% EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- SV9 EV9 SH1 SH0 SV8 EV8
  lsr.w   #3,\1              ;% --- --- --- --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
  addx.b  \3,\3              ;% EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- SV9 EV9 SH1 SH0 SV8 EV8 SH2
  move.b  \1,\2              ;% SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3: SPRxPOS
  ENDM


INIT_SPRITE_POINTERS_TABLE MACRO
  CNOP 0,4
spr_init_pointers_table
  IFNE spr_x_size1
    lea     spr0_construction(a3),a0 ;Zeiger auf Sprite-Bitmap
    lea     spr_pointers_construction(pc),a1 ;Zeiger auf Tabelle
    moveq   #spr_number-1,d7   ;Anzahl der Sprites
spr_init_pointers_table_loop1
    move.l  (a0)+,a2
    move.l  (a2),(a1)+         ;Zeiger auf Sprite-Struktur
    dbf     d7,spr_init_pointers_table_loop1
  ENDC
  IFNE spr_x_size2
    lea     spr0_display(a3),a0 ;Zeiger auf Sprite-Bitmap
    lea     spr_pointers_display(pc),a1 ;Zeiger auf Tabelle
    moveq   #spr_number-1,d7   ;Anzahl der Sprites
spr_init_pointers_table_loop2
    move.l  (a0)+,a2
    move.l  (a2),(a1)+         ;Zeiger auf Sprite-Struktur
    dbf     d7,spr_init_pointers_table_loop2
  ENDC
  rts
  ENDM


COPY_SPRITE_STRUCTURES MACRO
  CNOP 0,4
spr_copy_structures
  move.l  a4,-(a7)
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  lea     spr_pointers_display(pc),a4 ;Zeiger auf Sprites
  move.w  #(sprite0_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.w  #(sprite1_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.w  #(sprite2_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.w  #(sprite3_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.w  #(sprite4_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.w  #(sprite5_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.w  #(sprite6_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.w  #(sprite7_SIZE/4)-1,d7 ;Anzahl der Langwörter
  bsr.s   spr_copy_data
  move.l  (a7)+,a4
  rts
  CNOP 0,4
spr_copy_data
  move.l  (a2)+,a0           ;Quelle
  move.l  (a4)+,a1           ;Ziel
spr_copy_data_loop
  move.l  (a0)+,(a1)+        ;4 Bytes kopieren
  dbf     d7,spr_copy_data_loop
  rts
  ENDM


INIT_ATTACHED_SPRITES_CLUSTER MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 POINTER: Sprite-Struktur
; \3 WORD: X-Position (optional)
; \4 WORD: Y-Position (optional)
; \5 WORD: Breite des Sprites in Pixeln
; \6 WORD: Höhe des Sprites in Zeilen
; \7 STRING: "NOHEADER" (optional)
; \8 STRING: "BLANK" (optional)
; \9 STRING: "REPEAT" (optional)
  IFC "","\1"
    FAIL Makro INIT_ATTACHED_SPRITES_CLUSTER: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro INIT_ATTACHED_SPRITES_CLUSTER: Sprite-Struktur fehlt
  ENDC
  IFC "","\5"
    FAIL Makro INIT_ATTACHED_SPRITES_CLUSTER: Breite fehlt
  ENDC
  IFC "","\6"
    FAIL Makro INIT_ATTACHED_SPRITES_CLUSTER: Höhe fehlt
  ENDC
  CNOP 0,4
\1_init_attached_sprites_cluster
  IFNC "REPEAT","\9"
    movem.l a4-a5,-(a7)
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*0))*4,d0  ;X-Koord.
      MOVEF.W \4,d1 ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    lea     \2(pc),a5        ;Zeiger auf Sprite-Strukturen
    move.l  (a5)+,a0         ;Sprite0-Struktur
    bsr     \1_init_sprite_header
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*0))*4,d0 ;X-Koord.
      move.w  #\4,d1         ;Y-Koord.
      MOVEF.W SPRCTLF_ATT,d3
    ENDC

    IFNC "BLANK","\8"
      lea     \1_image_data,a1 ;Zeiger auf Playfield (1. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC
    move.l  (a5)+,a0           ;Sprite1-Struktur
    bsr     \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (1. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC

    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*1))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    move.l  (a5)+,a0           ;Sprite2-Struktur
    bsr     \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+8,a1 ;Zeiger auf Hintergrundbild (2. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*1))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      MOVEF.W  SPRCTLF_ATT,d3
    ENDC
    move.l  (a5)+,a0           ;Sprite3-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+8+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (2. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC

    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*2))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    move.l  (a5)+,a0           ;Sprite4-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+16,a1 ;Zeiger auf Hintergrundbild (3. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*2))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      MOVEF.W SPRCTLF_ATT,d3
    ENDC
    move.l  (a5)+,a0         ;Sprite5-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+16+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (3. Spalte 64 Pixel)
      bsr.s   \1_init_sprite_bitmap
    ENDC
  
    move.l  (a5)+,a0 ;Sprite6-Struktur
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*3))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+24,a1 ;Zeiger auf Hintergrundbild (4. Spalte 64 Pixel)
      bsr.s   \1_init_sprite_bitmap
    ENDC
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*3))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      MOVEF.W SPRCTLF_ATT,d3
    ENDC
    move.l  (a5),a0          ;Sprite7-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+24+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (4. Spalte 64 Pixel)
      bsr.s   \1_init_sprite_bitmap
    ENDC
    movem.l (a7)+,a4-a5
    rts
  ELSE
    movem.l a4-a5,-(a7)
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*0))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    lea     \2(pc),a5        ;Zeiger auf Sprite-Strukturen
    move.l  (a5)+,a0         ;Sprite0-Struktur
    bsr     \1_init_sprite_header
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*0))*4,d0 ;X-Koord.
      move.w  #\4,d1         ;Y-Koord.
      MOVEF.W SPRCTLF_ATT,d3
    ENDC
    IFNC "BLANK","\8"
      lea     \1_image_data+16,a1 ;Zeiger auf Playfield (3. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC
    move.l  (a5)+,a0           ;Sprite1-Struktur
    bsr     \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+16+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (3. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC

    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*1))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    move.l  (a5)+,a0         ;Sprite2-Struktur
    bsr     \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+24,a1 ;Zeiger auf Hintergrundbild (4. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*1))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      MOVEF.W  SPRCTLF_ATT,d3
    ENDC
    move.l  (a5)+,a0         ;Sprite3-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+24+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (4. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC

    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*2))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    move.l  (a5)+,a0         ;Sprite4-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data,a1 ;Zeiger auf Hintergrundbild (1. Spalte 64 Pixel)
      bsr     \1_init_sprite_bitmap
    ENDC
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*2))*4,d0 ;X-Koord.
      MOVEF.W \4,d1            ;Y-Koord.
      MOVEF.W SPRCTLF_ATT,d3
    ENDC
    move.l  (a5)+,a0           ;Sprite5-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (1. Spalte 64 Pixel)
      bsr.s   \1_init_sprite_bitmap
    ENDC
  
    move.l  (a5)+,a0 ;Sprite6-Struktur
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*3))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      moveq   #TRUE,d3
    ENDC
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+8,a1 ;Zeiger auf Hintergrundbild (2. Spalte 64 Pixel)
      bsr.s   \1_init_sprite_bitmap
    ENDC
    IFNC "NOHEADER","\7"
      move.w  #(\3+(\5*3))*4,d0 ;X-Koord.
      MOVEF.W \4,d1          ;Y-Koord.
      MOVEF.W SPRCTLF_ATT,d3
    ENDC
    move.l  (a5),a0          ;Sprite7-Struktur
    bsr.s   \1_init_sprite_header
    IFNC "BLANK","\8"
      lea     \1_image_data+8+(\1_image_plane_width*2),a1 ;Zeiger auf Hintergrundbild (2. Spalte 64 Pixel)
      bsr.s   \1_init_sprite_bitmap
    ENDC
    movem.l (a7)+,a4-a5
    rts
  ENDC

; ** init_sprite_header-Routine **
; d0 ... X-Koordinate
; d1 ... Y-Koordinate
; d3 ... Attached-Bit
; a0 ... Zeiger auf Sprite-Struktur
  CNOP 0,4
\1_init_sprite_header
  IFNC "NOHEADER","\7"
    MOVEF.W \6,d2            ;Höhe
    add.w   d1,d2            ;Höhe zu Y addieren
    SET_SPRITE_POSITION d0,d1,d2
    move.w  d1,(a0)          ;SPRxPOS
    or.b    d3,d2            ;Ggf. ATT-Bit setzen
    move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPRxCTL
  ENDC
  ADDF.W  (spr_pixel_per_datafetch/4),a0 ;Sprite-Header überspringen
  rts

  IFNC "BLANK","\8"
    CNOP 0,4
\1_init_sprite_bitmap
    move.w  #\1_image_plane_width-8,a2
    move.w  #(\1_image_plane_width*3)-8,a4
    MOVEF.W  \1_image_y_size-1,d7 ;Anzahl der Zeilen
\1_init_sprite_bitmap_loop
    move.l  (a1)+,(a0)+      ;BP0 64 Bits
    move.l  (a1)+,(a0)+
    add.l   a2,a1            ;Restliche Zeile in Quelle überspringen
    move.l  (a1)+,(a0)+      ;BP1 64 Bits
    move.l  (a1)+,(a0)+
    add.l   a4,a1            ;Restliche Zeile + zwei Folgeplanes in Quelle überspringen
    dbf     d7,\1_init_sprite_bitmap_loop
  ENDC
  rts
  ENDM


; -- Raster routines

SWAP_SPRITES_STRUCTURES MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 BYTE SIGNED: Anzahl der Sprites
; \3 NUMBER: [1,2,3,4,6,7] Index, ab welchem Sprite (optional)
  IFC "","\1"
    FAIL Makro SWAP_SPRITES_STRUCTURES: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SWAP_SPRITES_STRUCTURES: Anzahl der Sprites fehlt
  ENDC
  CNOP 0,4
\1_swap_structures
  IFC "","\3"
    lea     spr_pointers_construction(pc),a0 ;Aufbau-Sprites
    lea     spr_pointers_display(pc),a1 ;Darstellen-Sprites
  ELSE
    lea     spr_pointers_construction+(\3*4)(pc),a0 ;Aufbau-Sprites
    lea     spr_pointers_display+(\3*4)(pc),a1 ;Darstellen-Sprites
  ENDC
  moveq   #\2-1,d7           ;Anzahl der Sprites
\1_swap_structures_loop
  move.l  (a0),d0            ;Aufbau-Sprite
  move.l  (a1),(a0)+         ;Darstellen-Sprite -> Aufbau-Sprite
  move.l  d0,(a1)+           ;Aufbau-Sprite -> Darstellen-Sprite
  dbf     d7,\1_swap_structures_loop

  move.l  cl1_display(a3),a0 
  IFC "","\3"
    lea     spr_pointers_display(pc),a1 ;Zeiger auf Sprites
    ADDF.W  cl1_SPR0PTH+2,a0
  ELSE
    lea     spr_pointers_display+(\3*4)(pc),a1 ;Zeiger auf Sprites + Index
    ADDF.W  cl1_SPR\3PTH+2,a0
  ENDC
  moveq   #\2-1,d7           ;Anzahl der Sprites
\1_set_sprite_pointers_loop
  move.w  (a1)+,(a0)         ;SPRxPTH
  addq.w  #8,a0              ;nächter Spritezeiger
  move.w  (a1)+,4-8(a0)      ;SPRxPTL
  dbf     d7,\1_set_sprite_pointers_loop
  rts
  ENDM