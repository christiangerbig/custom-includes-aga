; -- Raster-Routines

SEPARATE_PLAYFIELD_SOFTSCROLL_64PIXEL_LORES MACRO
; \1 WORD: PF1 X-Koordinate
; \2 WORD: PF2 X-Koordinate
; \3 Datenregister D[0..7] Maske für H0-H7 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
  IFC "","\1"
    FAIL Makro SEPARATE_PLAYFIELD_SOFTSCROLL_64PIXEL_LORES: PF1 X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SEPARATE_PLAYFIELD_SOFTSCROLL_64PIXEL_LORES: PF1 Y-Koordinate fehlt
  ENDC
  IFC "","\3"
    and.w   #$00ff,\1        ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ELSE
    and.w   \3,\1            ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ENDC
  IFC "","\3"
    and.w   #$00ff,\2        ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ELSE
    and.w   \3,\2            ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ENDC
  lsl.w   #2,\1              ;%-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
  lsl.w   #2,\2              ;%-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
  ror.b   #4,\1              ;%-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
  ror.b   #4,\2              ;%-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
  lsl.w   #2,\1              ;%-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
  lsl.w   #2,\2              ;%-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
  lsr.b   #2,\1              ;%-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
  lsr.b   #2,\2              ;%-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
  lsl.b   #4,\2              ;%H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
  or.w    \2,\1              ;%H7 H6 H1 H0 H7 H6 H1 H0 H5 H4 H3 H2 H5 H4 H3 H2
  ENDM


BITPLANE_SOFTSCROLL_8PIXEL_LORES MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H4 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
  IFC "","\1"
    FAIL Makro BITPLANE_SOFTSCROLL_8PIXEL_LORES: PF1 X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro BITPLANE_SOFTSCROLL_8PIXEL_LORES: PF1 Y-Koordinate fehlt
  ENDC
  IFC "","\3"
    and.w    #$001f,\1       ;%-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
  ELSE
    and.w    \3,\1           ;%-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
  ENDC
  lsl.b   #2,\1              ;%-- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0 -- --
  ror.b   #4,\1              ;%-- -- -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2
  lsl.w   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2 -- --
  lsr.b   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
  move.w  \1,\2              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
  lsl.w   #4,\2              ;%-- -- H1 H0 -- -- -- -- -- H4 H3 H2 -- -- -- --
  or.w    \2,\1              ;%-- -- H1 H0 -- -- H1 H0 -- H4 H3 H2 -- H4 H3 H2
  ENDM


BITPLANE_SOFTSCROLL_16PIXEL_LORES MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H5 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
  IFC "","\1"
    FAIL Makro BITPLANE_SOFTSCROLL_16PIXEL_LORES: PF1 X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro BITPLANE_SOFTSCROLL_16PIXEL_LORES: Scratch-Register fehlt
  ENDC
  IFC "","\3"
    and.w    #$003f,\1       ;%-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
  ELSE
    and.w    \3,\1           ;%-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
  ENDC
  ror.b   #2,\1              ;%-- -- -- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2
  lsl.w   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2 -- --
  lsr.b   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
  move.w  \1,\2              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
  lsl.w   #4,\2              ;%-- -- H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
  or.w    \2,\1              ;%-- -- H1 H0 -- -- H1 H0 H5 H4 H3 H2 H5 H4 H3 H2
  ENDM


BITPLANE_SOFTSCROLL_8PIXEL_HIRES MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H3 (optional)
; Rückgabewert: [\1 WORD] BPLCON2 Softscrollwert
  IFC "","\1"
    FAIL Makro BITPLANE_SOFTSCROLL_8PIXEL_HIRES: PF1 X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro BITPLANE_SOFTSCROLL_8PIXEL_HIRES: Scratch-Register fehlt
  ENDC
  IFC "","\3"
    and.w    #$000f,\1       ;%-- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
  ELSE
    and.w    \3,\1           ;%-- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
  ENDC
  lsl.b   #2,\1              ;%-- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0 -- --
  ror.b   #4,\1              ;%-- -- -- -- -- -- -- -- H1 H0 -- -- -- -- H3 H2
  lsl.w   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- H3 H2 -- --
  lsr.b   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- -- -- H3 H2
  move.w  \1,\2              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- -- -- H3 H2
  lsl.w   #4,\2              ;%-- -- H1 H0 -- -- -- -- -- -- H3 H2 -- -- -- --
  or.w    \2,\1              ;%-- -- H1 H0 -- -- H1 H0 -- -- H3 H2 -- -- H3 H2
  ENDM


BITPLANE_SOFTSCROLL_16PIXEL_HIRES MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H4 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
  IFC "","\1"
    FAIL Makro BITPLANE_SOFTSCROLL_16PIXEL_HIRES: PF1 X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro BITPLANE_SOFTSCROLL_16PIXEL_HIRES: Scratch-Register fehlt
  ENDC
  IFC "","\3"
    and.w    #$001f,\1       ;%-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
  ELSE
    and.w    \3,\1           ;%-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
  ENDC
  ror.b   #2,\1              ;%-- -- -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2
  lsl.w   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2 -- --
  lsr.b   #2,\1              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
  move.w  \1,\2              ;%-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
  lsl.w   #4,\2              ;%-- -- H1 H0 -- -- -- -- -- H4 H3 H2 -- -- -- --
  or.w    \2,\1              ;%-- -- H1 H0 -- -- H1 H0 -- H4 H3 H2 -- H4 H3 H2
  ENDM


BITPLANE_SOFTSCROLL_64PIXEL_LORES MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H7 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
  IFC "","\1"
    FAIL Makro BITPLANE_SOFTSCROLL_64PIXEL_LORES: PF1 X-Koordinate fehlt
  ENDC
  IFC "","\2"
    FAIL Makro BITPLANE_SOFTSCROLL_64PIXEL_LORES: Scratch-Register fehlt
  ENDC
  IFC "","\3"
    and.w   #$00ff,\1        ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ELSE
    and.w   \3,\1            ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ENDC
  lsl.w   #2,\1              ;%-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
  ror.b   #4,\1              ;%-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
  lsl.w   #2,\1              ;%-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
  lsr.b   #2,\1              ;%-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
  move.w  \1,\2              ;%-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
  lsl.w   #4,\2              ;%H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
  or.w    \2,\1              ;%H7 H6 H1 H0 H7 H6 H1 H0 H5 H4 H3 H2 H5 H4 H3 H2
  ENDM


ODD_PLAYFIELD_SOFTSCROLL_64PIXEL_LORES MACRO
; \1 WORD: X-Koordinate
; \2 Datenregister D[0..7] Maske für H0-H7 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
  IFC "","\1"
    FAIL Makro ODD_PLAYFIELD_SOFTSCROLL_64PIXEL_LORES: X-Koordinate fehlt
  ENDC
  IFC "","\2"
    and.w   #$00ff,\1        ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ELSE
    and.w   \2,\1            ;%-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
  ENDC
  lsl.w   #2,\1              ;%-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
  ror.b   #4,\1              ;%-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
  lsl.w   #2,\1              ;%-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
  lsr.b   #2,\1              ;%-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
  ENDM

; -- Raster routines

SWAP_PLAYFIELD MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 NUMBER: Anzahl der Playfields [2,3]
; \3 BYTE SIGNED: Anzahl der Bitplanes
; \4 WORD: X-Offset (optional)
; \5 WORD: Y-Offset (optional)
  IFC "","\1"
    FAIL Makro SWAP_PLAYFIELD: Labels-Prefix der Routine fehlt
  ENDC
  IFC "","\2"
    FAIL Makro SWAP_PLAYFIELD: Anzahl der Playfields fehlt
  ENDC
  IFC "","\3"
    FAIL Makro SWAP_PLAYFIELD: Anzahl der Bitplanes fehlt
  ENDC
  CNOP 0,4
swap_playfield\*RIGHT(\1,1)
  IFEQ \2-2
    IFC "","\4"
      move.l  cl1_display(a3),a0
      move.l  \1_construction2(a3),a1
      ADDF.W  cl1_BPL1PTH+2,a0
      move.l  \1_display(a3),\1_construction2(a3)
      move.l  a1,\1_display(a3)
      moveq   #\1_depth3-1,d7   ;Anzahl der Planes
swap_playfield\*RIGHT(\1,1)_loop
      move.w  (a1)+,(a0)       ;BPLxPTH
      addq.w  #8,a0
      move.w  (a1)+,4-8(a0)    ;BPLxPTL
      dbf     d7,SWAP_PLAYFIELD\*RIGHT(\1,1)_loop
      rts
    ELSE
      move.l  cl1_display(a3),a0
      move.l  \1_construction2(a3),a1
      ADDF.W  cl1_BPL1PTH+2,a0
      move.l  \1_display(a3),\1_construction2(a3)
      MOVEF.L (\4/8)+(\5*\1_plane_width*\1_depth3),d1
      move.l  a1,\1_display(a3)
      moveq   #\1_depth3-1,d7   ;Anzahl der Planes
swap_playfield\*RIGHT(\1,1)_loop
      move.l  (a1)+,d0
      add.l   d1,d0
      move.w  d0,4(a0)       ;BPLxPTL
      swap    d0             ;High
      move.w  d0,(a0)        ;BPLxPTH
      addq.w  #8,a0
      dbf     d7,SWAP_PLAYFIELD\*RIGHT(\1,1)_loop
      rts
    ENDC
  ENDC
  IFEQ \2-3
    IFC "","\4"
      move.l  cl1_display(a3),a0
      move.l  \1_construction1(a3),a1
      move.l  \1_construction2(a3),a2
      move.l  \1_display(a3),\1_construction1(a3)
      move.l  a1,\1_construction2(a3)
      ADDF.W  cl1_BPL1PTH+2,a0   
      move.l  a2,\1_display(a3)
      moveq   #\3-1,d7         ;Anzahl der Planes
swap_playfield\*RIGHT(\1,1)_loop
      move.w  (a2)+,(a0)       ;BPLxPTH
      addq.w  #8,a0
      move.w  (a2)+,4-8(a0)    ;BPLxPTL
      dbf     d7,SWAP_PLAYFIELD\*RIGHT(\1,1)_loop
      rts
    ELSE
      move.l  cl1_display(a3),a0
      move.l  \1_construction1(a3),a1
      move.l  \1_construction2(a3),a2
      move.l  \1_display(a3),\1_construction1(a3)
      MOVEF.L (\4/8)+(\5*\1_plane_width*\1_depth3),d1
      move.l  a1,\1_construction2(a3)
      ADDF.W  cl1_BPL1PTH+2,a0   
      move.l  a2,\1_display(a3)
      moveq   #\3-1,d7         ;Anzahl der Planes
swap_playfield\*RIGHT(\1,1)_loop
      move.l  (a2)+,d0
      add.l   d1,d0
      move.w  d0,4(a0)       ;BPLxPTL
      swap    d0             ;High
      move.w  d0,(a0)        ;BPLxPTH
      addq.w  #8,a0
      dbf     d7,SWAP_PLAYFIELD\*RIGHT(\1,1)_loop
      rts
    ENDC
  ENDC
  ENDM