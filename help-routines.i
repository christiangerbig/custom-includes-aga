; Includedatei: "normsource-includes/help-routines.i"
; Datum:        19.06.2024
; Version:      4.5

; ## Hilfsroutinen ##
; -------------------

; ** FAST/CHIP-Memory reservieren und löschen **
; ----------------------------------------------
; d0 ... Größe des Speicherbereichs
;        Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
  CNOP 0,4
do_alloc_memory
  move.l  #MEMF_CLEAR+MEMF_PUBLIC,d1
  CALLEXECQ AllocMem         ;Speicher reservieren

; ** CHIP-Memory reservieren und löschen **
; -----------------------------------------
; d0 ... Größe des Speicherbereichs
;        Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
  CNOP 0,4
do_alloc_chip_memory
  move.l  #MEMF_CLEAR+MEMF_CHIP+MEMF_PUBLIC,d1
  CALLEXECQ AllocMem         ;Speicher reservieren

; ** FAST-Memory reservieren und löschen **
; -----------------------------------------
; d0 ... Größe des Speicherbereichs
;        Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
  CNOP 0,4
do_alloc_fast_memory
  move.l  #MEMF_CLEAR+MEMF_FAST+MEMF_PUBLIC,d1
  CALLEXECQ AllocMem         ;Speicher reservieren

; ** Bitmap-Memory reservieren und löschen **
; -------------------------------------------
; d0 ... Breite des Playfiels in Pixeln
;        Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
; d1 ... Höhe des Playfiels in Zeilen
; d2 ... Anzahl der Bitplanes
  CNOP 0,4
do_alloc_bitmap_memory
  moveq   #BMF_CLEAR+BMF_DISPLAYABLE+BMF_INTERLEAVED,d3 ;Flags
  sub.l   a0,a0            ;Friendbitmap = Null
  CALLGRAFQ AllocBitMap    ;Speicher reservieren

  IFD LINKER_SYS_TAKEN_OVER
    IFNE intena_bits&(~INTF_SETCLR)
; ** VBR auslesen **
; ------------------
; d0 ... Rückgabewert Inhalt von VBR
  CNOP 0,4
read_VBR
  or.w    #SRF_I0+SRF_I1+SRF_I2,SR ;Level-7-Interruptebene
  nop
  movec   VBR,d0
  nop
  rte
    ENDC
  ELSE

; ** VBR auslesen **
; ------------------
; d0 ... Rückgabewert Inhalt von VBR
    CNOP 0,4
read_VBR
    or.w    #SRF_I0+SRF_I1+SRF_I2,SR ;Level-7-Interruptebene
    nop
    movec   VBR,d0
    nop
    rte

; ** VBR beschreiben **
; ---------------------
; d0 ... neuer Inhalt von VBR
    CNOP 0,4
write_VBR
    or.w    #SRF_I0+SRF_I1+SRF_I2,SR ;Level-7-Interruptebene
    nop
    movec   d0,VBR
    nop
    rte

  ENDC

; ** Auf bestimmte Rasterzeile warten **
; --------------------------------------
  CNOP 0,4
wait_beam_position
  move.l  #$0003ff00,d1      ;Maske
  move.l  #beam_position<<8,d2 ;Y-Position
  lea     VPOSR-DMACONR(a6),a0
  lea     VHPOSR-DMACONR(a6),a1
wait_beam_loop
  move.w  (a0),d0            ;VPOSR
  swap    d0                 ;Bits in richtige Position bringen
  move.w  (a1),d0            ;VHPOSR
  and.l   d1,d0              ;Nur Y-Position
  cmp.l   d2,d0              ;Auf bestimmte Rasterzeile warten
  blt.s   wait_beam_loop
  rts

; ** Auf vertikale Austastlücke warten **
; ---------------------------------------
  CNOP 0,4
wait_vbi
  lea     INTREQR-DMACONR(a6),a0
wait_vbi_loop
  moveq   #INTF_VERTB,d0
  and.w   (a0),d0            ;VERTB-Interrupt ?
  beq.s   wait_vbi_loop      ;Nein -> verzweige
  move.w  d0,INTREQ-DMACONR(a6) ;VERTB-Interrupt löschen
  rts

; ** Auf Copperinterrupt warten **
; --------------------------------
  CNOP 0,4
wait_copint
  lea     INTREQR-DMACONR(a6),a0
wait_copint_loop
  moveq   #INTF_COPER,d0
  and.w   (a0),d0            ;COPER-Interrupt ?
  beq.s   wait_copint_loop   ;Nein -> verzweige
  move.w  d0,INTREQ-DMACONR(a6) ;COPER-Interrupt löschen
  rts

; ** RGB8-High-Werte in Copperliste schreiben **
; ----------------------------------------------
; a0 POINTER: Copperliste
; a1 POINTER: Tabelle mit Farbwerten
; d3 WORD: erstes Farbregister
; d7 BYTE_SIGNED: Anzahl der Farben
  CNOP 0,4
cop_init_high_colors
  move.w  #$0f0f,d2          ;Maske RGB-Nibbles
cop_init_high_colors_loop
  move.l  (a1)+,d0           ;24 Bit-Farbwert 
  RGB8_TO_RGB4_HIGH d0,d1,d2
  move.w  d3,(a0)+           ;COLORxx
  addq.w  #2,d3              ;nächstes Farbregister
  move.w  d0,(a0)+           ;High-Bits
  dbf     d7,cop_init_high_colors_loop
  rts

; ** RGB8-Low-Werte in Copperliste schreiben **
; ---------------------------------------------
; a0 POINTER: Copperliste
; a1 POINTER: Tabelle mit Farbwerten
; d3 WORD: erstes Farbregister
; d7 BYTE_SIGNED: Anzahl der Farben
  CNOP 0,4
cop_init_low_colors
  move.w  #$0f0f,d2          ;Maske RGB-Nibbles
cop_init_low_colors_loop
  move.l  (a1)+,d0           ;24 Bit-Farbwert 
  RGB8_TO_RGB4_LOW d0,d1,d2
  move.w  d3,(a0)+           ;COLORxx
  addq.w  #2,d3              ;nächstes Farbregister
  move.w  d0,(a0)+           ;Low-Bits
  dbf     d7,cop_init_low_colors_loop
  rts

; ** RGB8-High-Werte in Farbtabelle schreiben **
; ----------------------------------------------
; a0 WORD: Farbregister
; a1 POINTER: Tabelle mit Farbwerten
; d7 BYTE_SIGNED: Anzahl der Farben
  CNOP 0,4
cpu_init_high_colors
  move.w  #$0f0f,d2          ;Maske RGB-Nibbles
cpu_init_high_colors_loop
  move.l  (a1)+,d0           ;24 Bit-Farbwert 
  RGB8_TO_RGB4_HIGH d0,d1,d2
  move.w  d0,(a0)+           ;COLORxx
  dbf     d7,cpu_init_high_colors_loop
  rts

; ** RGB8-Low-Werte in Farbtabelle schreiben **
; ---------------------------------------------
; a0 WORD: Farbregister
; a1 POINTER: Tabelle mit Farbwerten
; d7 BYTE_SIGNED: Anzahl der Farben
cpu_init_low_colors
  move.w  #$0f0f,d2          ;Maske RGB-Nibbles
cpu_init_low_colors_loop
  move.l  (a1)+,d0           ;24 Bit-Farbwert 
  RGB8_TO_RGB4_LOW d0,d1,d2
  move.w  d0,(a0)+           ;COLORxx
  dbf     d7,cpu_init_low_colors_loop
  rts

  IFD color_gradient_rgb_nibbles4
; ** RGB4-Farbverlauf **
; d0 ... 12-Bit-RGB-Istwert
; d6 ... 12-Bit-RGB-Sollwert
; d7 ... Anzahl der Farbwerte
; a0 ... Zeiger auf Farbtabelle
; a1 ... Additions-/Subtraktionswert für Rot
; a2 ... Additions-/Subtraktionswert für Grün
; a4 ... Additions-/Subtraktionswert für Blau
; a5 ... Offset
    CNOP 0,4
init_color_gradient_rgb_nibbles4_loop
    move.w  d0,(a0)          ;RGB-Wert in Farbtabelle schreiben
    add.l   a5,a0            ;Offset
split_rgb_nibbles4
    move.w  d0,d1            ;4-Bit-Grünwert
    moveq   #$0f,d2          ;Maske Blauanteil
    and.w   #$0f0,d1         ;Nur Grünanteil
    and.b   d0,d2            ;Nur Blauanteil
    move.w  d6,d3            ;4-Bit-Sollwert 
    clr.b   d0               ;Nur Rotanteil
    move.w  d3,d4            ;4-Bit-Grünwert
    moveq   #$0f,d5          ;Maske Blauanteil
    and.w   #$0f0,d4         ;Nur Grünanteil
    and.b   d3,d5            ;Nur Blauanteil
    clr.b   d3               ;Nur Rotanteil
check_red_nibble_rgb_nibbles4
    cmp.w   d3,d0            ;Ist-Rotwert mit Soll-Rotwert vergleichen
    bgt.s   decrease_red_rgb_nibbles4_1 ;Wenn Ist-Rotwert > Soll-Rotwert -> verzweige
    blt.s   increase_red_rgb_nibbles4_1 ;Wenn Ist-Rotwert < Soll-Rotwert -> verzweige
check_green_nibble_rgb_nibbles4
    cmp.w   d4,d1            ;Ist-Grünwert mit Soll-Grünwert vergleichen
    bgt.s   decrease_green_rgb_nibbles4_1 ;Wenn Ist-Grünwert > Soll-Grünwert -> verzweige
    blt.s   increase_green_rgb_nibbles4_1 ;Wenn Ist-Grünwert < Soll-Grünwert -> verzweige
check_blue_nibble_rgb_nibbles4
    cmp.b   d5,d2            ;Ist-Blauwert mit Soll-Blauwert vergleichen
    bgt.s   decrease_blue_rgb_nibbles4_1 ;Wenn Ist-Blauwert < Soll-Blauwert -> verzweige
    blt.s   increase_blue_rgb_nibbles4_1 ;Wenn Ist-Blauwert > Soll-Blauwert -> verzweige
merge_rgb_nibbles4
    move.b  d1,d0              ;neuer Grünwert $RG0
    or.b    d2,d0              ;neuer Blauwert $RGB
    dbf     d7,init_color_gradient_rgb_nibbles4_loop
    rts
    CNOP 0,4
decrease_red_rgb_nibbles4_1
    sub.w   a1,d0              ;Rotanteil verringern
    cmp.w   d3,d0              ;Ist-Rotwert > Soll-Rotwert ?
    bgt.s   check_green_nibble_rgb_nibbles4   ;Ja -> verzweige
    move.w  d3,d0              ;Ist-Rotwert = Soll-Rotwert
    bra.s   check_green_nibble_rgb_nibbles4
    CNOP 0,4
increase_red_rgb_nibbles4_1
    add.w   a1,d0              ;Rotanteil erhöhen
    cmp.w   d3,d0              ;Ist-Rotwert < Soll-Rotwert ?
    blt.s   check_green_nibble_rgb_nibbles4 ;Ja -> verzweige
    move.w  d3,d0              ;Ist-Rotwert = Soll-Rotwert
    bra.s   check_green_nibble_rgb_nibbles4
    CNOP 0,4
decrease_green_rgb_nibbles4_1
    sub.w   a2,d1              ;Grünanteil verringern
    cmp.w   d4,d1              ;Ist-Grünwert > Soll-Grünwert ?
    bgt.s   check_blue_nibble_rgb_nibbles4    ;Ja -> verzweige
    move.w  d4,d1              ;Ist-Grünwert = Soll-Grünwert
    bra.s   check_blue_nibble_rgb_nibbles4
    CNOP 0,4
increase_green_rgb_nibbles4_1
    add.w   a2,d1              ;Grünanteil erhöhen
    cmp.w   d1,d4              ;Ist-Grünwert < Soll-Grünwert ?
    blt.s   check_blue_nibble_rgb_nibbles4    ;Ja -> verzweige
    move.w  d4,d1              ;Ist-Grünwert = Soll-Grünwert
    bra.s   check_blue_nibble_rgb_nibbles4
    CNOP 0,4
decrease_blue_rgb_nibbles4_1
    sub.w   a4,d2              ;Blauanteil verringern
    cmp.b   d5,d2              ;Ist-Blauwert > Soll-Blauwert ?
    bgt.s   merge_rgb_nibbles4         ;Ja -> verzweige
    move.b  d5,d2              ;Ist-Blauwert = Soll-Blauwert
    bra.s   merge_rgb_nibbles4
    CNOP 0,4
increase_blue_rgb_nibbles4_1
    add.w   a4,d2              ;Blauanteil erhöhen
    cmp.b   d5,d2              ;Ist-Blauwert < Soll-Blauwert ?
    blt.s   merge_rgb_nibbles4         ;Ja -> verzweige
    move.b  d5,d2              ;Ist-Blauwert = Soll-Blauwert
    bra.s   merge_rgb_nibbles4
  ENDC

  IFD color_gradient_rgb8
; ** RGB8-Farbverlauf **
; d0 ... 24-Bit-RGB-Istwert
; d6 ... 24-Bit-RGB-Sollwert
; d7 ... Anzahl der Farbwerte
; a0 ... Zeiger auf Farbtabelle
; a1 ... Additions-/Subtraktionswert für Rot
; a2 ... Additions-/Subtraktionswert für Grün
; a4 ... Additions-/Subtraktionswert für Blau
; a5 ... Offset
    CNOP 0,4
init_color_gradient_rgb8_loop
    move.l  d0,(a0)            ;RGB-Wert in Farbtabelle schreiben
    add.l   a5,a0              ;Offset
split_rgb8_nibbles
    moveq   #TRUE,d1
    move.w  d0,d1              ;8-Bit-Grünwert
    moveq   #TRUE,d2
    clr.b   d1                 ;Nur Grünanteil
    move.b  d0,d2              ;8-Bit-Blauwert
    clr.w   d0                 ;Nur Rotanteil
    move.l  d6,d3              ;8-Bit-Sollwert 
    moveq   #TRUE,d4
    move.w  d3,d4              ;8-Bit-Grünwert
    moveq   #TRUE,d5
    move.b  d3,d5              ;8-Bit-Blauwert
    clr.w   d3                 ;Nur Rotanteil
    clr.b   d4                 ;Nur Grünanteil
check_red_nibble
    cmp.l   d3,d0              ;Ist-Rotwert mit Soll-Rotwert vergleichen
    bgt.s   decrease_red_nibble_1 ;Wenn Ist-Rotwert > Soll-Rotwert -> verzweige
    blt.s   increase_red_nibble_1 ;Wenn Ist-Rotwert < Soll-Rotwert -> verzweige
check_green_nibble
    cmp.l   d4,d1              ;Ist-Grünwert mit Soll-Grünwert vergleichen
    bgt.s   decrease_green_nibble_1 ;Wenn Ist-Grünwert > Soll-Grünwert -> verzweige
    blt.s   increase_green_nibble_1 ;Wenn Ist-Grünwert < Soll-Grünwert -> verzweige
check_blue_nibble
    cmp.w   d5,d2              ;Ist-Blauwert mit Soll-Blauwert vergleichen
    bgt.s   decrease_blue_nibble_1 ;Wenn Ist-Blauwert > Soll-Blauwert -> verzweige
    blt.s   increase_blue_nibble_1 ;Wenn Ist-Blauwert < Soll-Blauwert -> verzweige
merge_rgb8_nibbles
    move.w  d1,d0              ;neuer Grünwert $RrGg00
    move.b  d2,d0              ;neuer Blauwert $RrGgBb
    dbf     d7,init_color_gradient_rgb8_loop
    rts
    CNOP 0,4
decrease_red_nibble_1
    sub.l   a1,d0              ;Rotanteil verringern
    cmp.l   d3,d0              ;Ist-Rotwert > Soll-Rotwert ?
    bgt.s   check_green_nibble ;Ja -> verzweige
    move.l  d3,d0              ;Ist-Rotwert = Soll-Rotwert
    bra.s   check_green_nibble
    CNOP 0,4
increase_red_nibble_1
    add.l   a1,d0              ;Rotanteil erhöhen
    cmp.l   d3,d0              ;Ist-Rotwert < Soll-Rotwert ?
    blt.s   check_green_nibble ;Ja -> verzweige
    move.l  d3,d0              ;Ist-Rotwert = Soll-Rotwert
    bra.s   check_green_nibble
    CNOP 0,4
decrease_green_nibble_1
    sub.l   a2,d1              ;Grünanteil verringern
    cmp.l   d4,d1              ;Ist-Grünwert > Soll-Grünwert ?
    bgt.s   check_blue_nibble  ;Ja -> verzweige
    move.l  d4,d1              ;Ist-Grünwert = Soll-Grünwert
    bra.s   check_blue_nibble
    CNOP 0,4
increase_green_nibble_1
    add.l   a2,d1              ;Grünanteil erhöhen
    cmp.l   d4,d1              ;Ist-Grünwert < Soll-Grünwert ?
    blt.s   check_blue_nibble  ;Ja -> verzweige
    move.l  d4,d1              ;Ist-Grünwert = Soll-Grünwert
    bra.s   check_blue_nibble
    CNOP 0,4
decrease_blue_nibble_1
    sub.w   a4,d2              ;Blauanteil verringern
    cmp.w   d5,d2              ;Ist-Blauwert > Soll-Blauwert ?
    bgt.s   merge_rgb8_nibbles ;Ja -> verzweige
    move.w  d5,d2              ;Ist-Blauwert = Soll-Blauwert
    bra.s   merge_rgb8_nibbles
    CNOP 0,4
increase_blue_nibble_1
    add.w   a4,d2              ;Blauanteil erhöhen
    cmp.w   d5,d2              ;Ist-Blauwert < Soll-Blauwert ?
    blt.s   merge_rgb8_nibbles         ;Ja -> verzweige
    move.w  d5,d2              ;Ist-Blauwert = Soll-Blauwert
    bra.s   merge_rgb8_nibbles
  ENDC
