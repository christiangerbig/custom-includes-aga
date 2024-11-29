; Datum:	05.10.2024
; Version:      4.7

; Globale Labels

; SYS_TAKEN_OVER

; COLOR_GRADIENT_RGB8


; Input
; d0.l	... Größe des Speicherbereichs
; Result
; d0.l	... Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
	CNOP 0,4
do_alloc_memory
	move.l	#MEMF_CLEAR|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	... Größe des Speicherbereichs
; Result
; d0.l	... Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
	CNOP 0,4
do_alloc_chip_memory
	move.l	#MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	... Größe des Speicherbereichs
; Result
; d0.l	... Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
	CNOP 0,4
do_alloc_fast_memory
	move.l	#MEMF_CLEAR|MEMF_FAST|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	... Breite des Playfiels in Pixeln
; d1.l	... Höhe des Playfiels in Zeilen
; d2.l	... Anzahl der Bitplanes
; Result
; d0.l	... Rückgabewert: Zeiger auf Speicherbereich wenn erfolgreich
	CNOP 0,4
do_alloc_bitmap_memory
	moveq	#BMF_CLEAR|BMF_DISPLAYABLE|BMF_INTERLEAVED,d3 ; Flags
	sub.l	a0,a0			; Keine Friendbitmap
	CALLGRAFQ AllocBitMap


	IFD SYS_TAKEN_OVER
		IFNE intena_bits&(~INTF_SETCLR)
; Input
; Result
; d0.l	... Rückgabewert: Inhalt von VBR
			CNOP 0,4
read_VBR
			or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; Level-7-Interruptebene
			nop
			movec	VBR,d0
			nop
			rte
		ENDC
	ELSE
; Input
; Result
; d0 ... Rückgabewert Inhalt von VBR
		CNOP 0,4
read_VBR
		or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; Level-7-Interruptebene
		nop
		movec	VBR,d0
		nop
		rte


; Input
; d0.l	... neuer Inhalt von VBR
; Result
; d0	... Kein Rückgabewert
		CNOP 0,4
write_VBR
		or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; Level-7-Interruptebene
		nop
		movec	d0,VBR
		nop
		rte
	ENDC


; Input
; Result
; d0	... Kein Rückgabewert
	CNOP 0,4
wait_beam_position
	move.l	#$0003ff00,d1		; Maske vertikale Position
	move.l	#beam_position<<8,d2	; Y-Position
	lea	VPOSR-DMACONR(a6),a0
	lea	VHPOSR-DMACONR(a6),a1
wait_beam_position_loop
	move.w	(a0),d0			; VPOSR
	swap	d0			; Bits in richtige Position bringen
	move.w	(a1),d0			; VHPOSR
	and.l	d1,d0			; Nur vertikale Position
	cmp.l	d2,d0			; Auf bestimmte Rasterzeile warten
	blt.s	wait_beam_position_loop
	rts


; Input
; Result
; d0	... Kein Rückgabewert
	CNOP 0,4
wait_vbi
	lea	INTREQR-DMACONR(a6),a0
wait_vbi_loop
	moveq	#INTF_VERTB,d0
	and.w	(a0),d0			; VERTB-Interrupt ?
	beq.s	wait_vbi_loop
	move.w	d0,INTREQ-DMACONR(a6)	; VERTB-Interrupt löschen
	rts


; Input
; Result
; d0	... Kein Rückgabewert
	CNOP 0,4
wait_copint
	lea	INTREQR-DMACONR(a6),a0
wait_copint_loop
	moveq	#INTF_COPER,d0
	and.w	(a0),d0			; COPER-Interrupt ?
	beq.s	wait_copint_loop
	move.w	d0,INTREQ-DMACONR(a6)	; COPER-Interrupt löschen
	rts


; Input
; a0	... Copperliste
; a1	... Tabelle mit Farbwerten
; d3.w	... erstes Farbregister
; d7.w	... Anzahl der Farben
; Result
; d0	... Kein Rückgabewert
	CNOP 0,4
cop_init_high_colors
	move.w	#RB_NIBBLES_MASK,d2
cop_init_high_colors_loop
	move.l	(a1)+,d0		; RGB8-Farbwert
	RGB8_TO_RGB4_HIGH d0,d1,d2
	move.w	d3,(a0)+		; COLORxx
	addq.w	#2,d3			; nächstes Farbregister
	move.w	d0,(a0)+		; High-Bits
	dbf	d7,cop_init_high_colors_loop
	rts


; Input
; a0	... Copperliste
; a1	... Tabelle mit Farbwerten
; d3.w	... erstes Farbregister
; d7.w	... Anzahl der Farben
; Result
; d0	... Kein Rückgabewert
	CNOP 0,4
cop_init_low_colors
	move.w	#RB_NIBBLES_MASK,d2
cop_init_low_colors_loop
	move.l	(a1)+,d0		; RGB8-Farbwert
	RGB8_TO_RGB4_LOW d0,d1,d2
	move.w	d3,(a0)+		; COLORxx
	addq.w	#2,d3			; nächstes Farbregister
	move.w	d0,(a0)+		; Low-Bits
	dbf	d7,cop_init_low_colors_loop
	rts


; Input
; a0	... Farbregister-Adresse
; a1	... Tabelle mit Farbwerten
; d7.w	... Anzahl der Farben
; Result
; d0	... Kein Rückgabewert
	CNOP 0,4
cpu_init_high_colors
	move.w	#RB_NIBBLES_MASK,d2
cpu_init_high_colors_loop
	move.l	(a1)+,d0		; RGB8-Farbwert
	RGB8_TO_RGB4_HIGH d0,d1,d2
	move.w	d0,(a0)+		; COLORxx
	dbf	d7,cpu_init_high_colors_loop
	rts


; Input
; a0	... Farbregister-Adresse
; a1	... Tabelle mit Farbwerten
; d7.w	... Anzahl der Farben
; Result
; d0	... Kein Rückgabewert
	CNOP 0,4
cpu_init_low_colors
	move.w	#RB_NIBBLES_MASK,d2
cpu_init_low_colors_loop
	move.l	(a1)+,d0		; RGB8-Farbwert
	RGB8_TO_RGB4_LOW d0,d1,d2
	move.w	d0,(a0)+		; COLORxx
	dbf	d7,cpu_init_low_colors_loop
	rts


	IFD COLOR_GRADIENT_RGB8
; Input
; d0.l	... RGB8-Istwert
; d6.l	... RGB8-Sollwert
; d7.w	... Anzahl der Farbwerte
; a0	... Zeiger auf Farbtabelle
; a1.l	... Additions-/Subtraktionswert für Rot
; a2.l	... Additions-/Subtraktionswert für Grün
; a4.w	... Additions-/Subtraktionswert für Blau
; a5	... Offset
; Result
; d0	... Kein Rückgabewert
		CNOP 0,4
init_color_gradient_rgb8_loop
		move.l	d0,(a0)		; RGB8-Wert in Farbtabelle schreiben
		add.l	a5,a0		; Offset
		moveq	#0,d1
		move.w	d0,d1
		moveq	#0,d2
		clr.b	d1		; Ist-G8
		move.b	d0,d2		; Ist-B8
		clr.w	d0		; Ist-R8
		move.l	d6,d3		; Soll-RGB8
		moveq	#0,d4
		move.w	d3,d4
		moveq	#0,d5
		move.b	d3,d5		; Soll-B8
		clr.w	d3		; Soll-R8
		clr.b	d4		; Soll-G8
		cmp.l	d3,d0
		bgt.s	decrease_red_rgb8
		blt.s	increase_red_rgb8
init_color_gradient_rgb8_skip1
		cmp.l	d4,d1
		bgt.s	decrease_green_rgb8
		blt.s	increase_green_rgb8
init_color_gradient_rgb8_skip2
		cmp.w	d5,d2
		bgt.s	decrease_blue_rgb8
		blt.s	increase_blue_rgb8
init_color_gradient_rgb8_skip3
		move.w	d1,d0		; G8
		move.b	d2,d0		; B8
		dbf	d7,init_color_gradient_rgb8_loop
		rts
		CNOP 0,4
decrease_red_rgb8
		sub.l	a1,d0
		cmp.l	d3,d0
		bgt.s	init_color_gradient_rgb8_skip1
		move.l	d3,d0
		bra.s	init_color_gradient_rgb8_skip1
		CNOP 0,4
increase_red_rgb8
		add.l	a1,d0
		cmp.l	d3,d0
		blt.s	init_color_gradient_rgb8_skip1
		move.l	d3,d0
		bra.s	init_color_gradient_rgb8_skip1
		CNOP 0,4
decrease_green_rgb8
		sub.l	a2,d1
		cmp.l	d4,d1
		bgt.s	init_color_gradient_rgb8_skip2
		move.l	d4,d1
		bra.s	init_color_gradient_rgb8_skip2
		CNOP 0,4
increase_green_rgb8
		add.l	a2,d1							;Grünanteil erhöhen
		cmp.l	d4,d1							;Ist-Grünwert < Soll-Grünwert ?
		blt.s	init_color_gradient_rgb8_skip2
		move.l	d4,d1
		bra.s	init_color_gradient_rgb8_skip2
		CNOP 0,4
decrease_blue_rgb8
		sub.w	a4,d2
		cmp.w	d5,d2
		bgt.s	init_color_gradient_rgb8_skip3
		move.w	d5,d2
		bra.s	init_color_gradient_rgb8_skip3
		CNOP 0,4
increase_blue_rgb8
		add.w	a4,d2
		cmp.w	d5,d2
		blt.s	init_color_gradient_rgb8_skip3
		move.w	d5,d2
		bra.s	init_color_gradient_rgb8_skip3
	ENDC
