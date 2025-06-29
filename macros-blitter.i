WAITBLIT			MACRO
; Input
; Result
wait_blitter_loop\@
	btst	#DMAB_BLTDONE-8,(a6)
	bne.s	wait_blitter_loop\@
	ENDM


WAITBLITQ			MACRO
; Input
; \1 STRING:	data register for BBUSY bit
; Result
wait_blitter_quick_loop\@
	btst	\1,(a6)
	bne.s	wait_blitter_quick_loop\@
	ENDM


GET_LINE_PARAMETERS		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["AREAFILL"] (optional)
; \3 STRING:	["COPPERUSE"] (optional)
; \4 WORD:	Multiplicator Y offset in playfield (optional)
; \5 STRING:	Hook label for "AREAFILL" mode (optional)
; Global reference
; pf1_plane_width
; pf1_depth3
; Result
	IFC "","\1"
		FAIL Macro GET_LINE_PARAMETERS: Labels prefix missing
	ENDC
	cmp.w	d1,d3
	IFC "AREAFILL","\2"
		beq	\5		; y1 = y2
		bgt.s	\1_get_line_parameters_skip1 ; y1 < y2
	ELSE
		bpl.s	\1_get_line_parameters_skip1 ; y1 <= y2
	ENDC
	exg	d0,d2			; swap x1 with x2
	exg	d1,d3			; swap y1 with y2
\1_get_line_parameters_skip1
	IFC "AREAFILL","\2"
		addq.w	#1,d1		; round edges
	ENDC
	moveq	#BLTCON1F_SUD,d5	; octant #8
	sub.w	d0,d2			; dx = x2-x1
	bpl.s	\1_get_line_parameters_skip2
	addq.w	#BLTCON1F_AUL,d5	; octant #5
	neg.w	d2
\1_get_line_parameters_skip2
	sub.w	d1,d3			; dy = y2-y1
	ror.l	#4,d0			; adjust shift bits
	IFC "","\4"
		MULUF.W	(pf1_plane_width*pf1_depth3)/2,d1,d4 ; y offset in playfield
	ELSE
		MULUF.W	(\4)/2,d1,d4	; y offset in playfield
	ENDC
	add.w	d0,d1			; x + y offset
	MULUF.L	2,d1,d0			; adjust offset
	cmp.w	d2,d3			; dx <= dy ?
	ble.s	\1_get_line_parameters_skip3
	SUBF.W	BLTCON1F_SUD,d5
	exg	d2,d3			; swap dx with dy
	MULUF.W	2,d5,d0			; octant #6,7
\1_get_line_parameters_skip3
	MULUF.W 4,d3,d0			; 4*dy
	move.w	d5,d0			; octant
	move.w	d3,d4			; 4*dy
	swap	d4			; high word: 4*dy
	MULUF.W	2,d2,d4			; dx*2
	move.w	d3,d4			; low word: 4*dy
	sub.w	d2,d3			; (4*dy)-(2*dx)
	bpl.s	\1_get_line_parameters_skip4
	or.w	#BLTCON1F_SIGN,d0
\1_get_line_parameters_skip4
	IFC "","\3"
		MULUF.W	2,d2,d5		; 2*(2*dx) = 4*dx
		sub.w	d2,d4		; low word: (4*dy)-(4*dx)
		addq.w	#1*4,d2		; (4*dx)+(1*4)
		MULUF.W WORD_BITS,d2,d5	; ((4*dx)+(1*4))*16 = length
		addq.w	#WORD_SIZE,d2	; width
	ENDC
	ENDM
