
SET_SPRITE_POSITION		MACRO
; Input
; \1 WORD:	X position
; \2 WORD:	Y position
; \3 WORD:	Height
; Result
; \2 WORD:	SPRxPOS
; \3 WORD:	SPRxCTL
	IFC "","\1"
		FAIL Macro SET_SPRITE_POSITION: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_SPRITE_POSITION: Y position missing
	ENDC
	IFC "","\3"
		FAIL Macro SET_SPRITE_POSITION: Height missing
	ENDC
	rol.w	#8,\2			;  SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- --- SV8
	lsl.w	#5,\1			; SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SH2 SH1 SH0 --- --- --- --- ---
	lsl.w	#8,\3			;  EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- --- ---
	addx.b	\2,\2			;  --- --- --- --- --- --- SV8 EV8
	add.b	\1,\1			;  SH1 SH0 --- --- --- --- --- ---
	addx.b	\2,\2			;  --- --- --- --- --- SV8 EV8 SH2
	lsr.b	#3,\1			;  --- --- --- SH1 SH0 --- --- ---
	or.b	\1,\2			;  --- --- --- SH1 SH0 SV8 EV8 SH2
	lsr.w	#8,\1			;  --- --- --- --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
	move.b	\2,\3			;  EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0  --- --- --- SH1 SH0 SV8 EV8 SH2
	move.b	\1,\2			;  SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
	ENDM


INIT_SPRITE_CONTROL_WORDS_1X		MACRO
; Input
; \1 WORD:	X position
; \2 WORD:	Y position
; \3 WORD:	Height
; Result
; \2 LONGWORD:	low word SPRxCTL, high word SPRxPOS
	IFC "","\1"
		FAIL Macro INIT_SPRITE_CONTROL_WORDS_1X: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_SPRITE_CONTROL_WORDS_1X: Y position missing
	ENDC
	IFC "","\3"
		FAIL Macro INIT_SPRITE_CONTROL_WORDS_1X: Height missing
	ENDC
	SET_SPRITE_POSITION \1,\2,\3
	swap	\2			; high word: SPRxPOS
	move.w	\3,\2			; low word: SPRxCTL
	ENDM


SET_SPRITE_POSITION_V9		MACRO
; Input
; \1 WORD:	X position
; \2 WORD:	Y position
; \3 WORD:	Height
; \4 BYTE:	Scratch register
; Result
; \2 WORD: SPRxPOS
; \3 WORD: SPRxCTL
	IFC "","\1"
		FAIL Macro SET_SPRITE_POSITION_V9: X position missing
	ENDC
	IFC "","\2"
		FAIL Macro SET_SPRITE_POSITION_V9: Y position missing
	ENDC
	IFC "","\3"
		FAIL Macro SET_SPRITE_POSITION_V9: Height missing
	ENDC
	IFC "","\4"
		FAIL Macro SET_SPRITE_POSITION_V9: Scratch register missing
	ENDC
	rol.w	#7,\2			; SV8 SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- SV9
	move.b	\2,\4			; SV0 --- --- --- --- --- --- SV9
	lsl.w	#7,\3			; EV8 EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- --- --- --- ---
	addx.b	\4,\4			; --- --- --- --- --- --- SV9 EV9
	ror.b	#2,\1			; --- --- --- --- --- SH10 SH9 SH8 SH1 SH0 SH7 SH6 SH5 SH4 SH3 SH2
	add.b	\1,\1			; --- --- --- --- --- SH10 SH9 SH8 SH0
	addx.b	\4,\4			; --- --- --- --- --- SV9 EV9 SH1
	add.b	\1,\1			; --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SH2 --- ---
	addx.b	\4,\4			; --- --- --- --- SV9 EV9 SH1 SH0
	or.b	\4,\3			; EV8 EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- SV9 EV9 SH1 SH0
	add.w	\2,\2			; SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 --- --- --- --- --- --- SV9 ---
	addx.w	\3,\3			; EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- --- SV9 EV9 SH1 SH0 SV8
	addx.b	\3,\3			; EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 --- --- SV9 EV9 SH1 SH0 SV8 EV8
	lsr.w	#3,\1			; --- --- --- --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
	addx.b	\3,\3			; EV7 EV6 EV5 EV4 EV3 EV2 EV1 EV0 ---- SV9 EV9 SH1 SH0 SV8 EV8 SH2
	move.b	\1,\2			; SV7 SV6 SV5 SV4 SV3 SV2 SV1 SV0 SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
	ENDM


INIT_SPRITE_POINTERS_TABLE	MACRO
	CNOP 0,4
spr_init_pointers_table
; Input
; Global reference
; spr0_construction
; spr_pointers_construction
; spr0_display
; spr_pointers_display
; spr_number
; Result
	IFNE spr_x_size1
		lea	spr0_construction(a3),a0
		lea	spr_pointers_construction(pc),a1
		moveq	#spr_number-1,d7
spr_init_pointers_table_loop1
		move.l	(a0)+,a2
		move.l	(a2),(a1)+	; sprite structure
		dbf	d7,spr_init_pointers_table_loop1
	ENDC
	IFNE spr_x_size2
		lea	spr0_display(a3),a0
		lea	spr_pointers_display(pc),a1
		moveq	#spr_number-1,d7
spr_init_pointers_table_loop2
		move.l	(a0)+,a2
		move.l	(a2),(a1)+	; sprite structure
		dbf	d7,spr_init_pointers_table_loop2
	ENDC
	rts
	ENDM


COPY_SPRITE_STRUCTURES		MACRO
	CNOP 0,4
spr_copy_structures
; Input
; Global reference
; spr_pointers_construction
; spr_pointers_display
; sprite0_size
; sprite1_size
; sprite2_size
; sprite3_size
; sprite4_size
; sprite5_size
; sprite6_size
; sprite7_size
; Result
	move.l	a4,-(a7)
	lea	spr_pointers_construction(pc),a2
	lea	spr_pointers_display(pc),a4
	move.w	#(sprite0_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite1_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite2_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite3_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite4_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite5_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite6_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.w	#(sprite7_size/LONGWORD_SIZE)-1,d7
	bsr.s	spr_copy_data
	move.l	(a7)+,a4
	rts
	CNOP 0,4
spr_copy_data
	move.l	(a2)+,a0		; source
	move.l	(a4)+,a1		; destination
spr_copy_data_loop
	move.l	(a0)+,(a1)+
	dbf	d7,spr_copy_data_loop
	rts
	ENDM


INIT_ATTACHED_SPRITES_CLUSTER	MACRO
; Input
; \1 STRING:	Labels prefix
; \2 POINTER:	Table sprite structures pointers
; \3 WORD:	x position (optional)
; \4 WORD:	y position (optional)
; \5 WORD:	Width
; \6 WORD:	Height
; \7 STRING:	["NOHEADER"] (optional)
; \8 STRING:	["BLANK"] (optional)
; \9 STRING:	["REPEAT"] (optional)
; Global refefrence
; _image_data
; Result
	IFC "","\1"
		FAIL Macro INIT_ATTACHED_SPRITES_CLUSTER: Labels prefix missing
	ENDC
	IFC "","\2"
		FAIL Macro INIT_ATTACHED_SPRITES_CLUSTER: Table sprite structures pointers missing
	ENDC
	IFC "","\5"
		FAIL Macro INIT_ATTACHED_SPRITES_CLUSTER: Width missing
	ENDC
	IFC "","\6"
		FAIL Macro INIT_ATTACHED_SPRITES_CLUSTER: Height missing
	ENDC
	CNOP 0,4
\1_init_attached_sprites_cluster
	IFNC "REPEAT","\9"
		movem.l a4-a5,-(a7)
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*0))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W \4,d1	; y
			moveq	#0,d3
		ENDC
		lea	\2(pc),a5	; table sprite structures pointers
		move.l	(a5)+,a0	; sprite0 structure
		bsr	\1_init_sprite_header
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*0))*SHIRES_PIXEL_FACTOR,d0 ; x
			move.w	#\4,d1	; y
			MOVEF.W	SPRCTLF_ATT,d3
		ENDC

		IFNC "BLANK","\8"
			lea	\1_image_data,a1 ; 1st column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC
		move.l	(a5)+,a0	; sprite1 structure
		bsr	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(\1_image_plane_width*2),a1 ; 1st column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC

		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*1))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1	; y
			moveq	#0,d3
		ENDC
		move.l	(a5)+,a0	; sprite2 structure
		bsr	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+QUADWORD_SIZE,a1 ; 2nd column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*1))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1	; y
			MOVEF.W	SPRCTLF_ATT,d3
		ENDC
		move.l	(a5)+,a0	; sprite3 structure
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+QUADWORD_SIZE+(\1_image_plane_width*2),a1 ; 2nd column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC

		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*2))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W \4,d1	; y
			moveq	#0,d3
		ENDC
		move.l	(a5)+,a0	; sprite4 structure
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*2),a1 ; 3rd column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*2))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1	; y
			MOVEF.W	SPRCTLF_ATT,d3
		ENDC
		move.l	(a5)+,a0	; sprite 5 structure
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*2)+(\1_image_plane_width*2),a1 ; 3rd column 64 pixel
			bsr.s	\1_init_sprite_bitmap
		ENDC
	
		move.l	(a5)+,a0	; sprite6 structure
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*3))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W \4,d1	; y
			moveq	#0,d3
		ENDC
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*3),a1 ; 4th column 64 pixel
			bsr.s	\1_init_sprite_bitmap
		ENDC
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*3))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W \4,d1	; y
			MOVEF.W SPRCTLF_ATT,d3
		ENDC
		move.l	(a5),a0		; sprite7 structure
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*3)+(\1_image_plane_width*2),a1 ; 4th column 64 pixel
			bsr.s	\1_init_sprite_bitmap
		ENDC
		movem.l (a7)+,a4-a5
		rts
	ELSE
		movem.l	a4-a5,-(a7)
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*0))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1	; y
			moveq	#0,d3
		ENDC
		lea	\2(pc),a5	; table sprite structures pointers
		move.l	(a5)+,a0	; sprite0 structure
		bsr	\1_init_sprite_header
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*0))*SHIRES_PIXEL_FACTOR,d0 ; x
			move.w	#\4,d1	; y
			MOVEF.W	SPRCTLF_ATT,d3
		ENDC
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*2),a1 ; 3rd column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC
		move.l	(a5)+,a0	; sprite1 structure
		bsr	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*2)+(\1_image_plane_width*2),a1 ; 3rd column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC

		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*1))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W \4,d1	; y
			moveq	#0,d3
		ENDC
		move.l	(a5)+,a0	; sprite2 structure
		bsr		\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*3),a1 ; 4th column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*1))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1	; y
			MOVEF.W	SPRCTLF_ATT,d3
		ENDC
		move.l	(a5)+,a0	; sprite3 structure
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(QUADWORD_SIZE*3)+(\1_image_plane_width*2),a1 ; 4th column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC

		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*2))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1	; y
			moveq	#0,d3
		ENDC
		move.l	(a5)+,a0	; sprite4 structure
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data,a1 ; 1st column 64 pixel
			bsr	\1_init_sprite_bitmap
		ENDC
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*2))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1	; y
			MOVEF.W	SPRCTLF_ATT,d3
		ENDC
		move.l	(a5)+,a0	; Sprite5-Struktur
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+(\1_image_plane_width*2),a1 ; 1st column 64 pixel
			bsr.s	\1_init_sprite_bitmap
		ENDC
	
		move.l	(a5)+,a0	; sprite6 structure
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*3))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W \4,d1	; y
			moveq	#0,d3
		ENDC
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+QUADWORD_SIZE,a1 ; 2nd column 64 pixel
			bsr.s	\1_init_sprite_bitmap
		ENDC
		IFNC "NOHEADER","\7"
			move.w	#(\3+(\5*3))*SHIRES_PIXEL_FACTOR,d0 ; x
			MOVEF.W	\4,d1		; y
			MOVEF.W	SPRCTLF_ATT,d3
		ENDC
		move.l	(a5),a0		; sprite7 structure
		bsr.s	\1_init_sprite_header
		IFNC "BLANK","\8"
			lea	\1_image_data+QUADWORD_SIZE+(\1_image_plane_width*2),a1 ; 2nd column 64 pixel
			bsr.s	\1_init_sprite_bitmap
		ENDC
		movem.l (a7)+,a4-a5
		rts
	ENDC

; Input
; d0.w	X position
; d1.w	Y position
; d3.b	Attached bit
; a0.l	 sprite structure
; Global reference
; spr_pixel_per_datafetch
; _image_plane_width
; _image_y_size
; Result
	CNOP 0,4
\1_init_sprite_header
	IFNC "NOHEADER","\7"
		MOVEF.W \6,d2		; height
		add.w	d1,d2		; VSTOP
		SET_SPRITE_POSITION d0,d1,d2
		move.w	d1,(a0)		; SPRxPOS
		or.b	d3,d2		; set attached bit
		move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRxCTL
	ENDC
	ADDF.W	(spr_pixel_per_datafetch/4),a0 ; skip sprite header
	rts

	IFNC "BLANK","\8"
		CNOP 0,4
\1_init_sprite_bitmap
		move.w	#\1_image_plane_width-QUADWORD_SIZE,a2
		move.w	#(\1_image_plane_width*3)-QUADWORD_SIZE,a4
		MOVEF.W	\1_image_y_size-1,d7
\1_init_sprite_bitmap_loop
		move.l	(a1)+,(a0)+	; bitplane1 64 Bits
		move.l	(a1)+,(a0)+
		add.l	a2,a1		; skip remaining lines
		move.l	(a1)+,(a0)+	; bitplane2 64 Bits
		move.l	(a1)+,(a0)+
		add.l	a4,a1		; skip remaining lines
		dbf	d7,\1_init_sprite_bitmap_loop
	ENDC
	rts
	ENDM


SWAP_SPRITES			MACRO
; Input
; \1 BYTE SIGNED:	Number of sprites
; \2 NUMBER:		[1..7] sprite structure pointer index (optional)
; Global reference
; spr_pointers_construction
; spr_pointers_display
; Result
	IFC "","\1"
		FAIL Macro SWAP_SPRITE_STRUCTURES: Number of sprites missing
	ENDC
	CNOP 0,4
swap_sprite_structures
	IFC "","\2"
		lea	spr_pointers_construction(pc),a0
		lea	spr_pointers_display(pc),a1
	ELSE
		lea	spr_pointers_construction+(\2*LONGWORD_SIZE)(pc),a0
		lea	spr_pointers_display+(\2*LONGWORD_SIZE)(pc),a1
	ENDC
	moveq	#\1-1,d7		; number of sprites
swap_sprite_structures_loop
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+
	dbf	d7,swap_sprite_structures_loop
	rts
	ENDM


SET_SPRITES			MACRO
; Input
; \1 BYTE SIGNED:	Number of sprites
; \2 NUMBER:		[1..7] sprite structure pointer index (optional)
; Global reference
; cl1_display
; spr_pointers_display
; Result
	IFC "","\1"
		FAIL Macro SWAP_SPRITE_STRUCTURES: Number of sprites missing
	ENDC
	CNOP 0,4
set_sprite_pointers
	move.l	cl1_display(a3),a0 
	IFC "","\2"
		lea	spr_pointers_display(pc),a1
		ADDF.W	cl1_SPR0PTH+WORD_SIZE,a0
	ELSE
		lea	spr_pointers_display+(\2*LONGWORD_SIZE)(pc),a1
		ADDF.W	cl1_SPR\2PTH+WORD_SIZE,a0
	ENDC
	moveq	#\1-1,d7		; number of sprites
set_sprite_pointers_loop
	move.w	(a1)+,(a0)		; SPRxPTH
	addq.w	#QUADWORD_SIZE,a0
	move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; SPRxPTL
	dbf	d7,set_sprite_pointers_loop
	rts
	ENDM
