; -- Inits --

INIT_BPLCON0_BITS		MACRO
; \1 STRING: Label
; \2 NUMBER: Playfield-Depth
; \3 STRING: Zusätzliche Bits (optiona)
	IFC "","\1"
		FAIL Makro INIT_BPLCON0_BITS: Label fehlt
	ENDC
	IFC "","\2"
		FAIL Makro INIT_BPLCON0_BITS: PF-Depth fehlt
	ENDC
	IFC "","\3"
\1 EQU BPLCON0F_ECSENA|((\2>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((\2&$07)*BPLCON0F_BPU0)
	ELSE
\1 EQU BPLCON0F_ECSENA|((\2>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((\2&$07)*BPLCON0F_BPU0)|\3
	ENDC
	ENDM


INIT_BPLCON4_BITS		MACRO
; \1 STRING: Label
; \2 NUMBER: Switchwert Bitplanes
; \3 NUMBER: Switchwert ungerade Sprites
; \4 NUMBER: Switchwert gerade Sprites
	IFC "","\1"
		FAIL Makro INIT_BPLCON4_BITS: Label fehlt
	ENDC
	IFC "","\2"
		FAIL Makro INIT_BPLCON4_BITS: Switchwert Bitplanes fehlt
	ENDC
	IFC "","\3"
		FAIL Makro INIT_BPLCON4_BITS: Switchwert ungerade Sprites fehlt
	ENDC
	IFC "","\4"
		FAIL Makro INIT_BPLCON4_BITS: Switchwert gerade Sprites fehlt
	ENDC
\1 EQU (BPLCON4F_BPLAM0*\2)|(BPLCON4F_OSPRM4*\3)|(BPLCON4F_ESPRM4*\4)
	ENDM


INIT_DIWSTRT_BITS		MACRO
; \1 STRING: Label
	IFC "","\1"
		FAIL Makro INIT_DIWSTRT_BITS: Label fehlt
	ENDC
\1 EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
	ENDM


INIT_DIWSTOP_BITS		MACRO
; \1 STRING: Label
	IFC "","\1"
		FAIL Makro INIT_DIWSTOP_BITS: Label fehlt
	ENDC
\1 EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
	ENDM


INIT_DIWHIGH_BITS		MACRO
; \1 STRING: Label
; \2 STRING: zusätzliche Bits (optional)
	IFC "","\1"
		FAIL Makro INIT_DIWHIGH_BITS: Label fehlt
	ENDC
	IFC "","\2"
\1 EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
	ELSE
\1 EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)|\2
	ENDC
	ENDM


; -- Raster-Routines --

DUALPF_SOFTSCROLL_64PIXEL_LORES	MACRO
; \1 WORD: PF1 X-Koordinate
; \2 WORD: PF2 X-Koordinate
; \3 Datenregister D[0..7] Maske für H0-H7 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro DUALPF_SOFTSCROLL_64PIXEL_LORES: PF1 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		FAIL Makro DUALPF_SOFTSCROLL_64PIXEL_LORES: PF1 Y-Koordinate fehlt
	ENDC
	IFC "","\3"
		and.w	 #$00ff,\1	; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ELSE
		and.w	 \3,\1		; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ENDC
	IFC "","\3"
		and.w	 #$00ff,\2	; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ELSE
		and.w	 \3,\2		; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ENDC
	lsl.w	#2,\1			; %-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
	lsl.w	#2,\2			; %-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
	ror.b	#4,\1			; %-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
	ror.b	#4,\2			; %-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
	lsl.w	#2,\2			; %-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
	lsr.b	#2,\2			; %-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
	lsl.b	#4,\2			; %H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
	or.w	\2,\1			; %H7 H6 H1 H0 H7 H6 H1 H0 H5 H4 H3 H2 H5 H4 H3 H2
	ENDM


PF_SOFTSCROLL_8PIXEL_LORES	MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H4 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro PF_SOFTSCROLL_8PIXEL_LORES: PF1 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		FAIL Makro PF_SOFTSCROLL_8PIXEL_LORES: PF1 Y-Koordinate fehlt
	ENDC
	IFC "","\3"
		and.w	#$001f,\1 	; %-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; %-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ENDC
	lsl.b	#2,\1			; %-- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0 -- --
	ror.b	#4,\1			; %-- -- -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	move.w	\1,\2			; %-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	lsl.w	#4,\2			; %-- -- H1 H0 -- -- -- -- -- H4 H3 H2 -- -- -- --
	or.w	\2,\1			; %-- -- H1 H0 -- -- H1 H0 -- H4 H3 H2 -- H4 H3 H2
	ENDM


PF_SOFTSCROLL_16PIXEL_LORES	MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H5 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro PF_SOFTSCROLL_16PIXEL_LORES: PF1 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		FAIL Makro PF_SOFTSCROLL_16PIXEL_LORES: Scratch-Register fehlt
	ENDC
	IFC "","\3"
		and.w	#$003f,\1	; %-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; %-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ENDC
	ror.b	#2,\1			; %-- -- -- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
	move.w	\1,\2			; %-- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
	lsl.w	#4,\2			; %-- -- H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
	or.w	\2,\1			; %-- -- H1 H0 -- -- H1 H0 H5 H4 H3 H2 H5 H4 H3 H2
	ENDM


ODDPF_SOFTSCROLL_16PIXEL_LORES	MACRO
; \1 WORD: X-Koordinate
; \2 Datenregister D[0..7] Maske für H0-H5 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro ODDPF_SOFTSCROLL_16PIXEL_LORES: PF1 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		and.w	#$003f,\1	; %-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ELSE
		and.w	\2,\1		; %-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ENDC
	ror.b	#2,\1			; %-- -- -- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
	ENDM


EVENPF_SOFTSCROLL_16PIXEL_LORES	MACRO
; \1 WORD: X-Koordinate
; \2 Datenregister D[0..7] Maske für H0-H5 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro EVENPF_SOFTSCROLL_16PIXEL_LORES: PF2 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		and.w	#$003f,\1	; %-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ELSE
		and.w	\2,\1		; %-- -- -- -- -- -- -- -- -- -- H5 H4 H3 H2 H1 H0
	ENDC
	ror.b	#2,\1			; %-- -- -- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- H5 H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- -- H5 H4 H3 H2
	lsl.w	#4,\1			; %-- -- H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
	ENDM


PF_SOFTSCROLL_8PIXEL_HIRES	MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H3 (optional)
; Rückgabewert: [\1 WORD] BPLCON2 Softscrollwert
	IFC "","\1"
		FAIL Makro PF_SOFTSCROLL_8PIXEL_HIRES: PF1 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		FAIL Makro PF_SOFTSCROLL_8PIXEL_HIRES: Scratch-Register fehlt
	ENDC
	IFC "","\3"
		and.w	#$000f,\1 	; %-- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; %-- -- -- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0
	ENDC
	lsl.b	#2,\1			; %-- -- -- -- -- -- -- -- -- -- H3 H2 H1 H0 -- --
	ror.b	#4,\1			; %-- -- -- -- -- -- -- -- H1 H0 -- -- -- -- H3 H2
	lsl.w	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- -- H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- -- -- -- H3 H2
	move.w	\1,\2			; %-- -- -- -- -- -- H1 H0 -- -- -- -- -- -- H3 H2
	lsl.w	#4,\2			; %-- -- H1 H0 -- -- -- -- -- -- H3 H2 -- -- -- --
	or.w	\2,\1			; %-- -- H1 H0 -- -- H1 H0 -- -- H3 H2 -- -- H3 H2
	ENDM


PF_SOFTSCROLL_16PIXEL_HIRES	MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H4 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro PF_SOFTSCROLL_16PIXEL_HIRES: PF1 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		FAIL Makro PF_SOFTSCROLL_16PIXEL_HIRES: Scratch-Register fehlt
	ENDC
	IFC "","\3"
		and.w	#$001f,\1	; %-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; %-- -- -- -- -- -- -- -- -- -- -- H4 H3 H2 H1 H0
	ENDC
	ror.b	#2,\1			; %-- -- -- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	move.w	\1,\2			; %-- -- -- -- -- -- H1 H0 -- -- -- -- -- H4 H3 H2
	lsl.w	#4,\2			; %-- -- H1 H0 -- -- -- -- -- H4 H3 H2 -- -- -- --
	or.w	\2,\1			; %-- -- H1 H0 -- -- H1 H0 -- H4 H3 H2 -- H4 H3 H2
	ENDM


PF_SOFTSCROLL_64PIXEL_LORES	MACRO
; \1 WORD: X-Koordinate
; \2 WORD: Scratch-Register
; \3 Datenregister D[0..7] Maske für H0-H7 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro PF_SOFTSCROLL_64PIXEL_LORES: PF1 X-Koordinate fehlt
	ENDC
	IFC "","\2"
		FAIL Makro PF_SOFTSCROLL_64PIXEL_LORES: Scratch-Register fehlt
	ENDC
	IFC "","\3"
		and.w	#$00ff,\1	; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ELSE
		and.w	\3,\1		; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ENDC
	lsl.w	#2,\1			; %-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
	ror.b	#4,\1			; %-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
	move.w	\1,\2			; %-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
	lsl.w	#4,\2			; %H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2 -- -- -- --
	or.w	\2,\1			; %H7 H6 H1 H0 H7 H6 H1 H0 H5 H4 H3 H2 H5 H4 H3 H2
	ENDM


ODDPF_SOFTSCROLL_64PIXEL_LORES	MACRO
; \1 WORD: X-Koordinate
; \2 Datenregister D[0..7] Maske für H0-H7 (optional)
; Rückgabewert: [\1 WORD] BPLCON1 Softscrollwert
	IFC "","\1"
		FAIL Makro ODDPF_SOFTSCROLL_64PIXEL_LORES: X-Koordinate fehlt
	ENDC
	IFC "","\2"
		and.w	#$00ff,\1	; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ELSE
		and.w	\2,\1		; %-- -- -- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0
	ENDC
	lsl.w	#2,\1			; %-- -- -- -- -- -- H7 H6 H5 H4 H3 H2 H1 H0 -- --
	ror.b	#4,\1			; %-- -- -- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2
	lsl.w	#2,\1			; %-- -- -- -- H7 H6 H1 H0 -- -- H5 H4 H3 H2 -- --
	lsr.b	#2,\1			; %-- -- -- -- H7 H6 H1 H0 -- -- -- -- H5 H4 H3 H2
	ENDM


; -- Raster routines --

SWAP_PLAYFIELD			MACRO
; \1 STRING: Labels-Prefix der Routine
; \2 NUMBER: Anzahl der Playfields [2,3]
; \3 BYTE SIGNED: Anzahl der Bitplanes Playfield
	IFC "","\1"
		FAIL Makro SWAP_PLAYFIELD: Labels-Prefix der Routine fehlt
	ENDC
	IFC "","\2"
		FAIL Makro SWAP_PLAYFIELD: Anzahl der Playfields fehlt
	ENDC
swap_playfield\*RIGHT(\1,1)
	IFEQ \2-2
		move.l	\1_construction2(a3),a0
		move.l	\1_display(a3),\1_construction2(a3)
		move.l	a0,\1_display(a3)
	ENDC
	IFEQ \2-3
		move.l	\1_construction1(a3),a0
		move.l	\1_construction2(a3),a1
		move.l	\1_display(a3),\1_construction1(a3)
		move.l	a0,\1_construction2(a3)
		move.l	a1,\1_display(a3)
	ENDC
	rts
	ENDM


SET_PLAYFIELD			MACRO
; Input
; \1 STRING:		Labels-Prefix der Routine
; \2 BYTE SIGNED:	Anzahl der Bitplanes Playfield
; \3 WORD:		X-Offset in Pixeln (optional)
; \4 WORD:		Y-Offset in Zeilen (optional)
; Result
	IFC "","\1"
		FAIL Makro SET_PLAYFIELD: Labels-Prefix der Routine fehlt
	ENDC
	IFC "","\2"
		FAIL Makro SET_PLAYFIELD: Anzahl der Bitplanes fehlt
	ENDC
	CNOP 0,4
set_playfield1
	IFC "","\3"
		move.l	cl1_display(a3),a0
		ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
		move.l	\1_display(a3),a1
		moveq	#\2-1,d7	; Anzahl der Planes
set_playfield1_loop
		move.w	(a1)+,(a0)	; BPLxPTH
		addq.w	#QUADWORD_SIZE,a0
		move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
		dbf	d7,set_playfield1_loop
	ELSE
		MOVEF.L (\3/8)+(\4*\1_plane_width*\2),d1
		move.l	cl1_display(a3),a0
		ADDF.W	cl1_BPL1PTH+WORD_SIZE,a0
		move.l	\1_display(a3),a1
		moveq	#\2-1,d7 ; Anzahl der Planes
set_playfield1_loop
		move.l	(a1)+,d0
		add.l	d1,d0
		move.w	d0,LONGWORD_SIZE(a0) ; BPLxPTL
		swap	d0		; High
		move.w	d0,(a0)		; BPLxPTH
		addq.w	#QUADWORD_SIZE,a0
		dbf	d7,set_playfield1_loop
	ENDC
	rts
	ENDM


SET_DUAL_PLAYFIELD		MACRO
; Input
; \1 STRING:		Labels-Prefix der Routine
; \2 BYTE SIGNED:	Anzahl der Bitplanes Playfield
; \3 WORD:		X-Offset in Pixeln (optional)
; \4 WORD:		Y-Offset in Zeilen (optional)
	IFC "","\1"
		FAIL Makro SET_DUAL_PLAYFIELD: Labels-Prefix der Routine fehlt
	ENDC
	IFC "","\2"
		FAIL Makro SET_DUAL_PLAYFIELD: Anzahl der Bitplanes fehlt
	ENDC
	CNOP 0,4
set_dual_playfield\*RIGHT(\1,1)
	IFC "","\3"
		move.l	cl1_display(a3),a0
		ADDF.W	cl1_BPL\*RIGHT(\1,1)PTH+WORD_SIZE,a0
		move.l	\1_display(a3),a1
		moveq	#\2-1,d7	; Anzahl der Planes
set_dual_playfield\*RIGHT(\1,1)_loop
		move.w	(a1)+,(a0)	; BPLxPTH
		ADDF.W	QUADWORD_SIZE*2,a0
		move.w	(a1)+,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a0) ; BPLxPTL
		dbf	d7,set_dual_playfield\*RIGHT(\1,1)_loop
		rts
	ELSE
		MOVEF.L (\3/8)+(\4*\1_plane_width*\2),d1
		move.l	cl1_display(a3),a0
		ADDF.W	cl1_BPL\*RIGHT(\1,1)PTH+WORD_SIZE,a0
		move.l	\1_display(a3),a1
		moveq	#\1_depth3-1,d7 ; Anzahl der Planes
set_dual_playfield\*RIGHT(\1,1)_loop
		move.l	(a1)+,d0
		add.l	d1,d0
		move.w	d0,LONGWORD_SIZE(a0) ; BPLxPTL
		swap	d0		; High
		move.w	d0,(a0)		; BPLxPTH
		ADDF.W	QUADWORD_SIZE*2,a0
		dbf	d7,set_dual_playfield\*RIGHT(\1,1)_loop
		rts
	ENDC
	ENDM
