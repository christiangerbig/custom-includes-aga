; Global labels
; 	SYS_TAKEN_OVER
; 	COLOR_GRADIENT_RGB8


; Input
; d0.l	Memory block size
; Result
; d0.l	Pointer memory block or 0
	CNOP 0,4
do_alloc_memory
	move.l	#MEMF_CLEAR|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	Memory block size
; Result
; d0.l	Pointer memory block or 0
	CNOP 0,4
do_alloc_chip_memory
	move.l	#MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	Memory block size
; Result
; d0.l	Pointer memory block or 0
	CNOP 0,4
do_alloc_fast_memory
	move.l	#MEMF_CLEAR|MEMF_FAST|MEMF_PUBLIC,d1
	CALLEXECQ AllocMem


; Input
; d0.l	Playfield width
; d1.l	Playfield height
; d2.l	Playfield depth
; Result
; d0.l	Pointer playfield or 0
	CNOP 0,4
do_alloc_bitmap_memory
	moveq	#BMF_CLEAR|BMF_DISPLAYABLE|BMF_INTERLEAVED,d3 ; flags
	sub.l	a0,a0			; no friend bitmap
	CALLGRAFQ AllocBitMap


	IFD SYS_TAKEN_OVER
		IFNE intena_bits&(~INTF_SETCLR)
; Input
; Result
; d0.l	Content VBR
			CNOP 0,4
read_VBR
			or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
			nop
			movec	VBR,d0
			nop
			rte
		ENDC
	ELSE
; Input
; Result
; d0.l	 Content VBR
		CNOP 0,4
read_VBR
		or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
		nop
		movec	VBR,d0
		nop
		rte


; Input
; d0.l	Content VBR
; Result
		CNOP 0,4
write_VBR
		or.w	#SRF_I0|SRF_I1|SRF_I2,SR ; highest interrupt level
		nop
		movec	d0,VBR
		nop
		rte
	ENDC


; Input
; Result
	CNOP 0,4
wait_beam_position
	move.l	#$0003ff00,d1		; mask vertical beam position V0..V9
	move.l	#beam_position<<8,d2	; adjust vertical position
	lea	VPOSR-DMACONR(a6),a0
	lea	VHPOSR-DMACONR(a6),a1
wait_beam_position_loop
	move.w	(a0),d0			; VPOSR
	swap	d0			; adjust bits
	move.w	(a1),d0			; VHPOSR
	and.l	d1,d0			; only vertical position
	cmp.l	d2,d0			; wait beam position
	blt.s	wait_beam_position_loop
	rts


; Input
; Result
	CNOP 0,4
wait_vbi
	lea	INTREQR-DMACONR(a6),a0
wait_vbi_loop
	moveq	#INTF_VERTB,d0
	and.w	(a0),d0
	beq.s	wait_vbi_loop
	move.w	d0,INTREQ-DMACONR(a6)	; clear interrupt
	rts


; Input
; Result
	CNOP 0,4
wait_copint
	lea	INTREQR-DMACONR(a6),a0
wait_copint_loop
	moveq	#INTF_COPER,d0
	and.w	(a0),d0
	beq.s	wait_copint_loop
	move.w	d0,INTREQ-DMACONR(a6)	; clear interrupt
	rts


; Input
; a0	Pointer copperlist
; a1	Pointer color table
; d3.w	Offset first color register
; d7.w	Number of colors
; Result
	CNOP 0,4
cop_init_high_colors
	move.w	#RB_NIBBLES_MASK,d2
cop_init_high_colors_loop
	move.l	(a1)+,d0		; RGB8 value
	RGB8_TO_RGB4_HIGH d0,d1,d2
	move.w	d3,(a0)+		; COLORxx
	addq.w	#WORD_SIZE,d3		; next color register
	move.w	d0,(a0)+		; high bits
	dbf	d7,cop_init_high_colors_loop
	rts


; Input
; a0	Pointer copperlist
; a1	Pointer color table
; d3.w	Offset first color register
; d7.w	Number of colors
; Result
	CNOP 0,4
cop_init_low_colors
	move.w	#RB_NIBBLES_MASK,d2
cop_init_low_colors_loop
	move.l	(a1)+,d0		; RGB8 value
	RGB8_TO_RGB4_LOW d0,d1,d2
	move.w	d3,(a0)+		; COLORxx
	addq.w	#WORD_SIZE,d3			; next color register
	move.w	d0,(a0)+		; low bits
	dbf	d7,cop_init_low_colors_loop
	rts


; Input
; a0	Color register address
; a1	Pointer color table
; d7.w	Number of colors
; Result
	CNOP 0,4
cpu_init_high_colors
	move.w	#RB_NIBBLES_MASK,d2
cpu_init_high_colors_loop
	move.l	(a1)+,d0		; RGB8 value
	RGB8_TO_RGB4_HIGH d0,d1,d2
	move.w	d0,(a0)+		; COLORxx
	dbf	d7,cpu_init_high_colors_loop
	rts


; Input
; a0	Color register address
; a1	Pointer color table
; d7.w	Number of colors
; Result
	CNOP 0,4
cpu_init_low_colors
	move.w	#RB_NIBBLES_MASK,d2
cpu_init_low_colors_loop
	move.l	(a1)+,d0		; RGB8 value
	RGB8_TO_RGB4_LOW d0,d1,d2
	move.w	d0,(a0)+		; COLORxx
	dbf	d7,cpu_init_low_colors_loop
	rts


	IFD COLOR_GRADIENT_RGB8
; Input
; d0.l	RGB8 current value
; d6.l	RGB8 tartget value
; d7.w	Number of colors
; a0	Pointer color table
; a1.l	Decrement/increment red
; a2.l	Decrement/increment green
; a4.w	Decrement/increment blue
; a5.l	Offset next RGB8 value
; Result
		CNOP 0,4
init_color_gradient_rgb8_loop
		move.l	d0,(a0)		; RGB8 value
		add.l	a5,a0		; next entry
		moveq	#0,d1
		move.w	d0,d1
		moveq	#0,d2
		clr.b	d1		; G8
		move.b	d0,d2		; B8
		clr.w	d0		; R8
		move.l	d6,d3
		moveq	#0,d4
		move.w	d3,d4
		moveq	#0,d5
		move.b	d3,d5		; B8 target
		clr.w	d3		; R8 target
		clr.b	d4		; G8 target
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
