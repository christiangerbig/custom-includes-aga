COP_MOVE			MACRO
; Input
; \1 WORD:	Source 16 bit value
; \2 WORD:	CUSTOM register offset
; Result
	IFC "","\1"
		FAIL Macro COP_MOVE: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_MOVE: Custom register offset missing
	ENDC
	move.w	#\2,(a0)+		; CUSTOM register offset
	move.w	\1,(a0)+		; register value
	ENDM


COP_MOVEQ			MACRO
; Input
; \1 WORD:	Source 16 bit value
; \2 WORD:	CUSTOM register offset
; Result
	IFC "","\1"
		FAIL Macro COP_MOVEQ: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_MOVEQ: Custom register offset missing
	ENDC
	move.l	#((\2)<<16)|((\1)&$ffff),(a0)+ ; CMOVE
	ENDM


COP_WAIT			MACRO
; Input
; \1 BYTE:	X position (bits 2..8)
; \2 BYTE: 	Y Position (bits 0..7)
; Result
	IFC "","\1"
		FAIL Macro COP_WAIT: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_WAIT: Y osition missing
	ENDC
	move.l	#((((\2)<<24)|((((\1)/4)*2)<<16))|$10000)|$fffe,(a0)+ ; CWAIT
	ENDM


COP_WAITBLIT			MACRO
; Input
; Result
	move.l	#$00010000,(a0)+	; wait for blitter
	ENDM


COP_WAITBLIT2			MACRO
; Input
; \1 BYTE:	X position (bits 2..8)
; \2 BYTE:	Y Position (bits 0..7)
; Result
	IFC "","\1"
		FAIL Macro COP_WAITBLIT2: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_WAITBLIT2: Y position missing
	ENDC
	move.l	#((((\2)<<24)|((((\1)/4)*2)<<16))|$10000)|$7ffe,(a0)+ ; CWAIT & wait for blitter
	ENDM


COP_SKIP			MACRO
; Input
; \1 BYTE:	X position (bits 2..8)
; \2 BYTE:	Y Position (bits 0..7)
; Result
	IFC "","\1"
		FAIL Macro COP_SKIP: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_SKIP: Y position missing
	ENDC
	move.l	#((\2)<<24)|((((\1)/4)*2)<<16)|$ffff,(a0)+ ; CSKIP
	ENDM


COP_LISTEND MACRO
; Input
; Result
; a0.l	Pointer CWAIT for copperlist end
	moveq	#-2,d0			; CWAIT impossible horizontal position
	move.l	d0,(a0)
	ENDM


COP_INIT_PLAYFIELD_REGISTERS	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["NOBITPLANES", "NOBITPLANESSPR", "BLANK", "BLANKSPR"] type of display
; \3 STRING:	["vp1", "vp2".."vpn"] viewport label prefix (optional)
; \4 STRING:	["TRIGGERBITPLANES"] to initialize BPLCON0 (optinal)
; Global reference
; diwstrt_bits
; diwstop_bits
; ddfstrt_bits
; ddfstop_bits
; bplcon0_bits
; bplcon1_bits
; bplcon2_bits
; bplcon3_bits
; bplcon4_bits
; diwhigh_bits
; fmode_bits
; pf1_plane_moduli
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_PLAYFIELD_REGISTERS: Labels prefix missing
	ENDC
	IFC "","\1"
		FAIL Macro COP_INIT_PLAYFIELD_REGISTERS: Type of display missing
	ENDC
	CNOP 0,4
	IFC "","\3"
\1_init_playfield_props
		IFC "","\2"
			COP_MOVEQ diwstrt_bits,DIWSTRT
			COP_MOVEQ diwstop_bits,DIWSTOP
			COP_MOVEQ ddfstrt_bits,DDFSTRT
			COP_MOVEQ ddfstop_bits,DDFSTOP
			COP_MOVEQ bplcon0_bits,BPLCON0
			COP_MOVEQ bplcon1_bits,BPLCON1
			COP_MOVEQ bplcon2_bits,BPLCON2
			COP_MOVEQ bplcon3_bits1,BPLCON3
			COP_MOVEQ pf1_plane_moduli,BPL1MOD
			IFGT pf_depth-1
				IFD pf2_plane_moduli
					COP_MOVEQ pf2_plane_moduli,BPL2MOD
				ELSE
					COP_MOVEQ pf1_plane_moduli,BPL2MOD
				ENDC
			ENDC
			COP_MOVEQ bplcon4_bits,BPLCON4
			COP_MOVEQ diwhigh_bits,DIWHIGH
			COP_MOVEQ fmode_bits,FMODE
			rts
		ELSE
			IFC "NOBITPLANES","\2"
				COP_MOVEQ diwstrt_bits,DIWSTRT
				COP_MOVEQ diwstop_bits,DIWSTOP
				COP_MOVEQ bplcon0_bits,BPLCON0
				COP_MOVEQ bplcon3_bits1,BPLCON3
				COP_MOVEQ bplcon4_bits,BPLCON4
				COP_MOVEQ diwhigh_bits,DIWHIGH
				rts
			ENDC
			IFC "NOBITPLANESSPR","\2"
				COP_MOVEQ diwstrt_bits,DIWSTRT
				COP_MOVEQ diwstop_bits,DIWSTOP
				COP_MOVEQ bplcon0_bits,BPLCON0
				COP_MOVEQ bplcon3_bits1,BPLCON3
				COP_MOVEQ bplcon4_bits,BPLCON4
				COP_MOVEQ diwhigh_bits,DIWHIGH
				COP_MOVEQ fmode_bits,FMODE
				rts
			ENDC
			IFC "BLANK","\2"
				COP_MOVEQ bplcon0_bits,BPLCON0
				COP_MOVEQ bplcon3_bits1,BPLCON3
				rts
			ENDC
			IFC "BLANKSPR","\2"
				COP_MOVEQ bplcon0_bits,BPLCON0
				COP_MOVEQ bplcon3_bits1,BPLCON3
				COP_MOVEQ bplcon4_bits,BPLCON4
				COP_MOVEQ fmode_bits,FMODE
				rts
			ENDC
		ENDC
	ELSE
\1_\3_init_playfield_props
		COP_MOVEQ \3_ddfstrt_bits,DDFSTRT
		COP_MOVEQ \3_ddfstop_bits,DDFSTOP
		IFC "TRIGGERBITPLANES","\4"
			COP_MOVEQ \3_bplcon0_bits,BPLCON0
		ENDC
		COP_MOVEQ \3_bplcon1_bits,BPLCON1
		COP_MOVEQ \3_bplcon2_bits,BPLCON2
		COP_MOVEQ \3_bplcon3_bits1,BPLCON3
		COP_MOVEQ \3_pf1_plane_moduli,BPL1MOD
		IFD \3_pf2_plane_moduli
			COP_MOVEQ \3_pf2_plane_moduli,BPL2MOD
		ELSE
			COP_MOVEQ \3_pf1_plane_moduli,BPL2MOD
		ENDC
		COP_MOVEQ \3_bplcon4_bits,BPLCON4
		COP_MOVEQ \3_fmode_bits,FMODE
		rts
	ENDC
	ENDM


COP_INIT_BITPLANE_POINTERS	MACRO
; Input
; \1 STRING:	Labels prefix
; Global reference
; pf_depth
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_BITPLANE_POINTERS: Labels prefix missing
	ENDC
	CNOP 0,4
\1_init_bitplane_pointers
	move.w	#BPL1PTH,d0
	moveq	#(pf_depth*2)-1,d7
\1_init_bitplane_pointers_loop
	move.w	d0,(a0)			; BPLxPTH/L
	addq.w	#WORD_SIZE,d0		; next register
	addq.w	#LONGWORD_SIZE,a0	; next entry in cl
	dbf	d7,\1_init_bitplane_pointers_loop
	rts
	ENDM


COP_SET_BITPLANE_POINTERS	MACRO
; Input
; \1 STRING:		Labels prefix
; \2 STRING:		["construction1","construction2","display"]
; \3 BYTE SIGNED:	Number of bitplanes playfield1
; \4 BYTE SIGNED:	Number of bisplanes playfield2 (optional)
; \5 WORD:		X offset (optional)
; \6 WORD:		Y offset (optional)
; Global reference
; pf1_display
; pf2_display
; pf1_plane_width
; pf2_plane_width
; pf1_depth3
; Result
	IFC "","\1"
		FAIL Macro COP_SET_BITPLANE_POINTERS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_SET_BITPLANE_POINTERS: Name of copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_SET_BITPLANE_POINTERS: Number of bitplanes playfield1 missing
	ENDC
	CNOP 0,4
\1_set_bitplane_pointers
	IFC "","\4"
		IFC "","\5"
			move.l	\1_\2(a3),a0
			ADDF.W	\1_BPL1PTH+WORD_SIZE,a0
			move.l	pf1_display(a3),a1
			moveq	#\3-1,d7 ; number of bitplanes
\1_set_bitplane_pointers_loop
			move.w	(a1)+,(a0) ; BPLxPTH
			addq.w	#QUADWORD_SIZE,a0
			move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
			dbf	d7,\1_set_bitplane_pointers_loop
		ELSE
			MOVEF.L	(\5/8)+(\6*pf1_plane_width*pf1_depth3),d1
			move.l	\1_\2(a3),a0
			ADDF.W	\1_BPL1PTH+WORD_SIZE,a0
			move.l	pf1_display(a3),a1
			moveq	#\3-1,d7 ; number of bitplanes
\1_set_bitplane_pointers_loop
			move.l	(a1)+,d0
			add.l	d1,d0
			move.w	d0,LONGWORD_SIZE(a0) ; BPLxPTL
			swap	d0
			move.w	d0,(a0)	; BPLxPTH
			addq.w	#QUADWORD_SIZE,a0
			dbf	d7,\1_set_bitplane_pointers_loop
		ENDC
	ELSE
; Playfield 1
		move.l	\1_\2(a3),a0
		lea	\1_BPL2PTH+2(a0),a1
		ADDF.W	\1_BPL1PTH+WORD_SIZE,a0
		move.l	pf1_display(a3),a2
		moveq	#\3-1,d7	; number of bitplanes
\1_set_bitplane_pointers_loop1
		move.w	(a2)+,(a0)	; BPLxPTH
		ADDF.W	QUADWORD_SIZE*2,a0
		move.w	(a2)+,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a0) ; BPLxPTL
		dbf	d7,\1_set_bitplane_pointers_loop1
; Playfield 2
		move.l	pf2_display(a3),a2
		moveq	#\4-1,d7	; number of bitplanes
\1_set_bitplane_pointers_loop2
		move.w	(a2)+,(a1)	; BPLxPTH
		ADDF.W	QUADWORD_SIZE*2,a1
		move.w	(a2)+,LONGWORD_SIZE-(QUADWORD_SIZE*2)(a1) ; BPLxPTL
		dbf	d7,\1_set_bitplane_pointers_loop2
	ENDC
	rts
	ENDM


COP_INIT_SPRITE_POINTERS	MACRO
; Input
; \1 STRING:	Labels prefix
; Global reference
; spr_number
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_SPRITE_POINTERS: Labels prefix missing
	ENDC
	CNOP 0,4
\1_init_sprite_pointers
	move.w	#SPR0PTH,d0
	moveq	#(spr_number*2)-1,d7
\1_init_sprite_pointers_loop
	move.w	d0,(a0)			; SPRxPTH/L
	addq.w	#WORD_SIZE,d0		; next register
	addq.w	#LONGWORD_SIZE,a0
	dbf	d7,\1_init_sprite_pointers_loop
	rts
	ENDM


COP_SET_SPRITE_POINTERS		MACRO
; Input
; \1 STRING:		Labels prefix
; \2 STRING:		["construction1", "construction2", "display"] name of copperlist
; \3 BYTE SIGNED:	[1..8] number of sprites
; \4 NUMBER:		[1..7] sprite structure index (optional)
; Global reference
; spr_pointers_display
; Result
	IFC "","\1"
		FAIL Macro COP_SET_SPRITE_POINTERS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_SET_SPRITE_POINTERS: Name of copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_SET_SPRITE_POINTERS: Number of sprites missing
	ENDC
	CNOP 0,4
\1_set_sprite_pointers
	move.l	\1_\2(a3),a0
	IFC "","\4"
		lea	spr_pointers_display(pc),a1
		ADDF.W	\1_SPR0PTH+WORD_SIZE,a0
	ELSE
		lea	spr_pointers_display+(\4*LONGWORD_SIZE)(pc),a1 ; with index
		ADDF.W	\1_SPR\3PTH+WORD_SIZE,a0
	ENDC
	moveq	#\3-1,d7		; number of sprites
\1_set_sprite_pointers_loop
	move.w	(a1)+,(a0)		; SPRxPTH
	addq.w	#QUADWORD_SIZE,a0
	move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; SPRxPTL
	dbf	d7,\1_set_sprite_pointers_loop
	rts
	ENDM


COP_SELECT_COLOR_HIGH_BANK	MACRO
; Input
; \1 NUMBER:	[0..7] color bank number
; \2 WORD:	BPLCON3 bits (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_SELECT_COLOR_HIGH_BANK MACRO: Color bank number missing
	ENDC
		COP_MOVEQ bplcon3_bits1|(BPLCON3F_BANK0*\1),BPLCON3
	IFNC "","\2"
		or.w	#\2,-WORD_SIZE(a0)
	ENDC
	ENDM


COP_SELECT_COLOR_LOW_BANK	MACRO
; Input
; \1 NUMBER:	[0..7] color bank number
; \2 WORD:	BPLCON3 bits (optional)
; Global reference
; bplcon3_bits2
; Result
	IFC "","\1"
		FAIL Macro COP_SELECT_COLOR_LOW_BANK MACRO: Color bank number missing
	ENDC
		COP_MOVEQ bplcon3_bits2|(BPLCON3F_BANK0*\1),BPLCON3
	IFNC "","\2"
		or.w	#\2,-WORD_SIZE(a0)
	ENDC
	ENDM


COP_INIT_COLOR_HIGH		MACRO
; Input
; \1 WORD:		First color register offset
; \2 BYTE_SIGNED:	Number of colors
; \3 POINTER:		Color table (optional)
; Global reference
; cop_init_colors
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COLOR_HIGH: First color register offset missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_COLOR_HIGH: Number of colors missing
	ENDC
	move.w	#\1,d3			; 1st color register offset
	moveq	#\2-1,d7		; number of colors
	IFNC "","\3"
		lea	\3(pc),a1	; color table
	ENDC
	bsr	cop_init_high_colors
	ENDM


COP_INIT_COLOR_LOW		MACRO
; Input
; \1 WORD:		First color register offset
; \2 BYTE_SIGNED:	  Number of colors
; \3 POINTER:		Color table (optional)
; Global reference
; cop_init_colors
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COLOR_LOW: First color register offset missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_COLOR_LOW: Number of colors missing
	ENDC
	move.w	#\1,d3			; 1st color register offset
	moveq	#\2-1,d7		; number of colors
	IFNC "","\3"
		lea	\3(pc),a1	; color table
	ENDC
	bsr	cop_init_low_colors
	ENDM


COP_INIT_COLOR00_SCREEN		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["YWRAP"] (optional)
; Global reference
; bplcon3_bits1
; bplcon3_bits2
; color00_high_bits
; color00_low_bits
; _vstart1
; _hstart1
; _display_y_size
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COLOR00_SCREEN: Labels prefix missing
	ENDC
	CNOP 0,4
\1_init_color00
	move.l	#(((\1_vstart1<<24)|(((\1_hstart1/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#(BPLCON3<<16)+bplcon3_bits1,d1
	move.l	#(COLOR00<<16)+color00_high_bits,d2
	move.l	#(BPLCON3<<16)+bplcon3_bits2,d3
	move.l	#(COLOR00<<16)+color00_low_bits,d4
	IFC "YWRAP","\2"
		move.l	#(((CL_Y_WRAPPING<<24)|(((\1_hstart1/4)*2)<<16))|$10000)|$fffe,d5 ; CWAIT
	ENDC
	move.l	#$01000000,d6
	MOVEF.W	\1_display_y_size-1,d7
\1_init_color00_loop
	move.l	d0,(a0)+		; CWAIT
	move.l	d1,(a0)+		; BPLCON3
	move.l	d2,(a0)+		; COLOR00
	move.l	d3,(a0)+		; BPLCON3
	move.l	d4,(a0)+		; COLOR00
	IFC "YWRAP","\2"
		COP_MOVEQ 0,NOOP
		cmp.l	d5,d0		; y wrapping ?
		bne.s	\1_init_color00_skip
		subq.w	#LONGWORD_SIZE,a0
		COP_WAIT CL_X_WRAPPING,CL_Y_WRAPPING ; patch cl
\1_init_color00_skip
	ENDC
	add.l	d6,d0			; next line
	dbf	d7,\1_init_color00_loop
	rts
	ENDM


COP_RESET_COLOR00		MACRO
; Input
; \1 STRING:	["cl1", "cl2"] label prefix copperlist
; \2 WORD:	X position
; \3 WORD:	Y postion
; Global reference
; bplcon3_bits1
; bplcon3_bits2
; color00_high_bits
; color00_low_bits
; Result
	IFC "","\1"
		FAIL Macro COP_RESET_COLOR00: Label prefix copperlist missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_RESET_COLOR00: X position missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_RESET_COLOR00: Y position missing
	ENDC
	CNOP 0,4
\1_reset_color00
	COP_WAIT \2,(\3)&$ff
	COP_MOVEQ bplcon3_bits1,BPLCON3
	COP_MOVEQ color00_high_bits,COLOR00
	COP_MOVEQ bplcon3_bits2,BPLCON3
	COP_MOVEQ color00_low_bits,COLOR00
	rts
	ENDM


COP_INIT_BPLCON4_CHUNKY	MACRO
; Input
; \1 STRING:	["cl1", "cl2"] label prefix copperlist
; \2 NUMBER:	HSTART
; \3 NUMBER:	VSTART
; \4 NUMBER:	Width
; \5 NUMBER:	Height
; \6 BOOLEAN:	TRUE = open border before display window start
; \7 BOOLEAN:	TRUE = quick clear
; \8 BOOLEAN:	TRUE = background effect
; \9 LONGWORD:	CMOVE value,register / STRING: ["OVERSCAN"] (optional)
; Global reference
; bplcon3_bits1
; bplcon3_bits2
; bplcon3_bits3
; bplcon3_bits4
; bplcon4_bits
; fmode_bits
; fmode_bits2
; color00_high_bits
; color00_low_bits
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: Label prefix copperlist missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: HSTART missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: VSTART missing
	ENDC
	IFC "","\4"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: Width missing
	ENDC
	IFC "","\5"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: Height missing
	ENDC
	IFC "","\6"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: Boolean open border missing
	ENDC
	IFC "","\7"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: Boolean quick clear missing
	ENDC
	IFC "","\8"
		FAIL Macro COP_INIT_BPLCON4_CHUNKY: Boolean background effect missing
	ENDC
	CNOP 0,4
\1_init_bplcon4_chunky
	IFNE \8
		move.l	#(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
		move.l	#(BPLCON4<<16)|(bplcon4_bits&$00ff),d1
		IFEQ \6
			IFNC "","\9"
				IFNC "OVERSCAN","\9"
					move.l	#\9,d2
				ELSE
					move.l	#BPL1DAT<<16,d2
				ENDC
			ELSE
				move.l	#BPL1DAT<<16,d2
			ENDC
		ENDC
		moveq	#1,d3
		ror.l	#8,d3		; $01000000
		MOVEF.W \5-1,d7		; number of lines
\1_init_bplcon4_chunky_loop1
		move.l	d0,(a0)+	; WAIT x,y
		IFEQ \6
			IFC "OVERSCAN","\9"
				COP_MOVEQ fmode_bits2,FMODE
				move.l	d2,(a0)+ ; BPL1DAT
				COP_MOVEQ 0,NOOP
				COP_MOVEQ fmode_bits,FMODE
			ELSE
				move.l	d2,(a0)+ ; BPL1DAT
			ENDC
		ENDC
		moveq	#(\4/8)-1,d6	; number of columns
\1_init_bplcon4_chunky_loop2
		move.l	d1,(a0)+	; BPLCON4
		dbf	d6,\1_init_bplcon4_chunky_loop2
		add.l	d3,d0		; next line
		dbf	d7,\1_init_bplcon4_chunky_loop1
		rts
	ELSE
		move.l	a4,-(a7)
		move.l	#(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
		IFEQ \7
			move.l	#(BPLCON3<<16)+bplcon3_bits3,d1 ; high color
		ELSE
			move.l	#(BPLCON3<<16)+bplcon3_bits1,d1 ; high color
		ENDC
		IFEQ \7
			move.l	#(COLOR31<<16)+color00_high_bits,a2
		ELSE
			move.l	#(COLOR00<<16)+color00_high_bits,a2
		ENDC
		IFEQ \7
			move.l	#(COLOR31<<16)+color00_low_bits,a4
		ELSE
			move.l	#(COLOR00<<16)+color00_low_bits,a4
		ENDC
		IFEQ \7
			move.l	#(BPLCON3<<16)+bplcon3_bits4,d3 ; low color
		ELSE
			move.l	#(BPLCON3<<16)+bplcon3_bits2,d3 ; low color
		ENDC
		move.l	#(BPLCON4<<16)|(bplcon4_bits&$00ff),d4
		IFEQ \6
			IFNC "","\9"
				IFNC "OVERSCAN","\9"
					move.l	#\9,d2
				ELSE
					move.l	#BPL1DAT<<16,d2
				ENDC
			ELSE
				move.l	#BPL1DAT<<16,d2
			ENDC
		ENDC
		move.l	#$01000000,d5
		MOVEF.W	\5-1,d7		; number of lines
\1_init_bplcon4_chunky_loop1
		move.l	d0,(a0)+	; CWAIT
		move.l	d1,(a0)+	; BPLCON3
		move.l	a2,(a0)+	; COLOR31/00
		move.l	d3,(a0)+	; BPLCON3
		move.l	a4,(a0)+	; COLOR31/00
		IFEQ \6
			IFC "OVERSCAN","\9"
				COP_MOVEQ fmode_bits2,FMODE
				move.l	d2,(a0)+ ; BPL1DAT
				COP_MOVEQ 0,NOOP
				COP_MOVEQ fmode_bits,FMODE
			ELSE
				move.l	d2,(a0)+ ; BPL1DAT
			ENDC
		ENDC
		moveq	#(\4/8)-1,d6	; number of columns
\1_init_bplcon4_chunky_loop2
		move.l	d4,(a0)+	; BPLCON4
		dbf	d6,\1_init_bplcon4_chunky_loop2
		add.l	d5,d0		; next line
		dbf	d7,\1_init_bplcon4_chunky_loop1
		move.l	(a7)+,a4
		rts
	ENDC
	ENDM


COP_INIT_BPLCON1_CHUNKY	MACRO
; Input
; \1 STRING:	["cl1", "cl2"] label prefix copperlist
; \2 NUMBER:	HSTART
; \3 NUMBER:	VSTART
; \4 NUMBER:	Width
; \5 NUMBER:	Height
; \6 WORD:	Alternative BPLCON1 bits (optinal)
; Global reference
; bplcon1_bits
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: ["cl1", "cl2"] label prefix copperlist missing
	ENDC
	IFC "","\2"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: HSTART missing
	ENDC
	IFC "","\3"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: VSTART missing
	ENDC
	IFC "","\4"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: Width missing
	ENDC
	IFC "","\5"
		FAIL Macro COP_INIT_BPLCON1_CHUNKY: Height missing
	ENDC
	CNOP 0,4
\1_init_bplcon1_chunky
	move.l	#(((\3<<24)|(((\2/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	IFC "","\6"
		move.l	#(BPLCON1<<16)|bplcon1_bits,d1
	ELSE
		move.l	#(BPLCON1<<16)|\6,d1
	ENDC
	move.l	#$01000000,d3
	MOVEF.W \5-1,d7			; number of lines
\1_init_bplcon1_chunky_loop1
	move.l	d0,(a0)+		; CWAIT
	moveq	#(\4/8)-1,d6		; number of columns
\1_init_bplcon1_chunky_loop2
	move.l	d1,(a0)+		; BPLCON1
	dbf	d6,\1_init_bplcon1_chunky_loop2
	add.l	d3,d0			; next line
	dbf	d7,\1_init_bplcon1_chunky_loop1
	rts
	ENDM


COP_INIT_COPINT			MACRO
; Input
; \1 STRING:	["cl1", "cl2"] label prefix copperlist
; \2 WORD:	X position (optional)
; \3 WORD:	Y postion (optional)
; \4 STRING:	["YWRAP"] (optional)
; Result
	IFC "","\1"
		FAIL Macro COP_INIT_COPINT: Label prefix copperlist missing
	ENDC
	CNOP 0,4
\1_init_copper_interrupt
	IFC "YWRAP","\4"
		COP_WAIT CL_X_WRAPPING,CL_Y_WRAPPING ; patch cl
	ENDC
	IFNC "","\2"
		IFNC "","\3"
			COP_WAIT \2,\3
		ENDC
	ENDC
	COP_MOVEQ INTF_COPER|INTF_SETCLR,INTREQ
	rts
	ENDM


COPY_COPPERLIST			MACRO
; Input
; \1 STRING:	["cl1", "cl2"] label prefix copperlist
; \2 NUMBER:	[2, 3] number of copperlists
; Global reference
; _construction1
; _construction2
; _display
; Result
	IFC "","\1"
		FAIL Macro COPY_COPPERLIST: Labels prefix copperlist missing
	ENDC
	IFC "","\2"
		FAIL Macro COPY_COPPERLIST: Number of copperlists missing
	ENDC
	CNOP 0,4
	IFC "cl1","\1"
copy_first_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0 ; source
			move.l	\1_display(a3),a1 ; destination
			MOVEF.W	(copperlist1_size/LONGWORD_SIZE)-1,d7
copy_first_copperlist_loop
			move.l	(a0)+,(a1)+
			dbf	d7,copy_first_copperlist_loop
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0 ; source
			move.l	\1_construction2(a3),a1 ; 1st destination
			move.l	\1_display(a3),a2 ; 2nd destination
			MOVEF.W	(copperlist1_size/LONGWORD_SIZE)-1,d7 ; number of commands
copy_first_copperlist_loop
			move.l	(a0),(a1)+
			move.l	(a0)+,(a2)+
			dbf	d7,copy_first_copperlist_loop
			rts
		ENDC
	ENDC
	IFC "cl2","\1"
copy_second_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0 ; source
			move.l	\1_display(a3),a1 ; destination
			MOVEF.W	(copperlist2_size/LONGWORD_SIZE)-1,d7  ; number of commands
copy_second_copperlist_loop
			move.l	(a0)+,(a1)+
			dbf	d7,copy_second_copperlist_loop
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0 ; source
			move.l	\1_construction2(a3),a1 ; 1st destination
			move.l	\1_display(a3),a2 ; 2nd destination
			MOVEF.W	(copperlist2_size/LONGWORD_SIZE)-1,d7
copy_second_copperlist_loop
			move.l	(a0),(a1)+
			move.l	(a0)+,(a2)+
			dbf	d7,copy_second_copperlist_loop
			rts
		ENDC
	ENDC
	ENDM


CONVERT_IMAGE_TO_RGB4_CHUNKY	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 POINTER:	Color table
; \3 STRING:	["pc", "a3"] pointer base
; Global reference
; _image_data
; _image_plane_width
; _image_depth
; _image_y_size
; _image_color_table
; Result
	IFC "","\1"
		FAIL Macro CONVERT_IMAGE_TO_RGB4_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CONVERT_IMAGE_TO_RGB4_CHUNKY: BPLAM table missing
	ENDC
	IFC "","\3"
		FAIL Macro CONVERT_IMAGE_TO_RGB4_CHUNKY:  base missing
	ENDC
	CNOP 0,4
\1_convert_image_data
	move.l	a4,-(a7)
	lea	\1_image_data,a0
	lea	\1_image_color_table(pc),a1
	IFC "","\2"
		lea	\1_\2(\3),a2
	ELSE
		move.l	\2(\3),a2
	ENDC
	move.w	#\1_image_plane_width*(\1_image_depth-1),a4
	moveq	#16,d1			; color 16
	MOVEF.W	\1_image_y_size-1,d7
\1_convert_image_data_loop1
	moveq	#\1_image_plane_width-1,d6
\1_convert_image_data_loop2
	moveq	#8-1,d5			; number of bits in byte
\1_convert_image_data_loop3
	moveq	#0,d0			; color 00
	IFGE \1_image_depth-1
		btst	d5,(a0)
		beq.s	\1_convert_image_data_skip1
		addq.w	#1,d0		; increase color number
\1_convert_image_data_skip1
	ENDC
	IFGE \1_image_depth-2
		btst	d5,\1_image_plane_width*1(a0)
		beq.s	\1_convert_image_data_skip2
		addq.w	#2,d0		; increase color number
\1_convert_image_data_skip2
	ENDC
	IFGE \1_image_depth-3
		btst	d5,\1_image_plane_width*2(a0)
		beq.s	\1_convert_image_data_skip3
		addq.w	#4,d0		; increase color number
\1_convert_image_data_skip3
	ENDC
	IFGE \1_image_depth-4
		btst	d5,\1_image_plane_width*3(a0)
		beq.s	\1_convert_image_data_skip4
		addq.w	#8,d0		; increase color number
\1_convert_image_data_skip4
	ENDC
	IFEQ \1_image_depth-5
		btst	d5,\1_image_plane_width*4(a0)
		beq.s	\1_convert_image_data_skip5
		add.w	d1,d0		; increase color number
\1_convert_image_data_skip5
	ENDC
	move.w	(a1,d0.l*2),(a2)+	; RGB4
	dbf	d5,\1_convert_image_data_loop3
	addq.w	#BYTE_SIZE,a0		; next byte in source
	dbf	d6,\1_convert_image_data_loop2
	add.l	a4,a0			; skip remaining bitplanes
	dbf	d7,\1_convert_image_data_loop1
	move.l	(a7)+,a4
	rts
	ENDM


CONVERT_IMAGE_TO_HAM6_CHUNKY	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 POINTER:	Color table
; \3 STRING:	["pc", "a3"] pointer base
; Global reference
; _image_data
; _image_plane_width
; _image_depth
; _image_y_size
; _image_color_table
; Result
	IFC "","\1"
		FAIL Macro CONVERT_IMAGE_TO_HAM6_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CONVERT_IMAGE_TO_HAM6_CHUNKY: BPLAM table missing
	ENDC
	IFC "","\3"
		FAIL Macro CONVERT_IMAGE_TO_HAM6_CHUNKY:  base missing
	ENDC
	CNOP 0,4
\1_convert_image_data
	movem.l	a4-a6,-(a7)
	lea	\1_image_data,a0	; source
	lea	\1_image_color_table(pc),a1
	IFC "","\2"
		lea	\1_\2(\3),a2
	ELSE
		move.l	\2(\3),a2
	ENDC
	move.w	#16,a4			; color 16
	move.w	#32,a5			; color 32
	move.w	#\1_image_plane_width*(\1_image_depth-1),a6
	moveq	#$30,d3
	moveq	#MASK_NIBBLE_LOW,d4
	MOVEF.W	\1_image_y_size-1,d7
\1_convert_image_data_loop1
	moveq	#0,d2
	moveq	#\1_image_plane_width-1,d6
\1_convert_image_data_loop2
	moveq	#8-1,d5			; number of bits in byte
\1_convert_image_data_loop3
	moveq	#0,d0			; color 00
	btst	d5,(a0)
	beq.s	\1_convert_image_data_skip1
	addq.w	#1,d0			; increase color number
\1_convert_image_data_skip1
	btst	d5,\1_image_plane_width*1(a0)
	beq.s	\1_convert_image_data_skip2
	addq.w	#2,d0			; increase color number
\1_convert_image_data_skip2
	btst	d5,\1_image_plane_width*2(a0)
	beq.s	\1_convert_image_data_skip3
	addq.w	#4,d0			; increase color number
\1_convert_image_data_skip3
	btst	d5,\1_image_plane_width*3(a0)
	beq.s	\1_convert_image_data_skip4
	addq.w	#8,d0			; increase color number
\1_convert_image_data_skip4
	btst	d5,\1_image_plane_width*4(a0)
	beq.s	\1_convert_image_data_skip5
	add.w	a4,d0			; increase color number
\1_convert_image_data_skip5
	btst	d5,\1_image_plane_width*5(a0)
	beq.s	\1_convert_image_data_skip6
	add.w	a5,d0			; increase color number
\1_convert_image_data_skip6
	move.l	d0,d1			; color number
	and.b	d3,d1			; bit 4 or 5 set ?
	bne.s	\1_convert_image_data_skip7
	move.w	(a1,d0.l*2),d2		; RGB4
	bra.s	\1_convert_image_data_skip10
	CNOP 0,4
\1_convert_image_data_skip7
	cmp.b	#$10,d1			; modify blue ?
	bne.s	\1_convert_image_data_skip8
	and.w	#$ff0,d2
	and.w	d4,d0
	or.b	d0,d2			; updated blue
	bra.s	\1_convert_image_data_skip10
	CNOP 0,4
\1_convert_image_data_skip8
	cmp.b	#$20,d1			; modify red ?
	bne.s	\1_convert_image_data_skip9
	and.w	#$0ff,d2
	and.w	d4,d0
	lsl.w	#8,d0			; adjust bits
	or.w	d0,d2			; updated red
	bra.s	\1_convert_image_data_skip10
	CNOP 0,4
\1_convert_image_data_skip9
	cmp.b	d3,d1			; modify green ?
	bne.s	\1_convert_image_data_skip10
	and.w	#$f0f,d2
	and.w	d4,d0
	lsl.b	#4,d0			; adjust bits
	or.b	d0,d2			; updated green
\1_convert_image_data_skip10
	move.w	d2,(a2)+		; RGB4
	dbf	d5,\1_convert_image_data_loop3
	addq.w	#BYTE_SIZE,a0		; next byte in source
	dbf	d6,\1_convert_image_data_loop2
	add.l	a6,a0			; skip remaining bitplanes
	dbf	d7,\1_convert_image_data_loop1
	movem.l	(a7)+,a4-a6
	rts
	ENDM


CONVERT_IMAGE_TO_RGB8_CHUNKY	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 POINTER:	Color table
; \3 STRING:	["pc", "a3"] pointer base
; Global reference
; _image_data
; _image_plane_width
; _image_depth
; _image_y_size
; _image_color_table
; Result
	IFC "","\1"
		FAIL Macro CONVERT_IMAGE_TO_RGB8_CHUNKY: Labels-Prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CONVERT_IMAGE_TO_RGB8_CHUNKY: BPLAM table missing
	ENDC
	IFC "","\3"
		FAIL Macro CONVERT_IMAGE_TO_RGB8_CHUNKY:  base missing
	ENDC
	CNOP 0,4
\1_convert_image_data
	movem.l a4-a6,-(a7)
	moveq	#16,d3			; color 16
	move.w	#RB_NIBBLES_MASK,d4
	lea	\1_image_data,a0
	lea	\1_image_color_table(pc),a1
	IFC "","\2"
		lea	\1_color_table(pc),a2
	ELSE
		move.l	\2(\3),a2
	ENDC
	move.w	#32,a4			; color 32
	move.w	#64,a5			; color 64
	move.w	#128,a6			; color 128
	MOVEF.W \1_image_y_size-1,d7
\1_convert_image_loop1
	moveq	#\1_image_plane_width-1,d6
\1_convert_image_loop2
	moveq	#8-1,d5			; number of bits in byte
\1_convert_image_loop3
	moveq	#0,d0			; color 00
	IFGE \1_image_depth-1
		btst	d5,(a0)
		beq.s	\1_convert_image_skip1
		addq.w	#1,d0		; increase color number
\1_convert_image_skip1
	ENDC
	IFGE \1_image_depth-2
		btst	5,\1_image_plane_width*1(a0)
		beq.s	\1_convert_image_skip2
		addq.w	#2,d0		; increase color number
\1_convert_image_skip2
	ENDC
	IFGE \1_image_depth-3
		btst	d5,\1_image_plane_width*2(a0)
		beq.s	\1_convert_image_skip3
		addq.w	#4,d0		; increase color number
\1_convert_image_skip3
	ENDC
	IFGE \1_image_depth-4
		btst	d5,\1_image_plane_width*3(a0)
		beq.s	\1_convert_image_skip4
		addq.w	#8,d0		; increase color number
\1_convert_image_skip4
	ENDC
	IFGE \1_image_depth-5
		btst	d5,\1_image_plane_width*4(a0)
		beq.s	\1_convert_image_skip5
		add.w	d3,d0		; increase color number
\1_convert_image_skip5
	ENDC
	IFGE \1_image_depth-6
		btst	d5,\1_image_plane_width*5(a0)
		beq.s	\1_convert_image_skip6
		add.w	a4,d0		; increase color number
\1_convert_image_skip6
	ENDC
	IFGE \1_image_depth-7
		btst	d5,\1_image_plane_width*6(a0)
		beq.s	\1_convert_image_skip7
		add.w	a5,d0		; increase color number
\1_convert_image_skip7
	ENDC
	IFEQ \1_image_depth-8
		btst	d5,\1_image_plane_width*7(a0)
		beq.s	\1_convert_image_skip8
		add.w	a6,d0		; increase color number
\1_convert_image_skip8
	ENDC
	move.l	(a1,d0.l*4),d0		; RGB8
	move.l	d0,d2							
	RGB8_TO_RGB4_HIGH d0,d1,d4
	move.w	d0,(a2)+		; RGB4 high
	RGB8_TO_RGB4_LOW d2,d1,d4
	move.w	d2,(a2)+		; RGB4 low
	dbf	5,\1_convert_image_loop3
	addq.w	#BYTE_SIZE,a0		; next byte in source
	dbf	6,\1_convert_image_loop2
	add.l	#\1_image_plane_width*(\1_image_depth-1),a0 ; skip remaining bitplanes
	dbf	7,\1_convert_image_loop1
	movem.l (a7)+,a4-a6
	rts
	ENDM


CONVERT_IMAGE_TO_HAM8_CHUNKY	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 POINTER:	Color table
; \3 STRING:	["pc", "a3"] pointer base
; Global reference
; variables
; save_a7
; _image_data
; _image_plane_width
; _image_depth
; _image_y_size
; _image_color_table
; Result
	IFC "","\1"
		FAIL Macro CONVERT_IMAGE_TO_HAM8_CHUNKY: Labels-Prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CONVERT_IMAGE_TO_HAM8_CHUNKY: BPLAM table missing
	ENDC
	IFC "","\3"
		FAIL Macro CONVERT_IMAGE_TO_HAM8_CHUNKY:  base missing
	ENDC
	CNOP 0,4
\1_convert_image_data
	movem.l	a3-a6,-(a7)
	move.l	a7,save_a7(a3)
	MOVEF.W	$c0,d3			; HAM8 bits mask
	move.w	#RB_NIBBLES_MASK,d4
	lea	\1_image_data,a0	; source
	lea	\1_image_color_table(pc),a1
	IFC "","\2"
		lea	\1_color_table(pc),a2
	ELSE
		move.l	\2(\3),a2
	ENDC
	move.w	#16,a3			; color 16
	move.w	#32,a4			; color 32
	move.w	#64,a5			; color 64
	move.w	#128,a6			; color 128
	move.w	#\1_image_plane_width*(\1_image_depth-1),a7
	MOVEF.W	\1_image_y_size-1,d7
\1_translate_image_data_loop1
	moveq	#0,d2			; color 00
	moveq	#\1_image_plane_width-1,d6
\1_translate_image_data_loop2
	moveq	#8-1,d5			; number of bits in byte
\1_translate_image_data_loop3
	moveq	#0,d0			; color 00
	btst	d5,(a0)
	beq.s	\1_translate_image_data_skip1
	addq.w	#1,d0			; increase color number
\1_translate_image_data_skip1
	btst	d5,\1_image_plane_width*1(a0)
	beq.s	\1_translate_image_data_skip2
	addq.w	#2,d0			; increase color number
\1_translate_image_data_skip2
	btst	d5,\1_image_plane_width*2(a0)
	beq.s	\1_translate_image_data_skip3
	addq.w	#4,d0			; increase color number
\1_translate_image_data_skip3
	btst	d5,\1_image_plane_width*3(a0)
	beq.s	\1_translate_image_data_skip4
	addq.w	#8,d0			; increase color number
\1_translate_image_data_skip4
	btst	d5,\1_image_plane_width*4(a0)
	beq.s	\1_translate_image_data_skip5
	add.w	a3,d0			; increase color number
\1_translate_image_data_skip5
	btst	d5,\1_image_plane_width*5(a0)
	beq.s	\1_translate_image_data_skip6
	add.w	a4,d0			; increase color number
\1_translate_image_data_skip6
	btst	d5,\1_image_plane_width*6(a0)
	beq.s	\1_translate_image_data_skip7
	add.w	a5,d0			; increase color number
\1_translate_image_data_skip1
	btst	d5,\1_image_plane_width*7(a0)
	beq.s	\1_translate_image_data_skip8
	add.w	a6,d0			; increase color number
\1_translate_image_data_skip8
	move.l	d0,d1			; color number
	and.b	d3,d1			; bit 6 or 7 set ?
	bne.s	\1_translate_image_data_skip9
	move.l	(a1,d0.l*4),d2		; fetch RGB8
	bra.s	\1_translate_image_data_skip12
	CNOP 0,4
\1_translate_image_data_skip9
	lsl.b	#2,d0			; adjust bits
	cmp.b	#$40,d1			; change blue ?
	bne.s	\1_translate_image_data_skip10
	move.b	d0,d2			; updated blue
	bra.s	\1_translate_image_data_skip12
	CNOP 0,4
\1_translate_image_data_skip10
	cmp.b	#$80,d1			; change red ?
	bne.s	\1_translate_image_data_skip11
	swap	d2
	move.w	d0,d2			; updated red
	swap	d2			; adjust bits
	bra.s	\1_set_rgb_nibbles
	CNOP 0,4
\1_translate_image_data_skip11
	cmp.b	d3,d1			; change green ?
	bne.s	\1_set_rgb_nibbles
	and.l	#$ff00ff,d2
	lsl.w	#8,d0			; adjust bits
	or.w	d0,d2			; updated green
\1_translate_image_data_skip12
	move.l	d2,d0			; RGB8
	RGB8_TO_RGB4_HIGH d0,d1,d4
	move.w	d0,(a2)+		; RGB4 high
	RGB8_TO_RGB4_LOW d0,d1,d4
	move.w	d0,(a2)+		; RGB4 low
	dbf	d5,\1_translate_image_data_loop3
	addq.w	#1,a0			; next byte in source
	dbf	d6,\1_translate_image_data_loop2
	add.l	a7,a0			; skip remaining bitplanes
	dbf	d7,\1_translate_image_data_loop1
	move.l	variables+save_a7(pc),a7
	movem.l	(a7)+,a3-a6
	rts
	ENDM


CONVERT_IMAGE_TO_BPLCON4_CHUNKY	MACRO
; Input
; \0 STRING:	["B", "W"] size
; \1 STRING:	Labels prefix
; \2 POINTER:	BPLAM table
; \3 STRING:	["pc", "a3"] pointer base
; \4 NUMBER:	Start BPLAM value (optional)
; Global reference
; variables
; save_a7
; bplcon4_bits
; _image_data
; _bplam_table
; _image_plane_width
; _image_depth
; _image_y_size
; Result
	IFC "","\0"
		FAIL Macro CONVERT_IMAGE_TO_BPLCON4_CHUNKY: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro CONVERT_IMAGE_TO_BPLCON4_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CONVERT_IMAGE_TO_BPLCON4_CHUNKY: BPLAM table missing
	ENDC
	IFC "","\3"
		FAIL Macro CONVERT_IMAGE_TO_BPLCON4_CHUNKY:  base missing
	ENDC
	CNOP 0,4
\1_convert_image_data
	IFGE \1_image_depth-5
		moveq	#16,d1
	ENDC
	IFGE \1_image_depth-6
		moveq	#32,d2
	ENDC
	IFGE \1_image_depth-7
		moveq	#64,d3
	ENDC
	IFEQ \1_image_depth-8
		MOVEF.W	128,d4
	ENDC
	lea	\1_image_data,a0
	IFC "","\2"
		lea	\1_bplam_table(pc),a1
	ELSE
		move.l	\2(\3),a1
	ENDC
	IFGE \1_image_depth-4
		move.w	#\1_image_plane_width*(\1_image_depth-1),a2
	ENDC
	MOVEF.W	\1_image_y_size-1,d7
\1_translate_image_data_loop1
	moveq	#\1_image_plane_width-1,d6
\1_translate_image_data_loop2
	moveq	#8-1,d5			; number of bits in byte
\1_translate_image_data_loop3
	IFC "","\4"
		moveq	#0,d0		; start BPLAM
	ELSE
		MOVEF.W	\4,d0		; start BPLAM
	ENDC
	IFGE \1_image_depth-1
		btst	d5,(a0)
		beq.s	\1_translate_image_data_skip1
		addq.w	#1,d0		; increase BPLAM
\1_translate_image_data_skip1
	ENDC
	IFGE \1_image_depth-2
		btst	d5,\1_image_plane_width*1(a0)
		beq.s	\1_translate_image_data_skip2
		addq.w	#2,d0		; increase BPLAM
\1_translate_image_data_skip2
	ENDC
	IFGE \1_image_depth-3
		btst	d5,\1_image_plane_width*2(a0)
		beq.s	\1_translate_image_data_skip3
		addq.w	#4,d0		; increase BPLAM
\1_translate_image_data_skip3
	ENDC
	IFGE \1_image_depth-4
		btst	d5,\1_image_plane_width*3(a0)
		beq.s	\1_translate_image_data_skip4
		addq.w	#8,d0		; increase BPLAM
\1_translate_image_data_skip4
	ENDC
	IFGE \1_image_depth-5
		btst	d5,\1_image_plane_width*4(a0)
		beq.s	\1_translate_image_data_skip5
		add.w	d1,d0		; increase BPLAM
\1_translate_image_data_skip5
	ENDC
	IFGE \1_image_depth-6
		btst	d5,\1_image_plane_width*5(a0)
		beq.s	\1_translate_image_data_skip6
		add.w	d2,d0		; increase BPLAM
\1_translate_image_data_skip6
	ENDC
	IFGE \1_image_depth-7
		btst	d5,\1_image_plane_width*6(a0)
		beq.s	\1_translate_image_data_skip7
		add.w	d3,d0		; increase BPLAM
\1_translate_image_data_skip7
	ENDC
	IFEQ \1_image_depth-8
		btst	d5,\1_image_plane_width*7(a0)
		beq.s	\1_translate_image_data_skip8
		add.w	d4,d0		; increase BPLAM
\1_translate_image_data_skip8
	ENDC
	IFC "B","\0"
		move.b	d0,(a1)+	; BPLCON4 low
	ENDC
	IFC "W","\0"
		move.b	d0,(a1)+	; BPLCON4 low
		move.b	#bplcon4_bits&FALSE_BYTE,(a1)+
	ENDC
	dbf	d5,\1_translate_image_data_loop3
	addq.w	#BYTE_SIZE,a0		; next byte in source
	dbf	d6,\1_translate_image_data_loop2
	add.l	a2,a0			; skip remaining bitplanes lines
	dbf	d7,\1_translate_image_data_loop1
	rts
	ENDM


SWAP_COPPERLIST			MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	[2,3] number of copperlists
; Global reference
; _construction1
; _construction2
; _display
; Result
	IFC "","\1"
		FAIL Macro SWAP_COPPERLIST: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SWAP_COPPERLIST: Number of copperlists missing
	ENDC
	IFC "cl1","\1"
		CNOP 0,4
swap_first_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0
			move.l	\1_display(a3),\1_construction2(a3)
			move.l	a0,\1_display(a3)
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0
			move.l	\1_display(a3),\1_construction1(a3)
			move.l	\1_construction2(a3),a1
			move.l	a0,\1_construction2(a3)
			move.l	a1,\1_display(a3)
			rts
		ENDC
	ENDC
	IFC "cl2","\1"
		CNOP 0,4
swap_second_copperlist
		IFEQ \2-2
			move.l	\1_construction2(a3),a0
			move.l	\1_display(a3),\1_construction2(a3)
			move.l	a0,\1_display(a3)
			rts
		ENDC
		IFEQ \2-3
			move.l	\1_construction1(a3),a0
			move.l	\1_display(a3),\1_construction1(a3)
			move.l	\1_construction2(a3),a1
			move.l	a0,\1_construction2(a3)
			move.l	a1,\1_display(a3)
			rts
		ENDC
	ENDC
	ENDM


SET_COPPERLIST			MACRO
; Input
; \1 STRING:	Labels prefix
; Global reference
; _display
; Result
	IFC "","\1"
		FAIL Macro SET_COPPERLIST: Labels prefix missing
	ENDC
	IFC "cl1","\1"
		CNOP 0,4
set_first_copperlist
		move.l	\1_display(a3),COP1LC-DMACONR(a6)
		rts
	ENDC
	IFC "cl2","\1"
		CNOP 0,4
set_second_copperlist
		move.l	\1_display(a3),COP2LC-DMACONR(a6)
		rts
	ENDC
	ENDM


CLEAR_COLOR00_SCREEN		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	[cl1,cl2] label prefix copperlist
; \3 STRING:	[construction1,construction2] name of copperlist
; \4 STRING:	"extension[1..n]"
; \5 NUMBER:	[16,32] number of commands per loop
; Global reference
; color00_high_bits
; color00_low_bits
; _display_y_size
; _COLOR00_low
; _COLOR00_high
; Result
	IFC "","\1"
		FAIL Macro CLEAR_COLOR00_SCREEN: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CLEAR_COLOR00_SCREEN: Label prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro CLEAR_COLOR00_SCREEN: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro CLEAR_COLOR00_SCREEN: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro CLEAR_COLOR00_SCREEN: Number of commands per loop missing
	ENDC
	CNOP 0,4
	IFC "cl1","\2"
\1_clear_first_copperlist
		IFC "16","\5"
			move.w	#color00_high_bits,d0
			move.w	#color00_low_bits,d1
			MOVEF.L	\2_\4_size*16,d2
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+WORD_SIZE,a0
			moveq	#(\2_display_y_size/WORD_BITS)-1,d7
\1_clear_first_copperlist_loop
			move.w	d0,(a0)	; COLOR00 high
			move.w	d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ; COLOR00 low
			move.w	d0,\2_\4_size*1(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*1)(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*2)(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*3)(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*4)(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*5)(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*6)(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*7)(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*8)(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*9)(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*10)(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*11)(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*12)(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*13)(a0)
			move.w	d0,\2_\4_size*14(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*14)(a0)
			move.w	d0,\2_\4_size*15(a0)
			add.l	d2,a0	; next line
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*15)-(\2_\4_size*16)(a0)
			dbf	d7,\1_clear_first_copperlist_loop
			rts
		ENDC
		IFC "32","\5"
			move.w	#color00_high_bits,d0
			move.w	#color00_low_bits,d1
			MOVEF.L \2_\4_size*32,d2
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+WORD_SIZE,a0
			moveq	#(\2_display_y_size/32)-1,d7
\1_clear_first_copperlist_loop
			move.w	d0,(a0)	; COLOR00 high
			move.w	d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ; COLOR00 low
			move.w	d0,\2_\4_size*1(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*1)(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*2)(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*3)(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*4)(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*5)(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*6)(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*7)(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*8)(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*9)(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*10)(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*11)(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*12)(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*13)(a0)
			move.w	d0,\2_\4_size*14(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*14)(a0)
			move.w	d0,\2_\4_size*15(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*15)(a0)
			move.w	d0,\2_\4_size*16(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*16)(a0)
			move.w	d0,\2_\4_size*17(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*17)(a0)
			move.w	d0,\2_\4_size*18(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*18)(a0)
			move.w	d0,\2_\4_size*19(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*19)(a0)
			move.w	d0,\2_\4_size*20(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*20)(a0)
			move.w	d0,\2_\4_size*21(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*21)(a0)
			move.w	d0,\2_\4_size*22(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*22)(a0)
			move.w	d0,\2_\4_size*23(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*23)(a0)
			move.w	d0,\2_\4_size*24(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*24)(a0)
			move.w	d0,\2_\4_size*25(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*25)(a0)
			move.w	d0,\2_\4_size*26(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*26)(a0)
			move.w	d0,\2_\4_size*27(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*27)(a0)
			move.w	d0,\2_\4_size*28(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*28)(a0)
			move.w	d0,\2_\4_size*29(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*29)(a0)
			move.w	d0,\2_\4_size*30(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*30)(a0)
			move.w	d0,\2_\4_size*31(a0)
			add.l	d2,a0	; next line
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*31)-(\2_\4_size*32)(a0)
			dbf	d7,\1_clear_first_copperlist_loop
			rts
		ENDC
	ENDC
	IFC "cl2","\2"
\1_clear_second_copperlist
		IFC "16","\5"
			move.w	#color00_high_bits,d0
			move.w	#color00_low_bits,d1
			MOVEF.L	\2_\4_size*16,d2
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+WORD_SIZE,a0
			moveq	#(\2_display_y_size/WORD_BITS)-1,d7
\1_clear_second_copperlist_loop
			move.w	d0,(a0)	; COLOR00 high
			move.w	d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ; COLOR00 low
			move.w	d0,\2_\4_size*1(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*1)(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*2)(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*3)(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*4)(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*5)(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*6)(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*7)(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*8)(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*9)(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*10)(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*11)(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*12)(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*13)(a0)
			move.w	d0,\2_\4_size*14(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*14)(a0)
			move.w	d0,\2_\4_size*15(a0)
			add.l	d2,a0	; next line
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*15)-(\2_\4_size*16)(a0)
			dbf	d7,\1_clear_second_copperlist_loop
			rts
		ENDC
		IFC "32","\5"
			move.w	#color00_high_bits,d0
			move.w	#color00_low_bits,d1
			MOVEF.L	\2_\4_size*32,d2
			move.l	\2_\3(a3),a0
			ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_COLOR00_high+WORD_SIZE,a0
			moveq	#(\2_display_y_size/32)-1,d7
\1_clear_second_copperlist_loop
			move.w	d0,(a0)	; COLOR00 high
			move.w	d1,\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high(a0) ; COLOR00 low
			move.w	d0,\2_\4_size*1(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*1)(a0)
			move.w	d0,\2_\4_size*2(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*2)(a0)
			move.w	d0,\2_\4_size*3(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*3)(a0)
			move.w	d0,\2_\4_size*4(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*4)(a0)
			move.w	d0,\2_\4_size*5(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*5)(a0)
			move.w	d0,\2_\4_size*6(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*6)(a0)
			move.w	d0,\2_\4_size*7(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*7)(a0)
			move.w	d0,\2_\4_size*8(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*8)(a0)
			move.w	d0,\2_\4_size*9(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*9)(a0)
			move.w	d0,\2_\4_size*10(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*10)(a0)
			move.w	d0,\2_\4_size*11(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*11)(a0)
			move.w	d0,\2_\4_size*12(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*12)(a0)
			move.w	d0,\2_\4_size*13(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*13)(a0)
			move.w	d0,\2_\4_size*14(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*14)(a0)
			move.w	d0,\2_\4_size*15(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*15)(a0)
			move.w	d0,\2_\4_size*16(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*16)(a0)
			move.w	d0,\2_\4_size*17(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*17)(a0)
			move.w	d0,\2_\4_size*18(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*18)(a0)
			move.w	d0,\2_\4_size*19(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*19)(a0)
			move.w	d0,\2_\4_size*20(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*20)(a0)
			move.w	d0,\2_\4_size*21(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*21)(a0)
			move.w	d0,\2_\4_size*22(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*22)(a0)
			move.w	d0,\2_\4_size*23(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*23)(a0)
			move.w	d0,\2_\4_size*24(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*24)(a0)
			move.w	d0,\2_\4_size*25(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*25)(a0)
			move.w	d0,\2_\4_size*26(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*26)(a0)
			move.w	d0,\2_\4_size*27(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*27)(a0)
			move.w	d0,\2_\4_size*28(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*28)(a0)
			move.w	d0,\2_\4_size*29(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*29)(a0)
			move.w	d0,\2_\4_size*30(a0)
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*30)(a0)
			move.w	d0,\2_\4_size*31(a0)
			add.l	d2,a0	; next line
			move.w	d1,(\2_ext\*RIGHT(\4,1)_COLOR00_low-\2_ext\*RIGHT(\4,1)_COLOR00_high)+(\2_\4_size*31)-(\2_\4_size*32)(a0)
			dbf	d7,\1_clear_second_copperlist_loop
			rts
		ENDC
	ENDC
	ENDM


CLEAR_BPLCON4_CHUNKY		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] label prefix copperlist
; \3 STRING:	["construction1", "construction2"] name of copperlist
; \4 STRING:	"extension[1..n]"
; \5 BOOLEAN:	TRUE = quick clear enabled
; Global refgerence
; bplcon4_bits
; 1_clear_blit_x_size
; 1_clear_blit_y_size
; Result
	IFC "","\1"
		FAIL Macro CLEAR_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro CLEAR_CHUNKY: Label prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro CLEAR_CHUNKY: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro CLEAR_CHUNKY: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro CLEAR_CHUNKY: Boolean quick clear missing
	ENDC
	CNOP 0,4
	IFC "cl1","\2"
\1_clear_first_copperlist
		move.l	\2_\3(a3),a0
		ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
		WAITBLIT
		move.l	#(BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D = A
		moveq	#-1,d0
		move.l	d0,BLTAFWM-DMACONR(a6)
		move.l	a0,BLTDPT-DMACONR(a6)
		move.w	#WORD_SIZE,BLTDMOD-DMACONR(a6)
		IFEQ \1_\5
			move.w	#-2,BLTADAT-DMACONR(a6) ; source 2nd word CWAIT
		ELSE
			IFEQ bplcon4_bits
				moveq	#bplcon4_bits,d0
				move.w	d0,BLTADAT-DMACONR(a6)
			ELSE
				move.w	#bplcon4_bits,BLTADAT-DMACONR(a6)
	 	ENDC
		ENDC
		move.l	#(\1_clear_blit_y_size<<16)|(\1_clear_blit_x_size/WORD_BITS),BLTSIZV-DMACONR(a6)
		rts
	ENDC
	IFC "cl2","\2"
\1_clear_second_copperlist
		move.l	\2_\3(a3),a0
		ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
		WAITBLIT
		move.l	#(BC0F_DEST|ANBNC|ANBC|ABNC|ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D = A
		moveq	#-1,d0
		move.l	d0,BLTAFWM-DMACONR(a6)
		move.l	a0,BLTDPT-DMACONR(a6)
		move.w	#WORD_SIZE,BLTDMOD-DMACONR(a6)
		IFEQ \1_\5
			move.w	#-2,BLTADAT-DMACONR(a6) ; source 2nd word CWAIT
		ELSE
			IFEQ bplcon4_bits
				moveq	#bplcon4_bits,d0
				move.w	d0,BLTADAT-DMACONR(a6)
			ELSE
				move.w	#bplcon4_bits,BLTADAT-DMACONR(a6)
	 	ENDC
		ENDC
		move.l	#(\1_clear_blit_y_size<<16)|(\1_clear_blit_x_size/WORD_BITS),BLTSIZV-DMACONR(a6)
		rts
	ENDC
	ENDM


RESTORE_BPLCON4_CHUNKY		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] label prefix copperlist
; \3 STRING:	["construction1", "construction2"] name of copperlist
; \4 STRING:	Extension[1..n]
; \5 NUMBER:	[16, 32] number of commands per loop
; \6 LABEL:	Sub routine clear by cpu (optional)
; \7 LABEL:	Sub routine clear by blitter (optional)
; Global reference
; _display_y_size
; _restore_blit_x_size
; _restore_blit_y_size
; Result
	IFC "","\1"
		FAIL Macro RESTORE_BLCON4_CHUNKY: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro RESTORE_BLCON4_CHUNKY: Label prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro RESTORE_BLCON4_CHUNKY: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro RESTORE_BLCON4_CHUNKY: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro RESTORE_BLCON4_CHUNKY: Number of commands per loop missing
	ENDC
	CNOP 0,4
	IFC "cl1","\2"
restore_first_copperlist
		IFEQ \1_restore_cl_cpu_enabled
			IFC "","\6"
				IFC "16","\5"
					moveq	#-2,d0 ; 2nd word CWAIT
					MOVEF.L	\2_\4_size*16,d1
					move.l	\2_\3(a3),a0
					ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
					moveq	#(\2_display_y_size/WORD_BITS)-1,d7
restore_first_copperlist_loop
					move.w	d0,(a0)	; restore CWAIT 2nd word
					move.w	d0,\2_\4_size*1(a0)
					move.w	d0,\2_\4_size*2(a0)
					move.w	d0,\2_\4_size*3(a0)
					move.w	d0,\2_\4_size*4(a0)
					move.w	d0,\2_\4_size*5(a0)
					move.w	d0,\2_\4_size*6(a0)
					move.w	d0,\2_\4_size*7(a0)
					move.w	d0,\2_\4_size*8(a0)
					move.w	d0,\2_\4_size*9(a0)
					move.w	d0,\2_\4_size*10(a0)
					move.w	d0,\2_\4_size*11(a0)
					move.w	d0,\2_\4_size*12(a0)
					move.w	d0,\2_\4_size*13(a0)
					move.w	d0,\2_\4_size*14(a0)
					add.l	d1,a0 ; skip lines in cl
					move.w	d0,(\2_\4_size*15)-(\2_\4_size*16)(a0)
					dbf	d7,restore_first_copperlist_loop
					rts
				ENDC
				IFC "32","\5"
					moveq	#-2,d0 ; 2nd word CWAIT
					MOVEF.L	\2_\4_size*32,d1
					move.l	\2_\3(a3),a0
					ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
					moveq	#(\2_display_y_size/32)-1,d7
restore_first_copperlist_loop
					move.w	d0,(a0)	; restore 2nd word CWAIT
					move.w	d0,\2_\4_size*1(a0)
					move.w	d0,\2_\4_size*2(a0)
					move.w	d0,\2_\4_size*3(a0)
					move.w	d0,\2_\4_size*4(a0)
					move.w	d0,\2_\4_size*5(a0)
					move.w	d0,\2_\4_size*6(a0)
					move.w	d0,\2_\4_size*7(a0)
					move.w	d0,\2_\4_size*8(a0)
					move.w	d0,\2_\4_size*9(a0)
					move.w	d0,\2_\4_size*10(a0)
					move.w	d0,\2_\4_size*11(a0)
					move.w	d0,\2_\4_size*12(a0)
					move.w	d0,\2_\4_size*13(a0)
					move.w	d0,\2_\4_size*14(a0)
					move.w	d0,\2_\4_size*15(a0)
					move.w	d0,\2_\4_size*16(a0)
					move.w	d0,\2_\4_size*17(a0)
					move.w	d0,\2_\4_size*18(a0)
					move.w	d0,\2_\4_size*19(a0)
					move.w	d0,\2_\4_size*20(a0)
					move.w	d0,\2_\4_size*21(a0)
					move.w	d0,\2_\4_size*22(a0)
					move.w	d0,\2_\4_size*23(a0)
					move.w	d0,\2_\4_size*24(a0)
					move.w	d0,\2_\4_size*25(a0)
					move.w	d0,\2_\4_size*26(a0)
					move.w	d0,\2_\4_size*27(a0)
					move.w	d0,\2_\4_size*28(a0)
					move.w	d0,\2_\4_size*29(a0)
					move.w	d0,\2_\4_size*30(a0)
					add.l	d1,a0 ; skip lines in cl
					move.w	d0,(\2_\4_size*31)-(\2_\4_size*32)(a0)
					dbf	d7,restore_first_copperlist_loop
					rts
				ENDC
			ENDC
		ENDC
		IFEQ \1_restore_cl_blitter_enabled
			IFC "","\7"
				move.l	\2_\3(a3),a0
				ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
				WAITBLIT
				move.l	a0,BLTDPT-DMACONR(a6) ; destination
				move.w	#\2_\4_size-\1_restore_blit_width,BLTDMOD-DMACONR(a6)
				move.w	#$fffe,BLTADAT-DMACONR(a6) ; 2nd word CWAIT
				move.w	#(((\1_restore_blit_y_size)<<6)|(\1_restore_blit_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
				rts
			ENDC
		ENDC
	ENDC
	IFC "cl2","\2"
restore_second_copperlist
		IFEQ \1_restore_cl_cpu_enabled
			IFC "","\6"
				IFC "16","\5"
					moveq	#-2,d0 ; 2nd word CWAIT
					MOVEF.L	\2_\4_size*16,d1
					move.l	\2_\3(a3),a0
					ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
					moveq	#(\2_display_y_size/WORD_BITS)-1,d7
restore_second_copperlist_loop
					move.w	d0,(a0) ; restore 2nd word CWAIT
					move.w	d0,\2_\4_size*1(a0)
					move.w	d0,\2_\4_size*2(a0)
					move.w	d0,\2_\4_size*3(a0)
					move.w	d0,\2_\4_size*4(a0)
					move.w	d0,\2_\4_size*5(a0)
					move.w	d0,\2_\4_size*6(a0)
					move.w	d0,\2_\4_size*7(a0)
					move.w	d0,\2_\4_size*8(a0)
					move.w	d0,\2_\4_size*9(a0)
					move.w	d0,\2_\4_size*10(a0)
					move.w	d0,\2_\4_size*11(a0)
					move.w	d0,\2_\4_size*12(a0)
					move.w	d0,\2_\4_size*13(a0)
					move.w	d0,\2_\4_size*14(a0)
					add.l	d1,a0 ; skip lines in cl
					move.w	d0,(\2_\4_size*15)-(\2_\4_size*16)(a0)
					dbf	d7,restore_second_copperlist_loop
					rts
				ENDC
				IFC "32","\5"
					moveq	#-2,d0	; 2nd word CWAIT
					MOVEF.L \2_\4_size*32,d1
					move.l	\2_\3(a3),a0 
					ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
					moveq	#(\2_display_y_size/32)-1,d7
restore_second_copperlist_loop
					move.w	d0,(a0)	; restore CWAIT 2nd word
					move.w	d0,\2_\4_size*1(a0)
					move.w	d0,\2_\4_size*2(a0)
					move.w	d0,\2_\4_size*3(a0)
					move.w	d0,\2_\4_size*4(a0)
					move.w	d0,\2_\4_size*5(a0)
					move.w	d0,\2_\4_size*6(a0)
					move.w	d0,\2_\4_size*7(a0)
					move.w	d0,\2_\4_size*8(a0)
					move.w	d0,\2_\4_size*9(a0)
					move.w	d0,\2_\4_size*10(a0)
					move.w	d0,\2_\4_size*11(a0)
					move.w	d0,\2_\4_size*12(a0)
					move.w	d0,\2_\4_size*13(a0)
					move.w	d0,\2_\4_size*14(a0)
					move.w	d0,\2_\4_size*15(a0)
					move.w	d0,\2_\4_size*16(a0)
					move.w	d0,\2_\4_size*17(a0)
					move.w	d0,\2_\4_size*18(a0)
					move.w	d0,\2_\4_size*19(a0)
					move.w	d0,\2_\4_size*20(a0)
					move.w	d0,\2_\4_size*21(a0)
					move.w	d0,\2_\4_size*22(a0)
					move.w	d0,\2_\4_size*23(a0)
					move.w	d0,\2_\4_size*24(a0)
					move.w	d0,\2_\4_size*25(a0)
					move.w	d0,\2_\4_size*26(a0)
					move.w	d0,\2_\4_size*27(a0)
					move.w	d0,\2_\4_size*28(a0)
					move.w	d0,\2_\4_size*29(a0)
					move.w	d0,\2_\4_size*30(a0)
					add.l	d1,a0 ; skip lines in cl
					move.w	d0,(\2_\4_size*31)-(\2_\4_size*32)(a0)
					dbf	d7,restore_second_copperlist_loop
					rts
				ENDC
			ENDC
		ENDC
		IFEQ \1_restore_cl_blitter_enabled
			IFC "","\7"
				move.l	\2_\3(a3),a0
				ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_WAIT+WORD_SIZE,a0
				WAITBLIT
				move.l	a0,BLTDPT-DMACONR(a6)
				move.w	#\2_\4_size-\1_restore_blit_width,BLTDMOD-DMACONR(a6)
				move.w	#$fffe,BLTADAT-DMACONR(a6) ; 2nd word CWAIT
				move.w	#((\1_restore_blit_y_size)<<6)|(\1_restore_blit_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
				rts
			ENDC
		ENDC
	ENDC
	ENDM


SET_TWISTED_BACKGROUND_BARS	MACRO
; Input
; \0 STRING:	["B", "W"] size
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] label prefix copperlist
; \3 STRING:	["construction2", "construction3"] name of copperlist
; \4 STRING:	"extension[1..n]"
; \5 NUMBER:	[14, 15, 32, 48] bar height in lines
; \6 POINTER:	BPLAM table
; \7 STRING:	[pc,a3] pointer base
; \8 WORD:	Offset table start (optional)
; \9 STRING:	["45"] (optional)
; Global reference
; _yz_coordinates
; _display_width
; _bars_number
; Result
	IFC "","\0"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Label prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Name of copperlist missing
	ENDC
	IFC "","\4"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS: Bar height missing
	ENDC
	IFC "","\6"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS:  BPLAM table missing
	ENDC
	IFC "","\7"
		FAIL Macro SET_TWISTED_BACKGROUND_BARS:  base missing
	ENDC
	CNOP 0,4
\1_set_background_bars
	movem.l	a4-a5,-(a7)
	IFC "B","\0"
		MOVEF.L	\1_\5*BYTE_SIZE,d4
	ENDC
	IFC "W","\0"
		MOVEF.L	\1_\5*WORD_SIZE,d4
	ENDC
	lea	\1_yz_coordinates(pc),a0
	move.l	\2_\3(a3),a2
	ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_BPLCON4_1+WORD_SIZE,a2
	IFC "pc","\7"
		lea	\1_\6(\7),a5	; BPLAM table
	ENDC
	IFC "a3","\7"
		move.l \6(\7),a5	; BPLAM table
	ENDC
	IFNC "","\8"
		ADDQ.W	\8*BYTE_SIZE,a5 ; offset table start
	ENDC
	IFC "45","\9"
		moveq	#(\2_display_width-1)-1,d7 ; number of columns
	ELSE
		moveq	#\2_display_width-1,d7 ; number of columns
	ENDC
\1_set_background_bars_loop1
	move.l	a5,a1			; BPLAM table
	moveq	#\1_bars_number-1,d6
\1_set_background_bars_loop2
	move.l	(a0)+,d0	 	; low word: y, high word: z vector
	bpl.s	\1_set_background_bars_skip1
	add.l	d4,a1			; skip BPLAMs
	bra	\1_set_background_bars_skip2
	CNOP 0,4
\1_set_background_bars_skip1
	lea	(a2,d0.w*4),a4		; y offset in cl
	COPY_TWISTED_BAR.\0 \1,\2,\4,\5
\1_set_background_bars_skip2
	dbf	d6,\1_set_background_bars_loop2
	addq.w	#LONGWORD_SIZE,a2	; next column
	dbf	d7,\1_set_background_bars_loop1
	movem.l	(a7)+,a4-a5
	rts
	IFC "B","\0"
		CNOP 0,4
\1_skip_background_bar

	ENDC
	ENDM


SET_TWISTED_FOREGROUND_BARS	MACRO
; Input
; \0 STRING:	["B", "W"] size
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1", "cl2"] label prefix copperlist
; \3 STRING:	["construction2", "construction3"] name of copperlist
; \4 STRING:	"extension[1..n]"
; \5 NUMBER:	[14, 15, 32, 48] bar height in lines
; \6 POINTER:	BPLAM table
; \7 STRING:	["pc", "a3"] pointer base
; \8 WORD:	Offset table start (optional)
; \9 STRING:	["45"] (optional)
; Global reference
; _yz_coordinates
; _display_width
; _bars_number
; Result
	IFC "","\0"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Label prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Name of coppwerelist missing
	ENDC
	IFC "","\4"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Extension missing
	ENDC
	IFC "","\5"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS: Bar height missing
	ENDC
	IFC "","\6"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS:  BPLAM table missing
	ENDC
	IFC "","\7"
		FAIL Macro SET_TWISTED_FOREGROUND_BARS:  base missing
	ENDC
	CNOP 0,4
\1_set_foreground_bars
	movem.l	a4-a5,-(a7)
	IFC "B","\0"
		MOVEF.L	\1_\5*BYTE_SIZE,d4
	ENDC
	IFC "W","\0"
		MOVEF.L	\1_\5*WORD_SIZE,d4
	ENDC
	lea	\1_yz_coordinates(pc),a0
	move.l	\2_\3(a3),a2
	ADDF.W	\2_\4_entry+\2_ext\*RIGHT(\4,1)_BPLCON4_1+WORD_SIZE,a2
	IFC "pc","\7"
		lea	\1_\6(\7),a5	; BPLAM table
	ENDC
	IFC "a3","\7"
		move.l	\6(\7),a5	; BPLAM table
	ENDC
	IFNC "","\8"
		ADDQ.W	\8,a5		; offset table start
	ENDC
	IFC "45","\9"
		moveq	#(\2_display_width-1)-1,d7 ; number of columns
	ELSE
		moveq	#\2_display_width-1,d7 ; number of columns
	ENDC
\1_set_foreground_bars_loop1
	move.l	a5,a1			; BPLAM table
	moveq	#\1_bars_number-1,d6
\1_set_foreground_bars_loop2
	move.l	(a0)+,d0	 	; low word: y, high word: z vector
	bmi.s	\1_set_foreground_bars_skip1
	add.l	d4,a1			; skip BPLAMs
	bra	\1_set_foreground_bars_skip2
	CNOP 0,4
\1_set_foreground_bars_skip1
	lea	(a2,d0.w*4),a4		; y offset in cl
	COPY_TWISTED_BAR.\0 \1,\2,\4,\5
\1_set_foreground_bars_skip2
	dbf	d6,\1_set_foreground_bars_loop2
	addq.w	#LONGWORD_SIZE,a2	; next column
	dbf	d7,\1_set_foreground_bars_loop1
	movem.l (a7)+,a4-a5
	rts
	ENDM


COPY_TWISTED_BAR		MACRO
; Input
; \0 STRING:	["B", "W"] size
; \1 STRING:	Labels prefix
; \2 STRING:	["cl1","cl2"] label prefix copperlist
; \3 STRING:	"extension[1..n]"
; \4 NUMBER:	[14, 15, 32, 48] bar height in lines
; Result
	IFC "","\0"
		FAIL Macro COPY_TWISTED_BAR: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro COPY_TWISTED_BAR: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COPY_TWISTED_BAR: Label prefix copperlist missing
	ENDC
	IFC "","\3"
		FAIL Macro COPY_TWISTED_BAR: Extension missing
	ENDC
	IFC "","\4"
		FAIL Macro COPY_TWISTED_BAR: Bar height missing
	ENDC
	IFC "B","\0"
		IFEQ \1_\4-15
			movem.l	(a1),d0-d3 ; fetch 15 values
			move.b	d0,\2_\3_size*3(a4)
			lsr.w	#8,d0
			move.b	d0,\2_\3_size*2(a4)
			swap	d0
			move.b	d0,\2_\3_size*1(a4)
			lsr.w	#8,d0
			move.b	d0,(a4)
			move.b	d1,\2_\3_size*7(a4)
			lsr.w	#8,d1
			move.b	d1,\2_\3_size*6(a4)
			swap	d1
			move.b	d1,\2_\3_size*5(a4)
			lsr.w	#8,d1
			move.b	d1,\2_\3_size*4(a4)
			move.b	d2,\2_\3_size*11(a4)
			lsr.w	#8,d2
			move.b	d2,\2_\3_size*10(a4)
			swap	d2
			move.b	d2,\2_\3_size*9(a4)
			lsr.w	#8,d2
			move.b	d2,\2_\3_size*8(a4)
			lsr.w	#8,d3
			move.b	d3,\2_\3_size*14(a4)
			swap	d3
			move.b	d3,\2_\3_size*13(a4)
			lsr.w	#8,d3
			move.b	d3,\2_\3_size*12(a4)
		ENDC
		IFEQ \1_\4-32
			movem.l	(a1)+,d0-d3 ; fetch 16 values
			move.b	d0,\2_\3_size*3(a4)
			swap	d0
			move.b	d0,\2_\3_size*1(a4)
			lsr.l	#8,d0
			move.b	d0,(a4)
			swap	d0
			move.b	d0,\2_\3_size*2(a4)
			move.b	d1,\2_\3_size*7(a4)
			swap	d1
			move.b	d1,\2_\3_size*5(a4)
			lsr.l	#8,d1
			move.b	d1,\2_\3_size*4(a4)
			swap	d1
			move.b	d1,\2_\3_size*6(a4)
			move.b	d2,\2_\3_size*11(a4)
			swap	d2
			move.b	d2,\2_\3_size*9(a4)
			lsr.l	#8,d2
			move.b	d2,\2_\3_size*8(a4)
			swap	d2
			move.b	d2,\2_\3_size*10(a4)
			move.b	d3,\2_\3_size*15(a4)
			swap	d3
			move.b	d3,\2_\3_size*13(a4)
			lsr.l	#8,d3
			move.b	d3,\2_\3_size*12(a4)
			swap	d3
			move.b	d3,\2_\3_size*14(a4)
			movem.l	(a1)+,d0-d3 ; fetch 16 values
			move.b	d0,\2_\3_size*19(a4)
			swap	d0
			move.b	d0,\2_\3_size*17(a4)
			lsr.l	#8,d0
			move.b	d0,\2_\3_size*16(a4)
			swap	d0
			move.b	d0,\2_\3_size*18(a4)
			move.b	d1,\2_\3_size*23(a4)
			swap	d1
			move.b	d1,\2_\3_size*21(a4)
			lsr.l	#8,d1
			move.b	d1,\2_\3_size*20(a4)
			swap	d1
			move.b	d1,\2_\3_size*22(a4)
			move.b	d2,\2_\3_size*27(a4)
			swap	d2
			move.b	d2,\2_\3_size*25(a4)
			lsr.l	#8,d2
			move.b	d2,\2_\3_size*24(a4)
			swap	d2
			move.b	d2,\2_\3_size*26(a4)
			move.b	d3,\2_\3_size*31(a4)
			swap	d3
			move.b	d3,\2_\3_size*29(a4)
			lsr.l	#8,d3
			move.b	d3,\2_\3_size*28(a4)
			swap	d3
			move.b	d3,\2_\3_size*30(a4)
		ENDC
		IFEQ \1_\4-48
			movem.l	(a1)+,d0-d3 ; fetch 16 values
			move.b	d0,\2_\3_size*3(a4)
			swap	d0
			move.b	d0,\2_\3_size*1(a4)
			lsr.l	#8,d0
			move.b	d0,(a4)
			swap	d0
			move.b	d0,\2_\3_size*2(a4)
			move.b	d1,\2_\3_size*7(a4)
			swap	d1
			move.b	d1,\2_\3_size*5(a4)
			lsr.l	#8,d1
			move.b	d1,\2_\3_size*4(a4)
			swap	d1
			move.b	d1,\2_\3_size*6(a4)
			move.b	d2,\2_\3_size*11(a4)
			swap	d2
			move.b	d2,\2_\3_size*9(a4)
			lsr.l	#8,d2
			move.b	d2,\2_\3_size*8(a4)
			swap	d2
			move.b	d2,\2_\3_size*10(a4)
			move.b	d3,\2_\3_size*15(a4)
			swap	d3
			move.b	d3,\2_\3_size*13(a4)
			lsr.l	#8,d3
			move.b	d3,\2_\3_size*12(a4)
			swap	d3
			move.b	d3,\2_\3_size*14(a4)
			movem.l	(a1)+,d0-d3 ; fetch 16 values
			move.b	d0,\2_\3_size*19(a4)
			swap	d0
			move.b	d0,\2_\3_size*17(a4)
			lsr.l	#8,d0
			move.b	d0,\2_\3_size*16(a4)
			swap	d0
			move.b	d0,\2_\3_size*18(a4)
			move.b	d1,\2_\3_size*23(a4)
			swap	d1
			move.b	d1,\2_\3_size*21(a4)
			lsr.l	#8,d1
			move.b	d1,\2_\3_size*20(a4)
			swap	d1
			move.b	d1,\2_\3_size*22(a4)
			move.b	d2,\2_\3_size*27(a4)
			swap	d2
			move.b	d2,\2_\3_size*25(a4)
			lsr.l	#8,d2
			move.b	d2,\2_\3_size*24(a4)
			swap	d2
			move.b	d2,\2_\3_size*26(a4)
			move.b	d3,\2_\3_size*31(a4)
			swap	d3
			move.b	d3,\2_\3_size*29(a4)
			lsr.l	#8,d3
			move.b	d3,\2_\3_size*28(a4)
			swap	d3
			move.b	d3,\2_\3_size*30(a4)
			movem.l	(a1)+,d0-d3 ; fetch 16 values
			move.b	d0,\2_\3_size*35(a4)
			swap	d0
			move.b	d0,\2_\3_size*33(a4)
			lsr.l	#8,d0
			move.b	d0,\2_\3_size*32(a4)
			swap	d0
			move.b	d0,\2_\3_size*34(a4)
			move.b	d1,\2_\3_size*39(a4)
			swap	d1
			move.b	d1,\2_\3_size*37(a4)
			lsr.l	#8,d1
			move.b	d1,\2_\3_size*36(a4)
			swap	d1
			move.b	d1,\2_\3_size*38(a4)
			move.b	d2,\2_\3_size*43(a4)
			swap	d2
			move.b	d2,\2_\3_size*41(a4)
			lsr.l	#8,d2
			move.b	d2,\2_\3_size*40(a4)
			swap	d2
			move.b	d2,\2_\3_size*42(a4)
			move.b	d3,\2_\3_size*47(a4)
			swap	d3
			move.b	d3,\2_\3_size*45(a4)
			lsr.l	#8,d3
			move.b	d3,\2_\3_size*44(a4)
			swap	d3
			move.b	d3,\2_\3_size*46(a4)
		ENDC
	ENDC
	IFC "W","\0"
		IFEQ \1_\4-14
			movem.l	(a1)+,d0-d3 ; fetch 8 values
			move.w	d0,\2_\3_size*1(a4)
			swap	d0
			move.w	d0,(a4)
			move.w	d1,\2_\3_size*3(a4)
			swap	d1
			move.w	d1,\2_\3_size*2(a4)
			move.w	d2,\2_\3_size*5(a4)
			swap	d2
			move.w	d2,\2_\3_size*4(a4)
			move.w	d3,\2_\3_size*7(a4)
			swap	d3
			move.w	d3,\2_\3_size*6(a4)
			movem.l	(a1),d0-d2 ; fetch 6 values
			move.w	d0,\2_\3_size*9(a4)
			swap	d0
			move.w	d0,\2_\3_size*8(a4)
			move.w	d1,\2_\3_size*11(a4)
			swap	d1
			move.w	d1,\2_\3_size*10(a4)
			move.w	d2,\2_\3_size*13(a4)
			swap	d2
			move.w	d2,\2_\3_size*12(a4)
		ENDC
		IFEQ \1_\4-15
			movem.l	(a1)+,d0-d3 ; fetch 8 values
			move.w	d0,\2_\3_size*1(a4)
			swap	d0
			move.w	d0,(a4)
			move.w	d1,\2_\3_size*3(a4)
			swap	d1
			move.w	d1,\2_\3_size*2(a4)
			move.w	d2,\2_\3_size*5(a4)
			swap	d2
			move.w	d2,\2_\3_size*4(a4)
			move.w	d3,\2_\3_size*7(a4)
			swap	d3
			move.w	d3,\2_\3_size*6(a4)
			movem.l	(a1),d0-d3 ; fetch 7 values
			move.w	d0,\2_\3_size*9(a4)
			swap	d0
			move.w	d0,\2_\3_size*8(a4)
			move.w	d1,\2_\3_size*11(a4)
			swap	d1
			move.w	d1,\2_\3_size*10(a4)
			move.w	d2,\2_\3_size*13(a4)
			swap	d2
			move.w	d2,\2_\3_size*12(a4)
			swap	d3
			move.w	d3,\2_\3_size*14(a4)
		ENDC
	ENDC
	ENDM
