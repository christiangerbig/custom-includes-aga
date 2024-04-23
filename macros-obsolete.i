; obsolete
MOVEF.BMACRO
; \1 ... 8-Bit Quellwert
; \2 ... Ziel
  IFLE $80-(\1)              ;Wenn Zahl >= $80, dann
    IFGE $ff-(\1)            ;Wenn Zahl <= $ff, dann
      moveq #-((-(\1)&$ff)),\2 ;erste Variante
    ENDC
  ELSE                       ;ansonsten
    moveq #\1,\2             ;zweite Variante
  ENDC
  ENDM


; obsolete
MOVEF.WMACRO
; \1 ... 16-Bit Quellwert
; \2 ... Ziel
  IFEQ (\1)&$ff00            ;Wenn Zahl <= $00ff, dann
    IFEQ (\1)&$80            ;Wenn Zahl <= $007f, dann
      moveq  #\1,\2          ;erste Variante
    ENDC
    IFEQ (\1)-$80            ;Wenn Zahl = $0080, dann
      moveq  #$7f,\2         ;zweite Variante
      not.b  \2
    ENDC
    IFGT (\1)-$80            ;Wenn Zahl > $0080, dann
      moveq  #256-(\1),\2    ;dritte Variante
      neg.b  \2
    ENDC
  ELSE                       ;Wenn Zahl > $00ff, dann
    move.w  #\1,\2           ;vierte Variante
  ENDC
  ENDM


; obsolete
MOVEF.LMACRO
; \1 ... 32-Bit Quellwert
; \2 ... Ziel
  IFEQ (\1)&$ffffff00        ;Wenn Zahl <= $000000ff, dann
    IFEQ (\1)&$80            ;Wenn Zahl <= $0000007f, dann
      moveq  #\1,\2          ;erste Variante
    ENDC
    IFEQ (\1)-$80            ;Wenn Zahl = $00000080, dann
      moveq  #$7f,\2         ;zweite Variante
      not.b  \2
    ENDC
    IFGT (\1)-$80            ;Wenn Zahl > $00000080, dann
      moveq  #256-(\1),\2    ;dritte Variante
      neg.b  \2
    ENDC
  ELSE                       ;Wenn Zahl > $000000ff, dann
    move.l  #\1,\2           ;vierte Variante
  ENDC
  ENDM


; obsolete
ADDQB MACRO
; \1 ... 8-Bit Quellwert
; \2 ... Ziel
  IFGE (\1)-$8000            ;Wenn Zahl > $7fff, dann
    add.b   #\1,\2
  ELSE
    IFLE (\1)-8              ;Wenn Zahl <= $0008, dann
      addq.b  #(\1),\2
    ELSE                     ;Wenn > $0008, dann
      IFLE (\1)-16           ;Wenn Zahl <= $0010, dann
        addq.b  #8,\2
        addq.b  #\1-8,\2
      ELSE                   ;Wenn Zahl > $0010, dann
      add.b   #\1,\2
      ENDC
    ENDC
  ENDC
  ENDM


; obsolete
ADDF.WMACRO
; \1 ... 16-Bit Quellwert
; \2 ... Ziel
  IFGE (\1)-$8000            ;Wenn Zahl > $7fff, dann
    add.w   #\1,\2
  ELSE
    IFLE (\1)-8              ;Wenn Zahl <= $0008, dann
      addq.w  #(\1),\2
    ELSE                     ;Wenn > $0008, dann
      IFLE (\1)-16           ;Wenn Zahl <= $0010, dann
        addq.w  #8,\2
        addq.w  #\1-8,\2
      ELSE                   ;Wenn Zahl > $0010, dann
      add.w   #\1,\2
      ENDC
    ENDC
  ENDC
  ENDM


; obsolete
ADDF.LMACRO
; \1 ... 32-Bit Quellwert
; \2 ... Ziel
  IFGE (\1)-$8000            ;Wenn Zahl > $7fff, dann
    add.l   #\1,\2
  ELSE
    IFLE (\1)-8              ;Wenn Zahl <= $0008, dann
      addq.l  #(\1),\2
    ELSE                     ;Wenn > $0008, dann
      IFLE (\1)-16           ;Wenn Zahl <= $0010, dann
        addq.l  #8,\2
        addq.l  #\1-8,\2
      ELSE                   ;Wenn Zahl > $0010, dann
      add.l   #\1,\2
      ENDC
    ENDC
    IFGE (\1)-$8000          ;Wenn Zahl > $7fff, dann
      add.l   #\1,\2
    ENDC
  ENDC
  ENDM


; obsolete
SUBQB MACRO
; \1 ... 8-Bit Quellwert
; \2 ... Ziel
  IFLE (\1)-8                ;Wenn Zahl <= $0008, dann
    subq.b  #(\1),\2
  ELSE                       ;Wenn > $0008, dann
    IFLE (\1)-16             ;Wenn Zahl <= $0010, dann
      subq.b  #8,\2
      subq.b  #\1-8,\2
    ELSE                     ;Wenn Zahl > $0010, dann
    sub.b   #\1,\2
    ENDC
  ENDC
  ENDM


; obsolete
SUBQW MACRO
; \1 ... 16-Bit Quellwert
; \2 ... Ziel
  IFLE (\1)-8                ;Wenn Zahl <= $0008, dann
    subq.w  #(\1),\2
  ELSE                       ;Wenn > $0008, dann
    IFLE (\1)-16             ;Wenn Zahl <= $0010, dann
      subq.w  #8,\2
      subq.w  #\1-8,\2
    ELSE                     ;Wenn Zahl > $0010, dann
    sub.w   #\1,\2
    ENDC
  ENDC
  ENDM


; obsolete
SUBQL MACRO
; \1 ... 32-Bit Quellwert
; \2 ... Ziel
  IFLE (\1)-8                ;Wenn Zahl <= $0008, dann
    subq.l  #(\1),\2
  ELSE                       ;Wenn > $0008, dann
    IFLE (\1)-16             ;Wenn Zahl <= $0010, dann
      subq.l  #8,\2
      subq.l  #\1-8,\2
    ELSE                     ;Wenn Zahl > $0010, dann
    sub.l   #\1,\2
    ENDC
  ENDC
  ENDM


; obsolet
MULUQB MACRO
; \1 ... 8-Bit Faktor
; \2 ... Produkt
; \3 ... Scratch-Register
  MULUF.B \1,\2,\3
  ENDM


; obsolete
MULUQW MACRO
; \1 ... 16-Bit Faktor
; \2 ... Produkt
; \3 ... Scratch-Register
  MULUF.W \1,\2,\3
  ENDM


; obsolete
MULUQL MACRO
; \1 ... 32-Bit Faktor
; \2 ... Produkt
; \3 ... Scratch-Register
  MULUF.L \1,\2,\3
  ENDM


; obsolete
MULSF.WMACRO
; \1 ... 16-Bit vorzeichenbhafteter Faktor
; \2 ... Produkt
; \3 ... Scratch-Register
  ext.l   \2                 ;Auf 32 Bit erweitern
  MULUF.L \1,\2,\3
  ENDM


; obsolete
INITCOLORHIGH MACRO
; \1 ... Farbregister-Adresse
; \2 ... Anzahl der Farben
  move.w  #\1,d3             ;erstes Farbregister
  moveq   #\2-1,d7           ;Anzahl der Farben
  bsr     init_high_cols_loop
  ENDM


; obsolete
INITCOLORLOW MACRO
; \1 ... Farbregister-Adresse
; \2 ... Anzahl der Farben
  move.w  #\1,d3             ;erstes Farbregister
  moveq   #\2-1,d7           ;Anzahl der Farben
  bsr     init_low_cols_loop
  ENDM


; obsolete
INITCOLORHIGH2 MACRO
; \1 ... erstes Farbregister
; \2 ... Anzahl der Farben
  lea     (\1)-DMACONR(a6),a0      ;erstes Farbregister
  moveq   #\2-1,d7           ;Anzahl der Farben
  bsr     init_high_cols_loop2
  ENDM


; obsolet
INITCOLORLOW2 MACRO
; \1 ... erstes Farbregister
; \2 ... Anzahl der Farben
  lea     (\1)-DMACONR(a6),a0      ;erstes Farbregister
  moveq   #\2-1,d7           ;Anzahl der Farben
  bsr     init_low_cols_loop2
  ENDM


; Obsolet ---> COLOR_24TO12_HIGHBITS
;COLOR_HIGHBITS_24TO12 MACRO
; \1 LONGWORD: 24-Bit Farbwert
; \2 WORD: Maske für High-Bits
; d0 Rückgabe: 12-Bit High-Farbwert
;  lsr.l   #4,\1              ;$000RrGgB
;  and.w   \2,\1              ;$000R0G0B
;  move.l  \1,d0              ;$000R0G0B
;  lsr.l   #4,d0              ;$0000R0G0
;  or.b    d0,\1              ;$GB
;  lsr.w   #4,d0              ;$0R0G
;  move.b  \1,d0              ;$0RGB
;  ENDM


; Obsolet ---> COLOR_24TO12_LOWBITS
;COLOR_LOWBITS_24TO12 MACRO
; \1 LONGWORD: 24-Bit Farbwert
; \2 WORD: Maske für Low-Bits
; d0 Rückgabe: 12-Bit Low-Farbwert
;  and.w   \2,\1              ;$00Rr0g0b
;  move.l  \1,d0              ;$00Rr0b0b
;  lsr.l   #4,d0              ;$000Rr0g0
;  or.b    d0,\1              ;$gb
;  lsr.w   #4,d0              ;$0r0g
;  move.b  \1,d0              ;$0rgb
;  ENDM
