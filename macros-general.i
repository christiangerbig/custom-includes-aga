; Datum:	08.09.2024
; Version:	1.0

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


RASTER_TIME			MACRO
; Input
; \1 HEXNUMBER:	RGB4-Wert (optional)
; Result
	move.l	d0,-(a7)
	move.w	VPOSR-DMACONR(a6),d0
	swap	d0
	move.w	VHPOSR-DMACONR(a6),d0
	and.l	#$3ff00,d0
	lsr.l	#8,d0
	cmp.l	rt_rasterlines_number(a3),d0
	blt.s	rt_no_update_y_pos_max\@
	move.l	d0,rt_rasterlines_number(a3)
rt_no_update_y_pos_max\@
	IFNC "","\1"
		SHOW_BEAM_POSITION \1
	ENDC
	move.l	(a7)+,d0
	ENDM


SHOW_BEAM_POSITION		MACRO
; Input
; \1 WORD:	Farbwert
; Result
	MOVEF.W	bplcon3_bits1,d0
	move.w	d0,BPLCON3-DMACONR(a6)
	move.w	#\1,COLOR00-DMACONR(a6)
	ENDM


AUDIO_TEST			MACRO
; Input
; Result
	lea	$20000,a0		; Zeiger auf Chip-Memory
	move.l	a0,AUD0LCH-DMACONR(a6)	; Zeiger auf Audio-Daten
	move.l	a0,AUD1LCH-DMACONR(a6)
	move.l	a0,AUD2LCH-DMACONR(a6)
	move.l	a0,AUD3LCH-DMACONR(a6)
	moveq	#1,d0			; Länge = 1 Wort
	move.w	d0,AUD0LEN-DMACONR(a6)	
	move.w	d0,AUD1LEN-DMACONR(a6)
	move.w	d0,AUD2LEN-DMACONR(a6)
	move.w	d0,AUD3LEN-DMACONR(a6)
	moveq	#64,d0			; maximale Lautstärke
	move.w	d0,AUD0VOL-DMACONR(a6)	
	move.w	d0,AUD1VOL-DMACONR(a6)
	move.w	d0,AUD2VOL-DMACONR(a6)
	move.w	d0,AUD3VOL-DMACONR(a6)
	move.w	#DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3|DMAF_SETCLR,DMACON-DMACONR(a6) ; Audio-DMA starten
	ENDM


MOVEF				MACRO
; Input
; \0 STRING:	Größenangabe B/W/L
; \1 NUMBER:	Quellwert
; \2 STRING:	Ziel
; Result
	IFC "","\0"
	 FAIL Makro MOVEF: Größenangabe B/W/L fehlt
	ENDC
	IFC "","\1"
	 FAIL Makro MOVEF: Quellwert fehlt
	ENDC
	IFC "","\2"
	 FAIL Makro MOVEF: Ziel fehlt
	ENDC
	IFC "B","\0"
		IFLE $80-(\1)		; Wenn Zahl >= $80, dann
			IFGE $ff-(\1)	; Wenn Zahl <= $ff, dann
				moveq #-((-(\1)&$ff)),\2 ; erste Variante
			ENDC
		ELSE			; ansonsten
			moveq #\1,\2	; zweite Variante
		ENDC
	ENDC
	IFC "W","\0"
		IFEQ (\1)&$ff00		; Wenn Zahl <= $00ff, dann
			IFEQ (\1)&$80	; Wenn Zahl <= $007f, dann
				moveq	#\1,\2 ; erste Variante
			ENDC
			IFEQ (\1)-$80	; Wenn Zahl = $0080, dann
				moveq	#$7f,\2	; zweite Variante
				not.b	\2
			ENDC
			IFGT (\1)-$80	; Wenn Zahl > $0080, dann
				moveq	#256-(\1),\2 ; dritte Variante
				neg.b	\2
			ENDC
		ELSE			; Wenn Zahl > $00ff, dann
			move.w	#\1,\2	; vierte Variante
		ENDC
	ENDC
	IFC "L","\0"
		IFEQ (\1)&$ffffff00	; Wenn Zahl <= $000000ff, dann
			IFEQ (\1)&$80	; Wenn Zahl <= $0000007f, dann
				moveq	#\1,\2 ; erste Variante
			ENDC
			IFEQ (\1)-$80	; Wenn Zahl = $00000080, dann
				moveq	#$7f,\2 ; zweite Variante
				not.b	\2
			ENDC
			IFGT (\1)-$80	; Wenn Zahl > $00000080, dann
				moveq	#256-(\1),\2	; dritte Variante
				neg.b	\2
			ENDC
		ELSE			; Wenn Zahl > $000000ff, dann
			move.l	#\1,\2	; vierte Variante
		ENDC
	ENDC
	ENDM


ADDF				MACRO
; Input
; \0 STRING:	Größenangabe B/W/L
; \1 NUMBER:	8/16-Bit Quellwert
; \2 STRING:	Ziel
; Result
	IFC "","\0"
	 FAIL Makro ADDF: Größenangabe B/W/L fehlt
	ENDC
	IFC "","\1"
	 FAIL Makro ADDF: 8/16-Bit Quellwert fehlt
	ENDC
	IFC "","\2"
	 FAIL Makro ADDF: Ziel fehlt
	ENDC
	IFEQ \1
		MEXIT
	ENDC
	IFC "B","\0"
		IFGE (\1)-$8000		; Wenn Zahl > $7fff, dann
			add.b	#\1,\2
		ELSE
			IFLE (\1)-8	; Wenn Zahl <= $0008, dann
				addq.b	#(\1),\2
			ELSE		; Wenn > $0008, dann
				IFLE (\1)-16	; Wenn Zahl <= $0010, dann
					addq.b	#8,\2
					addq.b	#\1-8,\2
				ELSE	; Wenn Zahl > $0010, dann
					add.b	#\1,\2
				ENDC
			ENDC
		ENDC
	ENDC
	IFC "W","\0"
		IFGE (\1)-$8000		; Wenn Zahl > $7fff, dann
			add.w	#\1,\2
		ELSE
			IFLE (\1)-8	; Wenn Zahl <= $0008, dann
				addq.w	#(\1),\2
			ELSE		; Wenn > $0008, dann
				IFLE (\1)-16 ; Wenn Zahl <= $0010, dann
					addq.w	#8,\2
					addq.w	#\1-8,\2
				ELSE	; Wenn Zahl > $0010, dann
					add.w	#\1,\2
				ENDC
			ENDC
		ENDC
	ENDC
	IFC "L","\0"
		IFGE (\1)-$8000		; Wenn Zahl > $7fff, dann
		add.l	#\1,\2
		ELSE
			IFLE (\1)-8	; Wenn Zahl <= $0008, dann
				addq.l	#(\1),\2
			ELSE		; Wenn > $0008, dann
				IFLE (\1)-16 ; Wenn Zahl <= $0010, dann
					addq.l	#8,\2
					addq.l	#\1-8,\2
				ELSE						;Wenn Zahl > $0010, dann
					add.l	#\1,\2
				ENDC
			ENDC
			IFGE (\1)-$8000	; Wenn Zahl > $7fff, dann
				add.l	#\1,\2
			ENDC
		ENDC
	ENDC
	ENDM


SUBF				MACRO
; Input
; \0 STRING:	Größenangabe B/W/L
; \1 NUMBER:	8/16-Bit Quellwert
; \2 STRING:	Ziel
; Result
	IFC "","\0"
		FAIL Makro SUBF: Größenangabe B/W/L fehlt
	ENDC
	IFC "","\1"
		FAIL Makro SUBF: 8/16-Bit Quellwert fehlt
	ENDC
	IFC "","\2"
		FAIL Makro SUBF: Ziel fehlt
	ENDC
	IFEQ \1
		MEXIT
	ENDC
	IFC "B","\0"
		IFLE (\1)-8		; Wenn Zahl <= $0008, dann
			subq.b	#(\1),\2
		ELSE			; Wenn > $0008, dann
			IFLE (\1)-16	; Wenn Zahl <= $0010, dann
				subq.b	#8,\2
				subq.b	#\1-8,\2
			ELSE		; Wenn Zahl > $0010, dann
				sub.b	#\1,\2
			ENDC
		ENDC
	ENDC
	IFC "W","\0"
		IFLE (\1)-8		; Wenn Zahl <= $0008, dann
			subq.w	#(\1),\2
		ELSE			; Wenn > $0008, dann
			IFLE (\1)-16	; Wenn Zahl <= $0010, dann
				subq.w	#8,\2
				subq.w	#\1-8,\2
			ELSE		; Wenn Zahl > $0010, dann
				sub.w	#\1,\2
			ENDC
		ENDC
	ENDC
	IFC "L","\0"
		IFLE (\1)-8		; Wenn Zahl <= $0008, dann
			subq.l	#(\1),\2
		ELSE			; Wenn > $0008, dann
			IFLE (\1)-16	; Wenn Zahl <= $0010, dann
				subq.l	#8,\2
				subq.l	#\1-8,\2
			ELSE		; Wenn Zahl > $0010, dann
				sub.l	#\1,\2
			ENDC
		ENDC
	ENDC
	ENDM


MULUF				MACRO
; Input
; \0 STRING:	Größenangabe B/W/L
; \1 NUMBER:	16/32-Bit Faktor
; \2 NUMBER:	Produkt
; \3 STRING:	Scratch-Register
; Result
	IFC "","\0"
		FAIL Makro MULUF: Größenangabe B/W/L fehlt
	ENDC
	IFC "","\1"
		FAIL Makro MULUF: 16/32-Bit Faktor fehlt
	ENDC
	IFC "","\2"
		FAIL Makro MULUF: Produkt fehlt
	ENDC
	IFEQ \1
		FAIL Makro MULUF: Faktor ist 0
	ENDC
	IFC "B","\0"
		IFGT \1-128
			FAIL Makro MULUF.B: Faktor ist größer als 128
		ENDC
	ENDC
	IFEQ (\1)-2		 	; *2
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
	IFEQ (\1)-64			; *64
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
		lsl.\0	#6,\2
		sub.\0	\3,\2
		add.\0	\3,\3
		sub.\0	\3,\2
		lsl.\0	#3,\2
	ENDC
	IFEQ (\1)-480			; *480
		move.\0	\2,\3
		lsl.\0	#4,\2
		sub.\0	\3,\2
		lsl.\0	#5,\2
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
; \1 NUMBER:	16-Bit vorzeichenbehafteter Faktor
; \2 NUMBER:	Produkt
; \3 STRING:	Scratch-Register
; Result
	IFC "","\1"
		FAIL Makro MULSF: 16-Bit vorzeichenbehafteter Faktor fehlt
	ENDC
	IFC "","\2"
		FAIL Makro MULSF: 16-Bit Produkt fehlt
	ENDC
	IFEQ \1
		FAIL Makro MULSF: Faktor ist 0
	ENDC
	ext.l	\2			; Auf 32 Bit erweitern
	MULUF.L \1,\2,\3
	ENDM


DIVUF				MACRO
; Input
; \0 STRING:	Größenangabe W
; \1 NUMBER:	Divisor
; \2 NUMBER:	Divident
; \3 STRING:	Scratch-Register, Ergebnis
; Result
	IFC "","\0"
		FAIL Makro DIVUF: Größenangabe W fehlt
	ENDC
	IFC "","\1"
		FAIL Makro DIVUF: Divsor fehlt
	ENDC
	IFC "","\2"
		FAIL Makro DIVUF: Divident fehlt
	ENDC
	moveq	#-1,\3			; Zähler für Ergebnis
divison_loop\@
	addq.w	#1,\3			; Zähler erhöhen
	sub.w	\1,\2			; Divisor solange von Divident abziehen
	bge.s	divison_loop\@		; bis Dividend < Divisor
	ENDM


CMPF MACRO
; Input
; \0 STRING:	Größenangabe B/W/L
; \1 NUMBER:	Quelle 8/16/32-Bit
; \2 STRING:	Ziel
; Result
	IFC "","\0"
		FAIL Makro CMPF: Größenangabe B/W/L fehlt
	ENDC
	IFC "","\1"
		FAIL Makro CMPF: Quelle 8/16/32-Bit fehlt
	ENDC
	IFC "","\2"
		FAIL Makro CMPF: Ziel fehlt
	ENDC
	IFEQ \1
		tst.\0	\2
	ELSE
		cmp.\0	#\1,\2
	ENDC
	ENDM


CPU_INIT_COLOR_HIGH		MACRO
; Input
; \1 WORD:		Erstes Farbregister-Offset
; \2 BYTE_SIGNED:	Anzahl der Farbwerte
; \3 POINTER:		Farbtabelle (optional)
; Result
	IFC "","\1"
		FAIL Makro CPU_INIT_COLOR_HIGH: Erstes Farbregister-Offset fehlt
	ENDC
	IFC "","\2"
		FAIL Makro CPU_INIT_COLOR_HIGH: Anzahl der Farbwerte fehlt
	ENDC
	lea		(\1)-DMACONR(a6),a0 ;erstes Farbregister
	moveq	#\2-1,d7		; Anzahl der Farbwerte
	IFNC "","\3"
		lea	\3(pc),a1	; Farbtabelle
	ENDC
	bsr	cpu_init_high_colors
	ENDM


CPU_INIT_COLOR_LOW		MACRO
; Input
; \1 WORD:		Erstes Farbregister-Offset
; \2 BYTE_SIGNED:	Anzahl der Farbwerte
; \3 POINTER:		Farbtabelle (optional)
; Result
	IFC "","\1"
		FAIL Makro CPU_INIT_COLOR_LOW: Erstes Farbregister-Offset fehlt
	ENDC
	IFC "","\2"
		FAIL Makro CPU_INIT_COLOR_LOW: Anzahl der Farbwerte fehlt
	ENDC
	lea		(\1)-DMACONR(a6),a0 ; erstes Farbregister
	moveq	#\2-1,d7		; Anzahl der Farbwerte
	IFNC "","\3"
		lea	\3(pc),a1	; Farbtabelle
	ENDC
	bsr	cpu_init_low_colors
	ENDM


RGB8_TO_RGB4_HIGH		MACRO
; Input
; \1 LONGWORD:	24-Bit Farbwert
; \2 LONGWORD:	Scratch-Register
; \3 STRING:	Maske für High-Bits
; Result
; \1 WORD:	Rückgabewert: 2-Bit High-Farbwert
	IFC "","\1"
		FAIL Makro RGB8_TO_RGB4_HIGH: 24-Bit Farbwert fehlt
	ENDC
	IFC "","\2"
		FAIL Makro RGB8_TO_RGB4_HIGH: Scratch-Register fehlt
	ENDC
	IFC "","\3"
		FAIL Makro RGB8_TO_RGB4_HIGH: Maske für High-Bits fehlt
	ENDC
	lsr.l	#4,\1			; $000RrGgB
	and.w	\3,\1			; $000R0G0B
	move.l	\1,\2			; $000R0G0B
	lsr.l	#4,\1			; $0000R0G0
	or.b	\1,\2			; $GB
	lsr.w	#4,\1			; $0R0G
	move.b	\2,\1			; $0RGB
	ENDM


RGB8_TO_RGB4_LOW		MACRO
; Input
; \1 LONGWORD:	24-Bit Farbwert
; \2 BYTE:	Scratch-Register
; \3 STRING:	Maske für Low-Bits
; Result
; \1 WORD:	Rückgabewert: 12-Bit Low-Farbwert
	IFC "","\1"
		FAIL Makro RGB8_TO_RGB4_LOW: 24-Bit Farbwert fehlt
	ENDC
	IFC "","\2"
		FAIL Makro RGB8_TO_RGB4_LOW: Scratch-Register fehlt
	ENDC
	IFC "","\3"
		FAIL Makro RGB8_TO_RGB4_LOW: Maske für Low-Bits fehlt
	ENDC
	and.w	\3,\1			; $0g0b
	move.b	\1,\2			; $0b
	lsr.l	#4,\1			; $000Rr0g0
	or.b	\1,\2			; $gb
	lsr.w	#4,\1			; $0r0g
	move.b	\2,\1			; $0rgb
	ENDM


RGB8_TO_RGB8_HIGH_LOW		MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; \2 NUMBER:	Anzahl der Einträge
; Result
	IFC "","\1"
		FAIL Makro RGB8_TO_RGB8_HIGH_LOW: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro RGB8_TO_RGB8_HIGH_LOW: Anzahl der Einträge fehlt
	ENDC
	CNOP 0,4
\1_convert_color_table
	move.w	#GB_NIBBLES_MASK,d3
	lea	\1_color_table(pc),a0 ;Zeiger auf Farbtabelle
	move.w	#\2-1,d7		; Anzahl der Einträge
\1_convert_color_table_loop
	move.l	(a0),d0			; Farbwert aus Tabelle lesen
	move.l	d0,d2					
	RGB8_TO_RGB4_HIGH d0,d1,d3
	move.w	d0,(a0)+		; High-Bits
	RGB8_TO_RGB4_LOW d2,d1,d3
	move.w	d2,(a0)+		; Low-Bits
	dbf	d7,\1_convert_color_table_loop
	rts
	ENDM


INIT_CHARACTERS_OFFSETS MACRO
; Input
; \0 STRING:	Größenangabe W/L
; \1 STRING:	Labels-Prefix der Routine
; Result
	CNOP 0,4
\1_init_characters_offsets
	IFC "","\0"
		FAIL Makro INIT_CHARACTERS_OFFSETS: Größenangabe W/L fehlt
	ENDC
	IFC "","\1"
		FAIL Makro INIT_CHARACTERS_OFFSETS: Labels-Prefix der Routine fehlt
	ENDC
	IFC "W","\0"
		moveq	#0,d0		; X-Offset erstes Zeichen in Zeichen-Playfieldvorlage
		moveq	#\1_image_plane_width,d1 ; X-Offset letztes Zeichen in Zeichen-Playfieldvorlage
		move.w	d1,d2		; X-Offset Resetwert
		MOVEF.W \1_image_plane_width*\1_image_depth*(\1_origin_character_y_size+1),d3 ; Y-Offset für nächste Reihe der Zeichen in Zeichen-Playfieldvorlage
		lea	\1_characters_offsets(pc),a0 ; Offsets der Zeichen in Zeichen-Playfieldvorlage
		moveq	#\1_ascii_end-\1_ascii-1,d7 ; Anzahl der Zeichen des Fonts
\1_init_characters_offsets_loop
		move.w	d0,(a0)+	; X+Y-Offset des Zeichens eintragen
		addq.w	#\1_origin_character_x_size/8,d0 ; X-Offset des nächsten Zeichens
		cmp.w	d1,d0		; Letztes Zeichen der Zeile in Zeichen-Playfieldvorlage?
		bne.s	\1_no_x_offset_reset ; Nein -> verzweige
\1_x_offset_reset
		sub.w	d2,d0		; X-Offset zurücksetzen (Erstes Zeichen in Zeile)
		add.w	d3,d1		; + Y-Offset
		add.w	d3,d0		; Y-Offset = Beginn nächste Reihe in Zeichen-Playfieldvorlage
\1_no_x_offset_reset
		dbf	d7,\1_init_characters_offsets_loop
		rts
	ENDC
	IFC "L","\0"
		lea	\1_characters_offsets(pc),a0 ; Offsets der Zeichen in Zeichen-Playfieldvorlage
		moveq	#0,d0		; X-Offset erstes Zeichen in Zeichen-Playfieldvorlage
		moveq	#\1_image_plane_width,d1 ; X-Offset letztes Zeichen in Zeichen-Playfieldvorlage
		move.l	d1,d2		; X-Offset Resetwert
		move.l	#\1_image_plane_width*\1_image_depth*(\1_origin_character_y_size),d3			Y-Offset für nächste Reihe der Zeichen in Zeichen-Playfieldvorlage
		moveq	#\1_ascii_end-\1_ascii-1,d7 ; Anzahl der Zeichen des Fonts
\1_init_characters_offsets_loop
		move.l	d0,(a0)+	; X+Y-Offset des Zeichens eintragen
		add.l	#\1_origin_character_x_size/8,d0 ; X-Offset des nächsten Zeichens
		cmp.l	d1,d0		; Letztes Zeichen der Zeile in Zeichen-Playfieldvorlage?
		bne.s	\1_no_x_offset_reset ;Nein -> verzweige
\1_x_offset_reset
		sub.l	d2,d0		; X-Offset zurücksetzen (Erstes Zeichen in Zeile)
		add.l	d3,d1		; + Y-Offset
		add.l	d3,d0		; Y-Offset = Beginn nächste Reihe in Zeichen-Playfieldvorlage
\1_no_x_offset_reset
		dbf	d7,\1_init_characters_offsets_loop
		rts
	ENDC
	ENDM


INIT_CHARACTERS_X_POSITIONS	MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; \2 STRING:	Pixel-Auflösung "LORES", "HIRES", "SHIRES"
; \3 STRING:	Tabellenzugriff "BACKWARDS" (optional)
; \4 NUMBER:	Anzahl der Buchstaben (optional)
; Result
	CNOP 0,4
\1_init_characters_x_positions
	IFC "","\1"
		FAIL Makro INIT_CHARACTERS_X_POSITIONS: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro INIT_CHARACTERS_X_POSITIONS: Pixel-Auflösung "LORES", "HIRES", "SHIRES" fehlt
	ENDC
	moveq	#0,d0			; 1. X-Position
	IFC "LORES","\2"
		moveq	#\1_text_character_x_size,d1 ; Additionswert
	ENDC
	IFC "HIRES","\2"
		moveq	#\1_text_character_x_size*2,d1 ; Additionswert
	ENDC
	IFC "SHIRES","\2"
		MOVEF.W	\1_text_character_x_size*4,d1 ; Additionswert
	ENDC
	IFNC "BACKWARDS","\3"
		lea	\1_characters_x_positions(pc),a0 ; Zeiger auf Tabelle mit X-Koords.
	ELSE
		IFC "","\4"
			lea	\1_characters_x_positions+(\1_text_characters_number*WORD_SIZE)(pc),a0 ; Tabelle mit X-Koords.-Ende
		ELSE
			lea	\1_characters_x_positions+((\1_\4)*WORD_SIZE)(pc),a0 ; Tabelle mit X-Koords.-Ende
		ENDC
	ENDC
	IFC "","\4"
		moveq	#(\1_text_characters_number)-1,d7 ;Anzahl der Buchstaben
	ELSE
		moveq	#(\1_\4)-1,d7	; Anzahl der Buchstaben
	ENDC
\1_init_characters_x_positions_loop
	IFNC "BACKWARDS","\3"
		move.w	d0,(a0)+	; X eintragen
	ELSE
		move.w	d0,-(a0)	; X eintragen
	ENDC
	add.w	d1,d0			; X erhöhen
	dbf	d7,\1_init_characters_x_positions_loop
	rts
	ENDM


INIT_CHARACTERS_Y_POSITIONS		MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; \2 NUMBER:	Anzahl der Buchstaben (optional)
; Result
	CNOP 0,4
\1_init_characters_y_positions
	IFC "","\1"
		FAIL Makro INIT_CHARACTERS_Y_POSITIONS: Labels-Prefix fehlt
	ENDC
	moveq	#0,d0			; 1. Y-Position
	moveq	#\1_text_character_y_size,d1 ; Additionswert
	lea	\1_characters_y_positions(pc),a0 ; Zeiger auf Tabelle mit X-Koords.
	IFC "","\2"
		moveq	#(\1_text_characters_number)-1,d7 ; Anzahl der Buchstaben
	ELSE
		moveq	#(\1_\2)-1,d7	; Anzahl der Buchstaben
	ENDC
\1_init_characters_y_positions_loop
	move.w	d0,(a0)+		; X eintragen
	add.w	d1,d0			; X erhöhen
	dbf	d7,\1_init_characters_y_positions_loop
	rts
	ENDM


INIT_CHARACTERS_IMAGES		MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; Result
	CNOP 0,4
\1_init_characters_images
	IFC "","\1"
		FAIL Makro INIT_CHARACTERS_IMAGES: Labels-Prefix fehlt
	ENDC
	lea	\1_characters_image_ptrs(pc),a2 ;Z eiger auf Tabelle mit Chars-Adressen
	MOVEF.W	(\1_text_characters_number)-1,d7 ; Anzahl der Buchstaben
\1_init_characters_images_loop
	bsr	\1_get_new_character_image
	move.l	d0,(a2)+		; Char-Adresse eintragen
	dbf	d7,\1_init_characters_images_loop
	rts
	ENDM


GET_NEW_CHARACTER_IMAGE		MACRO
; Input
; \0 STRING:	Größenangabe W/L
; \1 STRING:	Labels-Prefix der Routine
; \2 LABEL:	Sub-Routine zusätzliche Checks für Steuerungs-Codes (optional)
; \3 STRING:	"NORESTART" für Schriften, die nicht endlos sind (optional)
; \4 STRING:	"BACKWARDS" (optional)
; Result
; d0.l		Rückgabewert: Zeiger auf Zeichen-Playfield
	IFC "","\0"
		FAIL Makro GET_NEW_CHARACTER_IMAGE: Größenangabe W/L fehlt
	ENDC
	IFC "","\1"
		FAIL Makro GET_NEW_CHARACTER_IMAGE: Labels-Prefix fehlt
	ENDC
	CNOP 0,4
\1_get_new_character_image
	move.w	\1_text_table_start(a3),d1 ; Offset für bestimmtes Zeichen im Text
	IFC "BACKWARDS","\4"
		bpl.s	\1_no_restart_text ; Wenn positiv -> verzweige
		move.w	#\1_text_end-\1_text-1,d1 ; Neustart
\1_no_restart_text
	ENDC
	lea	\1_text(pc),a0		; Zeiger auf Text
\1_read_character
	move.b	(a0,d1.w),d0		; ASCII-Code
	IFNC "","\2"
		bsr.s	\2
		tst.w	d0		; Rückgabewert = TRUE ?
		beq.s	\1_skip_control_code ; Ja -> verzweige, Steuerzeichen gefunden
	ENDC
	IFNC "BACKWARDS","\4"
		IFNC "NORESTART","\3"
			cmp.b	#FALSE,d0 ; Wenn Ende des Textes erreicht,
			beq.s	\1_restart_text ; dann Neustart
		ENDC
	ENDC
	lea	\1_ascii(pc),a0		; Zeiger auf Tabelle mit ASCII-Codes der Zeichen
	moveq	#\1_ascii_end-\1_ascii-1,d6 ; Anzahl der zu suchenden Zeichen
\1_get_new_character_image_loop
	cmp.b	(a0)+,d0		; Zeichen gefunden ?
	dbeq	d6,\1_get_new_character_image_loop ; Nein -> Schleife
	IFC "BACKWARDS","\4"
		subq.w	#1,d1		; nächster Buchstabe
	ELSE
		IFLT \1_origin_character_x_size-32
			addq.w	#1,d1	; nächstes Zeichen
		ELSE
		IFNE \1_text_character_x_size-16
			addq.w	#1,d1	; nächstes Zeichen
		ENDC
		ENDC
	ENDC

	moveq	#\1_ascii_end-\1_ascii-1,d0 ; Anzahl der zu suchenden Zeichen
	IFLT \1_origin_character_x_size-32
		move.w	d1,\1_text_table_start(a3) ; Offset auf das Zeichen retten
	ELSE
		IFNE \1_text_character_x_size-16
			move.w	d1,\1_text_table_start(a3) ; Offset auf das Zeichen retten
		ENDC
	ENDC
	sub.w	d6,d0			; Anzahl der Zeichen - Schleifenzähler
	lea	\1_characters_offsets(pc),a0 ; Zeiger auf Tabelle mit Offsets der Zeichen-Playfields
	IFC "W","\0"
		move.w	(a0,d0.w*2),d0	; Offset des Zeichen-Playfieldes
	ENDC
	IFC "L","\0"
		move.l	(a0,d0.w*4),d0	; Offset des Zeichen-Playfieldes
	ENDC
	add.l	\1_image(a3),d0		; Adresse der Zeichen-Playfieldvorlage ergänzen
	IFNC "BACKWARDS","\4"
		IFEQ \1_origin_character_x_size-32
			IFEQ \1_text_character_x_size-16
				not.w	\1_character_toggle_image(a3) ; Neues Image für Char ?
				bne.s	\1_no_second_image_part ; FALSE -> verzweige
\1_second_image_part
				addq.w	#1,d1	; nächstes Zeichen
				addq.l	#2,d0	; 2. Teil des Character-Images
				move.w	d1,\1_text_table_start(a3)
\1_no_second_image_part
			ENDC
		ENDC
		IFGT \1_origin_character_x_size-32
			IFEQ \1_text_character_x_size-16
				moveq	#TRUE,d3
				move.w	\1_character_words_counter(a3),d3 ; Zähler für Worte
				move.l	d3,d4
				MULUF.W	2,d4 ; Wort-Offset des Images
				addq.w	#1,d3 ; Nächstes Wort in Image
				add.l	d4,d0 ; + Offset in Char-Image
				cmp.w	#\1_origin_character_x_size/16,d3 ; Neues Image für Char ?
				bne.s	\1_keep_character_image ; Nein -> verzweige
\1_next_character
				addq.w	#1,d1 ; nächster Buchstabe
				move.w	d1,\1_text_table_start(a3)
				moveq	#0,d3 ; Zähler zurücksetzen
\1_keep_character_image
				move.w	d3,\1_character_words_counter(a3)
			ENDC
		ENDC
	ENDC
	rts
	IFNC "BACKWARDS","\4"
		IFNC "","\2"
\1_skip_control_code
			addq.w	#1,d1	; nächstes Zeichen
			bra.s	\1_read_character
		ENDC
		IFNC "NORESTART","\3"
			CNOP 0,4
\1_restart_text
			moveq	#TRUE,d1
			bra.s	\1_read_character
		ENDC
	ENDC
	ENDM


CPU_SELECT_COLOR_HIGH_BANK	MACRO
; Input
; \1 NUMBER:	Color-Bank 0..7
; \2 WORD:	zusätzliche BPLCON3-bits (optional)
; Result
	IFC "","\1"
		FAIL Makro CPU_SELECT_COLOR_HIGH_BANK: Color-Bank-Nummer fehlt
	ENDC
	IFC "","\2"
		IFNE \1
			move.w	#bplcon3_bits1|(BPLCON3F_BANK0*\1),BPLCON3-DMACONR(a6) ; High-Bits
		ELSE
			MOVEF.W bplcon3_bits1|(BPLCON3F_BANK0*\1),d0
			move.w	d0,BPLCON3-DMACONR(a6) ; High-Bits
		ENDC
	ELSE
		MOVEF.W bplcon3_bits1|(BPLCON3F_BANK0*\1),d0
		or.w	#\2,d0
		move.w	d0,BPLCON3-DMACONR(a6) ; High-Bits
	ENDC
	ENDM


CPU_SELECT_COLOR_LOW_BANK	MACRO
; Input
; \1 NUMBER: Color-Bank 0..7
; \2 WORD: zusätzliche BPLCON3-bits (optional)
; Result
	IFC "","\1"
		FAIL Makro CPU_SELECT_COLOR_LOW_BANK: Color-Bank-Nummer fehlt
	ENDC
	IFC "","\2"
		move.w	#bplcon3_bits2|(BPLCON3F_BANK0*\1),BPLCON3-DMACONR(a6) ; Low-Bits
	ELSE
		MOVEF.W bplcon3_bits2|(BPLCON3F_BANK0*\1),d0
		or.w	#\2,d0
		move.w	d0,BPLCON3-DMACONR(a6) ; Low-Bits
	ENDC
	ENDM


DISABLE_060_STORE_BUFFER	MACRO
; Input
; Result
	move.l	_SysBase(pc),a6
	tst.b	AttnFlags+BYTESZE(a6)	; CPU 68060 ?
	bpl.s	dsb_no_CPU060		; Nein -> verzweige
	lea	dsb_CPU060_store_buffer_off(pc),a5 ; Zeiger auf Supervisor-Routine
	CALLLIBS Supervisor
	move.l	d0,os_cacr(a3)		; alten Inhalt retten
dsb_no_CPU060
	rts
; ** Store-Buffer deaktivieren **
; d0 ... Alter Inhalt von CACR
	CNOP 0,4
dsb_CPU060_store_buffer_off
	or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; Level-7-Interruptebene
	nop
	movec.l CACR,d0			; Alter Inhalt von CACR
	move.l	d0,d1					
	nop
	CPUSHA	BC			; Instruction/Data/Branch-Caches flushen
	nop
	and.l	#~CACR060F_ESB,d1
	movec.l	d1,CACR			; Store-Buffer aus
	nop
	rte
	ENDM


ENABLE_060_STORE_BUFFER		MACRO
; Input
; Result
	move.l	_SysBase(pc),a6
	tst.b	AttnFlags+BYTE_SIZE(a6)	; CPU 68060 ?
	bpl.s	esb_no_CPU060		; Nein -> verzweige
	lea	esb_CPU060_store_buffer_on(pc),a5 ; Zeiger auf Supervisor-Routine
	move.l	os_cacr(a3),d1		 ;Alter Inhalt von CACR
	CALLLIBQ Supervisor
esb_no_CPU060
	rts
	CNOP 0,4
; d1 ... alter Inhalt von CACR
	CNOP 0,4
esb_CPU060_store_buffer_on
	or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; Level-7-Interruptebene
	nop
	CPUSHA	BC			; Instruction/Data/Branch-Caches flushen
	nop
	movec.l d1,CACR			; Store Buffer an
	nop
	rte
	ENDM


INIT_MIRROR_SWITCH_TABLE	MACRO
; Input
; \0 STRING:		Größenangabe B/W
; \1 STRING:		Labels-Prefix der Routine
; \2 NUMBER:		Erster Switchwert (optional)
; \3 NUMBER:		Additionswert für Switchwert (optional)
; \4 BYTE SIGNED:	Anzahl der Farbverläufe
; \5 BYTE SINGED:	Anzahl der Abschnitte pro Farbverlauf
; \6 POINTER:		Tabelle mit Switchwerten
; \7 STRING:		Pointer-Base [pc, a3]
; \8 WORD:		Offset Tabellenanfang (optional)
; \9 NUMBER:		Erster Switchwert für Spiegelung (optional)
; Result
	CNOP 0,4
\1_init_mirror_switch_table
	IFC "","\0"
		FAIL Makro MIRROR_SWITCH_TABLE: Größenangabe B/W fehlt
	ENDC
	IFC "","\1"
		FAIL Makro MIRROR_SWITCH_TABLE: Labels-Prefix fehlt
	ENDC
	IFC "","\4"
		FAIL Makro INIT_MIRROR_SWITCH_TABLE: Anzahl der Farbverläufe fehlt
	ENDC
	IFC "","\5"
		FAIL Makro INIT_MIRROR_SWITCH_TABLE: Anzahl der Abschnitte pro Farbverlauf fehlt
	ENDC
	IFC "","\6"
		FAIL Makro INIT_MIRROR_SWITCH_TABLE: Tabelle mit Switchwerten fehlt
	ENDC
	IFC "","\7"
		FAIL Makro INIT_MIRROR_SWITCH_TABLE: Pointer-Base [pc, a3] fehlt
	ENDC
	IFC "pc","\7"
		lea	\1_\6(\7),a0	; Zeiger auf Switch-Tabelle
	ENDC
	IFC "a3","\7"
		move.l	\6(\7),a0	; Zeiger auf Switch-Tabelle
	ENDC
	IFC "B","\0"
		IFNC "","\8"
			add.l	#\8*BYTE_SIZE,a0 ; Offset Tabellenanfang
		ENDC
		IFNC "","\2"
			moveq	#\2,d0	; Erster Switchwert
		ENDC
		IFNC "","\3"
			moveq	#\3,d2	; Additionswert für Switchwert
		ENDC
		moveq	#\4-1,d7	; Anzahl der Farbverläufe
\1_init_mirror_switch_table_loop1
		MOVEF.W \5-1,d6		; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_mirror_switch_table_loop2_1
		move.b	d0,(a0)+	; Switchwert retten
		add.w	d2,d0		; Switchwert erhöhen
		dbf	d6,\1_init_mirror_switch_table_loop2_1
		IFC "","\9"
			move.w	d0,d1
		ELSE
			move.w	#\9,d1
		ENDC
		MOVEF.W	\5-1,d6		; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_mirror_switch_table_loop2_2
		sub.w	d2,d1		; Switchwert verringern
		move.b	d1,(a0)+	; Switchwert retten
		dbf	d6,\1_init_mirror_switch_table_loop2_2
		dbf	d7,\1_init_mirror_switch_table_loop1
	ENDC
	IFC "W","\0"
		IFNC "","\8"
			add.l	#\8*WORD_SIZE,a0 ; Offset Tabellenanfang
		ENDC
		IFNC "","\2"
			move.l	#(\2<<8)|bplcon4_bits,d0 ; Erster Switchwert
		ENDC
		IFNC "","\3"
			move.l	#\3<<8,d2 ; Additionswert für Switchwert
		ENDC
		moveq	#\4-1,d7	; Anzahl der Farbverläufe
\1_init_mirror_switch_table_loop1
		MOVEF.W	\5-1,d6		; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_mirror_switch_table_loop2_1
		move.w	d0,(a0)+	; Switchwert retten
		add.l	d2,d0		; Switchwert erhöhen
		dbf	d6,\1_init_mirror_switch_table_loop2_1
		IFC "","\9"
			move.l	d0,d1
		ELSE
			move.l	#\9,d1
		ENDC
		moveq	#\5-1,d6	; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_mirror_switch_table_loop2_2
		sub.l	d2,d1		; Switchwert verringern
		move.w	d1,(a0)+	; Switchwert retten
		dbf	d6,\1_init_mirror_switch_table_loop2_2
		dbf	d7,\1_init_mirror_switch_table_loop1
	ENDC
	rts
	ENDM


INIT_NESTED_MIRROR_SWITCH_TABLE	MACRO
; Input
; \0 STRING:		Größenangabe B/W
; \1 STRING:		Labels-Prefix der Routine
; \2 NUMBER:		Erster Switchwert
; \3 NUMBER:		Additionswert für Switchwert
; \4 BYTE SIGNED:	Anzahl der Farbverläufe
; \5 BYTE SINGED:	Anzahl der Abschnitte pro Farbverlauf
; \6 POINTER:		Tabelle mit Switchwerten
; \7 STRING:		Pointer-Base [pc, a3]
; \8 WORD:		Offset Tabellenanfang (optional)
; \9 NUMBER:		Erster Switchwert für Spiegelung (optional)
; Result
	CNOP 0,4
\1_init_nested_mirror_switch_table
	IFC "","\0"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Größenangabe B/W fehlt
	ENDC
	IFC "","\1"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Erster Switchwert fehlt
	ENDC
	IFC "","\3"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Additionswert für Switchwert fehlt
	ENDC
	IFC "","\4"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Anzahl der Farbverläufe fehlt
	ENDC
	IFC "","\5"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Anzahl der Abschnitte pro Farbverlauf fehlt
	ENDC
	IFC "","\6"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Tabelle mit Switchwerten fehlt
	ENDC
	IFC "","\7"
		FAIL Makro INIT_NESTED_MIRROR_SWITCH_TABLE: Pointer-Base [pc, a3] fehlt
	ENDC
	IFC "pc","\7"
		lea	\1_\6(\7),a1	; Zeiger auf Switch-Tabelle
	ENDC
	IFC "a3","\7"
		move.l	\6(\7),a1	; Zeiger auf Switch-Tabelle
	ENDC
	IFNC "","\8"
		add.l	#\8,a1		; Offset Tabellenanfang
	ENDC
	IFC "B","\0"
		moveq	#\2,d0		; Erster Switchwert
		moveq	#\3,d2		; Additionswert für Switchwert
		moveq	#\4-1,d7	; Anzahl der Farbverläufe
\1_init_nested_mirror_switch_table_loop1
		move.l	a1,a0		; Zeiger auf Tabelle mit Switchwerten
		moveq	#\5-1,d6	; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_nested_mirror_switch_table_loop2_1
		move.b	d0,(a0)		; Switchwert retten
		add.w	d2,d0		; Switchwert erhöhen
		addq.w	#\4*BYTE_SIZE,a0 ; Offset addieren
		dbf	d6,\1_init_nested_mirror_switch_table_loop2_1
		IFC "","\9"
			move.w	d0,d1
		ELSE
			move.w	#\9,d1
		ENDC
		MOVEF.W	\5-1,d6		; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_nested_mirror_switch_table_loop2_2
		sub.w	d2,d1		; Switchwert verringern
		move.b	d1,(a0)		; Switchwert retten
		addq.w	#\4*BYTE_SIZE,a0 ; Offset addieren
		dbf	d6,\1_init_nested_mirror_switch_table_loop2_2
		addq.w	#BYTE_SIZE,a1	; nächstes Segment
		dbf	d7,\1_init_nested_mirror_switch_table_loop1
	ENDC
	IFC "W","\0"
		move.l	#(\2<<8)|bplcon4_bits,d0 ; Erster Switchwert
		move.l	#\3<<8,d2	; Additionswert für Switchwert
		moveq	#\4-1,d7	; Anzahl der Farbverläufe
\1_init_nested_mirror_switch_table_loop1
		move.l	a1,a0		; Zeiger auf Tabelle mit Switchwerten
		moveq	#\5-1,d6	; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_nested_mirror_switch_table_loop2_1
		move.w	d0,(a0)		; Switchwert retten
		add.l	d2,d0		; Switchwert erhöhen
		addq.w	#\4*WORD_SIZE,a0 ; Offset addieren
		dbf	d6,\1_init_nested_mirror_switch_table_loop2_1
		IFC "","\9"
			move.l	d0,d1
		ELSE
			move.l	#\9,d1
		ENDC
		moveq	#\5-1,d6	; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_nested_mirror_switch_table_loop2_2
		sub.l	d2,d1		; Switchwert verringern
		move.w	d1,(a0)		; Switchwert retten
		addq.w	#\4*WORD_SIZE,a0 ; Offset addieren
		dbf	d6,\1_init_nested_mirror_switch_table_loop2_2
		addq.w	#WORD_SIZE,a1	; nächstes Segment
		dbf	d7,\1_init_nested_mirror_switch_table_loop1
	ENDC
	rts
	ENDM


INIT_SWITCH_TABLE		MACRO
; Input
; \0 STRING:		Größenangabe B/W
; \1 STRING:		Labels-Prefix der Routine
; \2 NUMBER:		Erster Switchwert
; \3 NUMBER:		Additionswert für Switchwert
; \4 BYTE SIGNED:	Anzahl der Farb/Switchwerte pro Farbverlauf
; \5 POINTER:		Tabelle mit Switchwerten (optional)
; \6 STRING:		Pointer-Base [pc, a3] (optoinal)
; \7 WORD:		Offset Tabellenanfang (optional)
; \8 LONGWORD:		Offset zum nächsten Wert in Switchtabelle (optional)
; Result
; d0.w			Rückgabewert: Letzter Switchwert
	CNOP 0,4
\1_init_switch_table
	IFC "","\0"
		FAIL Makro INIT_SWITCH_TABLE: Größenangabe B/W fehlt
	ENDC
	IFC "","\1"
		FAIL Makro INIT_SWITCH_TABLE: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro INIT_SWITCH_TABLE: Erster Switchwert fehlt
	ENDC
	IFC "","\3"
		FAIL Makro INIT_SWITCH_TABLE: Additionswert für Switchwert fehlt
	ENDC
	IFC "","\4"
		FAIL Makro INIT_SWITCH_TABLE: Anzahl der Farb/Switcvhwerte pro Farbverlauf fehlt
	ENDC
	IFC "B","\0"
		IFC "pc","\6"
			lea	\1_\5(\6),a0 ; Zeiger auf Farbtabelle
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0 ; Zeiger auf Farbtabelle
		ENDC
		IFNC "","\7"
			add.l	#(\7)*BYTE_SIZE,a0 ; Offset Tabellenanfang
		ENDC
		IFNC "","\8"
			move.l	#(\8)*BYTE_SIZE,a1 ; Offset zum nächsten Wert
		ENDC
		IFNC "","\2"
			MOVEF.W	\2,d0		; Erster Switchwert
		ENDC
		IFNC "","\3"
			moveq	#\3,d2		; Additionswert für Switchwert
		ENDC
		MOVEF.W	\4-1,d7			; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_switch_table_loop
		IFC "","\8"
			move.b	d0,(a0)+	; Switchwert retten
		ELSE
			move.b	d0,(a0)		; Switchwert retten
			add.l	a1,a0		; nächste Zeile in Switchtabelle
		ENDC
		add.w	d2,d0			; Switchwert erhöhen
		dbf	d7,\1_init_switch_table_loop
	ENDC
	IFC "W","\0"
		IFC "pc","\6"
			lea	\1_\5(\6),a0	; Zeiger auf Switch-Tabelle
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0	; Zeiger auf Switch-Tabelle
		ENDC
		IFNC "","\7"
			add.l	#(\7)*WORD_SIZE,a0 ; Offset Tabellenanfang
		ENDC
		IFNC "","\8"
			move.l	#(\8)*WORD_SIZE,a1 ; Offset zum nächsten Wert
		ENDC
		IFNC "","\2"
			move.l	#\2<<8,d0	; Erster Switchwert
		ENDC
		IFNC "","\3"
			move.l	#\3<<8,d2	; Additionswert für Switchwert
		ENDC
		MOVEF.W	\4-1,d7			; Anzahl der Farb/Switchwerte pro Farbverlauf
\1_init_switch_table_loop
		IFC "","\8"
			move.w	d0,(a0)+	; Switchwert retten
		ELSE
			move.w	d0,(a0)		; Switchwert retten
			add.l	a1,a0		; nächste Zeile in Switchtabelle
		ENDC
		add.l	d2,d0			; Switchwert erhöhen
		dbf	d7,\1_init_switch_table_loop
	ENDC
	rts
	ENDM


INIT_COLOR_GRADIENT_RGB8	MACRO
; Input
; \1 HEXNUMBER:		RGB8 Startwert/Istwert
; \2 HEXNUMBER:		RGB8 Endwert/Sollwert
; \3 BYTE SIGNED:	Anzahl der Farbwerte
; \4 NUMBER:		Color-Step-Wert für RGB (optional)
; \5 POINTER:		Zeiger auf Farbtabelle(optional)
; \6 STRING:		Pointer-Base [pc, a3] (optional)
; \7 LONGWORD:		Offset zum nächsten Wert in Farbtabelle (optional)
; \8 LONGWORD:		Offset Anfang Farbtabelle (optional)
; Result
	IFC "","\1"
		FAIL Makro COLOR_GRADIENT_RGB8: RGB8 Startwert/Istwert fehlt
	ENDC
	IFC "","\2"
		FAIL Makro COLOR_GRADIENT_RGB8: RGB8 Endwert/Sollwert fehlt
	ENDC					
	IFC "","\3"
		FAIL Makro COLOR_GRADIENT_RGB8: Anzahl der Farbwerte fehlt
	ENDC
	move.l	#\1,d0			; RGB-Istwert
	move.l	#\2,d6			; RGB-Sollwert
	IFNC "","\5"
		IFC "pc","\6"
			lea	\5(\6),a0 ; Zeiger auf Farbtabelle
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0 ; Zeiger auf Farbtabelle
		ENDC
	ENDC
	IFNC "","\8"
		add.l	#(\8)*LONGWORD_SIZE,a0 ; Offset Anfang Farbtabelle
	ENDC
	IFNC "","\4"
		move.l	#(\4)<<16,a1	; Additions-/Subtraktionswert für Rot
		move.w	#(\4)<<8,a2	; Additions-/Subtraktionswert für Grün
		move.w	#\4,a4		; Additions-/Subtraktionswert für Grün
	ENDC
	IFNC "","\7"
		move.w	#(\7)*LONGWORD_SIZE,a5 ; Offset nächster Farbwert
	ENDC
	MOVEF.W	\3-1,d7			; Anzahl der Farbwerte
	bsr	init_color_gradient_RGB8_loop
	ENDM


INIT_COLOR_GRADIENT_GROUP_RGB8	MACRO
; Input
; \1 WORD:		Anzahl der Farbwerte
; \2 BYTE SIGNED:	Anzahl der Zeilen
; \3 BYTE SIGNED:	Anzahl der Segmente
; \4 NUMBER:		Colorstep-Wert für RGB (optional)
; \5 POINTER:		Zeiger auf Farbtabelle (optional)
; \6 STRING:		Pointer-Base [pc, a3] (optional)
; \7 LONGWORD:		Offset Anfang Farbtabelle (optional)
; \8 LONGWORD:		Offset zum nächsten Wert in Farbtabelle (optional)
; Result
	IFC "","\1"
		FAIL Makro COLOR_GRADIENT_GROUP_RGB8: Anzahl der Farbwerte fehlt
	ENDC
	IFC "","\2"
		FAIL Makro COLOR_GRADIENT_GROUP_RGB8: Anzahl der Zeilen fehlt
	ENDC
	IFC "","\3"
		FAIL Makro COLOR_GRADIENT_GROUP_RGB8: Anzahl der Segmente fehlt
	ENDC
	IFNC "","\5"
		IFC "pc","\6"
			lea	\5(\6),a0 ; Zeiger auf Farbtabelle
		ENDC
		IFC "a3","\6"
			move.l	\5(\6),a0
		ENDC
		IFNC "","\7"
			add.l	#(\7)*LONGWORD_SIZE,a0 ; Nur Offset addieren
		ENDC
	ENDC
	IFNC "","\4"
		move.l	#\4<<16,a1	; Additions-/Subtraktionswert für Rot
		move.w	#\4<<8,a2	; Additions-/Subtraktionswert für Grün
		move.w	#\4,a4		; Additions-/Subtraktionswert für Grün
	ENDC
	move.w	#(\8)*LONGWORD_SIZE,a5	; Offset
	moveq	#\2-1,d7		; Anzahl der Zeilen
lines_loop\@
	moveq	#\3-1,d5		; Anzahl der Segmente
segments_loop\@
	move.l	(a0),d0			; RGB-Startwert
	move.l	(\1)*LONGWORD_SIZE(a0),d6 ; RGB-Endwert
	tst.w	d5			; Letzte Schleife bei Segmenten ?
	bne.s	no_last_segment\@	; Nein -> verzweige
	move.l	-((\1)*LONGWORD_SIZE*(\3-1))(a0),d6 ; RGB-Endwert = erster Wert in Segment 1
no_last_segment\@
	movem.l d5/d7,-(a7)
	MOVEF.L	\1-1,d7			; Anzahl der Farbwerte
	bsr	init_color_gradient_RGB8_loop
	movem.l	(a7)+,d5/d7
	dbf	d5,segments_loop\@
	dbf	d7,lines_loop\@
	ENDM


COPY_IMAGE_TO_BITPLANE		MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; \2 WORD:	X-Offset in Pixeln optional (optional)
; \3 WORD:	Y-Offset in Zeilen optional (optional)
; \4 POINTER:	Zielbild (optional)
; Result
	IFC "","\1"
		FAIL Makro COPY_IMAGE_TO_BITPLANE: Labels-Prefix fehlt
	ENDC
	CNOP 0,4
\1_copy_image_to_plane
	movem.l a4-a6,-(a7)
	IFNC "","\2"
		IFC "","\4"
			MOVEF.L (\2/8)+(\3*pf1_plane_width*pf1_depth3),d4
		ELSE
			MOVEF.L (\2/8)+(\3*\4_plane_width*\4_depth),d4
		ENDC
	ENDC
	lea	\1_image_data,a1	; Quellbild
	IFC "","\4"
		move.l	pf1_display(a3),a4 ; Zielbild
	ELSE
		move.l	\4(a3),a4	; Zielbild
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
\1_copy_image_to_plane_loop1
	bsr.s	\1_copy_image_data
	add.l	#\1_image_plane_width,a1 ; nächte Bitplane
	dbf	d7,\1_copy_image_to_plane_loop1
	movem.l (a7)+,a4-a6
	rts
	CNOP 0,4
\1_copy_image_data
	move.l	a1,a0			; Quellbild
	move.l	(a4)+,a2		; Zielbild
	IFNC "","\2"
		add.l	d4,a2		; + XY-Offset
	ENDC
	MOVEF.W	\1_image_y_size-1,d6	; Anzahl der Zeilen
\1_copy_image_data_loop1
	moveq	#(\1_image_x_size/16)-1,d5
\1_copy_image_data_loop2
	move.w	(a0)+,(a2)+
	dbf	d5,\1_copy_image_data_loop2
	add.l	a5,a0			; nächste Zeile in Quellbild
	add.l	a6,a2			; nächste Zeile in Zielbild
	dbf	d6,\1_copy_image_data_loop1
	rts
	ENDM


INIT_DISPLAY_PATTERN		MACRO
; Input
; \1 STRING: Labels-Prefix der Routine
; \2 NUMBER: Breite einer Spalte
; Result
	IFC "","\1"
		FAIL Makro INIT_DISPLAY_PATTERN: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro INIT_DISPLAY_PATTERN: Breite einer Spalte fehlt
	ENDC
	CNOP 0,4
\1_init_display_pattern
	moveq	#0,d0			; Spaltenzähler-Startwert
	moveq	#TRUE,d1		; Langwortzugriff
	moveq	#1,d3			; Farbnummer
	move.l	pf1_display(a3),a0	; Playfield
	move.l	(a0),a0			; Bitplane0
	moveq	#(cl2_display_width)-1,d7 ; Anzahl der Spalten
\1_init_display_pattern_loop1
	moveq	#\2-1,d6		; Breite einer Spalte
\1_init_display_pattern_loop2
	move.w	d0,d1			; Spaltenzähler retten
	move.w	d0,d2			; Spaltenzähler retten
	lsr.w	#3,d1			; /8 = X-Offset
	not.b	d2			; Bitnr.
	btst	#0,d3			; Bit0 gesetzt?
	beq.s	\1_no_set_pixel_plane0 ; Nein -> verzweige
	bset	d2,(a0,d1.l)		; Bit in Bitplane0 setzen
\1_no_set_pixel_plane0
	btst	#1,d3			; Bit1 gesetzt?
	beq.s	\1_no_set_pixel_plane1 ; Nein -> verzweige
	bset	d2,pf1_plane_width*1(a0,d1.l) ; Bit in Bitplane1 setzen
\1_no_set_pixel_plane1
	btst	#2,d3			; Bit2 gesetzt?
	beq.s	\1_no_set_pixel_plane2 ; Nein -> verzweige
	bset	d2,pf1_plane_width*2(a0,d1.l) ; Bit in Bitplane2 setzen
\1_no_set_pixel_plane2
	btst	#3,d3			; Bit3 gesetzt?
	beq.s	\1_no_set_pixel_plane3 ; Nein -> verzweige
	bset	d2,pf1_plane_width*3(a0,d1.l) ; Bit in Bitplane3 setzen
\1_no_set_pixel_plane3
	btst	#4,d3			; Bit4 gesetzt?
	beq.s	\1_no_set_pixel_plane4 ; Nein -> verzweige
	bset	d2,(pf1_plane_width*4,a0,d1.l) ; Bit in Bitplane4 setzen
\1_no_set_pixel_plane4
	btst	#5,d3			; Bit5 gesetzt?
	beq.s	\1_no_set_pixel_plane5 ; Nein -> verzweige
	bset	d2,(pf1_plane_width*5,a0,d1.l) ; Bit in Bitplane5 setzen
\1_no_set_pixel_plane5
	btst	#6,d3			; Bit6 gesetzt?
	beq.s	\1_no_set_pixel_plane6 ; Nein -> verzweige
	bset	d2,(pf1_plane_width*6,a0,d1.l) ; Bit in Bitplane6 setzen
\1_no_set_pixel_plane6
	addq.w	#1,d0			; Spaltenzähler erhöhen
	dbf	d6,\1_init_display_pattern_loop2
	addq.w	#1,d3			; Farbnummer erhöhen
	dbf	d7,\1_init_display_pattern_loop1
	rts
	ENDM


GET_SINE_BARS_YZ_COORDINATES MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; \2 NUMBER:	Länge der Sinustabelle [256, 360, 512]
; \3 WORD:	Multiplikator Y-Offset in CL
; Result
	IFC "","\1"
		FAIL Makro GET_SINE_BARS_YZ_COORDINATES: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro GET_SINE_BARS_YZ_COORDINATES: Länge der Sinustabelle [256, 360, 512] fehlt
	ENDC
	IFC "","\3"
		FAIL Makro GET_SINE_BARS_YZ_COORDINATES: Multiplikator Y-Offset in CL fehlt
	ENDC
	CNOP 0,4
\1_get_yz_coords
	IFC "","\1"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Länge der Sinustabelle [256, a260, 512] fehlt
	ENDC
	IFC "","\3"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Multiplikator Y-Offset in CL fehlt
	ENDC
	IFEQ \2-256
		move.w	\1_y_angle(a3),d2 ; 1. Y-Winkel
		move.w	d2,d0				
		addq.b	#\1_y_angle_speed,d0
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		lea	sine_table(pc),a0
		lea	\1_yz_coords(pc),a1 ; Zeiger auf Y+Z-Koords-Tabelle
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7 ; Anzahl der Stangen
\1_get_yz_coords_loop
		moveq	#-(sine_table_length/4),d1 ; - 90 Grad
		move.l	(a0,d2.w*4),d0	; sin(w)
		add.w	d2,d1		; Y-Winkel - 90 Grad
		ext.w	d1		; Vorzeichenrichtig auf ein Wort erweitern
		move.w	d1,(a1)+	; Z-Vektor retten
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + Y-Mittelpunkt
		MULUF.W (\3)/4,d0,d1	; Y-Offset in CL
		move.w	d0,(a1)+	; Y retten
		add.b	d3,d2		; Y-Abstand zur nächsten Bar
		dbf	d7,\1_get_yz_coords_loop
		rts
	ENDC
	IFEQ \2-360
		move.w	\1_y_angle(a3),d2 ; 1. Y-Winkel
		move.w	d2,d0				
		MOVEF.W sine_table_length,d3 ; Überlauf
		addq.w	#\1_y_angle_speed,d0
		cmp.w	d3,d0		; Y-Winkel < 360 Grad ?
		blt.s	\1_no_restart_y_angle1 ; Ja -> verzweige
		sub.w	d3,d0		; Y-Winkel zurücksetzen
\1_no_restart_y_angle1
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W sine_table_length/2,d4 ; 180 Grad
		MOVEF.W \1_y_distance,d5
		lea	sine_table(pc),a0
		lea	\1_yz_coords(pc),a1 ; Zeiger auf Y+Z-Koords-Tabelle
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7 ; Anzahl der Stangen
\1_get_yz_coords_loop
		moveq	#-(sine_table_length/4),d1 ; - 90 Grad
		move.l	(a0,d2.w*4),d0 ; sin(w)
		add.w	d2,d1		; - 90 Grad + Y-Winkel
		bmi.s	\1_set_z_vector	; Wenn negativ -> verzweige
		sub.w	d4,d1		; Y-Winkel - 180 Grad
		neg.w	d1		; Vorzeichen umdrehen
\1_set_z_vector
		move.w	d1,(a1)+	; Z-Vektor retten
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + Y-Mittelpunkt
		MULUF.W (\3)/4,d0,d1	; Y-Offset in CL
		move.w	d0,(a1)+	; Y retten
		add.w	d5,d2		; Y-Abstand zur nächsten Bar
		cmp.w	d3,d2		; Y-Winkel < 360 Grad ?
		blt.s	\1_no_restart_y_angle2 ; Ja -> verzweige
		sub.w	d3,d2		; Y-Winkel zurücksetzen
\1_no_restart_y_angle2
		dbf	d7,\1_get_yz_coords_loop
		rts
	ENDC
	IFEQ \2-512
		move.w	\1_y_angle(a3),d2 ; 1. Y-Winkel
		move.w	d2,d0				
		MOVEF.W sine_table_length-1,d5 ; Überlauf
		addq.w	#\1_y_angle_speed,d0 ; nächster Y-Winkel
		and.w	d5,d0		; Überlauf entfernen
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		MOVEF.W sine_table_length/2,d4 ; 180 Grad
		lea	sine_table(pc),a0
		lea	\1_yz_coords(pc),a1 ; Zeiger auf Y+Z-Koords-Tabelle
		move.w	#\1_y_center,a2
		moveq	#\1_bars_number-1,d7 ; Anzahl der Stangen
\1_get_yz_coords_loop
		moveq	#-(sine_table_length/4),d1 ; - 90 Grad
		move.l	(a0,d2.w*4),d0 ; sin(w)
		add.w	d2,d1		; - 90 Grad + Y-Winkel
		bmi.s	\1_set_z_vector	; Wenn negativ -> verzweige
		sub.w	d4,d1		; Y-Winkel + 180 Grad
		neg.w	d1		; Vorzeichen umdrehen
\1_set_z_vector
		move.w	d1,(a1)+	; Z-Vektor retten
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + Y-Mittelpunkt
		MULUF.W (\3)/4,d0,d1	; Y-Offset in CL
		move.w	d0,(a1)+	; Y retten
		add.w	d3,d2		; Y-Abstand zur nächsten Bar
		and.w	d5,d2		; Überlauf entfernen
		dbf	d7,\1_get_yz_coords_loop
		rts
	ENDC
	ENDM


GET_TWISTED_BARS_YZ_COORDINATES MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; \2 NUMBER:	Länge der Sinustabelle [256, 360, 512]
; \3 WORD:	Multiplikator Y-Offset in CL
; Result
	IFC "","\1"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Länge der Sinustabelle [256, 360, 512] fehlt
	ENDC
	IFC "","\3"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Multiplikator Y-Offset in CL fehlt
	ENDC
	CNOP 0,4
\1_get_yz_coords
	IFC "","\1"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Länge der Sinustabelle [256, a260, 512] fehlt
	ENDC
	IFC "","\3"
		FAIL Makro GET_TWISTED_BARS_YZ_COORDINATES: Multiplikator Y-Offset in CL fehlt
	ENDC
	IFEQ \2-256
		move.w	\1_y_angle(a3),d2 ; 1. Y-Winkel
		move.w	d2,d0				
		addq.b	#\1_y_angle_speed,d0
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W \1_y_distance,d3
		lea	sine_table(pc),a0
		lea	\1_yz_coords(pc),a1 ; Zeiger auf Y+Z-Koords-Tabelle
		move.w	#\1_y_center,a2
		moveq	#\*LEFT(\3,3)_display_width-1,d7 ; Anzahl der Spalten
\1_get_yz_coords_loop1
		moveq	#\1_bars_number-1,d6 ; Anzahl der Stangen
\1_get_yz_coords_loop2
		moveq	#-(sine_table_length/4),d1 ; - 90 Grad
		move.l	(a0,d2.w*4),d0	; sin(w)
		add.w	d2,d1		; Y-Winkel - 90 Grad
		ext.w	d1		; Vorzeichenrichtig auf ein Wort erweitern
		move.w	d1,(a1)+	; Z-Vektor retten
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + Y-Mittelpunkt
		MULUF.W	(\3)/4,d0,d1	; Y-Offset in CL
		move.w	d0,(a1)+	; Y retten
		add.b	d3,d2		; Y-Abstand zur nächsten Bar
		dbf	d6,\1_get_yz_coords_loop2
		IFGE \1_y_angle_step
			addq.b	#\1_y_angle_step,d2 ; nächster Y-Winkel
		ELSE
			subq.b	#-\1_y_angle_step,d2 ; nächster Y-Winkel
		ENDC
		dbf	d7,\1_get_yz_coords_loop1
		rts
	ENDC
	IFEQ \2-360
		move.w	\1_y_angle(a3),d2 ; 1. Y-Winkel
		move.w	d2,d0				
		MOVEF.W sine_table_length,d3 ; Überlauf
		addq.w	#\1_y_angle_speed,d0
		cmp.w	d3,d0		; Y-Winkel < 360 Grad ?
		blt.s	\1_no_restart_y_angle1 ; Ja -> verzweige
		sub.w	d3,d0		; Y-Winkel zurücksetzen
\1_no_restart_y_angle1
		move.w	d0,\1_y_angle(a3) 
		MOVEF.W sine_table_length/2,d4 ; 180 Grad
		MOVEF.W \1_y_distance,d5
		lea	sine_table(pc),a0
		lea	\1_yz_coords(pc),a1 ; Zeiger auf Y+Z-Koords-Tabelle
		move.w	#\1_y_center,a2
		moveq	#\*LEFT(\3,3)_display_width-1,d7 ; Anzahl der Spalten
\1_get_yz_coords_loop1
		moveq	#\1_bars_number-1,d6 ; Anzahl der Stangen
\1_get_yz_coords_loop2
		moveq	#-(sine_table_length/4),d1 ; - 90 Grad
		move.l	(a0,d2.w*4),d0	; sin(w)
		add.w	d2,d1		; - 90 Grad + Y-Winkel
		bmi.s	\1_set_z_vector	; Wenn negativ -> verzweige
		sub.w	d4,d1		; Y-Winkel + 180 Grad
		neg.w	d1		; Vorzeichen umdrehen
\1_set_z_vector
		move.w	d1,(a1)+	; Z-Vektor retten
		MULUF.L \1_y_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
		swap	d0
		add.w	a2,d0		; y' + Y-Mittelpunkt
		MULUF.W	(\3)/4,d0,d1	; Y-Offset in CL
		move.w	d0,(a1)+	; Y retten
		add.w	d5,d2		; Y-Abstand zur nächsten Bar
		cmp.w	d3,d2		; Y-Winkel < 360 Grad ?
		blt.s	\1_no_restart_y_angle2 ; Ja -> verzweige
		sub.w	d3,d2		; Y-Winkel zurücksetzen
\1_no_restart_y_angle2
		dbf	d6,\1_get_yz_coords_loop2
		addq.w	#\1_y_angle_step,d2
		cmp.w	d3,d2		; Y-Winkel < 360 Grad ?
		blt.s	\1_no_restart_y_angle3 ; Ja -> verzweige
		sub.w	d3,d2		; Y-Winkel zurücksetzen
\1_no_restart_y_angle3
		dbf	d7,\1_get_yz_coords_loop1
		rts
	ENDC
	ENDM


RGB8_COLOR_FADER			MACRO
; \1 STRING: Labels-Prefix der Routine
	IFC "","\1"
		FAIL Makro RGB8_COLOR_FADER: Labels-Prefix fehlt
	ENDC
	CNOP 0,4
\1_rgb8_fader_loop
	move.l	(a0),d0			; RGB8-Istwert
	moveq	#0,d1
	move.w	d0,d1			; $00GgBb
	moveq	#0,d2
	clr.b	d1			; $00Gg00
	move.b	d0,d2			; $0000Bb
	clr.w	d0			; $Rr0000
	move.l	(a1)+,d3		; RGB8-Sollwert
	moveq	#0,d4
	move.w	d3,d4			; $00GgBb
	moveq	#0,d5
	move.b	d3,d5			; $0000Bb
	clr.w	d3			; $Rr0000
	clr.b	d4			; $00Gg00

; ** Rotwert **
\1_rgb8_check_red
	cmp.l	d3,d0
	bgt.s	\1_rgb8_decrease_red
	blt.s	\1_rgb8_increase_red
\1_rgb8_matched_red
	subq.w	#1,d6			; Zielfarbwert erreicht

; ** Grünwert **
\1_rgb8_check_green
	cmp.l	d4,d1
	bgt.s	\1_rgb8_decrease_green
	blt.s	\1_rgb8_increase_green
\1_rgb8_matched_green
	subq.w	#1,d6			; Zielfarbwert erreicht

; ** Blauwert **
\1_rgb8_check_blue
	cmp.w	d5,d2
	bgt.s	\1_rgb8_decrease_blue
	blt.s	\1_rgb8_increase_blue
\1_rgb8_matched_blue
	subq.w	#1,d6			; Zielfarbwert erreicht

\1_merge_rgb8
	move.l	d0,d3			; neuer Rotwert	$Rr0000
	move.w	d1,d3			; neuer Grünwert $RrGg00
	move.b	d2,d3			; neuer Blauwert $RrGgBb

; ** Farbwerte in Copperliste eintragen **
	move.l	d3,(a0)+		; neuen RGB-Wert in Cache schreiben
	dbf	d7,\1_rgb8_fader_loop
	rts
	CNOP 0,4
\1_rgb8_decrease_red
	sub.l	a2,d0			; Rotanteil verringern
	cmp.l	d3,d0			; Ist-Rotwert > Soll-Rotwert ?
	bgt.s	\1_rgb8_check_green	; Ja -> verzweige
	move.l	d3,d0			; Rotanteil Zielwert
	bra.s	\1_rgb8_matched_red
	CNOP 0,4
\1_rgb8_increase_red
	add.l	a2,d0			; Rotanteil erhöhen
	cmp.l	d3,d0
	blt.s	\1_rgb8_check_green
	move.l	d3,d0			; Rotanteil Zielwert
	bra.s	\1_rgb8_matched_red
	CNOP 0,4
\1_rgb8_decrease_green
	sub.l	a4,d1			; Grünanteil verringern
	cmp.l	d4,d1
	bgt.s	\1_rgb8_check_blue
	move.l	d4,d1			; Grünanteil Zielwert
	bra.s	\1_rgb8_matched_green
	CNOP 0,4
\1_rgb8_increase_green
	add.l	a4,d1			; Grünanteil erhöhen
	cmp.l	d4,d1
	blt.s	\1_rgb8_check_blue
	move.l	d4,d1			; Grünanteil Zielwert
	bra.s	\1_rgb8_matched_green
	CNOP 0,4
\1_rgb8_decrease_blue
	sub.w	a5,d2			; Blauanteil verringern
	cmp.w	d5,d2
	bgt.s	\1_merge_rgb8
	move.w	d5,d2			; Blauanteil Zielwert
	bra.s	\1_rgb8_matched_blue
	CNOP 0,4
\1_rgb8_increase_blue
	add.w	a5,d2			; Blauanteil erhöhen
	cmp.w	d5,d2
	blt.s	\1_merge_rgb8
	move.w	d5,d2			; Blauanteil Zielwert
	bra.s	\1_rgb8_matched_blue
	ENDM


ROTATE_X_AXIS			MACRO
	move.w	d1,d3			; Y -> d3
	muls.w	d4,d1			; y*cos(a)
	swap	d4			; sin(w)
	move.w	d2,d7			; Z -> d7
	muls.w	d4,d3			; y*sin(a)
	muls.w	d4,d7			; z*sin(a)
	swap	d4			; cos(a)
	sub.l	d7,d1			; y*cos(a)-z*sin(a)
	muls.w	d4,d2			; z*cos(a)
	MULUF.L 2,d1			; y'=(y*cos(a)-z*sin(a))/2^15
	add.l	d3,d2			; y*sin(a)+z*cos(a)
	swap	d1			; neue Y-Pos.
	MULUF.L 2,d2			; z'=(y*sin(a)+z*cos(a))/2^15
	swap	d2			; neue Z-Pos.
	ENDM


ROTATE_Y_AXIS			MACRO
	move.w	d0,d3			; X -> d3
	muls.w	d5,d0			; x*cos(b)
	swap	d5			; sin(b)
	move.w	d2,d7			; Z -> d7
	muls.w	d5,d3			; x*sin(b)
	muls.w	d5,d7			; z*sin(b)
	swap	d5			; cos(b)
	add.l	d7,d0			; x*cos(b)+z*sin(b)
	muls.w	d5,d2			; z*cos(b)
	MULUF.L 2,d0			; x'=(x*cos(b)+z*sin(b))/2^15
	sub.l	d3,d2			; z*cos(b)-x*sin(b)
	swap	d0			; neue X-Pos.
	MULUF.L 2,d2			; z'=(z*cos(b)-x*sin(b))/2^15
	swap	d2			; neue Z-Pos.
	ENDM


ROTATE_Z_AXIS			MACRO
	move.w	d0,d3			; X -> d3
	muls.w	d6,d0			; x*cos(c)
	swap	d6			; sin(c)
	move.w	d1,d7			; Y -> d7
	muls.w	d6,d3			; x*sin(c)
	muls.w	d6,d7			; y*sin(c)
	swap	d6			; cos(c)
	sub.l	d7,d0			; x*cos(c)-y*sin(c)
	muls.w	d6,d1			; y*cos(c)
	MULUF.L 2,d0			; x'=(x*cos(c)-y*sin(c))/2^15
	add.l	d3,d1			; x*sin(c)+y*cos(c)
	swap	d0			; X-Pos.
	MULUF.L 2,d1			; y'=(x)*sin(c)+y*cos(c))/2^15
	swap	d1			; Y-Pos.
	ENDM


COPY_RGB8_COLORS_TO_COPPERLIST	MACRO
; Input
; \1 STRING:	Labels-Prefix der Routine
; \2 STRING:	Color-Table-Prefix
; \3 STRUNG:	Copperlist-Prefix
; \4 STRING:	Offset in Copperliste High-Werte
; \5 STRING:	Offset in Copperliste Low-Werte
; \6 LONGWORD:	Offset-Base (optional)
; Result
	IFC "","\1"
		FAIL Makro COPY_RGB8_COLORS_TO_COPPERLIST: Labels-Prefix fehlt
	ENDC
	IFC "","\2"
		FAIL Makro COPY_RGB8_COLORS_TO_COPPERLIST: Color-Table-Prefix fehlt
	ENDC
	IFC "","\3"
		FAIL Makro COPY_RGB8_COLORS_TO_COPPERLIST: Copperlist-Prefix fehlt
	ENDC
	IFC "","\4"
		FAIL Makro COPY_RGB8_COLORS_TO_COPPERLIST: Offset in Copperliste High-Werte fehlt
	ENDC
	IFC "","\5"
		FAIL Makro COPY_RGB8_COLORS_TO_COPPERLIST: Offset in Copperliste Low-Werte fehlt
	ENDC
	CNOP 0,4
\1_rgb8_copy_color_table
	IFNE \3_size2
		move.l	a4,-(a7)
	ENDC
	tst.w	\1_rgb8_copy_colors_active(a3)
	bne.s	\1_rgb8_copy_color_table_skip2
	move.w	#GB_NIBBLES_MASK,d3
	IFGT \1_rgb8_colors_number-32
		MOVEF.W \1_rgb8_start_color<<3,d4 ; Color-Bank Farbregisterzähler
	ENDC
	lea	\2_rgb8_color_table+(\1_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; Puffer für Farbwerte
	move.l	\3_display(a3),a1
	IFC "","\6"
		ADDF.W	\4+WORD_SIZE,a1
	ELSE
		ADDF.W	\6+\4+WORD_SIZE,a1
	ENDC
	IFNE \3_size1
		move.l	\3_construction1(a3),a2
		IFC "","\6"
			ADDF.W	\4+WORD_SIZE,a2
		ELSE
			ADDF.W	\6+\4+WORD_SIZE,a2
		ENDC
	ENDC
	IFNE \3_size2
		move.l	\3_construction2(a3),a4
		IFC "","\6"
			ADDF.W	\4+WORD_SIZE,a4
		ELSE
			ADDF.W	\6+\4+WORD_SIZE,a4
		ENDC
	ENDC
	MOVEF.W	\1_rgb8_colors_number-1,d7
\1_rgb8_copy_color_table_loop
	move.l	(a0)+,d0		; RGB8-Farbwert
	move.l	d0,d2					
	RGB8_TO_RGB4_HIGH d0,d1,d3
	move.w	d0,(a1)			; COLORxx High-Bits
	IFNE \3_size1
		move.w	d0,(a2)		; COLORxx High-Bits
	ENDC
	IFNE \3_size2
		move.w	d0,(a4)		; COLORxx High-Bits
	ENDC
	RGB8_TO_RGB4_LOW d2,d1,d3
	move.w	d2,\5-\4(a1)		; Low-Bits COLORxx
	addq.w	#LONGWORD_SIZE,a1	; nächstes Farbregister
	IFNE \3_size1
		move.w	d2,\5-\4(a2)	; Low-Bits COLORxx
		addq.w	#LONGWORD_SIZE,a2 ; nächstes Farbregister
	ENDC
	IFNE \3_size2
		move.w	d2,\5-\4(a4)	; Low-Bits COLORxx
		addq.w	#LONGWORD_SIZE,a4 ; nächstes Farbregister
	ENDC
	IFGT \1_rgb8_colors_number-32
		addq.b	#1<<3,d4	; Farbregister-Zähler erhöhen
		bne.s	\1_rgb8_copy_color_table_skip1
		addq.w	#LONGWORD_SIZE,a1 ; CMOVE überspringen
		IFNE \3_size1
			addq.w	#LONGWORD_SIZE,a2 ; CMOVE überspringen
		ENDC
		IFNE \3_size2
			addq.w	#LONGWORD_SIZE,a4 ; CMOVE überspringen
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


INIT_CUSTOM_ERROR_ENTRY		MACRO
; Input
; \1 BYTE_SIGNED:	Fehlernummer
; \2 POINTER:		Zeiger auf Fehlertext
; \3 BYTE_SIGNED:	Länge des Fehrlertexts
; Result
	IFC "","\1"
		FAIL Makro INIT_CUSTOM_ERROR_ENTRY: Fehlernummer fehlt
	ENDC
	IFC "","\2"
		FAIL Makro INIT_CUSTOM_ERROR_ENTRY: Zeiger auf Fehlertext fehlt
	ENDC
	IFC "","\3"
		FAIL Makro INIT_CUSTOM_ERROR_ENTRY: Länge des Fehlertextes fehlt
	ENDC

	moveq	#\1-1,d0
	MULUF.W	8,d0,d1			; 68000er unterstützt kein variables Register-Index
	lea	\2(pc),a1
	move.l	a1,(a0,d0.w)		; Damit es auf dem 68000 keinen Guru gibt.
	moveq	#\3,d1
	move.l	d1,4(a0,d0.w)
	ENDM
