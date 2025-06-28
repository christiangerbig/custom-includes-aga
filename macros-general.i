RS_ALIGN_LONGWORD		MACRO
; Input
; Result
	IFNE __RS%4
		RS.W 1
	ENDC
	ENDM


WAIT_LEFT_MOUSE_BUTTON		MACRO
; Input
; Result
wait_left_button_loop\@
	btst	#CIAB_GAMEPORT0,CIAPRA(a4)
	bne.s	wait_left_button_loop\@
	ENDM


WAIT_RIGHT_MOUSE_BUTTON		MACRO
; Input
; Result
wait_right_button_loop\@
	btst	#POTINPB_DATLY-8,POTINP-DMACONR(a6)
	bne.s	wait_right_button_loop\@
	ENDM


WAIT_MOUSE			MACRO	; !ONLY for testing purposes!
; Input
; Result
wm_loop\@
	move.w	_CUSTOM+VHPOSR,_CUSTOM+COLOR00
	btst	#POTINPB_DATLY-8,_CUSTOM+POTINP
	bne.s	wm_loop\@
	ENDM


RASTER_TIME			MACRO
; Input
; \1 WORD:	RGB4 hex value (optional)
; Global reference
; rt_rasterlines_number
; Result
	move.l	d0,-(a7)
	move.w	VPOSR-DMACONR(a6),d0
	swap	d0
	move.w	VHPOSR-DMACONR(a6),d0
	and.l	#$3ff00,d0
	lsr.l	#8,d0
	cmp.l	rt_rasterlines_number(a3),d0
	blt.s	raster_time_skip\@
	move.l	d0,rt_rasterlines_number(a3)
raster_time_skip\@
	IFNC "","\1"
		SHOW_BEAM_POSITION \1
	ENDC
	move.l	(a7)+,d0
	ENDM


SHOW_BEAM_POSITION		MACRO
; Input
; \1 WORD:	RGB4 hex value
; Global refence
; bplcon3_bits1
; Result
	MOVEF.W	bplcon3_bits1,d0
	move.w	d0,BPLCON3-DMACONR(a6)
	move.w	#\1,COLOR00-DMACONR(a6)
	ENDM


AUDIO_TEST			MACRO
; Input
; Result
	lea	$20000,a0		; dummy chip memory address
	move.l	a0,AUD0LCH-DMACONR(a6)
	move.l	a0,AUD1LCH-DMACONR(a6)
	move.l	a0,AUD2LCH-DMACONR(a6)
	move.l	a0,AUD3LCH-DMACONR(a6)
	moveq	#1,d0
	move.w	d0,AUD0LEN-DMACONR(a6)	
	move.w	d0,AUD1LEN-DMACONR(a6)
	move.w	d0,AUD2LEN-DMACONR(a6)
	move.w	d0,AUD3LEN-DMACONR(a6)
	moveq	#0,d0
	move.w	d0,AUD0VOL-DMACONR(a6)
	move.w	d0,AUD1VOL-DMACONR(a6)
	move.w	d0,AUD2VOL-DMACONR(a6)
	move.w	d0,AUD3VOL-DMACONR(a6)
	move.w	#DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3|DMAF_SETCLR,DMACON-DMACONR(a6) ; start replay
	ENDM


MOVEF				MACRO
; Input
; \0 STRING:	["B", "W", "L"] size
; \1 NUMBER:	Source value
; \2 STRING:	Target
; Result
	IFC "","\0"
		FAIL Macro MOVEF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro MOVEF: Source value missing
	ENDC
	IFC "","\2"
		FAIL Macro MOVEF: Target missing
	ENDC
	IFC "B","\0"
		IFLE $80-(\1)		; number >= $80
			IFGE $ff-(\1)	; number <= $ff
				moveq #-((-(\1)&$ff)),\2
			ENDC
		ELSE
			moveq #\1,\2
		ENDC
	ENDC
	IFC "W","\0"
		IFEQ (\1)&$ff00		; number <= $00ff
			IFEQ (\1)&$80	; number <= $007f
				moveq	#\1,\2
			ENDC
			IFEQ (\1)-$80	; number = $0080
				moveq	#$7f,\2
				not.b	\2
			ENDC
			IFGT (\1)-$80	; number > $0080
				moveq	#256-(\1),\2
				neg.b	\2
			ENDC
		ELSE			; number > $00ff
			move.w	#\1,\2
		ENDC
	ENDC
	IFC "L","\0"
		IFEQ (\1)&$ffffff00	; number <= $000000ff
			IFEQ (\1)&$80	; number <= $0000007f
				moveq	#\1,\2
			ENDC
			IFEQ (\1)-$80	; number = $00000080
				moveq	#$7f,\2
				not.b	\2
			ENDC
			IFGT (\1)-$80	; number > $00000080
				moveq	#256-(\1),\2
				neg.b	\2
			ENDC
		ELSE			; number > $000000ff
			move.l	#\1,\2
		ENDC
	ENDC
	ENDM


ADDF				MACRO
; Input
; \0 STRING:	["B", "W", "L"] size
; \1 NUMBER:	8/16 bit source value
; \2 STRING:	Target
; Result
	IFC "","\0"
		FAIL Macro ADDF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro ADDF: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro ADDF: Destination missing
	ENDC
	IFEQ \1
		MEXIT
	ENDC
	IFC "B","\0"
		IFGE (\1)-$8000		; number > $7fff
			add.b	#\1,\2
		ELSE
			IFLE (\1)-8	; number <= $0008
				addq.b	#(\1),\2
			ELSE		; number > $0008
				IFLE (\1)-16 ; number <= $0010
					addq.b	#8,\2
					addq.b	#\1-8,\2
				ELSE	; number > $0010
					add.b	#\1,\2
				ENDC
			ENDC
		ENDC
	ENDC
	IFC "W","\0"
		IFGE (\1)-$8000		; number > $7fff
			add.w	#\1,\2
		ELSE
			IFLE (\1)-8	; number <= $0008
				addq.w	#(\1),\2
			ELSE		; number > $0008
				IFLE (\1)-16 ; number <= $0010
					addq.w	#8,\2
					addq.w	#\1-8,\2
				ELSE	; number > $0010
					add.w	#\1,\2
				ENDC
			ENDC
		ENDC
	ENDC
	IFC "L","\0"
		IFGE (\1)-$8000		; number > $7fff
			add.l	#\1,\2
		ELSE
			IFLE (\1)-8	; number <= $0008
				addq.l	#(\1),\2
			ELSE		; number > $0008
				IFLE (\1)-16 ; number <= $0010
					addq.l	#8,\2
					addq.l	#\1-8,\2
				ELSE	; number > $0010
					add.l	#\1,\2
				ENDC
			ENDC
			IFGE (\1)-$8000	; number > $7fff
				add.l	#\1,\2
			ENDC
		ENDC
	ENDC
	ENDM


SUBF				MACRO
; Input
; \0 STRING:	["B", "W", "L"] size
; \1 NUMBER:	8/16 bit source value
; \2 STRING:	Target
; Result
	IFC "","\0"
		FAIL Macro SUBF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro SUBF: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro SUBF: Target missing
	ENDC
	IFEQ \1
		MEXIT
	ENDC
	IFC "B","\0"
		IFLE (\1)-8		; number <= $0008
			subq.b	#(\1),\2
		ELSE			; number > $0008
			IFLE (\1)-16	; number <= $0010
				subq.b	#8,\2
				subq.b	#\1-8,\2
			ELSE		; number > $0010
				sub.b	#\1,\2
			ENDC
		ENDC
	ENDC
	IFC "W","\0"
		IFLE (\1)-8		; number <= $0008
			subq.w	#(\1),\2
		ELSE			; number > $0008
			IFLE (\1)-16	; number <= $0010
				subq.w	#8,\2
				subq.w	#\1-8,\2
			ELSE		; number > $0010
				sub.w	#\1,\2
			ENDC
		ENDC
	ENDC
	IFC "L","\0"
		IFLE (\1)-8		; number <= $0008
			subq.l	#(\1),\2
		ELSE			; number > $0008
			IFLE (\1)-16	; number <= $0010
				subq.l	#8,\2
				subq.l	#\1-8,\2
			ELSE		; number > $0010
				sub.l	#\1,\2
			ENDC
		ENDC
	ENDC
	ENDM


MULUF				MACRO
; Input
; \0 STRING:	["B", "W", "L"] size
; \1 NUMBER:	16/32 bit factor
; \2 NUMBER:	Product
; \3 STRING:	Scratch register
; Result
	IFC "","\0"
		FAIL Macro MULUF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro MULUF: Factor missing
	ENDC
	IFC "","\2"
		FAIL Macro MULUF: Product missing
	ENDC
	IFEQ \1
		FAIL Macro MULUF: Factor is 0
	ENDC
	IFC "B","\0"
		IFGT \1-128
			FAIL Macro MULUF.B: Fcktor is greater than 128
		ENDC
	ENDC
	IFEQ (\1)-2			; *2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-3			; *3
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-4			; *4
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-5			; *5
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-6			; *6
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-7			; *7
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-8			; *8
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-9			; *9
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-10			; *10
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-11			; *11
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-12			; *12
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-13			; *13
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-14			; *14
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-15			; *15
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-16			; *16
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-17			; *17
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-18			; *18
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-19			; *19
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-20			; *20
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-22			; *22
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-23			; *23
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-24			; *24
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-25			; *25
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-28			; *28
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-29			; *29
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-30			; *30
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-31			; *31
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-32			; *32
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-33			; *33
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-34			; *34
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-35			; *35
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-36			; *36
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-37			; *37
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-38			; *38
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-40			; *40
		move.\0	\2,\3
		lsl.\0	#5,\2
		lsl.\0	#3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-41			; *41
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-42			; *42
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-44			; *44
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-45			; *45
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-46			; *46
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-47			; *47
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-48			; *48
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-49			; *49
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-50			; *50
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-51			; *51
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-55			; *55
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		lsl.\0	#3,\3
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-56			; *56
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-60			; *60
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-62			; *62
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-63			; *63
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-64			; )<<6
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-65			; *65
		move.\0	\2,\3
		lsl.\0	#6,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-66			; *66
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-67			; *67
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-68			; *68
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-70			; *70
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\3
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-72			; *72
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-74			; *74
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-76			; *76
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\3
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-80			; *80
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-84			; *84
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-88			; *88
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-92			; *92
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-94			; *94
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#5,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-96			; *96
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-104			; *104
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-110			; *110
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		lsl.\0	#3,\3
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-112			; *112
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-120			; *120
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-122			; *122
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\3,\3
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-124			; *124
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-126			; *126
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-127			; *127
		move.\0	\2,\3
		lsl.\0	#7,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-128			; *128
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-129			; *129
		move.\0	\2,\3
		lsl.\0	#7,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-130			; *130
		move.\0	\2,\3
		lsl.\0	#6,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-132			; *132
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-136			; *136
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-144			; *144
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-156			; *156
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#5,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-158			; *158
		move.\0 \2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
		add.\0	\3,\3
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-160			; *160
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-168			; *168
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-176			; *176
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-184			; *184
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-192			; *192
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-196			; *196
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-200			; *200
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-208			; *208
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-224			; *224
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-240			; *240
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-248			; *248
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-252			; *252
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-254			; *254
		move.\0	\2,\3
		lsl.\0	#7,\2
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-255			; *255
		move.\0	\2,\3
		lsl.\0	#8,\2
		sub.\0	\3,\2
	ENDC
	IFEQ (\1)-256			; *256
		lsl.\0	#8,\2
	ENDC
	IFEQ (\1)-257			; *257
		move.\0	\2,\3
		lsl.\0	#8,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-258			; *258
		move.\0	\2,\3
		lsl.\0	#7,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-260			; *260
		move.\0	\2,\3
		lsl.\0	#6,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-264			; *264
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-266			; *266
		move.\0	\2,\3
		lsl.\0	#5,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-272			; *272
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-280			; *280
		move.\0	\2,\3
		lsl.\0	#4,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-288			; *288
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-304			; *304
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-320			; *320
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-384			; *384
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-400			; *400
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-416			; *416
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-448			; *448
		move.\0	\2,\3
		lsl.\0	#8,\2
		lsl.\0	#5,\3
		sub.\0	\3,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-464			; *464
		move.\0	\2,\3
		lsl.\0	#5,\2
		sub.\0	\3,\2
		add.\0	\3,\3
		sub.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-480			; *480
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-488			; *488
		move.\0	\2,\3
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\3,\3
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-512			; *512
		lsl.\0	#8,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-576			; *576
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-608			; *608
		move.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\3,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#5,\2
	ENDC
	IFEQ (\1)-624			; *624
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#4,\2
	ENDC
	IFEQ (\1)-625			; *625
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\2,\3
		lsl.\0	#3,\2
		add.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
	ENDC
	IFEQ (\1)-640			; *640
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-704			; *704
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-768			; *768
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
	ENDC
	IFEQ (\1)-832			; *832
		move.\0	\2,\3
		add.\0	\3,\3
		add.\0	\3,\3
		add.\0	\3,\2
		add.\0	\3,\3
		add.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-896			; *896
		move.\0	\2,\3
		lsl.\0	#3,\2
		sub.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-960			; *960
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#6,\2
	ENDC
	IFEQ (\1)-1016			; *1016
		move.\0	\2,\3
		lsl.\0	#7,\2
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-1024			; *1024
		lsl.\0	#8,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-1280			; *1280
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
	ENDC
	IFEQ (\1)-1920			; *1920
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#7,\2
	ENDC
	IFEQ (\1)-2048			; *2048
		lsl.\0	#8,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-2560			; *2560
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-3072			; *3072
		move.\0	\2,\3
		add.\0	\2,\2
		add.\0	\3,\2
		lsl.\0	#8,\2
		add.\0	\2,\2
		add.\0	\2,\2
	ENDC
	IFEQ (\1)-8192			; *8192
		swap	\2
		asr.l	#3,\2
	ENDC
	ENDM


MULSF				MACRO
; Input
; \1 NUMBER:	16 bit signed factor
; \2 NUMBER:	Product
; \3 STRING:	Scratch register
; Result
	IFC "","\1"
		FAIL Macro MULSF: Factor missing
	ENDC
	IFC "","\2"
		FAIL Macro MULSF: Product missing
	ENDC
	IFEQ \1
		FAIL Macro MULSF: Factor is 0
	ENDC
	ext.l	\2
	MULUF.L \1,\2,\3
	ENDM


DIVUF				MACRO
; Input
; \0 STRING:	["W"] size
; \1 NUMBER:	Divisor
; \2 NUMBER:	Divident
; \3 STRING:	Scratch register, result
; Result
	IFC "","\0"
		FAIL Macro DIVUF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro DIVUF: Divsor missing
	ENDC
	IFC "","\2"
		FAIL Macro DIVUF: Divident missing
	ENDC
	moveq	#-1,\3			; counter for result
divison_loop\@
	addq.w	#1,\3
	sub.w	\1,\2			; divisor - divident
	bge.s	divison_loop\@		; until dividend < divisor
	ENDM


CMPF				MACRO
; Input
; \0 STRING:	["B", "W", "L"] size
; \1 NUMBER:	Source 8/16/32 bit
; \2 STRING:	Target
; Result
	IFC "","\0"
		FAIL Macro CMPF: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro CMPF: Source missing
	ENDC
	IFC "","\2"
		FAIL Macro CMPF: Target missing
	ENDC
	IFEQ \1
		tst.\0	\2
	ELSE
		cmp.\0	#\1,\2
	ENDC
	ENDM


CPU_INIT_COLOR_HIGH		MACRO
; Input
; \1 WORD:		First color register offset
; \2 BYTE_SIGNED:	Number of colors
; \3 POINTER:		Color table (optional)
; Global reference
; cpu_init_high_colors
; Result
	IFC "","\1"
		FAIL Macro CPU_INIT_COLOR_HIGH: First color register offset missing
	ENDC
	IFC "","\2"
		FAIL Macro CPU_INIT_COLOR_HIGH: Number of colors missing
	ENDC
	lea		(\1)-DMACONR(a6),a0 ;first color register
	IFNC "","\3"
		lea	\3(pc),a1	; color table
	ENDC
	moveq	#\2-1,d7		; number of colors
	bsr	cpu_init_high_colors
	ENDM


CPU_INIT_COLOR_LOW		MACRO
; Input
; \1 WORD:		First color register offset
; \2 BYTE_SIGNED:	Number of colors
; \3 POINTER:		Color table (optional)
; Global reference
; cpu_init_high_colors
; Result
	IFC "","\1"
		FAIL Macro CPU_INIT_COLOR_LOW: First color register offset missing
	ENDC
	IFC "","\2"
		FAIL Macro CPU_INIT_COLOR_LOW: Number of colors missing
	ENDC
	lea		(\1)-DMACONR(a6),a0 ; first color register
	IFNC "","\3"
		lea	\3(pc),a1	; color table
	ENDC
	moveq	#\2-1,d7		; number of colors
	bsr	cpu_init_low_colors
	ENDM


RGB8_TO_RGB4_HIGH		MACRO
; Input
; \1 LONGWORD:	RGB8 value
; \2 LONGWORD:	Scratch register
; \3 STRING:	Color high mask
; Result
; \1 WORD:	RGB4 high
	IFC "","\1"
		FAIL Macro RGB8_TO_RGB4_HIGH: RGB8 value missing
	ENDC
	IFC "","\2"
		FAIL Macro RGB8_TO_RGB4_HIGH: Scratch register missing
	ENDC
	IFC "","\3"
		FAIL Macro RGB8_TO_RGB4_HIGH: Color high mask missing
	ENDC
	lsr.l	#4,\1			; RrGgB
	and.w	\3,\1			; RrG0B
	move.l	\1,\2			; RrG0B
	lsr.l	#4,\1			; RrGB
	or.b	\1,\2			; RrGB
	lsr.w	#4,\1			; RrG
	move.b	\2,\1			; RGB
	ENDM


RGB8_TO_RGB4_LOW		MACRO
; Input
; \1 LONGWORD:	RGB8 value
; \2 BYTE:	Scratch register
; \3 STRING:	Color low mask
; Result
; \1 WORD:	Return RGB4 low
	IFC "","\1"
		FAIL Macro RGB8_TO_RGB4_LOW: RGB8 value missing
	ENDC
	IFC "","\2"
		FAIL Macro RGB8_TO_RGB4_LOW: Scratch register missing
	ENDC
	IFC "","\3"
		FAIL Macro RGB8_TO_RGB4_LOW: Color low mask missing
	ENDC
	and.w	\3,\1			; g0b
	move.b	\1,\2			; 0b
	lsr.l	#4,\1			; Rr0g0
	or.b	\1,\2			; gb
	lsr.w	#4,\1			; r0g
	move.b	\2,\1			; rgb
	ENDM


RGB8_TO_RGB8_HIGH_LOW		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	Number of entries
; Result
	IFC "","\1"
		FAIL Macro RGB8_TO_RGB8_HIGH_LOW: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro RGB8_TO_RGB8_HIGH_LOW: Number of entries missing
	ENDC
	CNOP 0,4
\1_convert_color_table
	move.w	#RB_NIBBLES_MASK,d3
	lea	\1_color_table(pc),a0
	move.w	#\2-1,d7		; number of colors
\1_convert_color_table_loop
	move.l	(a0),d0			; RGB8
	move.l	d0,d2					
	RGB8_TO_RGB4_HIGH d0,d1,d3
	move.w	d0,(a0)+		; RGB4 high
	RGB8_TO_RGB4_LOW d2,d1,d3
	move.w	d2,(a0)+		; RGB4 low
	dbf	d7,\1_convert_color_table_loop
	rts
	ENDM


INIT_CHARS_OFFSETS MACRO
; Input
; \0 STRING:	["W", "L"] size
; \1 STRING:	Labels prefix
; Global reference
; _image_plane_width
; _image_depth
; _origin_char_x_size
; _origin_char_y_size
; _chars_offsets
; _ascii
; _ascii_end
; Result
	CNOP 0,4
\1_init_chars_offsets
	IFC "","\0"
		FAIL Macro INIT_CHARS_OFFSETS: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro INIT_CHARS_OFFSETS: Labels prefix missing
	ENDC
	IFC "W","\0"
		moveq	#0,d0		; 1st character image x offset
		moveq	#\1_image_plane_width,d1 ; last character image x offset
		move.w	d1,d2		; x offset reset
		MOVEF.W \1_image_plane_width*\1_image_depth*(\1_origin_char_y_size+1),d3 ; next character images line
		lea	\1_chars_offsets(pc),a0
		moveq	#\1_ascii_end-\1_ascii-1,d7
\1_init_chars_offsets_loop
		move.w	d0,(a0)+	; character image offset
		addq.w	#\1_origin_char_x_size/8,d0 ; next character image
		cmp.w	d1,d0		; last character image in line ?
		bne.s	\1_init_chars_offsets_skip
		sub.w	d2,d0		; reset x offset
		add.w	d3,d1		; + y offset
		add.w	d3,d0		; next character images line
\1_init_chars_offsets_skip
		dbf	d7,\1_init_chars_offsets_loop
		rts
	ENDC
	IFC "L","\0"
		moveq	#0,d0		; 1st character image x offset
		moveq	#\1_image_plane_width,d1 ; last character image x offset
		move.l	d1,d2		; x offset reset
		move.l	#\1_image_plane_width*\1_image_depth*(\1_origin_char_y_size),d3 ; next character images line
		lea	\1_chars_offsets(pc),a0
		moveq	#\1_ascii_end-\1_ascii-1,d7
\1_init_chars_offsets_loop
		move.l	d0,(a0)+	; character image offset
		add.l	#\1_origin_char_x_size/8,d0 ; next character image
		cmp.l	d1,d0		; last character image in line ?
		bne.s	\1_init_chars_offsets_skip
		sub.l	d2,d0		; reset x offset
		add.l	d3,d1		; + y offset
		add.l	d3,d0		; next character images line
\1_init_chars_offsets_skip
		dbf	d7,\1_init_chars_offsets_loop
		rts
	ENDC
	ENDM


INIT_CHARS_X_POSITIONS	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	["LORES", "HIRES", "SHIRES"] pixel resolution
; \3 STRING:	["BACKWARDS"] (optional)
; \4 NUMBER:	Number of characters (optional)
; Global reference
; _text_char_x_size
; _chars_x_positions
; _text_chars_number
; Result
	CNOP 0,4
\1_init_chars_x_positions
	IFC "","\1"
		FAIL Macro INIT_CHARS_X_POSITIONS: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_CHARS_X_POSITIONS: Pixel resolution missing
	ENDC
	moveq	#0,d0			; 1st x
	IFC "LORES","\2"
		moveq	#\1_text_char_x_size,d1 ; next character image
	ENDC
	IFC "HIRES","\2"
		moveq	#\1_text_char_x_size*HIRES_PIXEL_FACTOR,d1 ; next character image
	ENDC
	IFC "SHIRES","\2"
		MOVEF.W	\1_text_char_x_size*SHIRES_PIXEL_FACTOR,d1 ; next character image
	ENDC
	IFNC "BACKWARDS","\3"
		lea	\1_chars_x_positions(pc),a0
	ELSE
		IFC "","\4"
			lea	\1_chars_x_positions+(\1_text_chars_number*WORD_SIZE)(pc),a0
		ELSE
			lea	\1_chars_x_positions+((\1_\4)*WORD_SIZE)(pc),a0
		ENDC
	ENDC
	IFC "","\4"
		moveq	#(\1_text_chars_number)-1,d7
	ELSE
		moveq	#(\1_\4)-1,d7	; number of chracters
	ENDC
\1_init_chars_x_positions_loop
	IFNC "BACKWARDS","\3"
		move.w	d0,(a0)+	; x position
	ELSE
		move.w	d0,-(a0)	; x position
	ENDC
	add.w	d1,d0			; next character image
	dbf	d7,\1_init_chars_x_positions_loop
	rts
	ENDM


INIT_CHARS_Y_POSITIONS		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	Number of characters (optional)
; Global reference
; _text_char_y_size
; _chars_y_positions
; _text_chars_number
; Result
	CNOP 0,4
\1_init_chars_y_positions
	IFC "","\1"
		FAIL Macro INIT_CHARS_Y_POSITIONS: Labels prefix missing
	ENDC
	moveq	#0,d0			; 1st y
	moveq	#\1_text_char_y_size,d1 ; next chracter image
	lea	\1_chars_y_positions(pc),a0
	IFC "","\2"
		moveq	#(\1_text_chars_number)-1,d7
	ELSE
		moveq	#(\1_\2)-1,d7	; number of characters
	ENDC
\1_init_chars_y_positions_loop
	move.w	d0,(a0)+		; y position
	add.w	d1,d0			; next character image
	dbf	d7,\1_init_chars_y_positions_loop
	rts
	ENDM


INIT_CHARS_IMAGES		MACRO
; Input
; \1 STRING:	Labels prefix
; Global reference
; _chars_image_pointers
; _text_chars_number
; _get_new_char_image

; Result
	CNOP 0,4
\1_init_chars_images
	IFC "","\1"
		FAIL Macro INIT_CHARS_IMAGES: Labels prefix missing
	ENDC
	lea	\1_chars_image_pointers(pc),a2
	MOVEF.W	(\1_text_chars_number)-1,d7
\1_init_chars_images_loop
	bsr	\1_get_new_char_image
	move.l	d0,(a2)+		; character image
	dbf	d7,\1_init_chars_images_loop
	rts
	ENDM


GET_NEW_CHAR_IMAGE		MACRO
; Input
; \0 STRING:	["W", "L"] size
; \1 STRING:	Labels prefix
; \2 LABEL:	Sub routine acheck control codes (optional)
; \3 STRING:	["NORESTART"] (optional)
; \4 STRING:	["BACKWARDS"] (optional)
; \5 STRING:	Offset next character image (optional)
; Global reference
; _text_table_start
; _text
; _text_end
; _ascii
; _ascii_end
; _origin_char_x_size
; _text_char_x_size
; _chars_offsets
; _image
; _char_toggle_image
; _char_words_counter
; Result
; d0.l		Pointer character image
	IFC "","\0"
		FAIL Macro GET_NEW_CHAR_IMAGE: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro GET_NEW_CHAR_IMAGE: Labels prefix missing
	ENDC
	CNOP 0,4
\1_get_new_char_image
	move.w	\1_text_table_start(a3),d1
	IFC "BACKWARDS","\4"
		bpl.s	\1_get_new_char_image_skip1
		move.w	#\1_text_end-\1_text-1,d1 ; restart text
\1_get_new_char_image_skip1
	ENDC
	lea	\1_text(pc),a0
\1_get_new_char_image_skip2
	move.b	(a0,d1.w),d0		; ASCII code
	IFNC "","\2"
		bsr.s	\2
		tst.l	d0
		beq.s	\1_get_new_char_image_skip5
	ENDC
	IFNC "BACKWARDS","\4"
		IFNC "NORESTART","\3"
			cmp.b	#FALSE,d0 ; end of text ?
			beq.s	\1_get_new_char_image_skip6
		ENDC
	ENDC
	lea	\1_ascii(pc),a0
	moveq	#\1_ascii_end-\1_ascii-1,d6
\1_get_new_char_image_loop
	cmp.b	(a0)+,d0		; character found ?
	dbeq	d6,\1_get_new_char_image_loop
	IFC "BACKWARDS","\4"
		IFC "","\5"
			subq.w	#BYTE_SIZE,d1 ; next character
		ELSE
			SUBF.W	\1_\5,d1 ; next character
		ENDC
	ELSE
		IFLT \1_origin_char_x_size-32
			IFC "","\5"
				addq.w	#BYTE_SIZE,d1 ; next character
			ELSE
				ADDF.W	\1_\5,d1 ; next character
			ENDC
		ELSE
		IFNE \1_text_char_x_size-16
			IFC "","\5"
				addq.w	#BYTE_SIZE,d1 ; next character
			ELSE
				ADDF.W	\1_\5,d1 ; next character
			ENDC
		ENDC
		ENDC
	ENDC

	moveq	#\1_ascii_end-\1_ascii-1,d0
	IFLT \1_origin_char_x_size-32
		move.w	d1,\1_text_table_start(a3)
	ELSE
		IFNE \1_text_char_x_size-16
			move.w	d1,\1_text_table_start(a3)
		ENDC
	ENDC
	sub.w	d6,d0			; number of characters - loop counter
	lea	\1_chars_offsets(pc),a0
	IFC "W","\0"
		move.w	(a0,d0.w*2),d0	; offset character image
	ENDC
	IFC "L","\0"
		move.l	(a0,d0.w*4),d0	; offset character image
	ENDC
	add.l	\1_image(a3),d0
	IFNC "BACKWARDS","\4"
		IFEQ \1_origin_char_x_size-32
			IFEQ \1_text_char_x_size-16
				not.w	\1_char_toggle_image(a3) ; new character image ?
				bne.s	\1_get_new_char_image_skip3
				IFC "","\5"
					addq.w	#BYTE_SIZE,d1 ; next character
				ELSE
					ADDF.W	\1_\5,d1 ; next character
				ENDC
				addq.l	#WORD_SIZE,d0 ; 2nd part of character image
				move.w	d1,\1_text_table_start(a3)
\1_get_new_char_image_skip3
			ENDC
		ENDC
		IFGT \1_origin_char_x_size-32
			IFEQ \1_text_char_x_size-16
				moveq	#0,d3
				move.w	\1_char_words_counter(a3),d3
				move.l	d3,d4
				MULUF.W	WORD_SIZE,d4,d2 ; character image word offset
				addq.w	#1,d3 ; next character image
				add.l	d4,d0 ; offset in character image
				cmp.w	#\1_origin_char_x_size/16,d3 ; new character image ?
				bne.s	\1_get_new_char_image_skip4
				IFC "","\5"
					addq.w	#BYTE_SIZE,d1 ; next character
				ELSE
					ADDF.W	\1_\5,d1 ; next character
				ENDC
				move.w	d1,\1_text_table_start(a3)
				moveq	#0,d3 ; reset words counter
\1_get_new_char_image_skip4
				move.w	d3,\1_char_words_counter(a3)
			ENDC
		ENDC
	ENDC
	rts
	IFNC "BACKWARDS","\4"
		IFNC "","\2"
			CNOP 0,4
\1_get_new_char_image_skip5
			IFC "","\5"
				addq.w	#BYTE_SIZE,d1 ; next character
			ELSE
				ADDF.W	\1_\5,d1 ; next character
			ENDC
			IFGE \1_origin_char_x_size-32
				IFEQ \1_text_char_x_size-16
					move.w	d1,\1_text_table_start(a3)
				ENDC
			ENDC
		bra.s	\1_get_new_char_image_skip2
		ENDC
		IFNC "NORESTART","\3"
			CNOP 0,4
\1_get_new_char_image_skip6
			moveq	#0,d1
			bra.s	\1_get_new_char_image_skip2
		ENDC
	ENDC
	ENDM


CPU_SELECT_COLOR_HIGH_BANK	MACRO
; Input
; \1 NUMBER:	[0..7] color bank
; \2 WORD:	Additional BPLCON3 bits (optional)
; global reference
; bplcon3_bits1
; Result
	IFC "","\1"
		FAIL Macro CPU_SELECT_COLOR_HIGH_BANK: Color bank missing
	ENDC
	IFC "","\2"
		IFNE \1
			move.w	#bplcon3_bits1|(BPLCON3F_BANK0*\1),BPLCON3-DMACONR(a6)
		ELSE
			MOVEF.W bplcon3_bits1|(BPLCON3F_BANK0*\1),d0
			move.w	d0,BPLCON3-DMACONR(a6)
		ENDC
	ELSE
		MOVEF.W bplcon3_bits1|(BPLCON3F_BANK0*\1),d0
		or.w	#\2,d0
		move.w	d0,BPLCON3-DMACONR(a6)
	ENDC
	ENDM


CPU_SELECT_COLOR_LOW_BANK	MACRO
; Input
; \1 NUMBER:	[0..7] color bank
; \2 WORD:	Additional BPCON3 bits (optional)
; Global reference
; bplcon3_bits1
; Result
	IFC "","\1"
		FAIL Macro CPU_SELECT_COLOR_LOW_BANK: Color bank missing
	ENDC
	IFC "","\2"
		move.w	#bplcon3_bits2|(BPLCON3F_BANK0*\1),BPLCON3-DMACONR(a6)
	ELSE
		MOVEF.W bplcon3_bits2|(BPLCON3F_BANK0*\1),d0
		or.w	#\2,d0
		move.w	d0,BPLCON3-DMACONR(a6)
	ENDC
	ENDM


DISABLE_060_STORE_BUFFER	MACRO
; Input
; Result
; d0.l		CACR old content
; Global reference
; os_cacr
	move.l	_SysBase(pc),a6
	tst.b	AttnFlags+BYTESZE(a6)	; MC68060 ?
	bpl.s	disable_060_store_buffer_skip
	lea	do_disable_060_store_buffer(pc),a5
	CALLLIBS Supervisor
	move.l	d0,os_cacr(a3)
disable_060_store_buffer_skip
	rts

	CNOP 0,4
do_disable_060_store_buffer
	or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
	nop
	movec.l CACR,d0
	move.l	d0,d1					
	nop
	CPUSHA	BC			; flush instruction/data/branch caches
	nop
	and.l	#~CACR060F_ESB,d1	; disable store buffer
	movec.l	d1,CACR
	nop
	rte
	ENDM


ENABLE_060_STORE_BUFFER		MACRO
; Input
; d1.l		CACR old content
; Global reference
; os_cacr
; Result
	move.l	_SysBase(pc),a6
	tst.b	AttnFlags+BYTE_SIZE(a6)	; MC68060 ?
	bpl.s	enable_060_store_buffer_skip
	lea	do_enable_060_store_buffer(pc),a5
	move.l	os_cacr(a3),d1
	CALLLIBQ Supervisor
enable_060_store_buffer_skip
	rts
	CNOP 0,4
do_enable_060_store_buffer
	or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
	nop
	CPUSHA	BC			; flush instruction/data/branch caches
	nop
	or.b	#CACR060F_ESB,d1	; enable store buffer
	nop
	movec.l d1,CACR
	nop
	rte
	ENDM


INIT_MIRROR_BPLAM_TABLE		MACRO
; Input
; \0 STRING:		["B", "W"] size
; \1 STRING:		Labels prefix
; \2 NUMBER:		First BPLAM value (optional)
; \3 NUMBER:		Next switch value (optional)
; \4 BYTE SIGNED:	Number of color gradients
; \5 BYTE SINGED:	Number of sections per color gradient
; \6 POINTER:		BPLAM table
; \7 STRING:		["pc", "a3"] pointer base
; \8 WORD:		Offset table start (optional)
; \9 NUMBER:		First switch value for mirroring (optional)
; Global reference
; bplcon4_bits
; Result
	CNOP 0,4
\1_init_mirror_bplam_table
	IFC "","\0"
		FAIL Macro MIRROR_bplam_table: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro MIRROR_bplam_table: Labels prefix missing
	ENDC
	IFC "","\4"
		FAIL Macro INIT_MIRROR_bplam_table: Number of color gradients missing
	ENDC
	IFC "","\5"
		FAIL Macro INIT_MIRROR_bplam_table: Number of sections per color gradient missing
	ENDC
	IFC "","\6"
		FAIL Macro INIT_MIRROR_bplam_table: BPLAM table missing
	ENDC
	IFC "","\7"
		FAIL Macro INIT_MIRROR_bplam_table: Pointer base missing
	ENDC
	IFC "pc","\7"
		lea	\1_\6(\7),a0	; BPLAM table
	ENDC
	IFC "a3","\7"
		move.l	\6(\7),a0	; BPLAM table
	ENDC
	IFC "B","\0"
		IFNC "","\8"
			add.l	#\8*BYTE_SIZE,a0 ; offset table start
		ENDC
		IFNC "","\2"
			moveq	#\2,d0	; 1st BPLAM
		ENDC
		IFNC "","\3"
			moveq	#\3,d2	; next BPLAM
		ENDC
		moveq	#\4-1,d7	; number of color gradients
\1_init_mirror_bplam_table_loop1
		MOVEF.W \5-1,d6		; number of sections per color gradient
\1_init_mirror_bplam_table_loop2_1
		move.b	d0,(a0)+
		add.w	d2,d0		; next BPLAM
		dbf	d6,\1_init_mirror_bplam_table_loop2_1
		IFC "","\9"
			move.w	d0,d1
		ELSE
			move.w	#\9,d1
		ENDC
		MOVEF.W	\5-1,d6		; number of sections per color gradient
\1_init_mirror_bplam_table_loop2_2
		sub.w	d2,d1		; previous BPLAM
		move.b	d1,(a0)+
		dbf	d6,\1_init_mirror_bplam_table_loop2_2
		dbf	d7,\1_init_mirror_bplam_table_loop1
	ENDC
	IFC "W","\0"
		IFNC "","\8"
			add.l	#\8*WORD_SIZE,a0 ; offset table start
		ENDC
		IFNC "","\2"
			move.l	#(\2<<8)|bplcon4_bits,d0 ; 1st BPLAM
		ENDC
		IFNC "","\3"
			move.l	#\3<<8,d2 ; next BPLAM
		ENDC
		moveq	#\4-1,d7	; number of color gradients
\1_init_mirror_bplam_table_loop1
		MOVEF.W	\5-1,d6		; number of sections per color gradient
\1_init_mirror_bplam_table_loop2_1
		move.w	d0,(a0)+
		add.l	d2,d0		; next BPLAM
		dbf	d6,\1_init_mirror_bplam_table_loop2_1
		IFC "","\9"
			move.l	d0,d1
		ELSE
			move.l	#\9,d1
		ENDC
		moveq	#\5-1,d6	; number of sections per color gradient
\1_init_mirror_bplam_table_loop2_2
		sub.l	d2,d1		; previous BPLAM
		move.w	d1,(a0)+
		dbf	d6,\1_init_mirror_bplam_table_loop2_2
		dbf	d7,\1_init_mirror_bplam_table_loop1
	ENDC
	rts
	ENDM


INIT_NESTED_MIRROR_BPLAM_TABLE	MACRO
; Input
; \0 STRING:		["B", "W"] size
; \1 STRING:		Labels prefix
; \2 NUMBER:		First BPLAM value
; \3 NUMBER:		next BPLAM value
; \4 BYTE SIGNED:	Number of color gradients
; \5 BYTE SINGED:       Number of sections per color gradient
; \6 POINTER:		BPLAM table
; \7 STRING:		["pc", "a3"] pointer base
; \8 WORD:		Offset table start (optional)
; \9 NUMBER:		First BPLAM value for mirroring (optional)
; Global reference
; bplcon4_bits
; Result
	CNOP 0,4
\1_init_nested_mirror_bplam_table
	IFC "","\0"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: First BPLAM value missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: Next BPLAM value missing
	ENDC
	IFC "","\4"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: Number of color gradients missing
	ENDC
	IFC "","\5"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: Number of sections per color gradient missing
	ENDC
	IFC "","\6"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: BPLAM table missing
	ENDC
	IFC "","\7"
		FAIL Macro INIT_NESTED_MIRROR_bplam_table: Pointer base missing
	ENDC
	IFC "pc","\7"
		lea	\1_\6(\7),a1	; BPLAM table
	ENDC
	IFC "a3","\7"
		move.l	\6(\7),a1	; BPLAM table
	ENDC
	IFNC "","\8"
		add.l	#\8,a1		; offset table start
	ENDC
	IFC "B","\0"
		moveq	#\2,d0		; 1st BPLAM
		moveq	#\3,d2		; next BPLAM
		moveq	#\4-1,d7	; number of color gradients
\1_init_nested_mirror_bplam_table_loop1
		move.l	a1,a0		; BPLAM table
		moveq	#\5-1,d6	; number of sections per color gradient
\1_init_nested_mirror_bplam_table_loop2_1
		move.b	d0,(a0)
		add.w	d2,d0		; next BPLAM
		addq.w	#\4*BYTE_SIZE,a0 ; add offset
		dbf	d6,\1_init_nested_mirror_bplam_table_loop2_1
		IFC "","\9"
			move.w	d0,d1
		ELSE
			move.w	#\9,d1
		ENDC
		MOVEF.W	\5-1,d6		; number of sections per color gradient
\1_init_nested_mirror_bplam_table_loop2_2
		sub.w	d2,d1		; previous BPLAM
		move.b	d1,(a0)
		addq.w	#\4*BYTE_SIZE,a0 ; add offset
		dbf	d6,\1_init_nested_mirror_bplam_table_loop2_2
		addq.w	#BYTE_SIZE,a1	; next section
		dbf	d7,\1_init_nested_mirror_bplam_table_loop1
	ENDC
	IFC "W","\0"
		move.l	#(\2<<8)|bplcon4_bits,d0 ; 1st BPLAM
		move.l	#\3<<8,d2	; next BPLAM
		moveq	#\4-1,d7	; number of color gradients
\1_init_nested_mirror_bplam_table_loop1
		move.l	a1,a0		; BPLAM table
		moveq	#\5-1,d6	; number of sections per color gradient
\1_init_nested_mirror_bplam_table_loop2_1
		move.w	d0,(a0)
		add.l	d2,d0		; next BPLAM
		addq.w	#\4*WORD_SIZE,a0 ; add offset
		dbf	d6,\1_init_nested_mirror_bplam_table_loop2_1
		IFC "","\9"
			move.l	d0,d1
		ELSE
			move.l	#\9,d1
		ENDC
		moveq	#\5-1,d6	; number of sections per color gradient
\1_init_nested_mirror_bplam_table_loop2_2
		sub.l	d2,d1		; previous BPLAM
		move.w	d1,(a0)
		addq.w	#\4*WORD_SIZE,a0 ; add offset
		dbf	d6,\1_init_nested_mirror_bplam_table_loop2_2
		addq.w	#WORD_SIZE,a1	; next section
		dbf	d7,\1_init_nested_mirror_bplam_table_loop1
	ENDC
	rts
	ENDM


INIT_BPLAM_TABLE		MACRO
; Input
; \0 STRING:		["B", "W"] size
; \1 STRING:		Labels prefix
; \2 NUMBER:		First BPLAM value
; \3 NUMBER:		Next BPLAM value
; \4 BYTE SIGNED:	Number of sections per color gradient
; \5 POINTER:		BPLAM table (optional)
; \6 STRING:		["pc", "a3"] pointer base (optional)
; \7 WORD:		Offset table start (optional)
; \8 LONGWORD:		Offset next BPLAM value (optional)
; Result
; d0.w			Last BPLAM value
	CNOP 0,4
\1_init_bplam_table
	IFC "","\0"
		FAIL Macro INIT_bplam_table: Size missing
	ENDC
	IFC "","\1"
		FAIL Macro INIT_bplam_table: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_bplam_table: First BPLAM value missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_bplam_table: Next BPLAM value missing
	ENDC
	IFC "","\4"
		FAIL Macro INIT_bplam_table: Number of sections per color gradient missing
	ENDC
	IFC "B","\0"
		IFC "pc","\6"
			lea	\1_\5(\6),a0 ; BPLAM table
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0 ; BPLAM table
		ENDC
		IFNC "","\7"
			add.l	#(\7)*BYTE_SIZE,a0 ; offset table start
		ENDC
		IFNC "","\8"
			move.l	#(\8)*BYTE_SIZE,a1 ; offset next BPLAM
		ENDC
		IFNC "","\2"
			MOVEF.W	\2,d0		; 1st BPLAM
		ENDC
		IFNC "","\3"
			moveq	#\3,d2		; next BPLAM
		ENDC
		MOVEF.W	\4-1,d7			; number of sections per color gradient
\1_init_bplam_table_loop
		IFC "","\8"
			move.b	d0,(a0)+
		ELSE
			move.b	d0,(a0)
			add.l	a1,a0		; next line in BPLAM table
		ENDC
		add.w	d2,d0			; next BPLAM
		dbf	d7,\1_init_bplam_table_loop
	ENDC
	IFC "W","\0"
		IFC "pc","\6"
			lea	\1_\5(\6),a0	; BPLAM table
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0	; BPLAM table
		ENDC
		IFNC "","\7"
			add.l	#(\7)*WORD_SIZE,a0 ; offset table start
		ENDC
		IFNC "","\8"
			move.l	#(\8)*WORD_SIZE,a1 ; offset next BPLAM
		ENDC
		IFNC "","\2"
			move.l	#\2<<8,d0	; 1st BPLAM
		ENDC
		IFNC "","\3"
			move.l	#\3<<8,d2	; next BPLAM
		ENDC
		MOVEF.W	\4-1,d7			; number of sections per color gradient missing
\1_init_bplam_table_loop
		IFC "","\8"
			move.w	d0,(a0)+
		ELSE
			move.w	d0,(a0)
			add.l	a1,a0		; next line in BPLAM table
		ENDC
		add.l	d2,d0			; next BPLAM
		dbf	d7,\1_init_bplam_table_loop
	ENDC
	rts
	ENDM


INIT_COLOR_GRADIENT_RGB8	MACRO
; Input
; \1 LONGWORD:		RGB8 start
; \2 LONGWORD:		RGB8 end
; \3 BYTE SIGNED:	Number of color values
; \4 NUMBER:		Color step RGB8 (optional)
; \5 POINTER:		Color table (optional)
; \6 STRING:		["pc", "a3"] pointer base (optional)
; \7 LONGWORD:		Offset table start (optional)
; \8 LONGWORD:		Offset next color value (optional)
; Result
	IFC "","\1"
		FAIL Macro INIT_COLOR_GRADIENT_RGB8: RGB8 start missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_COLOR_GRADIENT_RGB8: RGB8 end missing
	ENDC					
	IFC "","\3"
		FAIL Macro INIT_COLOR_GRADIENT_RGB8: Number of color values missing
	ENDC
	move.l	#\1,d0			; RGB8 start
	move.l	#\2,d6			; RGB8 end
	IFNC "","\5"
		IFC "pc","\6"
			lea	\5(\6),a0 ; color table
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0 ; color table
		ENDC
	ENDC
	IFNC "","\7"
		ADDF.W	(\7)*LONGWORD_SIZE,a0 ; offset table start
	ENDC
	IFNC "","\4"
		move.l	#(\4)<<16,a1	; increase/decrease red
		move.w	#(\4)<<8,a2	; increase/decrease green
		move.w	#\4,a4		; increase/decrease blue
	ENDC
	IFNC "","\8"
		move.w	#(\8)*LONGWORD_SIZE,a5 ; offset next color
	ENDC
	MOVEF.W	\3-1,d7			; number of colors
	bsr	init_color_gradient_RGB8_loop
	ENDM


INIT_COLOR_GRADIENTS_RGB8	MACRO
; Input
; \1 WORD:		Number of colors
; \2 BYTE SIGNED:	Number of lines
; \3 BYTE SIGNED:	Number of sections
; \4 NUMBER:		RGB8 step (optional)
; \5 POINTER:		Color table (optional)
; \6 STRING:		[pc, a3] pointer base (optional)
; \7 LONGWORD:		Offset table start (optional)
; \8 LONGWORD:		Offset next color value (optional)
; Result
	IFC "","\1"
		FAIL Macro INIT_COLOR_GRADIENTS_GROUP_RGB8: Number of colors missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_COLOR_GRADIENTS_GROUP_RGB8: Number of lines missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_COLOR_GRADIENTS_GROUP_RGB8: Number of sections missing
	ENDC
	IFNC "","\5"
		IFC "pc","\6"
			lea	\5(\6),a0 ; color table
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0 ; color table
		ENDC
		IFNC "","\7"
			add.l	#(\7)*LONGWORD_SIZE,a0 ; add offset
		ENDC
	ENDC
	IFNC "","\4"
		move.l	#\4<<16,a1	; increase/decrease red
		move.w	#\4<<8,a2	; increase/decrease green
		move.w	#\4,a4		; increase/decrease blue
	ENDC
	move.w	#(\8)*LONGWORD_SIZE,a5	; offset
	moveq	#\2-1,d7		; number of lines
init_color_gradients_rgb8_loop1\@
	moveq	#\3-1,d5		; number of sections
init_color_gradients_rgb8_loop2\@
	move.l	(a0),d0			; RGB8 start
	move.l	(\1)*LONGWORD_SIZE(a0),d6 ; RGB8 end
	tst.w	d5			; last loop in section ?
	bne.s	init_color_gradients_rgb8_skip\@
	move.l	-((\1)*LONGWORD_SIZE*(\3-1))(a0),d6 ; RGB8 end = 1st value in section 1
init_color_gradients_rgb8_skip\@
	movem.l d5/d7,-(a7)
	MOVEF.L	\1-1,d7			; number of colors
	bsr	init_color_gradient_RGB8_loop
	movem.l	(a7)+,d5/d7
	dbf	d5,init_color_gradients_rgb8_loop2\@
	dbf	d7,init_color_gradients_rgb8_loop1\@
	ENDM


COPY_IMAGE_TO_BITPLANE		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 WORD:	X offset (optional)
; \3 WORD:	Y offset (optional)
; \4 POINTER:	Target (optional)
; Global reference
; pf1_plane_width
; pf1_depth3
; pf1_display
; _image_data
; _image_plane_width
; _image_x_size
; _image_y_size
; Result
	IFC "","\1"
		FAIL Macro COPY_IMAGE_TO_BITPLANE: Labels prefix missing
	ENDC
	CNOP 0,4
\1_copy_image_to_bitplane
	movem.l a4-a6,-(a7)
	IFNC "","\2"
		IFC "","\4"
			MOVEF.L (\2/8)+(\3*pf1_plane_width*pf1_depth3),d4
		ELSE
			MOVEF.L (\2/8)+(\3*\4_plane_width*\4_depth),d4
		ENDC
	ENDC
	lea	\1_image_data,a1	; source
	IFC "","\4"
		move.l	pf1_display(a3),a4 ; destination
	ELSE
		move.l	\4(a3),a4	; destination
	ENDC
	move.w	#(\1_image_plane_width*\1_image_depth)-\1_image_plane_width,a5
	IFC "","\4"
		move.w	#(pf1_plane_width*pf1_depth3)-\1_image_plane_width,a6
	ELSE
		move.w	#(\4_plane_width*\4_depth)-\1_image_plane_width,a6
	ENDC
	IFC "","\4"
		moveq	#pf1_depth3-1,d7
	ELSE
		moveq	#\4_depth-1,d7
	ENDC
\1_copy_image_to_bitplane_loop1
	bsr.s	\1_copy_image_data
	add.l	#\1_image_plane_width,a1 ; next bitplane
	dbf	d7,\1_copy_image_to_bitplane_loop1
	movem.l (a7)+,a4-a6
	rts
	CNOP 0,4
\1_copy_image_data
	move.l	a1,a0			; source
	move.l	(a4)+,a2		; destination
	IFNC "","\2"
		add.l	d4,a2		; + xy offset
	ENDC
	MOVEF.W	\1_image_y_size-1,d6
\1_copy_image_data_loop1
	moveq	#(\1_image_x_size/WORD_BITS)-1,d5
\1_copy_image_data_loop2
	move.w	(a0)+,(a2)+
	dbf	d5,\1_copy_image_data_loop2
	add.l	a5,a0			; next line in source
	add.l	a6,a2			; next line in destination
	dbf	d6,\1_copy_image_data_loop1
	rts
	ENDM


INIT_DISPLAY_PATTERN		MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	Column width
; Global reference
; pf1_display
; cl2_display_width
; pf1_plane_width
; Result
	IFC "","\1"
		FAIL Macro INIT_DISPLAY_PATTERN: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_DISPLAY_PATTERN: Column width missing
	ENDC
	CNOP 0,4
\1_init_display_pattern
	moveq	#0,d0			; columns counter
	moveq	#0,d1
	moveq	#1,d3			; 1st color number
	move.l	pf1_display(a3),a0
	move.l	(a0),a0
	moveq	#(cl2_display_width)-1,d7 ; number of columns
\1_init_display_pattern_loop1
	moveq	#\2-1,d6		; column width
\1_init_display_pattern_loop2
	move.w	d0,d1			; columns counter
	move.w	d0,d2
	lsr.w	#3,d1			; x offset
	not.b	d2			; bit number
	btst	#0,d3
	beq.s	\1_init_display_pattern_skip1
	bset	d2,(a0,d1.l)		; set bit in bitplane
\1_init_display_pattern_skip1
	btst	#1,d3
	beq.s	\1_init_display_pattern_skip2
	bset	d2,pf1_plane_width*1(a0,d1.l)
\1_init_display_pattern_skip2
	btst	#2,d3
	beq.s	\1_init_display_pattern_skip3
	bset	d2,pf1_plane_width*2(a0,d1.l)
\1_init_display_pattern_skip3
	btst	#3,d3
	beq.s	\1_init_display_pattern_skip4
	bset	d2,pf1_plane_width*3(a0,d1.l)
\1_init_display_pattern_skip4
	btst	#4,d3
	beq.s	\1_init_display_pattern_skip5
	bset	d2,(pf1_plane_width*4,a0,d1.l)
\1_init_display_pattern_skip5
	btst	#5,d3
	beq.s	\1_init_display_pattern_skip6
	bset	d2,(pf1_plane_width*5,a0,d1.l)
\1_init_display_pattern_skip6
	btst	#6,d3
	beq.s	\1_init_display_pattern_skip7
	bset	d2,(pf1_plane_width*6,a0,d1.l)
\1_init_display_pattern_skip7
	addq.w	#1,d0			; increase columns counter
	dbf	d6,\1_init_display_pattern_loop2
	addq.w	#1,d3			; increase color number
	dbf	d7,\1_init_display_pattern_loop1
	rts
	ENDM


GET_SINE_BARS_YZ_COORDINATES	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	[256, 360, 512] sine table length
; \3 WORD:	Multiplier y offset in copperlist
; Global reference
; sine_table
; sine_table_length
; _y_angle
; _y_angle_speed
; _y_distance
; _yz_coordinates
; _y_center
; _bars_number
; _y_radius
; Result
	IFC "","\1"
		FAIL Macro GET_SINE_BARS_YZ_COORDINATES: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro GET_SINE_BARS_YZ_COORDINATES: Sine table length missing
	ENDC
	IFC "","\3"
		FAIL Macro GET_SINE_BARS_YZ_COORDINATES: Multiplier y offset in copperlist missing
	ENDC
	CNOP 0,4
\1_get_yz_coordinates
	IFC "","\1"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Sine table length missing
	ENDC
	IFC "","\3"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Multiplier y offset in copperlist missing
	ENDC
	IFEQ \2-256
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		addq.b	#\1_y_angle_speed,d0
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7
\1_get_yz_coordinates_loop
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.l	(a0,d2.w*4),d0	; sin(w)
		add.w	d2,d1		; y angle - 90°
		ext.w	d1
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W (\3)/8,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; y
		add.b	d3,d2		; y distance next bar
		dbf	d7,\1_get_yz_coordinates_loop
		rts
	ENDC
	IFEQ \2-360
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		MOVEF.W sine_table_length,d3 ; overflow 360°
		addq.w	#\1_y_angle_speed,d0
		cmp.w	d3,d0		; 360° ?
		blt.s	\1_get_yz_coordinates_skip1
		sub.w	d3,d0		; reset y angle
\1_get_yz_coordinates_skip1
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W sine_table_length/2,d4 ; 180°
		MOVEF.W \1_y_distance,d5
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7
\1_get_yz_coordinates_loop
		moveq	#-(sine_table_length/4),d1 ; - 90+°
		move.l	(a0,d2.w*4),d0 ; sin(w)
		add.w	d2,d1		; y angle - 90°
		bmi.s	\1_get_yz_coordinates_skip2
		sub.w	d4,d1		; y angle - 180°
		neg.w	d1
\1_get_yz_coordinates_skip2
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W (\3)/8,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; y
		add.w	d5,d2		; y distance next bar
		cmp.w	d3,d2		; 360° ?
		blt.s	\1_get_yz_coordinates_skip3
		sub.w	d3,d2		; reset y angle
\1_get_yz_coordinates_skip3
		dbf	d7,\1_get_yz_coordinates_loop
		rts
	ENDC
	IFEQ \2-512
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		MOVEF.W sine_table_length-1,d5 ; overflow 360°
		addq.w	#\1_y_angle_speed,d0 ; next y angle
		and.w	d5,d0		; remove overflow
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		MOVEF.W sine_table_length/2,d4 ; 180°
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7
\1_get_yz_coordinates_loop
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.l	(a0,d2.w*4),d0 ; sin(w)
		add.w	d2,d1		; y angle - 90°
		bmi.s	\1_get_yz_coordinates_skip
		sub.w	d4,d1		; y angle + 180°
		neg.w	d1
\1_get_yz_coordinates_skip
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + center
		MULUF.W (\3)/8,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; y
		add.w	d3,d2		; y distance to next bar
		and.w	d5,d2		; remove overflow
		dbf	d7,\1_get_yz_coordinates_loop
		rts
	ENDC
	ENDM


GET_TWISTED_BARS_YZ_COORDINATES	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 NUMBER:	[256, 360] sine table length
; \3 WORD:	Multiplier y offset in copperlist
; Global reference
; sine_table
; sine_table_length
; _y_angle
; _y_angle_speed
; _y_distance
; _y_center
; _display_width
; _bars_number
; _y_radius
; _y_angle_step
; Result
	IFC "","\1"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Sine table length missing
	ENDC
	IFC "","\3"
		FAIL Macro GET_TWISTED_BARS_YZ_COORDINATES: Multiplier y offset in copperlist missing
	ENDC
	CNOP 0,4
\1_get_yz_coordinates
	IFEQ \2-256
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		addq.b	#\1_y_angle_speed,d0
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\*LEFT(\3,3)_display_width-1,d7 ; number of columns
\1_get_yz_coordinates_loop1
		moveq	#\1_bars_number-1,d6
\1_get_yz_coordinates_loop2
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.l	(a0,d2.w*4),d0	; sin(w)
		add.w	d2,d1		; y angle - 90°
		ext.w	d1
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W	(\3)/4,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; y
		add.b	d3,d2		; y distance to next bar
		dbf	d6,\1_get_yz_coordinates_loop2
		IFGE \1_y_angle_step
			addq.b	#\1_y_angle_step,d2 ; next y angle
		ELSE
			subq.b	#-\1_y_angle_step,d2 ; next y angle
		ENDC
		dbf	d7,\1_get_yz_coordinates_loop1
		rts
	ENDC
	IFEQ \2-360
		move.w	\1_y_angle(a3),d2
		move.w	d2,d0				
		MOVEF.W sine_table_length,d3 ; overflow
		addq.w	#\1_y_angle_speed,d0
		cmp.w	d3,d0		; 360° ?
		blt.s	\1_get_yz_coordinates_skip1
		sub.w	d3,d0		; reset y angle
\1_get_yz_coordinates_skip1
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W sine_table_length/2,d4 ; 180°
		MOVEF.W \1_y_distance,d5
		lea	sine_table(pc),a0
		lea	\1_yz_coordinates(pc),a1
		move.w	#\1_y_center,a2
		moveq	#\*LEFT(\3,3)_display_width-1,d7 ; number of columns
\1_get_yz_coordinates_loop1
		moveq	#\1_bars_number-1,d6
\1_get_yz_coordinates_loop2
		moveq	#-(sine_table_length/4),d1 ; - 90°
		move.l	(a0,d2.w*4),d0	; sin(w)
		add.w	d2,d1		; y angle - 90°
		bmi.s	\1_get_yz_coordinates_skip2
		sub.w	d4,d1		; y angle + 180°
		neg.w	d1
\1_get_yz_coordinates_skip2
		move.w	d1,(a1)+	; z vector
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + y center
		MULUF.W	(\3)/4,d0,d1	; y offset in cl
		move.w	d0,(a1)+	; y
		add.w	d5,d2		; y distance next bar
		cmp.w	d3,d2		; 360° ?
		blt.s	\1_get_yz_coordinates_skip3
		sub.w	d3,d2		; reset y angle
\1_get_yz_coordinates_skip3
		dbf	d6,\1_get_yz_coordinates_loop2
		addq.w	#\1_y_angle_step,d2
		cmp.w	d3,d2		; 360° ?
		blt.s	\1_get_yz_coordinates_skip4
		sub.w	d3,d2		; rset y angle
\1_get_yz_coordinates_skip4
		dbf	d7,\1_get_yz_coordinates_loop1
		rts
	ENDC
	ENDM


RGB8_COLOR_FADER		MACRO
; Input
; \1 STRING:	Labels prefix
; Result
	IFC "","\1"
		FAIL Macro RGB8_COLOR_FADER: Labels prefix missing
	ENDC
	CNOP 0,4
\1_rgb8_fader_loop
	move.l	(a0),d0			; RGB8 source
	moveq	#0,d1
	move.w	d0,d1			; GgBb
	moveq	#0,d2
	clr.b	d1			; Gg
	move.b	d0,d2			; Bb
	clr.w	d0			; Rr
	move.l	(a1)+,d3		; RGB8 destination
	moveq	#0,d4
	move.w	d3,d4			; GgBb
	moveq	#0,d5
	move.b	d3,d5			; Bb
	clr.w	d3			; Rr
	clr.b	d4			; Gg
; Rotwert
	cmp.l	d3,d0
	bgt.s	\1_rgb8_decrease_red
	blt.s	\1_rgb8_increase_red
\1_rgb8_matched_red
	subq.w	#1,d6			; destination red reched
; Grünwert
\1_rgb8_check_green
	cmp.l	d4,d1
	bgt.s	\1_rgb8_decrease_green
	blt.s	\1_rgb8_increase_green
\1_rgb8_matched_green
	subq.w	#1,d6			; destination green reached
; Blauwert
\1_rgb8_check_blue
	cmp.w	d5,d2
	bgt.s	\1_rgb8_decrease_blue
	blt.s	\1_rgb8_increase_blue
\1_rgb8_matched_blue
	subq.w	#1,d6			; destination blue reached
\1_merge_rgb8
	move.l	d0,d3			; updated red
	move.w	d1,d3			; updated green
	move.b	d2,d3			; updated blue
; Farbwerte in Copperliste eintragen
	move.l	d3,(a0)+		; RGB8
	dbf	d7,\1_rgb8_fader_loop
	rts
	CNOP 0,4
\1_rgb8_decrease_red
	sub.l	a2,d0			; decrease red
	cmp.l	d3,d0
	bgt.s	\1_rgb8_check_green
	move.l	d3,d0			; destination red
	bra.s	\1_rgb8_matched_red
	CNOP 0,4
\1_rgb8_increase_red
	add.l	a2,d0			; increase red
	cmp.l	d3,d0
	blt.s	\1_rgb8_check_green
	move.l	d3,d0			; destination red
	bra.s	\1_rgb8_matched_red
	CNOP 0,4
\1_rgb8_decrease_green
	sub.l	a4,d1			; decrease green
	cmp.l	d4,d1
	bgt.s	\1_rgb8_check_blue
	move.l	d4,d1			; destination green
	bra.s	\1_rgb8_matched_green
	CNOP 0,4
\1_rgb8_increase_green
	add.l	a4,d1			; increase green
	cmp.l	d4,d1
	blt.s	\1_rgb8_check_blue
	move.l	d4,d1			; destination green
	bra.s	\1_rgb8_matched_green
	CNOP 0,4
\1_rgb8_decrease_blue
	sub.w	a5,d2			; decrease blue
	cmp.w	d5,d2
	bgt.s	\1_merge_rgb8
	move.w	d5,d2			; destination blue
	bra.s	\1_rgb8_matched_blue
	CNOP 0,4
\1_rgb8_increase_blue
	add.w	a5,d2			; increase blue
	cmp.w	d5,d2
	blt.s	\1_merge_rgb8
	move.w	d5,d2			; destination blue
	bra.s	\1_rgb8_matched_blue
	ENDM


COPY_RGB8_COLORS_TO_COPPERLIST	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 STRING:	Color table prefix
; \3 STRUNG:	Copperlist prefix
; \4 STRING:	Offset in copperlist color high
; \5 STRING:	Offset in copperlist color low
; \6 LONGWORD:	Offset base (optional)
; Global reference
; _rgb8_copy_colors_active
; _rgb8_colors_number
; _rgb8_start_color
; _rgb8_color_table
; _rgb8_color_table_offset
; Result
	IFC "","\1"
		FAIL Macro COPY_RGB8_COLORS_TO_COPPERLIST: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro COPY_RGB8_COLORS_TO_COPPERLIST: Color table prefix missing
	ENDC
	IFC "","\3"
		FAIL Macro COPY_RGB8_COLORS_TO_COPPERLIST: Copperlist prefix missing
	ENDC
	IFC "","\4"
		FAIL Macro COPY_RGB8_COLORS_TO_COPPERLIST: Offset in copperlist color high missing
	ENDC
	IFC "","\5"
		FAIL Macro COPY_RGB8_COLORS_TO_COPPERLIST: Offset in copperlist color low missing
	ENDC
	CNOP 0,4
\1_rgb8_copy_color_table
	IFNE \3_size2
		move.l	a4,-(a7)
	ENDC
	tst.w	\1_rgb8_copy_colors_active(a3)
	bne.s	\1_rgb8_copy_color_table_skip2
	move.w	#RB_NIBBLES_MASK,d3
	IFGT \1_rgb8_colors_number-32
		MOVEF.W \1_rgb8_start_color<<3,d4 ; counter color registers per color bank
	ENDC
	lea	\2_rgb8_color_table+(\1_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	move.l	\3_display(a3),a1
	IFC "","\6"
		ADDF.W	\4+(\1_rgb8_start_color*LONGWORD_SIZE)+WORD_SIZE,a1
	ELSE
		ADDF.W	\6+\4+(\1_rgb8_start_color*LONGWORD_SIZE)+WORD_SIZE,a1
	ENDC
	IFNE \3_size1
		move.l	\3_construction1(a3),a2
		IFC "","\6"
			ADDF.W	\4+(\1_rgb8_start_color*LONGWORD_SIZE)+WORD_SIZE,a2
		ELSE
			ADDF.W	\6+(\1_rgb8_start_color*LONGWORD_SIZE)+\4+WORD_SIZE,a2
		ENDC
	ENDC
	IFNE \3_size2
		move.l	\3_construction2(a3),a4
		IFC "","\6"
			ADDF.W	\4+(\1_rgb8_start_color*LONGWORD_SIZE)+WORD_SIZE,a4
		ELSE
			ADDF.W	\6+(\1_rgb8_start_color*LONGWORD_SIZE)+\4+WORD_SIZE,a4
		ENDC
	ENDC
	MOVEF.W	\1_rgb8_colors_number-1,d7
\1_rgb8_copy_color_table_loop
	move.l	(a0)+,d0		; RGB8
	move.l	d0,d2					
	RGB8_TO_RGB4_HIGH d0,d1,d3
	move.w	d0,(a1)			; color high
	IFNE \3_size1
		move.w	d0,(a2)		; color high
	ENDC
	IFNE \3_size2
		move.w	d0,(a4)		; color high
	ENDC
	RGB8_TO_RGB4_LOW d2,d1,d3
	move.w	d2,\5-\4(a1)		; color low
	addq.w	#LONGWORD_SIZE,a1	; next color register
	IFNE \3_size1
		move.w	d2,\5-\4(a2)	; color low
		addq.w	#LONGWORD_SIZE,a2 ; next color register
	ENDC
	IFNE \3_size2
		move.w	d2,\5-\4(a4)	; color low
		addq.w	#LONGWORD_SIZE,a4 ; next color register
	ENDC
	IFGT \1_rgb8_colors_number-32
		addq.b	#1<<3,d4	; increase color registers counter
		bne.s	\1_rgb8_copy_color_table_skip1
		addq.w	#LONGWORD_SIZE,a1 ; skip CMOVE
		IFNE \3_size1
			addq.w	#LONGWORD_SIZE,a2 ; skip CMOVE
		ENDC
		IFNE \3_size2
			addq.w	#LONGWORD_SIZE,a4 ; skip CMOVE
		ENDC
\1_rgb8_copy_color_table_skip1
	ENDC
	dbf	d7,\1_rgb8_copy_color_table_loop
	tst.w	\1_rgb8_colors_counter(a3)
	bne.s	\1_rgb8_copy_color_table_skip2
	move.w	#FALSE,\1_rgb8_copy_colors_active(a3)
\1_rgb8_copy_color_table_skip2
	IFNE \3_size2
		move.l	(a7)+,a4
	ENDC
	rts
	ENDM


ROTATE_X_AXIS			MACRO
; Input
; d1.w	y
; d2.w	z
; Result
; d1.w	y position
; d2.w	z position
	move.w	d1,d3			; save y
	muls.w	d4,d1			; y*cos(a)
	swap	d4			; sin(w)
	move.w	d2,d7			; save z
	muls.w	d4,d3			; y*sin(a)
	muls.w	d4,d7			; z*sin(a)
	swap	d4			; cos(a)
	sub.l	d7,d1			; y*cos(a)-z*sin(a)
	muls.w	d4,d2			; z*cos(a)
	MULUF.L 2,d1			; y'=(y*cos(a)-z*sin(a))/2^15
	add.l	d3,d2			; y*sin(a)+z*cos(a)
	swap	d1			; y position
	MULUF.L 2,d2			; z'=(y*sin(a)+z*cos(a))/2^15
	swap	d2			; z position
	ENDM


ROTATE_Y_AXIS			MACRO
; Input
; d0.w	x
; d2.w	z
; Result
; d0.w	x position
; d2.w	z position
	move.w	d0,d3			; save x
	muls.w	d5,d0			; x*cos(b)
	swap	d5			; sin(b)
	move.w	d2,d7			; save z
	muls.w	d5,d3			; x*sin(b)
	muls.w	d5,d7			; z*sin(b)
	swap	d5			; cos(b)
	add.l	d7,d0			; x*cos(b)+z*sin(b)
	muls.w	d5,d2			; z*cos(b)
	MULUF.L 2,d0			; x'=(x*cos(b)+z*sin(b))/2^15
	sub.l	d3,d2			; z*cos(b)-x*sin(b)
	swap	d0			; x position
	MULUF.L 2,d2			; z'=(z*cos(b)-x*sin(b))/2^15
	swap	d2			; z position
	ENDM


ROTATE_Z_AXIS			MACRO
; Input
; d0.w	x
; d1.w	y
; Result
; d0.w	x position
; d1.w	y position
	move.w	d0,d3			; save x
	muls.w	d6,d0			; x*cos(c)
	swap	d6			; sin(c)
	move.w	d1,d7			; save y
	muls.w	d6,d3			; x*sin(c)
	muls.w	d6,d7			; y*sin(c)
	swap	d6			; cos(c)
	sub.l	d7,d0			; x*cos(c)-y*sin(c)
	muls.w	d6,d1			; y*cos(c)
	MULUF.L 2,d0			; x'=(x*cos(c)-y*sin(c))/2^15
	add.l	d3,d1			; x*sin(c)+y*cos(c)
	swap	d0			; x position
	MULUF.L 2,d1			; y'=(x*sin(c)+y*cos(c))/2^15
	swap	d1			; y position
	ENDM


INIT_CUSTOM_ERROR_ENTRY		MACRO
; Input
; \1 BYTE_SIGNED:	Error number
; \2 POINTER:		Error text
; \3 BYTE_SIGNED:	Error text length
; Result
	IFC "","\1"
		FAIL Macro INIT_CUSTOM_ERROR_ENTRY: Error number missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_CUSTOM_ERROR_ENTRY: Error text missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_CUSTOM_ERROR_ENTRY: Error text length missing
	ENDC

	moveq	#\1-1,d0
	MULUF.W	8,d0,d1			; offset in error texts
	lea	\2(pc),a1		; error text
	move.l	a1,(a0,d0.w)
	moveq	#\3,d1			; error text length
	move.l	d1,4(a0,d0.w)
	ENDM


INIT_MIRROR_COLOR_TABLE		MACRO
; Input
; \1 STRING:		Labels prefix
; \2 BYTE SIGNED:	Number of color gradients
; \3 BYTE SIGNED:	Number of segments
; \4 POINTER:		Source: color table
; \5 POINTER:		Destination: color table
; \6 STRING:		["pc", "a3"] pointer base for destination
; Result
	CNOP 0,4
\1_init_mirror_color_table
	IFC "","\1"
		FAIL Macro MIRROR_COLOR_TABLE: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_MIRROR_COLOR_TABLE: Number of color gradients missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_MIRROR_COLOR_TABLE: Number of color segments missing
	ENDC
	IFC "","\4"
		FAIL Macro INIT_MIRROR_COLOR_TABLE: Source color table missing
	ENDC
	IFC "","\5"
		FAIL Macro INIT_MIRROR_COLOR_TABLE: Destination color table missing
	ENDC
	IFC "","\6"
		FAIL Macro INIT_MIRROR_COLOR_TABLE: Pointer base for destination missing
	ENDC
	lea	\4(pc),a0		; source: color table
	IFC "pc","\6"
		lea	\1_\5(\6),a1	; destination: color table
	ENDC
	IFC "a3","\6"
		move.l	\5(\6),a1	; destination: color table
	ENDC
	moveq	#\3-1,d7		; number of segments
\1_init_mirror_color_table_loop1
	lea	(\2-1)*2*LONGWORD_SIZE(a1),a2 ; end of destination segment
	moveq	#\2-1,d6		; number of color gradients
\1_init_mirror_color_table_loop2
	move.l	(a0),(a1)+		; copy RGB8 value
	move.l	(a0)+,-(a2)
	dbf	d6,\1_init_mirror_color_table_loop2
	ADDF.W	\2*LONGWORD_SIZE,a1
	dbf	d7,\1_init_mirror_color_table_loop1
	rts
	ENDM
