WAITBLITTER MACRO
wait_blit\@
  btst    #DMAB_BLTDONE-8,(a6) ;ggf. auf Blitter warten
  bne.s   wait_blit\@        ;Wenn False -> Schleife
  ENDM


WAITBLITTERQ MACRO
; \1 ... Datenregister mit BBUSY-Bit
wait_blit_quick\@
  btst    \1,(a6)            ;ggf. auf Blitter warten
  bne.s   wait_blit_quick\@  ;Wenn False -> Schleife
  ENDM


GET_LINE_PARAMETERS MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 STRING: "AREAFILL" (optional)
; \3 STRING: "COPPERUSE" (optional)
; \4 WORD: Multiplikator für Y-Offset in Bild
  IFC "","\1"
    FAIL Makro GET_LINE_PARAMETERS: Labels-Prefix fehlt
  ENDC
  cmp.w   d1,d3
  IFC "AREAFILL","\2"
    beq     \1_draw_lines_no_line ;Wenn Y1 = Y2 -> verzweige
    bgt.s   \1_draw_lines_delta_y_positive y2 ;Wenn Y1 < Y2  -> verzweige
  ELSE
    bpl.s   \1_draw_lines_delta_y_positive y2 ;Wenn Y1 <= Y2  -> verzweige
  ENDC
  exg     d0,d2              ;X1 mit X2 vertauschen
  exg     d1,d3              ;Y1 mit Y2 vertauschen
\1_draw_lines_delta_y_positive
  IFC "AREAFILL","\2"
    addq.w  #1,d1            ;Für stumpfe Kanten
  ENDC
  moveq   #BLTCON1F_SUD,d5   ;Octant #8
  sub.w   d0,d2              ;dx = x2-x1
  bpl.s   \1_draw_lines_delta_x_positive ;Wenn dx = positiv -> verzweige
  addq.w  #BLTCON1F_AUL,d5   ;Octant #5
  neg.w   d2                 ;Vorzeichen umdrehen
\1_draw_lines_delta_x_positive
  sub.w   d1,d3              ;dy = y2-y1
  ror.l   #4,d0              ;Shift-Bits in richtige Position bringen
  IFC "","\4"
    MULUF.W (pf1_plane_width*pf1_depth3)/2,d1,d4 ;Y-Offset in Bild
  ELSE
    MULUF.W (\4)/2,d1,d4     ;Y-Offset in Bild
  ENDC
  add.w   d0,d1              ;Y + X-Offset
  MULUF.W 2,d1               ;X/Y-Offset korrigieren
  cmp.w   d2,d3              ;dx <= dy ?
  ble.s   \1_draw_lines_delta_positive  ;Ja  -> verzweige
  SUBF.W  BLTCON1F_SUD,d5
  exg     d2,d3              ;dx mit dy vertauschen
  MULUF.W 2,d5               ;Octant #6,7
\1_draw_lines_delta_positive
  MULUF.W 4,d3               ;dy*4
  move.w  d5,d0              ;Oktanten retten
  move.w  d3,d4              ;4*dy retten
  swap    d4                 ;Bits 16-31: 4*dy
  MULUF.W 2,d2               ;dx*2
  move.w  d3,d4              ;Bits 0-15: 4*dy
  sub.w   d2,d3              ;(4*dy)-(2*dx)
  bpl.s   \1_draw_lines_no_sign_bit ;Wenn positiv -> verzweige
  or.w    #BLTCON1F_SIGN,d0  ;Vorzeichenbit setzen
\1_draw_lines_no_sign_bit
  IFC "","\3"
    MULUF.W 2,d2             ;2*(2*dx) = 4*dx
    sub.w   d2,d4            ;Bits 0-15: (4*dy)-(4*dx)
    addq.w  #1*4,d2          ;(4*dx)+(1*4)
    MULUF.W 16,d2            ;((4*dx)+(1*4))*16 = Länge der Linie
    addq.w  #2,d2            ;Breite = 1 Wort
  ENDC
  ENDM
